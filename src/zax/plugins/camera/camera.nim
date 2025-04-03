import flecs

type
  CameraApi* = object
    init*: proc(w: ptr World) {.cdecl.}
    update*: proc(w: ptr World) {.cdecl.}

var cameraApi*: CameraApi
