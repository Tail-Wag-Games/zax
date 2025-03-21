import hoodoo, sync

type
  Whence* = distinct int32

  MemBlock* = object
    data*: pointer
    size*: int64
    startOffset*: int64
    align*: int32
    refCount*: Atomic[uint32]

  MemReader* = object
    data*: ptr UncheckedArray[uint8]
    pos*: int64
    top*: int64

const
  wBegin* = Whence(0)
  wCurrent* = Whence(1)
  wEnd* = Whence(2)

when defined(macosx):
  const naturalAlignment* = 16
else:
  const naturalAlignment* = 8

template truncateData() =
  assert(false, "truncated data")

template readVar*(r, v: untyped) =
  discard readMem(r, addr(v), sizeof(v))

proc createMemBlock(size: int64; data: pointer;
    desiredAlignment: int32): ptr MemBlock =
  let align = uint32(max(desiredAlignment, naturalAlignment))
  result = cast[ptr MemBlock](allocShared0(size + sizeof(MemBlock) + int64(align)))
  if result != nil:
    result.data = alignPtr(result + 1, 0, align)
    result.size = size
    result.startOffset = 0
    result.align = align.int32
    store(result.refCount, 1'u32, moRelease)
    if data != nil:
      copyMem(result.data, data, size)
  else:
    echo "out of memory!"

proc destroyMemBlock*(mem: ptr MemBlock) =
  assert(not isNil(mem))
  assert(load(mem.refCount, moAcquire) >= 1)

  if fetchSub(mem.refCount, 1) == 1:
    deallocShared(mem)

proc loadBinaryFile*(filepath: string): ptr MemBlock =
  block outer:
    var f: File
    if open(f, filepath):
      let size = getFileSize(f)
      if size > 0:
        result = createMemBlock(size, nil, 0)
        if result != nil:
          discard readBuffer(f, result.data, size)
          close(f)
          break outer
      close(f)
      break outer

    result = nil

proc loadTextFile*(filepath: string): ptr MemBlock =
  block outer:
    var f: File
    if open(f, filepath):
      let size = getFileSize(f)
      if size > 0:
        result = createMemBlock(size + 1, nil, 0)
        if result != nil:
          discard readBuffer(f, result.data, size)
        close(f)
        cast[ptr UncheckedArray[char]](result.data)[size] = '\0'
        break outer
      close(f)
      break outer

  result = nil

proc readMem*(reader: ptr MemReader; data: pointer; size: int64): int64 =
  let remaining = reader.top - reader.pos

  result = size
  if result > remaining:
    result = remaining
    truncateData()
  copyMem(data, addr(reader.data[reader.pos]), result)
  reader.pos += result

proc seekr*(reader: ptr MemReader; offset: int64; w: Whence): int64 =
  case w:
  of wBegin:
    reader.pos = clamp(offset, 0'i64, reader.top)
  of wCurrent:
    reader.pos = clamp(reader.pos + offset, 0'i64, reader.top)
  of wEnd:
    reader.pos = clamp((reader.top - offset), 0'i64, reader.top)
  else:
    discard

  result = reader.pos

proc initMemReader*(reader: ptr MemReader; data: pointer; size: int64) =
  assert(data != nil)
  assert(size > 0)

  reader.data = cast[ptr UncheckedArray[uint8]](data)
  reader.top = size
  reader.pos = 0
