import std/[os, strutils]

when defined(windows):
  --cc:vcc
  # --passC:"-fsanitize=address /Zi"

# --passC:"-fsanitize=address"
# --passL:"-fsanitize=address"
--path:"../src"
--path:"thirdparty"
--path:"thirdparty/sokol-nim/src"
--path:"thirdparty/polymorph/src"
--mm:arc
--threads:on
--tls_emulation:off
--threadanalysis:off
--debugger:native
--define:useMalloc
--define:host

# var useMimalloc = defined(mimalloc) or defined(mimallocDynamic)

# # Uncomment this to use mimalloc by default
# #useMimalloc = true

# if useMimalloc:
#   switch("gc", "orc")
#   switch("define", "useMalloc")

#   when not defined(mimallocDynamic):
#     let
#       mimallocPath = projectDir() / "mimalloc"
#       # Quote the paths so we support paths with spaces
#       # TODO: Is there a better way of doing this?
#       mimallocStatic = "mimallocStatic=\"" & (mimallocPath / "src" / "static.c") & '"'
#       mimallocIncludePath = "mimallocIncludePath=\"" & (mimallocPath / "include") & '"'

#     # So we can compile mimalloc from the patched files
#     switch("define", mimallocStatic)
#     switch("define", mimallocIncludePath)

#   # Not sure if we really need those or not, but Mimalloc uses them
#   case get("cc")
#   of "gcc", "clang", "icc", "icl":
#     switch("passC", "-ftls-model=initial-exec -fno-builtin-malloc")
#   else:
#     discard

#   {.hint: "Patching malloc.nim to use mimalloc".}
#   patchFile("stdlib", "malloc", "thirdparty" / "mimalloc")

# task buildTerminalPlugin, "build terminal emulator plugin":
#   exec "nim c --debugger:native --threads:on --app:lib --out:terminal.dll ./src/zax/plugins/terminal_plugin.nim"

task buildEcsPlugin, "build ecs plugin":
  when defined(macosx):
    exec "nim c --debugger:native --threads:off --app:lib --passL:-lstdc++ --out:ecs.dylib ./src/zax/plugins/ecs_plugin.nim"
  else:
    exec "nim c --debugger:native --threads:off --app:lib --out:ecs.dylib ./src/zax/plugins/ecs_plugin.nim"

task build3dPlugin, "build 3d plugin":
  when defined(macosx):
    exec "nim c --debugger:native --threads:off --app:lib --passL:-lstdc++ --out:3d.dylib ./src/zax/plugins/three_d_plugin.nim"
  else:
    exec "nim c --debugger:native --threads:off --app:lib --out:3d.dylib ./src/zax/plugins/three_d_plugin.nim"


task buildPlugins, "build default plugins":
  discard
  # exec "nim buildTerminalPlugin"
  exec "nim buildEcsPlugin"
  exec "nim build3dPlugin"

task make, "build zax project":
  when defined(windows):
    exec "ml64.exe /nologo /c /Fo./thirdparty/context/src/asm/make_x86_64_ms_pe_masm.obj /Zd /Zi /I./thirdparty/context/src/asm /DBOOST_CONTEXT_EXPORT= ./thirdparty/context/src/asm/make_x86_64_ms_pe_masm.asm"
    exec "ml64.exe /nologo /c /Fo./thirdparty/context/src/asm/jump_x86_64_ms_pe_masm.obj /Zd /Zi /I./thirdparty/context/src/asm /DBOOST_CONTEXT_EXPORT= ./thirdparty/context/src/asm/jump_x86_64_ms_pe_masm.asm"
    exec "ml64.exe /nologo /c /Fo./thirdparty/context/src/asm/ontop_x86_64_ms_pe_masm.obj /Zd /Zi /I./thirdparty/context/src/asm /DBOOST_CONTEXT_EXPORT= ./thirdparty/context/src/asm/ontop_x86_64_ms_pe_masm.asm"
    exec "cl.exe /c /g /DCR_DEBUG /DCR_MAIN_FUNC \"zPlugin\" /std:c++17 thirdparty/cr.cpp /o thirdparty/cr.o"
  elif defined(macosx):
    exec "cc -O0 -ffunction-sections -fdata-sections -g -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./thirdparty/context/src/asm -o ./thirdparty/context/src/asm/make_arm64_aapcs_macho_gas.S.o -c ./thirdparty/context/src/asm/make_arm64_aapcs_macho_gas.S"
    exec "cc -O0 -ffunction-sections -fdata-sections -g -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./thirdparty/context/src/asm -o ./thirdparty/context/src/asm/jump_arm64_aapcs_macho_gas.S.o -c ./thirdparty/context/src/asm/jump_arm64_aapcs_macho_gas.S"
    exec "cc -O0 -ffunction-sections -fdata-sections -g -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./thirdparty/context/src/asm -o ./thirdparty/context/src/asm/ontop_arm64_aapcs_macho_gas.S.o -c ./thirdparty/context/src/asm/ontop_arm64_aapcs_macho_gas.S"
    exec "clang++ -c -g -DCR_DEBUG -DCR_MAIN_FUNC=\"zPlugin\" -DCR_EVENT_FUNC=\"zPluginEventHandler\" --std=c++17 thirdparty/cr.cpp -o thirdparty/cr.o"
  else:
    echo "platform not supported"

  exec "nim buildPlugins"

  when defined(macosx):
    exec "nim objc --passL:-Wl,-rpath,/usr/local/lib --passL:\"-framework Cocoa -framework QuartzCore -framework Metal -framework MetalKit -lstdc++\" --out:./bin/zax.exe src/zax.nim"
  elif defined(windows):
    exec "nim c --out:./bin/zax.exe src/zax.nim"
  else:
    exec "nim c --passL:-Wl,-rpath,/usr/local/lib --out:./bin/zax.exe src/zax.nim"
