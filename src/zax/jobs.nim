import std/[osproc, os],
       api, fiber, pool, sync

include system/timers

type
  JobObj = object
    jobIndex: int32
    done: bool
    ownerTid: uint32
    tags: uint32
    stackMem: FiberStack
    fiber: Fiber
    selectorFiber: Fiber
    counter: Job
    waitCounter: Job
    ctx: ptr JobContext
    callback: JobCallback
    userData: pointer
    rangeStart: int32
    rangeEnd: int32
    priority: JobPriority
    next: ptr JobObj
    prev: ptr JobObj

  JobThreadData = object
    curJob: ptr JobObj
    selectorStack: FiberStack
    selectorFiber: Fiber
    threadIdx: int32
    tid: uint32
    tags: uint32
    mainThread: bool

  JobPending = object
    counter: Job
    rangeSize: int32
    rangeRemainder: int32
    callback: JobCallback
    userData: pointer
    priority: JobPriority
    tags: uint32

  JobContextDesc* = object
    numThreads*: int32
    fiberStackSize*: int32
    maxFibers*: int32

  JobSelectResult = object
    job: ptr JobObj
    waitingListAlive: bool

  JobContext* = object
    threads: seq[Thread[tuple[ctx: ptr JobContext; idx: int32]]]
    numThreads: int32
    stackSize: int32
    jobPool: ptr Pool
    counterPool: ptr Pool
    waitingList: array[ord(jpCount), ptr JobObj]
    waitingListLast: array[ord(jpCount), ptr JobObj]
    tags: seq[uint32]
    jobLock: SpinLock
    counterLock: SpinLock
    dummyCounter: Atomic[uint32]
    sem: Semaphore
    quit: bool
    pending: seq[JobPending]

const
  CounterPoolSize = 256
  DefaultMaxFibers = 64
  DefaultFiberStackSize = 1048576 # 1MB

var tData {.threadvar.}: ptr JobThreadData

proc jobThreadIndex*(ctx: ptr JobContext): int32 =
  result = tData.threadIdx

proc delJob(ctx: ptr JobContext; job: ptr JobObj) =
  withLock(ctx.jobLock):
    pool.del(ctx.jobPool, job)

proc fiberFn(transfer: FiberTransfer) {.cdecl.} =
  let
    job = cast[ptr JobObj](transfer.userData)
    ctx = job.ctx

  assert(tData.curJob == job)

  job.selectorFiber = transfer.last
  tData.selectorFiber = transfer.last
  tData.curJob = job

  job.callback(job.rangeStart, job.rangeEnd, tData.threadIdx, job.userData)
  job.done = true

  discard switch(transfer.last, transfer.userData)

proc jobAddList(pFirst, pLast: ptr ptr JobObj; node: ptr JobObj) {.inline.} =
  if not isNil(pLast[]):
    (pLast[])[].next = node
    node.prev = pLast[]
  pLast[] = node
  if isNil(pFirst[]):
    pFirst[] = node

proc jobRemoveList(pFirst, pLast: ptr ptr JobObj; node: ptr JobObj) {.inline.} =
  if not isNil(node.prev):
    node.prev.next = node.next
  if not isNil(node.next):
    node.next.prev = node.prev
  if pFirst[] == node:
    pFirst[] = node.next
  if pLast[] == node:
    pLast[] = node.prev
  node.next = nil
  node.prev = node.next

proc newJob(ctx: ptr JobContext; idx: int32; callback: JobCallback;
            userData: pointer; rangeStart, rangeEnd: int32;
            counter: Job; tags: uint32; priority: JobPriority): ptr JobObj =
  result = cast[ptr JobObj](new(ctx.jobPool))

  if result != nil:
    result.jobIndex = idx
    result.ownerTid = 0
    result.tags = tags
    result.done = false
    if isNil(result.stackMem.stack):
      discard fiberStackInit(addr result.stackMem, uint(ctx.stackSize))
    result.fiber = fiberCreate(result.stackMem, fiberFn)
    result.counter = counter
    result.waitCounter = cast[Job](addr ctx.dummyCounter)
    result.ctx = ctx
    result.callback = callback
    result.userData = userData
    result.rangeStart = rangeStart
    result.rangeEnd = rangeEnd
    result.priority = priority
    result.prev = nil
    result.next = result.prev

proc jobSelect(ctx: ptr JobContext; tid, tags: uint32): JobSelectResult =
  withLock(ctx.jobLock):
    var jp = ord(jpHigh)
    while jp < ord(jpCount):
      var node = ctx.waitingList[jp]
      while node != nil:
        result.waitingListAlive = true
        if load(cast[ptr Atomic[uint32]](node.waitCounter)[], moAcquire) == 0:
          if (node.ownerTid == 0'u32 or node.ownerTid == tid) and
            (node.tags == 0'u32 or (node.tags and tags) != 0):
            result.job = node
            jobRemoveList(addr ctx.waitingList[jp], addr ctx.waitingListLast[jp], node)
            jp = ord(jpCount)
            break
        node = node.next
      inc(jp)

proc jobSelectorMainThread(transfer: FiberTransfer) {.cdecl.} =
  var ctx = cast[ptr JobContext](transfer.userData)

  let r = jobSelect(ctx, tData.tid, if ctx.numThreads > 0: tData.tags else: 0xffffffff'u32)

  if r.job != nil:
    if r.job.ownerTid > 0:
      assert(isNil(tData.curJob))
      r.job.ownerTid = 0

    tData.selectorFiber = r.job.selectorFiber
    tData.curJob = r.job
    r.job.fiber = switch(r.job.fiber, r.job).last

    if r.job.done:
      tData.curJob = nil
      discard fetchSub(cast[ptr Atomic[uint32]](r.job.counter)[], 1)
      delJob(ctx, r.job)

  tData.selectorFiber = nil
  discard switch(transfer.last, transfer.userData)

proc jobSelectorFn(transfer: FiberTransfer) {.cdecl.}  =
  var ctx = cast[ptr JobContext](transfer.userData)

  while not ctx.quit:
    wait(ctx.sem)

    var r = jobSelect(ctx, tData.tid, tData.tags)

    if r.job != nil:
      if r.job.ownerTid > 0:
        assert(isNil(tData.curJob))
        r.job.ownerTid = 0

      tData.selectorFiber = r.job.selectorFiber
      tData.curJob = r.job
      r.job.fiber = switch(r.job.fiber, r.job).last

      if r.job.done:
        tData.curJob = nil
        discard fetchSub(cast[ptr Atomic[uint32]](r.job.counter)[], 1)
        delJob(ctx, r.job)
    elif r.waitingListAlive:
      signal(ctx.sem)
      cpuRelax()

  discard switch(transfer.last, transfer.userData)

proc jobCreateTData(tid: uint32; idx: int32; mainThread: bool  = false): ptr JobThreadData =
  result = createShared(JobThreadData)
  result.threadIdx = idx
  result.tid = tid
  result.tags = 0xffffffff'u32
  result.mainThread = mainThread

  discard fiberStackInit(addr result.selectorStack, minStackSize)

proc jobDestroyTData(tData: ptr JobThreadData) =
  fiberStackDestroy(addr tData.selectorStack)
  freeShared(tData)

proc jobThreadFn(userData: tuple[ctx: ptr JobContext; idx: int32]) {.thread, gcsafe.} =
  let threadId = threadId()

  tData = jobCreateTData(threadId.uint32, userData.idx + 1'i32)

  let fiber = fiberCreate(tData.selectorStack, jobSelectorFn)
  discard switch(fiber, userData.ctx)

proc dispatch*(ctx: ptr JobContext; count: int32;
                  callback: JobCallback; userData: pointer; priority: JobPriority;
                  tags: uint32): Job =
  let
    numWorkers = ctx.numThreads + 1'i32
    rangeSize = int32(count div numWorkers)
  var rangeRemainder = int32(count mod numWorkers)
  let numJobs = int32(if rangeSize > 0: numWorkers else: (
      if rangeRemainder > 0: rangeRemainder else: 0
    )
  )
  assert(numJobs > 0)

  var counter: Job
  withLock(ctx.counterLock):
    counter = cast[Job](newAndGrow(ctx.counterPool))

  if isNil(counter):
    return

  store(cast[ptr Atomic[uint32]](counter)[], numJobs.uint32, moRelease)

  if tData.curJob != nil:
    tData.curJob.waitCounter = counter

  withLock(ctx.jobLock):
    if not isFullN(ctx.jobPool, numJobs):
      var
        rangeStart = 0'i32
        rangeEnd = int32(rangeSize + (if rangeRemainder > 0: 1 else: 0))
      dec(rangeRemainder)

      for i in 0 ..< numJobs:
        jobAddList(
          addr ctx.waitingList[ord(priority)],
          addr ctx.waitingListLast[ord(priority)],
          newJob(
            ctx, i, callback, userData, rangeStart,
            rangeEnd, cast[Job](counter), tags, priority
          )
        )
        rangeStart = rangeEnd
        rangeEnd += int32(rangeSize + (if rangeRemainder > 0: 1 else: 0))
        dec(rangeRemainder)

      assert(rangeRemainder <= 0)
      signal(ctx.sem, numJobs)
    else:
      let pending = JobPending(
        counter: cast[Job](counter),
        rangeSize: rangeSize,
        rangeRemainder: rangeRemainder,
        callback: callback,
        userData: userData,
        priority: priority,
        tags: tags,
      )
      add(ctx.pending, pending)

  result = cast[Job](counter)

proc jobProcessPending(ctx: ptr JobContext) =
  for i in 0 ..< len(ctx.pending):
    let pending = addr(ctx.pending[i])

    if not isFullN(ctx.jobPool, load(cast[ptr Atomic[uint32]](pending.counter)[], moAcquire).int):
      var
        rangeStart = 0'i32
        rangeEnd = pending.rangeSize + (if pending.rangeRemainder > 0: 1 else: 0)
      dec(pending.rangeRemainder)

      del(ctx.pending, i)

      let count = load(cast[ptr Atomic[uint32]](pending.counter)[], moAcquire).int32
      for k in 0 ..< count:
        jobAddList(
          addr(ctx.waitingList[ord(pending.priority)]), addr(ctx.waitingListLast[ord(pending.priority)]),
          newJob(ctx, k, pending.callback, pending.userData, rangeStart, rangeEnd,
                 pending.counter, pending.tags, pending.priority)
        )
        rangeStart = rangeEnd
        rangeEnd += pending.rangeSize + (if pending.rangeRemainder > 0: 1 else: 0)
        dec(pending.rangeRemainder)

      signal(ctx.sem, count)
      break

proc jobProcessPendingSingle(ctx: ptr JobContext; idx: int) =
  withLock(ctx.jobLock):
    let pending = addr(ctx.pending[idx])
    let count = load(cast[ptr Atomic[uint32]](pending.counter)[], moAcquire).int32
    if not isFullN(ctx.jobPool,count):
      del(ctx.pending, idx)

      var
        rangeStart = 0'i32
        rangeEnd = pending.rangeSize + (if pending.rangeRemainder > 0: 1 else : 0)
      dec(pending.rangeRemainder)

      for i in 0 ..< count:
        jobAddList(
          addr(ctx.waitingList[ord(pending.priority)]), addr(ctx.waitingListLast[ord(pending.priority)]),
          newJob(ctx, i, pending.callback, pending.userData, rangeStart, rangeEnd,
                 pending.counter, pending.tags, pending.priority)
        )
        rangeStart = rangeEnd
        rangeEnd += (pending.rangeSize + (if pending.rangeRemainder > 0: 1 else: 0))
        dec(pending.rangeRemainder)

      signal(ctx.sem, count)

proc waitAndDel(ctx: ptr JobContext; job: Job) =
  var prevTm = getTicks()

  while load(cast[ptr Atomic[uint32]](job)[], moAcquire) > 0:
    for i in 0 ..< len(ctx.pending):
      if ctx.pending[i].counter == job:
        jobProcessPendingSingle(ctx, i)
        break

    if tData.curJob != nil:
      var curJob = tData.curJob
      tData.curJob = nil
      curJob.ownerTid = tData.tid

      withLock(ctx.jobLock):
        let listIdx = ord(curJob.priority)
        jobAddList(addr(ctx.waitingList[listIdx]), addr(ctx.waitingListLast[listIdx]),
                   curJob)

      if not tData.mainThread:
        signal(ctx.sem, 1)

    discard switch(tData.selectorFiber, ctx)

    if tData.selectorFiber == nil:
      tData.selectorFiber = fiberCreate(tData.selectorStack, jobSelectorMainThread)

    let
      nowTm = getTicks()
      diff = nowTm - prevTm
    prevTm = nowTm
    if diff < 300:
      cpuRelax()

  withLock(ctx.counterLock):
    pool.del(ctx.counterPool, cast[pointer](job))

  withLock(ctx.jobLock):
    jobProcessPending(ctx)

proc testAndDel*(ctx: ptr JobContext, job: Job): bool =
  if load(cast[ptr Atomic[uint32]](job)[], moAcquire) == 0:
    withLock(ctx.counterLock):
      pool.del(ctx.counterPool, cast[pointer](job))

    withLock(ctx.jobLock):
      jobProcessPending(ctx)

    return true
  return false

proc createContext*(desc: JobContextDesc): ptr JobContext =
  result = createShared(JobContext)
  result.numThreads = if desc.numThreads > 0: desc.numThreads else: int32(countProcessors() - 1)
  result.stackSize = DefaultFiberStackSize
  let maxFibers = if desc.maxFibers > 0: desc.maxFibers else: DefaultMaxFibers

  init(result.sem)

  tData = jobCreateTData(threadId().uint32, 0, true)
  tData.selectorFiber = fiberCreate(tData.selectorStack, jobSelectorMainThread)

  result.jobPool = pool.createPool(int32(sizeof(JobObj)), maxFibers)
  result.counterPool = pool.createPool(int32(sizeof(int)), CounterPoolSize)
  zeroMem(result.jobPool.pages.buff, sizeof(JobObj) * maxFibers)

  if result.numThreads > 0:
    result.threads = newSeq[Thread[tuple[ctx: ptr JobContext, idx: int32]]](result.numThreads)

    for i in 0 ..< result.numThreads:
      createThread(result.threads[i], jobThreadFn, (result, i))

proc destroyContext*(ctx: ptr JobContext) =
  ctx.quit = true

  signal(ctx.sem, ctx.numThreads + 1'i32)

  joinThreads(toOpenArray(ctx.threads, 0, ctx.numThreads - 1))

  jobDestroyTData(tData)

  destroyPool(ctx.jobPool)
  destroyPool(ctx.counterPool)

  `=destroy`(ctx.sem) # needs to be called explicitly since ctx is manually allocated

  freeShared(ctx)

when isMainModule:
  import std/strformat

  type
    ExampleJob = object
      foo: int

  var gCtx: ptr JobContext

  proc jobWaitCb(rangeStart, rangeEnd, threadIdx: int32; userData: pointer) {.cdecl.} =
    echo "wait job..."
    sleep(100)

  proc jobFibCb(rangeStart, rangeEnd, threadIdx: int32; userData: pointer) {.cdecl.} =
    var results = cast[ptr UncheckedArray[int32]](userData)
    for r in rangeStart ..< rangeEnd:
      var
        a = 0'u32
        b = 1'u32
        n = 100000

      for i in 0 ..< n:
        let f = a + b
        a = b
        b = f

      results[r] = b.int32

    var j = dispatch(gCtx, 2, jobWaitCb, nil, jpHigh, 0)
    waitAndDel(gCtx, j)

    j = dispatch(gCtx, 2, jobWaitCb, nil, jpHigh, 0)
    waitAndDel(gCtx, j)

  var
    numWorkerThreads = int32(countProcessors() - 1)
    jobContextDesc = JobContextDesc(
      numThreads: numWorkerThreads,
      maxFibers: 64,
    )
    jobCtx = createContext(jobContextDesc)
    results: array[16, uint32]

  echo &"num worker threads: {numWorkerThreads}"
  gCtx = jobCtx

  echo "dispatching jobs..."
  let jHandles = dispatch(jobCtx, 16, jobFibCb, results[0].addr(), jpHigh, 0)

  echo "waiting..."
  waitAndDel(jobCtx, jHandles)

  echo "results: "
  for i in 0 ..< 16:
    echo &"\t{results[i]}\n"

  destroyContext(jobCtx)
