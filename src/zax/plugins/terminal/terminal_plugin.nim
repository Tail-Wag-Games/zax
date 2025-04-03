import std/[unicode, with],
       ../../api, ../../plugin,
       terminal

when defined(macosx):
  import terminal_msl

type
  Size[T] = object
    width, height: T

  Rectangle[T] = object
    left, top, width, height: T

  Color = object
    b, g, r, a: uint8

  Leaf = object
    color: array[4, Color]
    dx, dy: int16
    code: Rune
    flags: uint8
    reserved: uint8

  Cell = object
    leaves: seq[Leaf]

  Layer = object
    cells: seq[Cell]
    crop: Rectangle[int]

  Scene = object
    layers: seq[Layer]
    background: seq[Color]

  Stage = object
    size: Size[int]
    frontBuffer: Scene
    backBuffer: Scene

  State = object
    cellSize: Size[int]
    halfCellSize: Size[int]
    color: Color
    bgColor: Color
    composition: int
    layer: int
    fontOffset: Rune

  World = object
    stage: Stage
    state: State

  Terminal = ref object
    world: World

  Context = object
    term: owned Terminal

const
  cornerColored = 0x01'u8

var
  pluginApi {.zState.}: ptr PluginApi
  ctx {.zState.}: Context

proc init(): World {.cdecl.} =
  discard

proc put(x, y, code: int32) {.cdecl.} =
  discard

proc render(term: Terminal) =
  discard

proc refresh(term: Terminal) =
  term.world.stage.frontBuffer = term.world.stage.backBuffer
  render(term)

proc refresh() {.cdecl.} =
  block early:
    if isNil(ctx.term):
      break early

    refresh(ctx.term)

proc zPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.cdecl,
    exportc, dynlib.} =
  case operation:
  of poStep:
    discard
  of poInit:
    pluginApi = plugin.api

    pluginApi.injectApi("terminal", 0, addr(terminalApi))
  else:
    discard

proc zPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("terminal", 0, 31)
  info.desc[0..255] = toOpenArray("Terminal emulator plugin", 0, 255)


terminalApi = TerminalApi(
)
