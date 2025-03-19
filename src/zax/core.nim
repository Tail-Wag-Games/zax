import std/cpuinfo,
       sokol/gfx as sg, sokol/glue as sglue,
       api, asset, cfg, gfx, jobs, plugin, zapis

type
  CoreContext = object
    frameIndex: int64
    elapsedTick: uint64
    deltaTick: uint64
    lastTick: uint64
    fpsMean: float32
    fpsFrame: float32

    jobCtx: ptr JobContext

    numThreads: int32

var
  ctx: CoreContext
  passAction = PassAction(
    colors: [ ColorAttachmentAction( loadAction: loadActionClear, clearValue: (1, 0, 0, 0)) ]
  )

proc deltaTick(): uint64 {.cdecl.} =
  result = ctx.deltaTick

proc deltaTime(): float32 {.cdecl.} =
  # result = float32(sec(ctx.deltaTick))
  discard

proc frameIndex(): int64 {.cdecl.} =
  result = ctx.frameIndex

proc dispatchJob(count: int32; callback: proc(start, finish, threadIdx: int32;
    userData: pointer) {.cdecl.}; userData: pointer; priority: JobPriority;
    tags: uint32): Job {.cdecl.} =
  assert(ctx.jobCtx != nil)
  result = jobs.dispatch(ctx.jobCtx, count, callback, userData, priority, tags)

proc testAndDelJob(j: Job): bool {.cdecl.} =
  assert(ctx.jobCtx != nil)
  result = jobs.testAndDel(ctx.jobCtx, j)

proc numJobThreads(): int32 {.cdecl.} =
  ctx.numThreads

proc jobThreadIndex(): int32 {.cdecl.} =
  assert(ctx.jobCtx != nil)
  result = jobThreadIndex(ctx.jobCtx)

proc init*(cfg: var Config) =
  var numWorkerThreads = if cfg.numJobThreads >=
      0: cfg.numJobThreads else: int32(countProcessors() - 1)
  numWorkerThreads = max(1, numWorkerThreads)
  ctx.numThreads = numWorkerThreads + 1

  # vfs.init()

  ctx.jobCtx = jobs.createContext(JobContextDesc(
    numThreads: 4,
    maxFibers: 64,
    fiberStackSize: 1024 * 1024
  ))

  asset.init()

  gfx.init()

  plugin.init(cfg.pluginPath)

proc frame*() =
  # ctx.deltaTick = laptime(addr(ctx.lastTick))
  ctx.elapsedTick += ctx.deltaTick

  let
    deltaTick = ctx.deltaTick
    # dt = float32(sec(deltaTick))

  if deltaTick > 0:
    # var
    #   aFps = ctx.fpsMean
    #   # fps = 1.0'f64 / dt

    # aFps += (fps - aFps) / float64(ctx.frameIndex)
    # ctx.fpsMean = float32(aFps)
    # ctx.fpsFrame = float32(fps)
    discard

  # vfs.update()

  # asset.update()
  plugin.update()

  gfx.executeCommandBuffers()

  # let imguiApi = cast[ptr ImguiApi](pluginApi.getApiByName("imgui", 0))
  # if imguiApi != nil:
  #   imguiApi.render()

  sg.commit()

  inc(ctx.frameIndex)

proc shutdown*() =
  plugin.shutdown()
  gfx.shutdown()
  # asset.shutdown()
  jobs.destroyContext(ctx.jobCtx)
  # vfs.shutdown()

coreApi = CoreApi(
  deltaTick: deltaTick,
  deltaTime: deltaTime,
  frameIndex: frameIndex,
  dispatchJob: dispatchJob,
  testAndDelJob: testAndDelJob,
  numJobThreads: numJobThreads,
  jobThreadIndex: jobThreadIndex
)
