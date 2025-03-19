import std/[dynlib, os, pathnorm, strformat],
       api, cfg, zapis

type

  MainCallback* = proc(ctx: ptr Plugin; e: PluginEvent)
  # EventHandlerCallback* = proc(e: ptr sapp.Event)

  PluginInfo* = object
    version*: uint32
    deps*: ptr UncheckedArray[cstring]
    numDeps*: int32
    name*: array[32, char]
    desc*: array[256, char]

  PluginInfoCb* = proc(outInfo: ptr PluginInfo) {.cdecl.}

  InjectedApi = object
    name: cstring
    version: uint32
    api: pointer

  PluginObject = object
    lib: pointer
    # eventHandlerCb: EventHandlerCallback
    mainCb: MainCallback

  PluginData {.union.} = object
    plugin: Plugin
    obj: PluginObject

  PluginHandle = object
    data: PluginData

    info: PluginInfo
    filepath: string

var
  loaded = false
  injected: seq[InjectedApi]
  pluginPath: string
  plugins: seq[PluginHandle]
  pluginUpdateOrder: seq[int]

let nativeApis = [ cast[pointer](addr(coreApi)), cast[pointer](addr(pluginApi)), cast[pointer](addr(appApi)),
                   cast[pointer](addr(gfxApi)), cast[pointer](addr(vfsApi)), cast[pointer](addr(assetApi)) ]

when defined(host):
  {.link: "../../thirdparty/cr.o".}

  proc openPlugin*(ctx: ptr Plugin; fullpath: cstring): bool {.importc: "cr_plugin_open".}
  proc updatePlugin*(ctx: ptr Plugin; reloadCheck: bool = true): int32 {.importc: "cr_plugin_update", discardable.}
  proc pluginEvent*(ctx: ptr Plugin; e: pointer) {.importc: "cr_plugin_event".}
  proc closePlugin*(ctx: ptr Plugin) {.importc: "cr_plugin_close".}

  proc getApi(api: ApiKind): pointer {.cdecl.} =
    assert(api < akCount)
    result = nativeApis[api]

  proc getApiByName(name: cstring): pointer {.cdecl.} =
    block outer:
      for i in 0 ..< len(injected):
        if name == injected[i].name:
          result = injected[i].api
          break outer

      result = nil

  proc injectApi(name: cstring; version: uint32; api: pointer) {.cdecl.} =
    var apiIdx = -1
    for i in 0 ..< len(injected):
      if injected[i].name == name:
        apiIdx = i
        break

    if apiIdx == -1:
      add(injected, InjectedApi(
        name: name,
        version: version,
        api: api
      ))
    else:
      injected[apiIdx].api = api


  proc initPlugins*() =
    block outer:
      for i in 0 ..< pluginUpdateOrder.len():
        let
          idx = pluginUpdateOrder[i]
          handle = plugins[idx].addr

        if not openPlugin(addr(handle.data.plugin), cstring(
            handle.filepath)).bool:
          # logWarn("failed initialing plugin: $#", handle.filepath)
          break outer

        # logDebug("initialized plugin!")

      loaded = true

  proc loadAbs*(filepath: string; entry: bool; entryDeps: openArray[cstring];
      numEntryDeps: int) =
    block outer:
      var handle: PluginHandle
      handle.data.plugin.api = addr pluginApi

      var dll: pointer
      if not entry:
        dll = loadLib($filepath)
        if isNil(dll):
          echo &"plugin load failed: {filepath}"
          break outer

        let getPluginInfo = cast[PluginInfoCb](symAddr(dll, "zPluginInfo"))
        if isNil(getPluginInfo):
          echo &"plugin missing `zPluginInfo` symbol: {filepath}"
          break outer

        getPluginInfo(addr(handle.info))
      else:
        # let appName = appApi.name()
        let appName = "zax"
        handle.info.name[0..high(appName)] = toOpenArray(appName, 0, high(appName))

      handle.filepath = filepath

      let
        numDeps = if entry: numEntryDeps else: handle.info.numDeps
        deps = if entry: cast[ptr UncheckedArray[cstring]](
            entryDeps) else: handle.info.deps

      if numDeps > 0 and not isNil(deps):
        discard

      unloadLib(dll)

      plugins.add(handle)
      pluginUpdateOrder.add(plugins.len() - 1)
      echo &"loaded plugin: {filepath}"

  proc load*(name: cstring): bool {.cdecl.} =
    when defined(macosx):
      loadAbs($name & ".dylib", false, [], 0)
    else:
      loadAbs($name & ".dll", false, [], 0)
    true

  proc init*(pp: cstring) =
    block early:
      if isNil(pp) or not bool(pp[0]):
        break early

      pluginPath = $pp
      normalizePath(pluginPath)
      if not dirExists(pluginPath):
        echo "plugin path: ", pluginPath, " is incorrect"

  proc update*() =
    block:
      for i in 0 ..< pluginUpdateOrder.len():
        let handle = plugins[pluginUpdateOrder[i]].addr
        assert updatePlugin(handle.data.plugin.addr, true) >= 0

  proc shutdown*() =
    echo "shutting down plugins"
    for i in 0 ..< pluginUpdateOrder.len():
      let handle = plugins[pluginUpdateOrder[i]].addr
      closePlugin(handle.data.plugin.addr)
    echo "plugins shut down"

  pluginApi = PluginApi(
    load: load,
    getApi: getApi,
    getApibyName: getApiByName,
    injectApi: injectApi
  )
