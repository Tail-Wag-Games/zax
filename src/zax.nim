import zax/[api, cfg],
       zax/plugins/[ecs]

export api,
       cfg,
       ecs

when isMainModule:
  import std/[dynlib, os, parseopt, strformat],
         zax/[app, pool]

  when defined(windows):
    import winim/lean

  proc messageBox(msg: string) =
    when defined(Windows):
      MessageBoxA(HWND(0), msg, "zax", MB_OK or MB_ICONERROR)
    else:
      echo(msg)


  proc saveCfgString(cacheStr: var string, str: var cstring) =
    if len(str) > 0:
      setLen(cacheStr, len(str))
      for i in 0 ..< len(str):
        cacheStr[i] = str[i]
      str = addr(cacheStr[0])

  proc main() =
    block early:
      var
        appPluginFilepath: string
        defaultAppName = "zax"
        defaultPluginPath: string
        defaultPlugins: array[maxPlugins, string]

      for kind, key, val in getopt():
        case kind
        of cmdArgument:
          discard
        of cmdLongOption, cmdShortOption:
          case key
          of "r", "run":
            appPluginFilepath = val
        of cmdEnd:
          discard

      if appPluginFilepath.len == 0:
        messageBox("provide path to application plugin to run via run option (ex: --run=app_plugin.dll|so|dylib)")
        break early

      if not fileExists(appPluginFilepath):
        messageBox(&"application plugin does not exist: {appPluginFilepath}")
        break early

      let appPlugin = loadLib(appPluginFilepath)
      if isNil(appPlugin):
        messageBox(&"file at path: {appPluginFilepath} is not a valid application plugin")
        break early

      let appPluginEntry = cast[proc(cfg: ptr Config) {.cdecl.}](
          symAddr(appPlugin, "zMain"))
      if isNil(appPluginEntry):
        messageBox(&"application plugin at path: {appPluginFilepath} does not export a procedure named `zMain`")
        break early

      var cfg = Config(appName: cstring(defaultAppName))
      appPluginEntry(addr(cfg))

      saveCfgString(defaultAppName, cfg.appName)
      saveCfgString(defaultPluginPath, cfg.pluginPath)
      for i in 0 ..< maxPlugins:
        if cfg.plugins[i] != nil and len(cfg.plugins[i]) > 0:
          saveCfgString(defaultPlugins[i], cfg.plugins[i])

      unloadLib(appPlugin)

      var app = newApp(appPluginFilepath, cfg)
      app.run()

  main()
