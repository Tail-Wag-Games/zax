import math, hoodoo

when defined(macosx):
  {.link: "../../thirdparty/context/src/asm/make_arm64_aapcs_macho_gas.S.o".}
  {.link: "../thirdparty/context/src/asm/jump_arm64_aapcs_macho_gas.S.o".}
  {.link: "../thirdparty/context/src/asm/ontop_arm64_aapcs_macho_gas.S.o".}

  import posix
when defined(windows):
  {.link: "C:\\Users\\Zach\\dev\\frag\\src\\asm\\make_x86_64_ms_pe_masm.obj".}
  {.link: "C:\\Users\\Zach\\dev\\frag\\src\\asm\\jump_x86_64_ms_pe_masm.obj".}
  {.link: "C:\\Users\\Zach\\dev\\frag\\src\\asm\\ontop_x86_64_ms_pe_masm.obj".}

  import winim/lean

type
  Fiber* = pointer

  FiberTransfer* = object
    last*: Fiber
    userData*: pointer

  FiberStack* = object
    stack*: pointer
    stackSize: uint

  FiberCb* = proc(transfer: FiberTransfer) {.cdecl.}

const
  defaultStackSize = 131072'u # 120kb
  minStackSize* = 32768 # 32kb

proc jumpFContext(a: Fiber, b: pointer = nil): FiberTransfer {.importc: "jump_fcontext".}
proc makeFContext(a: pointer; b: csize_t; cb: FiberCb): Fiber {.importc: "make_fcontext".}

proc maxSize*(): int =
  when defined(windows):
    result = 1073741824 # 1gb
  else:
    var limit: RLimit
    discard getrlimit(3, limit)
    result = limit.rlim_max

proc pageSize*(): uint =
  when defined(windows):
    var si: SYSTEM_INFO
    GetSystemInfo(addr(si))
    result = uint(si.dwPageSize)
  else:
    result = uint(sysconf(SC_PAGESIZE))

proc alignPageSize*(size: uint): uint =
  let
    pageSz = pageSize()
    pageCnt = (size + pageSz - 1) div pageSz
  result = pageCnt * pageSz

proc fiberStackInit*(fStack: ptr FiberStack; size: uint): bool =
  var
    p: pointer
    stackSize = if size == 0: defaultStackSize else: size

  stackSize = uint32(alignPageSize(stackSize))

  when defined(windows):
    p = VirtualAlloc(nil, SIZE_T(stackSize), MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE)
    if isNil(p):
      return
    var oldOpts: DWORD
    VirtualProtect(p, SIZE_T(pageSize()), PAGE_READWRITE or PAGE_GUARD, addr(oldOpts))
  else:
    p = mmap(nil, int32(stackSize), PROT_READ or PROT_WRITE, MAP_PRIVATE or MAP_ANONYMOUS, -1, 0)
    if p == MAP_FAILED:
      return
    discard mprotect(p, int(pageSize()), PROT_NONE)

  fStack.stack = cast[ptr uint8](p) + int(stackSize)
  fStack.stackSize = stackSize

proc fiberStackDestroy*(fStack: ptr FiberStack) =
  var vp = cast[ptr uint8](fStack.stack) - int(fStack.stackSize)

  when defined(windows):
    VirtualFree(vp, 0, MEM_RELEASE)
  else:
    discard munmap(vp, int32(fStack.stackSize))

proc fiberCreate*(fStack: FiberStack; cb: FiberCb): Fiber =
  result = makeFContext(fstack.stack, c_sizet(fstack.stackSize), cb)

proc switch*(to: Fiber; userData: pointer): FiberTransfer =
  let frameState = getFrameState()
  result = jumpFContext(to, userData)
  setFrameState(frameState)
