import std/[lists, tables, unicode],
       ../api, ../plugin, terminal

type
  BasicPoint[T] = object
    x, y: T
  BasicRectangle[T] = object
    left, top, width, height: T
  BasicSize[T] = object
    width, height: T
  Dimensions = object
    width, height: int32
  Cell = object
    leaves: seq[ref Leaf]
  Color = object
    b, g, r, a: uint8 # BGRA8 format
  Context = object
    codespace: Table[Rune, ref TileInfo]
    tilesets: OrderedTable[Rune, ref Tileset]
    terminal: ref Terminal
  Layer = object
    cells: seq[Cell]
    crop: Rectangle
  Leaf = object
    color: array[4, Color]
    dx, dy: int16
    code: Rune
    flags: LeafFlag
    reserved: uint8
  LeafFlag = distinct uint8
  Line = object
    symbols: seq[Symbol]
    size: Size
  Mode = distinct uint32
  Point = BasicPoint[int32]
  Rectangle = BasicRectangle[int32]
  Scene = object
    layers: seq[Layer]
    bg: seq[Color]
  Size = BasicSize[int32]
  Stage = object
    size: Size
    fBuff: Scene
    bBuff: Scene
  State = object
    cellSize: Size
    halfCellSize: Size
    color: Color
    bgColor: Color
    composition: Mode
    layer: int32
    fontOffset: Rune
  Symbol = object
    code: int
    spacing: Size
  Terminal = object
    world: World
  TextPrintingAlignment = distinct uint32
  TileInfo = object
    tileset: ref Tileset
    spacing: Size
    isAnimated: bool
  Tileset = object
    offset: Rune
    cache: Table[Rune, ref TileInfo]
    spacing: Size
  World = object
    stage: Stage
    state: State

const
  lfCornerColored = LeafFlag(0x01)

  mOff = Mode(0)
  mOn = Mode(1)

  tpaDefault = TextPrintingAlignment(0)

let
  fontOffsetMultiplier = Rune(0x01000000'i32)
  fontOffsetMask = Rune(0xFF000000'i32)
  charOffsetMask = Rune(0x00FFFFFF'i32)

  # surrogateHighStart = Rune(0xD800)
  # surrogateHighEnd = Rune(0xDBFF)
  # unicodeMaxBmp = Rune(0xFFFF)

  # trailingBytesForUTF8: array[256, uint8] = [
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  #   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  #   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  #   2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  #   3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5
  # ]

  # offsetsFromUTF8: array[6, uint32] = [
  #   0x00000000'u32,
  #   0x00003080'u32,
  #   0x000E2080'u32,
  #   0x03C82080'u32,
  #   0xFA082080'u32,
  #   0x82082080'u32
  # ]

  # replacementChar = Rune(0x1A) # ASCII 'replacement' character

var
  ctx {.zState.}: Context
  pluginApi {.zState.}: ptr PluginApi

proc `or`(l, r: LeafFlag): LeafFlag {.borrow.}

proc `==`(l, r: Mode): bool {.borrow.}

proc `and`(l, r: Rune): Rune =
  Rune(int32(l) and int32(r))

proc `+`(l, r: Rune): Rune =
  Rune(int32(l) + int32(r))

proc `<`(l, r: Rune): bool =
  int32(l) < int32(r)

proc `>`(l, r: Rune): bool =
  int32(l) > int32(r)

proc get(ts: ref Tileset; code: Rune): ref TileInfo =
  block early:
    if contains(ts.cache, code):
      result = new(TileInfo)
    result = ts.cache[code]

proc provides(ts: ref Tileset; code: Rune): bool =
  result = contains(ts.cache, code)

template printOrMeasure(x, y, a, c, m) =
  # block early:
  #   if isNil(ctx) or isNil(s):
  #     if outW != nil: outW[] = 0
  #     if outH != nil: outH[] = 0
  #     break early

  let size = printImpl(x, y, w, h, a, c, false, m)
  if outW != nil: outW[] = size.width
  if outH != nil: outH[] = size.width

proc getTileInfo(code: Rune): ref TileInfo =
  block early:
    if contains(ctx.codespace, code):
      result = ctx.codespace[code]
      break early

    let
      fontLow = Rune(code and fontOffsetMask)
      fontHigh = fontLow + charOffsetMask

    for r, ts in ctx.tilesets:
      if r < fontLow or r > fontHigh:
        continue

      if provides(ts, code):
        let tile = get(ts, code)
        ctx.codespace[code] = tile
        result = tile
        break early

proc putInternal2(x, y, dx, dy: int; code: Rune; fg, bg: Color;
    colors: openArray[Color]) =
  block early:
    if x < 0 or y < 0 or x >= ctx.terminal.world.stage.size.width or y >=
        ctx.terminal.world.stage.size.height:
      break early

    var ti: ref TileInfo
    if contains(ctx.codespace, code):
      ti = ctx.codespace[code]
    else:
      ti = getTileInfo(code)

    let idx = y * ctx.terminal.world.stage.size.width + x

    var cell = ctx.terminal.world.stage.bBuff.layers[
        ctx.terminal.world.state.layer].cells[idx]

    if code != Rune(0):
      if ctx.terminal.world.state.composition == mOff:
        setLen(cell.leaves, 0)

      add(cell.leaves, new(Leaf))
      let leaf = cell.leaves[^1]
      leaf.code = code
      leaf.dx = int16(dx)
      leaf.dy = int16(dy)

      if len(colors) > 0:
        for i in 0 ..< 4: leaf.color[i] = colors[i]
        leaf.flags = leaf.flags or lfCornerColored
      else:
        leaf.color[0] = fg

      if ctx.terminal.world.state.layer == 0:
        for by in y ..< min(y + ti.spacing.height,
            ctx.terminal.world.stage.size.height):
          for bx in x ..< min(x + ti.spacing.width,
              ctx.terminal.world.stage.size.width):
            ctx.terminal.world.stage.bBuff.bg[
                by*ctx.terminal.world.stage.size.width+bx] = bg
    else:
      setLen(cell.leaves, 0)
      if ctx.terminal.world.state.layer == 0:
        ctx.terminal.world.stage.bBuff.bg[idx] = Color()

proc putInternal(x, y, dx, dy: int; code: Rune; colors: openArray[Color]) =
  putInternal2(x, y, dx, dy, code, ctx.terminal.world.state.color,
      ctx.terminal.world.state.bgColor, colors)

when not (defined(js) or defined(nimdoc) or defined(nimscript)):
  from system/ansi_c import c_memchr

  const hasCStringBuiltin = true
else:
  const hasCStringBuiltin = false

func find*(s: seq[Rune]; sub: char; start: Natural = 0; last = -1): int =
  ## Searches for `sub` in `s` inside range `start..last` (both ends included).
  ## If `last` is unspecified or negative, it defaults to `s.high` (the last element).
  ##
  ## Searching is case-sensitive. If `sub` is not in `s`, -1 is returned.
  ## Otherwise the index returned is relative to `s[0]`, not `start`.
  ## Subtract `start` from the result for a `start`-origin index.
  ##
  ## See also:
  ## * `rfind func<#rfind,string,char,Natural,int>`_
  ## * `replace func<#replace,string,char,char>`_
  result = -1
  let last = if last < 0: s.high else: last

  template findImpl =
    for i in int(start)..last:
      if s[i] == Rune(sub):
        return i

  when nimvm:
    findImpl()
  else:
    when hasCStringBuiltin:
      let length = last-start+1
      if length > 0:
        let found = c_memchr(s[start].unsafeAddr, cint(sub), cast[csize_t](length))
        if not found.isNil:
          return cast[int](found) -% cast[int](($s).cstring)
    else:
      findImpl()

proc printImpl(x0, y0, w0, h0: int32; align: TextPrintingAlignment;
    str: seq[Rune]; raw, measureOnly: bool): Size =
  let originalState = ctx.terminal.world.state

  var
    fontOffset = ctx.terminal.world.state.fontOffset
    combine = false
    offset = Point(x: 0, y: 0)
    wrap = Size(width: w0, height: h0)
    x, y, w: int
    tags: seq[proc(code: Rune)]
    lines: DoublyLinkedList[Line]

  add(lines, newDoublyLinkedNode[Line](Line()))

  proc getTileSpacing(code: Rune): Size =
    block early:
      let ti = getTileInfo(code)
      if isNil(ti):
        result = Size(width: 1, height: 1)
        break early

      result = ti.spacing


  proc appendSymbol(r: Rune) =
    block early:
      let code = fontOffset + r

      if code == Rune(0):
        break early

      if combine:
        add(
          tags,
          proc(code: Rune) =
          block early:
            if w == -1:
              break early
            let saved = ctx.terminal.world.state.composition
            ctx.terminal.world.state.composition = mOn
            putInternal(w, y, offset.x, offset.y, code, [])
            ctx.terminal.world.state.composition = saved
        )
        add(lines.tail.value.symbols, Symbol(code: -(len(tags) - 1)))
        combine = false
      else:
        add(lines.tail.value.symbols, Symbol(code: int(code),
                                             spacing: getTileSpacing(Rune(code))))

  var i = 0
  while i < len(str):
    let r = str[i]

    if (r == Rune('[') and not raw):
      inc(i)
      if i >= len(str): # malformed
        continue
      if str[i] == Rune('['): # escaped left bracket
        appendSymbol(Rune('['))
        continue


      let closingBracketPos = find(str, ']', i)
      if closingBracketPos == -1: # malformed
        continue

      var paramsPos = find(str, '=', i)
      paramsPos = min(closingBracketPos, if paramsPos == -1: len(
          str) else: paramsPos)

      let
        name = $str[i..paramsPos-i]
        params = if paramsPos < closingBracketPos: str[
          paramsPos+1..closingBracketPos-(paramsPos+1)] else: @[]
        arbitraryCode = 0

      var tag: proc()
      if name == "color" or name == "c" and len(params) > 0:
        discard


    inc(i)

  result

proc printExt8(x, y, w, h: int32; align: TextPrintingAlignment; s: ptr int8;
    outW, outH: ptr int32) =
  let cstr = cast[cstring](s)
  printOrMeasure(0, 0, tpaDefault, toRunes(toOpenArray(cstr, 0, len(cstr))), false)

proc print(x, y: int32; s: cstring): Dimensions {.cdecl.} =
  printExt8(x, y, 0, 0, tpaDefault, cast[ptr int8](s), addr(result.width),
      addr(result.height))

proc open() {.cdecl.} =
  # TODO: Make all of this stuff configurable
  ctx.terminal = new(Terminal)
  echo "opening terminal"

proc fragPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.cdecl,
    exportc, dynlib.} =
  case operation:
  of poStep:
    discard
  of poInit:
    echo "initializing terminal plugin!"
    pluginApi = plugin.api

    pluginApi.injectApi("terminal", 0, addr(terminalApi))
  else:
    discard

proc fragPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("terminal", 0, 31)
  info.desc[0..255] = toOpenArray("Terminal emulator related functionality", 0, 255)

terminalApi = TerminalApi(
  open: open,
)

when isMainModule:
  open()
  echo print(0, 0, "Hello, World!")
