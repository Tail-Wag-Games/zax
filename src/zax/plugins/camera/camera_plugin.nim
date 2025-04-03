import hmm, flecs, sokol_app as sapp,
       ../../api, ../../plugin, camera

struct(CameraComponent):
  position: Vec3
  target: Vec3

var
  pluginApi {.zState.}: ptr PluginApi
  e1 {.zState.}: Entity

proc init(w: ptr World) {.cdecl.} =
  ecs_os_init()
  echo metaComponent(w, CameraComponent)
  echo "is valid: ", ecs_is_valid(w, FLECS_IDCameraComponentID)
  echo "name: ", ecs_get_name(w, FLECS_IDCameraComponentID)
  echo "symbol: ", ecs_get_symbol(w, FLECS_IDCameraComponentID)
  echo "init: ", FLECS_IDCameraComponentID
  e1 = ecs_new(w)
  set(w, e1, FLECS_IDCameraComponentID, CameraComponent,
      CameraComponent(position: vec3(5, 5, 5), target: vec3(0, 0, 0)))
  let occ = get(w, e1, CameraComponent)
  echo repr occ

proc update(w: ptr World) {.cdecl.} =
  # let occ = get(w, e1, OrbitCameraComponent)
  # echo repr occ
  # echo "inspecting component for world: ", repr w, "!"
  # echo "orbit cam id: ", ecs_id_from_str(w, "OrbitCameraComponent")
  # echo "orbit cam stored id: ", FLECS_IDOrbitCameraComponentID
  # set(w, e1, FLECS_IDOrbitCameraComponentID, OrbitCameraComponent,
  #     OrbitCameraComponent(foo: occ.foo + 1))
  discard

proc zPluginEventHandler(e: ptr sapp.Event) {.cdecl, exportc, dynlib.} =
  discard

proc zPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.cdecl,
    exportc, dynlib.} =
  case operation:
  of poStep:
    discard
  of poInit:
    pluginApi = plugin.api

    pluginApi.injectApi("camera", 0, addr(cameraApi))
  else:
    discard

proc zPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("camera", 0, 31)
  info.desc[0..255] = toOpenArray("Camera component", 0, 255)
  info.deps[0] = "ecs"
  info.numDeps = 1

cameraApi = CameraApi(
  init: init,
  update: update
)
