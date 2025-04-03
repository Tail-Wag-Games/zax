import flecs

type
  EcsApi* = object
    newWorld*: proc(): ptr World {.cdecl.}

var ecsApi*: EcsApi
