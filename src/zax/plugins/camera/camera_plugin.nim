import flecs, sokol_app as sapp,
       ../../api, ../../plugin, camera
# var
#   FLECS_IDOrbitCameraComponentID {.zState, nodecl,
#       exportc: "FLECS_IDOrbitCameraComponentID_".}: Entity
#   FLECS_OrbitCameraComponent_desc {.zState,
#                                     exportc: "FLECS__OrbitCameraComponent_desc".}: cstring = "{int foo;}"
#   FLECS_OrbitCameraComponent_kind {.zState,
#                                     exportc: "FLECS__OrbitCameraComponent_kind".}: ecs_type_kind_t = EcsStructType

# type
#   OrbitCameraComponent* = object
#     foo*: int
struct(OrbitCameraComponent):
  foo: int

var
  pluginApi {.zState.}: ptr PluginApi
  e1 {.zState.}: Entity

proc init(w: ptr World) {.cdecl.} =
  ecs_os_init()
  metaComponent(w, OrbitCameraComponent)
  echo "is valid: ", ecs_is_valid(w, FLECS_IDOrbitCameraComponentID)
  echo "name: ", ecs_get_name(w, FLECS_IDOrbitCameraComponentID)
  echo "symbol: ", ecs_get_symbol(w, FLECS_IDOrbitCameraComponentID)
  echo "init: ", FLECS_IDOrbitCameraComponentID
  # e1 = ecs_new(w)
  # set(w, e1, FLECS_IDOrbitCameraComponentID, OrbitCameraComponent,
  #     OrbitCameraComponent(foo: 1))
  # let occ = get(w, e1, OrbitCameraComponent)
  # echo repr occ

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
