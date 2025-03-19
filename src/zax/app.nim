import api, cfg, core, plugin, zapis,
       sokol/log as slog, sokol/app as sapp,
       sokol/gfx as sg, sokol/glue as sglue

type
  App* = object
    cfg: Config
    appPluginFilepath: string
    passAction: sg.PassAction

# proc init*(app: var App; apc: AppPluginConfig; apfp: string) =

# proc init(userData: pointer) {.cdecl.} =
#   echo "initializing zax"
#   let app = cast[ptr App](userData)


# proc frame() {.cdecl.} =
#   plugin.update()

# proc shutdown() {.cdecl.} =
#   echo "shutting down zax"
#   plugin.shutdown()

# proc event(e: ptr sapp.Event) {.cdecl.} =
#   discard
#


proc init(p: pointer) {.cdecl.} =
  let app = cast[ptr App](p)

  echo "initializing zax core..."
  core.init(app.cfg)
  echo "zax core initialized."

  echo app.cfg.plugins

  var numPlugins = 0
  for i in 0 ..< maxPlugins:
    if isNil(app.cfg.plugins[i]) or not bool(app.cfg.plugins[i][0]):
      break

    echo "loading plugin: ", $app.cfg.plugins[i]
    if not pluginApi.load(app.cfg.plugins[i]):
      quit(QuitFailure)

    inc(numPlugins)

  echo "num plugins: ", numPlugins
  plugin.loadAbs(app.appPluginFilepath, true,
      app.cfg.plugins, numPlugins)

  plugin.initPlugins()

  # app[].passAction = PassAction(
  #   colors: [ ColorAttachmentAction( loadAction: loadActionClear, clearValue: (1, 0, 0, 0)) ]
  # )

  # sg.setup(sg.Desc(
  #   environment: sglue.environment(),
  #   logger: sg.Logger(fn: slog.fn),
  # ))
  # case sg.queryBackend():
  #   of backendGlcore: echo "using GLCORE backend"
  #   of backendD3d11: echo "using D3D11 backend"
  #   of backendMetalMacos: echo "using Metal backend"
  #   else: echo "using untested backend"

proc frame(p: pointer) {.cdecl.} =
  # let app = cast[ptr App](p)

  # var g = app.passAction.colors[0].clearValue.g + 0.01
  # app.passAction.colors[0].clearValue.g = if g > 1.0: 0.0 else: g
  # beginPass(Pass(action: app.passAction, swapchain: sglue.swapchain()))
  # endPass()
  # commit()

  core.frame()

proc cleanup(p: pointer) {.cdecl.} =
  core.shutdown()

proc run*(app: var App) =
  sapp.run(sapp.Desc(
    userData: addr(app),
    initUserdataCb: init,
    frameUserdataCb: frame,
    cleanupUserdataCb: cleanup,
    windowTitle: "clear.nim",
    width: 400,
    height: 300,
    icon: IconDesc(sokol_default: true),
    logger: sapp.Logger(fn: slog.fn)
  ))

proc newApp*(apf: string; cfg: Config): App =
  result.appPluginFilepath = apf
  result.cfg = cfg
