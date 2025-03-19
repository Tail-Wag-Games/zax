import hoodoo,
       smartptrs

type
  Page = object
    ptrs: ptr UncheckedArray[pointer]
    buff*: ptr uint8
    next: ptr Page
    iter: int

  Pool* = object
    itemSize: int
    capacity: int
    pages*: ptr Page

  MemPool* = object
    pool*: UniquePtr[Pool]

proc createPage(pool: ptr Pool): ptr Page =
  let
    cap = pool.capacity
    itemSize = pool.itemSize

  var buff = cast[ptr uint8](
    alignedAlloc(
      (sizeof(Page) + (itemSize + sizeof(pointer)) * cap).uint,
      16'u
    )
  )

  result = cast[ptr Page](buff)
  buff += sizeof(Page)
  result.iter = cap
  result.ptrs = cast[ptr UncheckedArray[pointer]](buff)
  buff += sizeof(pointer) * cap
  result.buff = buff
  result.next = nil
  for i in 0 ..< cap:
    result.ptrs[cap - i - 1] = result.buff + i * itemSize

proc createPool*(itemSize, capacity: int): ptr Pool =
  let cap = alignMask(capacity, 15).int

  var buff = cast[ptr uint8](
    alignedAlloc(
      (sizeof(Pool) + sizeof(Page) + (itemSize + sizeof(pointer)) * cap).uint,
      16'u
    )
  )

  result = cast[ptr Pool](buff)
  buff += sizeof(Pool)
  result.itemSize = itemSize
  result.capacity = cap
  result.pages = cast[ptr Page](buff)
  buff += sizeof(Page)

  var page = cast[ptr Page](result.pages)
  page.iter = cap
  page.ptrs = cast[ptr UncheckedArray[pointer]](buff)
  buff += sizeof(pointer) * cap
  page.buff = buff
  page.next = nil
  for i in 0 ..< cap:
    page.ptrs[cap - i - 1] = page.buff + i * itemSize

proc newMemPool*(itemSize, capacity: int): MemPool =
  result.pool = newUniquePtr(createPool(itemSize, capacity)[])

proc destroyPool*(pool: ptr Pool) =
  var page = pool.pages.next
  while page != nil:
    let next = page.next
    alignedFree(page)
    page = next
  pool.capacity = 0
  pool.pages.iter = 0
  pool.pages.next = nil
  alignedFree(pool)

# proc `=destroy`*(mp: MemPool) =
#   destroyPool(mp.pool[].addr)

proc new*(pool: ptr Pool): pointer =
  var page = pool.pages
  while page.iter == 0 and page.next != nil:
    page = page.next

  if page.iter > 0:
    dec(page.iter)
    return page.ptrs[page.iter]

proc new*(mp: MemPool): pointer =
  result = addr(mp.pool[]).new()

proc grow(pool: ptr Pool): bool =
  let page = createPage(pool)
  if page != nil:
    var last = pool.pages
    while last.next != nil:
      last = last.next
    last.next = page
    result = true

proc isFull(pool: ptr Pool): bool =
  var page = pool.pages
  while page != nil:
    if page.iter > 0:
      return false
    page = page.next
  result = true

proc isFullN*(pool: ptr Pool, n: int): bool =
  var page = pool.pages
  while page != nil:
    if (page.iter - n) >= 0:
      return false
    page = page.next
  result = true

proc isFullN*(mp: MemPool, n: int): bool =
  result = addr(mp.pool[]).isFullN(n)

proc del*(pool: ptr Pool, p: pointer) =
  let uptr = cast[uint](p)
  var page = pool.pages

  while page != nil:
    if uptr >= cast[uint](page.buff) and
       uptr < cast[uint](page.buff + pool.capacity * pool.itemSize):
      page.ptrs[page.iter] = p
      inc(page.iter)
      return

    page = page.next

proc del*(mp: MemPool, p: pointer) =
  addr(mp.pool[]).del(p)

template newAndGrow*(pool: ptr Pool): untyped =
  if isFull(pool):
    discard pool.grow()

  new(pool)

template newAndGrow*(mp: MemPool): untyped =
  addr(mp.pool[]).newAndGrow()
