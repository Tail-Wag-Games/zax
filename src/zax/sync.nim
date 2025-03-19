import std/locks

{.compile: "../../thirdparty/c89atomic.c".}

when defined(windows):
  import winim

when defined(cpu64):
  const cacheLineSize = 64

type
  MemoryOrder* = distinct int32

  Atomic*[T] = object
    val: T

  SpinLock* = object
    lock {.align: cacheLineSize.}: Atomic[uint32]

  Semaphore* = object
    cond: Cond
    lock: Lock
    count: int

const
  moRelaxed* = MemoryOrder(0)
  moConsume* = MemoryOrder(1)
  moAcquire* = MemoryOrder(2)
  moRelease* = MemoryOrder(3)
  moAcqRel* = MemoryOrder(4)
  moSeqCst* = MemoryOrder(5)

proc `==`*[T](a: Atomic[T]; b: T): bool =
  result = a.val == b

proc cExchange32(dst: ptr uint32; src: uint32; order: MemoryOrder): uint32 {.importc: "zax_atomic_exchange32_explicit".}
proc exchange*(dst: var Atomic[uint32]; src: uint32; order: MemoryOrder): uint32 =
  result = cExchange32(dst.val.addr, src, order)

proc cLoad32(src: ptr uint32; order: MemoryOrder): uint32 {.importc: "zax_atomic_load32_explicit".}
proc load*(src: var Atomic[uint32]; order: MemoryOrder): uint32 =
  result = cLoad32(src.val.addr, order)

proc cStore32(dst: ptr uint32; src: uint32; order: MemoryOrder) {.importc: "zax_atomic_store32_explicit".}
proc store*(dst: var Atomic[uint32]; src: uint32; order: MemoryOrder) =
  cStore32(dst.val.addr, src, order)

proc cFetchAdd32(src: ptr uint32; val: uint32): uint32 {.importc: "zax_atomic_fetch_add32".}
proc fetchAdd*(src: var Atomic[uint32]; val: uint32): uint32 =
  result = cFetchAdd32(src.val.addr, val)

proc cFetchSub32(src: ptr uint32; val: uint32): uint32 {.importc: "zax_atomic_fetch_sub32".}
proc fetchSub*(src: var Atomic[uint32]; val: uint32): uint32 =
  result = cFetchSub32(src.val.addr, val)

proc enter*(sl: var SpinLock) =
    while true:
      if exchange(sl.lock, 1, moAcquire) == 0:
        break
      while load(sl.lock, moRelaxed) != 0:
        cpuRelax()

proc exit*(sl: var SpinLock) =
  store(sl.lock, 0, moRelease)

proc tryEnter*(sl: var SpinLock): bool =
  result = load(sl.lock, moRelaxed) == 0 and exchange(sl.lock, 1, moAcquire) == 0

template withLock*(sl: var SpinLock; body: untyped) =
  sl.enter()
  body
  sl.exit()

when isMainModule:
  var
    sl: SpinLock
    val = 100

  assert alignof(sl) == 64

  # TODO: Better test
  withLock(sl):
    val -= 99

proc init*(s: var Semaphore) =
  initLock(s.lock)
  initCond(s.cond)
  s.count = 0

proc destroy*(s: var Semaphore) =
  deinitCond(s.cond)
  deinitLock(s.lock)
  s.count = 0

proc wait*(s: var Semaphore) =
  acquire(s.lock)
  while s.count <= 0:
    wait(s.cond, s.lock)
  dec s.count
  release(s.lock)

proc signal*(s: var Semaphore) =
  withLock s.lock:
    inc s.count
    signal s.cond

proc signal*(s: var Semaphore; count: int) =
  for i in 0 ..< count:
    signal(s)

proc threadId*(): uint32 =
  when defined(windows):
    result = GetCurrentThreadId().uint32
