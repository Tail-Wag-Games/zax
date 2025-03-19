const
  maxPath* = 256
  maxPlugins* = 32

type
  Config* = object
    plugins*: array[maxPlugins, cstring]
    pluginPath*: cstring
    appName*: cstring
    numJobThreads*: int32
