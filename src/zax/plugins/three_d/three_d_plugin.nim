import ../../api, ../../plugin, three_d

var
  pluginApi {.zState.}: ptr PluginApi

proc zPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.cdecl,
    exportc, dynlib.} =
  case operation:
  of poStep:
    discard
  of poInit:
    pluginApi = plugin.api

    pluginApi.injectApi("3d", 0, addr(threeDApi))
  else:
    discard

proc zPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("3d", 0, 31)
  info.desc[0..255] = toOpenArray("3d functionality", 0, 255)


threeDApi = ThreeDApi(
)
