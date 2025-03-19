import ../api, ../plugin,
       ecs

var
  pluginApi {.zState.}: ptr PluginApi

proc init() =
  discard

proc zPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.cdecl,
    exportc, dynlib.} =
  case operation:
  of poStep:
    discard
  of poInit:
    pluginApi = plugin.api

    pluginApi.injectApi("ecs", 0, addr(ecsApi))

    init()
  else:
    discard

proc zPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("ecs", 0, 31)
  info.desc[0..255] = toOpenArray("ECS functionality", 0, 255)

ecsApi = ecs.EcsApi(
)
