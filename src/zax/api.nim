import std/macros,
       sokol/gfx as sg,
       mstreams, sync, zmath


type
  ApiKind* = distinct uint8

  AppApi* = object

  Asset* {.union.} = object
    id*: uint
    p*: pointer

  AssetHandle* = object
    id*: uint32

  AssetLoadData* = object
    asset*: Asset
    userData1*: pointer
    userData2*: pointer

  AssetLoadFlag* = distinct uint32
  AssetState* = distinct uint32

  AssetLoadParams* = object
    path*: cstring
    params*: pointer
    tags*: uint32
    flags*: AssetLoadFlag

  AssetCallbacks* = object
    onPrepare*: proc(params: ptr AssetLoadParams;
        mem: ptr MemBlock): AssetLoadData {.cdecl.}
    onLoad*: proc(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock): bool {.cdecl.}
    onFinalize*: proc(data: ptr AssetLoadData; params: ptr AssetLoadParams;
        mem: ptr MemBlock) {.cdecl.}
    onReload*: proc(handle: AssetHandle; prevAsset: Asset) {.cdecl.}
    onRelease*: proc(asset: Asset) {.cdecl.}

  AssetApi* = object
    registerAssetType*: proc(name: cstring; callbacks: AssetCallbacks; paramsTypeName: cstring; paramsSize: int32;
                             failedObj, asyncObj: Asset;
                                 forcedFlags: AssetLoadFlag) {.cdecl.}
    load*: proc(name: cstring; path: cstring; params: pointer;
        flags: AssetLoadFlag; tags: uint32): AssetHandle {.cdecl.}
    asset*: proc(handle: AssetHandle): Asset {.cdecl.}

  Job* = ptr Atomic[uint32]

  JobPriority* = enum
    jpHigh = 0
    jpNormal = 1
    jpLow = 2
    jpCount = 3

  JobCallback* = proc(rangeStart, rangeEnd, threadIdx: int32;
      userData: pointer) {.cdecl.}

  CoreApi* = object
    deltaTick*: proc(): uint64 {.cdecl.}
    deltaTime*: proc(): float32 {.cdecl.}
    frameIndex*: proc(): int64 {.cdecl.}
    dispatchJob*: proc(count: int32; callback: JobCallback; userData: pointer;
        priority: JobPriority; tags: uint32): Job {.cdecl.}
    testAndDelJob*: proc(job: Job): bool {.cdecl.}
    numJobThreads*: proc(): int32 {.cdecl.}
    jobThreadIndex*: proc(): int32 {.cdecl.}

  GfxStage* = object
    id*: uint32

  Shader* = object
    shd*: sg.Shader

  TextureLoadParams* = object
    firstMip*: int32
    minFilter*: Filter
    magFilter*: Filter
    wrapU*: Wrap
    wrapV*: Wrap
    wrapW*: Wrap
    fmt*: PixelFormat
    aniso*: int32
    srgb*: int32

  DepthLayers* {.union.} = object
    depth*: int32
    layers*: int32

  TextureInfo* = object
    nameHandle*: uint32
    imageType*: ImageType
    format*: PixelFormat
    memSizeBytes*: int32
    width*: int32
    height*: int32
    dl*: DepthLayers
    mips*: int32
    bpp*: int32

  Texture* = object
    img*: sg.Image
    info*: TextureInfo

  VertexAttribute* = object
    semantic*: cstring
    semanticIndex*: int32
    offset*: int32
    format*: VertexFormat
    bufferIndex*: int32

  VertexLayout* = object
    attributes*: array[maxVertexAttributes, VertexAttribute]

  GfxDrawApi* = object
    begin*: proc(stage: GfxStage): bool {.cdecl.}
    finish*: proc() {.cdecl.}
    updateBuffer*: proc(bufId: sg.Buffer; data: ptr sg.Range) {.cdecl.}
    beginDefaultPass*: proc(passAction: ptr PassAction; width,
        height: int32) {.cdecl.}
    beginPass*: proc(pass: Pass) {.cdecl.}
    applyViewport*: proc(x, y, width, height: int32; originTopLeft: bool) {.cdecl.}
    applyScissorRect*: proc(x, y, width, height: int32; originTopLeft: bool) {.cdecl.}
    applyPipeline*: proc(pip: Pipeline) {.cdecl.}
    applyBindings*: proc(bindings: ptr Bindings) {.cdecl.}
    applyUniforms*: proc(stage: sg.ShaderStage; ubIndex: int32; data: pointer;
        numBytes: int32) {.cdecl.}
    draw*: proc(baseElement: int32; numElements: int32;
        numInstances: int32) {.cdecl.}
    dispatch*: proc(threadGroupX, threadGroupY, threadGroupZ: int32) {.cdecl.}
    dispatchIndirect*: proc(buf: Buffer; offset: int32) {.cdecl.}
    drawIndexedInstancedIndirect*: proc(buf: Buffer; offset: int32) {.cdecl.}
    finishPass*: proc() {.cdecl.}
    appendBuffer*: proc(buf: Buffer; data: pointer;
        dataSize: int32): int32 {.cdecl.}
    updateImage*: proc(img: sg.Image; data: ptr ImageData) {.cdecl.}
    mapImage*: proc(img: Image; offset: int32; data: sg.Range) {.cdecl.}

  GfxApi* = object
    imm*: GfxDrawApi
    staged*: GfxDrawApi
    glFamily*: proc(): bool {.cdecl.}
    makeBuffer*: proc(desc: ptr BufferDesc): sg.Buffer {.cdecl.}
    makeImage*: proc(desc: ptr sg.ImageDesc): sg.Image {.cdecl.}
    makeShader*: proc(desc: ptr ShaderDesc): sg.Shader {.cdecl.}
    makePipeline*: proc(desc: ptr PipelineDesc): sg.Pipeline {.cdecl.}
    # makePass*: proc(desc: ptr PassDesc): sg.Pass {.cdecl.}
    allocImage*: proc(): sg.Image {.cdecl.}
    allocShader*: proc(): sg.Shader {.cdecl.}
    initImage*: proc(imgId: sg.Image; desc: ptr sg.ImageDesc) {.cdecl.}
    initShader*: proc(shdId: sg.Shader; desc: ptr ShaderDesc) {.cdecl.}
    registerStage*: proc(name: cstring; parentStage: GfxStage): GfxStage {.cdecl.}
    makeShaderWithData*: proc(vsDataSize: uint32; vsData: ptr UncheckedArray[
        uint32]; vsReflSize: uint32; vsReflJson: ptr UncheckedArray[uint32];
            fsDataSize: uint32;
        fsData: ptr UncheckedArray[uint32]; fsReflSize: uint32;
            fsReflJson: ptr UncheckedArray[uint32]): Shader {.cdecl.}
    bindShaderToPipeline*: proc(shd: ptr Shader; pipDesc: ptr PipelineDesc;
        vl: ptr VertexLayout): ptr PipelineDesc {.cdecl.}
    getShader*: proc(shaderAssetHandle: AssetHandle): ptr api.Shader {.cdecl.}
    whiteTexture*: proc(): sg.Image {.cdecl.}
    # createCheckerTexture*: proc(checkerSize, size: int32; colors: array[2, zmath.Color]): Texture {.cdecl.}
    getTexture*: proc(textureAssetHandle: AssetHandle): ptr api.Texture {.cdecl.}
    swapchain*: proc(): sg.Swapchain {.cdecl.}

  PluginEvent* = distinct uint32
  PluginFailure* = distinct uint32
  PluginOperation* = distinct uint32

  Plugin* = object
    p*: pointer
    api*: ptr PluginApi
    version*: uint32
    failure*: PluginFailure
    nextVersion*: uint32
    lastWorkingVersion*: uint32

  PluginApi* = object
    load*: proc(name: cstring): bool {.cdecl.}
    injectApi*: proc(name: cstring; version: uint32; api: pointer) {.cdecl.}
    getApi*: proc(api: ApiKind): pointer {.cdecl.}
    getApiByName*: proc(name: cstring): pointer {.cdecl.}

  VfsAsyncReadCallback* = proc(path: cstring; mem: ptr MemBlock;
      userData: pointer) {.cdecl.}
  VfsAsyncWriteCallback* = proc(path: cstring; bytesWritten: int64;
      mem: ptr MemBlock; userData: pointer) {.cdecl.}

  VfsFlag* = distinct uint32

  VfsApi* = object
    mount*: proc(path, alias: cstring; watch: bool): bool {.cdecl.}
    read*: proc(path: cstring; flags: VfsFlag): ptr MemBlock {.cdecl.}
    readAsync*: proc(path: cstring; flags: VfsFlag;
        readFn: VfsAsyncReadCallback; userData: pointer) {.cdecl.}

  CameraApi* = object

const
  # API Kinds
  akCore* = ApiKind(0)
  akPlugin* = ApiKind(1)
  akApp* = ApiKind(2)
  akGfx* = ApiKind(3)
  akVfs* = ApiKind(4)
  akAsset* = ApiKind(5)
  akCamera* = ApiKind(6)
  akCount* = ApiKind(7)

  # Asset Load Flags
  alfNone* = AssetLoadFlag(0)
  alfReload* = AssetLoadFlag(1)
  alfAbsolutePath* = AssetLoadFlag(2)
  alfWaitOnLoad* = AssetLoadFlag(3)

  # Asset States
  asZombie* = AssetState(0)
  asOk* = AssetState(1)
  asFailed* = AssetState(2)
  asLoading* = AssetState(3)

  # Plugin Operations
  poLoad* = PluginOperation(0)
  poStep* = PluginOperation(1)
  poUnload* = PluginOperation(2)
  poClose* = PluginOperation(3)
  poInit* = PluginOperation(4)

  # Virtual File System Flags
  vfsfNone* = VfsFlag(0x1)
  vfsfAbsolutePath* = VfsFlag(0x2)
  vfsfTextFile* = VfsFlag(0x4)
  vfsfAppend* = VfsFlag(0x8)

when defined(vcc):
  macro zState*(t: typed): untyped =
    let typeNode = if t[0][1].kind == nnkSym:
        newIdentNode(t[0][1].strVal)
      elif t[0][1].kind == nnkPtrTy:
        nnkPtrTy.newTree(newIdentNode(t[0][1][0].strVal))
      elif t[0][1].kind == nnkRefTy:
        nnkRefTy.newTree(newIdentNode(t[0][1][0].strVal))
      else:
        newIdentNode("")

    let pragmaNode = quote do:
      {.emit: "#pragma section(\".state\", read, write)".}

    result = nnkStmtList.newTree(
      pragmaNode,
      nnkVarSection.newTree(
        nnkIdentDefs.newTree(
          nnkPragmaExpr.newTree(
            newIdentNode(t[0][0].strVal),
            nnkPragma.newTree(
              nnkExprColonExpr.newTree(
                newIdentNode("codegenDecl"),
                newLit("__declspec(allocate(\".state\")) $# $#")
        )
      )
        ),
        typeNode,
        newEmptyNode()
      )
      )
    )
elif defined(macosx):
  macro zState*(t: typed): untyped =
    let typeNode = if t[0][1].kind == nnkSym:
        newIdentNode(t[0][1].strVal)
      elif t[0][1].kind == nnkPtrTy:
        nnkPtrTy.newTree(newIdentNode(t[0][1][0].strVal))
      elif t[0][1].kind == nnkRefTy:
        nnkRefTy.newTree(newIdentNode(t[0][1][0].strVal))
      else:
        newIdentNode("")

    result = nnkStmtList.newTree(
      nnkVarSection.newTree(
        nnkIdentDefs.newTree(
          nnkPragmaExpr.newTree(
            newIdentNode(t[0][0].strVal),
            nnkPragma.newTree(
              nnkExprColonExpr.newTree(
                newIdentNode("codegenDecl"),
                newLit("__attribute__((used, section(\"__DATA,__state\"))) $# $#")
        )
      )
        ),
        typeNode,
        newEmptyNode()
      )
      )
    )



proc `<`*(a, b: ApiKind): bool {.borrow.}
template`[]`*[N, T](a: array[N, T]; b: ApiKind): T = a[ord(b)]

proc `and`*(a, b: AssetLoadFlag): AssetLoadFlag {.borrow.}
proc `or`*(a, b: AssetLoadFlag): AssetLoadFlag {.borrow.}
