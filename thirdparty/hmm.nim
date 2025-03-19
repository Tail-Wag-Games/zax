import std/[fenv, math]

{.compile: "./hmm.c".}

when defined(i386) or defined(amd64):
  # SIMD throughput and latency:
  #   - https://software.intel.com/sites/landingpage/IntrinsicsGuide/
  #   - https://www.agner.org/optimize/instruction_tables.pdf

  # Reminder: x86 is little-endian, order is [low part, high part]
  # Documentation at https://software.intel.com/sites/landingpage/IntrinsicsGuide/

  when defined(vcc):
    {.pragma: x86_type, byCopy, header:"<intrin.h>".}
    {.pragma: x86, noDecl, header:"<intrin.h>".}
  else:
    {.pragma: x86_type, byCopy, header:"<x86intrin.h>".}
    {.pragma: x86, noDecl, header:"<x86intrin.h>".}
  type
    m128* {.importc: "__m128", x86_type.} = object
      raw: array[4, float32]
    m128d* {.importc: "__m128d", x86_type.} = object
      raw: array[2, float64]
    m128i* {.importc: "__m128i", x86_type.} = object
      raw: array[16, byte]
    m256* {.importc: "__m256", x86_type.} = object
      raw: array[8, float32]
    m256d* {.importc: "__m256d", x86_type.} = object
      raw: array[4, float64]
    m256i* {.importc: "__m256i", x86_type.} = object
      raw: array[32, byte]
    m512* {.importc: "__m512", x86_type.} = object
      raw: array[16, float32]
    m512d* {.importc: "__m512d", x86_type.} = object
      raw: array[8, float64]
    m512i* {.importc: "__m512i", x86_type.} = object
      raw: array[64, byte]
    mmask16* {.importc: "__mmask16", x86_type.} = distinct uint16
    mmask64* {.importc: "__mmask64", x86_type.} = distinct uint64

  proc mm_set_ss(w: float32): m128 {.importc: "_mm_set_ss".}
  proc mm_sqrt_ss(w: m128): m128 {.importc: "_mm_sqrt_ss".}
  proc mm_rsqrt_ss(w: m128): m128 {.importc: "_mm_rsqrt_ss".}
  proc mm_cvtss_f32(w: m128): float32 {.importc: "_mm_cvtss_f32".}
  proc mm_setr_ps(a, b, c, d: float32): m128 {.importc: "_mm_setr_ps".}
  proc mm_set_ps1(a: float32): m128 {.importc: "_mm_set_ps1".}
  proc mm_store_ss(p: ptr float32; a: m128) {.importc: "_mm_store_ss".}
  proc mm_add_ps(a, b: m128): m128 {.importc: "_mm_add_ps".}
  proc mm_sub_ps(a, b: m128): m128 {.importc: "_mm_sub_ps".}
  proc mm_mul_ps(a, b: m128): m128 {.importc: "_mm_mul_ps".}
  proc mm_div_ps(a, b: m128): m128 {.importc: "_mm_div_ps".}
  proc mm_shuffle_ps(a, b: m128; c: int32): m128 {.importc: "_mm_shuffle_ps".}
  proc mm_xor_ps(a, b: m128): m128 {.importc: "_mm_xor_ps".}


  type
    INNER_C_STRUCT_handmademath_pp_5* {.bycopy.} = object
      x*: float32
      y*: float32

    INNER_C_STRUCT_handmademath_pp_10* {.bycopy.} = object
      U*: float32
      V*: float32

    INNER_C_STRUCT_handmademath_pp_15* {.bycopy.} = object
      l*: float32
      r*: float32

    INNER_C_STRUCT_handmademath_pp_20* {.bycopy.} = object
      width*: float32
      height*: float32

    INNER_C_STRUCT_handmademath_pp_31* {.bycopy.} = object
      x*: float32
      y*: float32
      z*: float32

    INNER_C_STRUCT_handmademath_pp_36* {.bycopy.} = object
      u*: float32
      v*: float32
      w*: float32

    INNER_C_STRUCT_handmademath_pp_41* {.bycopy.} = object
      r*: float32
      g*: float32
      b*: float32

    INNER_C_STRUCT_handmademath_pp_46* {.bycopy.} = object
      xy*: Vec2
      ignored0*: float32

    INNER_C_STRUCT_handmademath_pp_52* {.bycopy.} = object
      ignored1*: float32
      yz*: Vec2

    INNER_C_STRUCT_handmademath_pp_58* {.bycopy.} = object
      uv*: Vec2
      ignored2*: float32

    INNER_C_STRUCT_handmademath_pp_64* {.bycopy.} = object
      ignored3*: float32
      vw*: Vec2

    INNER_C_STRUCT_handmademath_pp_81* {.bycopy.} = object
      x*: float32
      y*: float32
      z*: float32

    INNER_C_UNION_handmademath_pp_78* {.bycopy, union.} = object
      xyz*: Vec3
      ano_handmademath_pp_82*: INNER_C_STRUCT_handmademath_pp_81

    INNER_C_STRUCT_handmademath_pp_76* {.bycopy.} = object
      ano_handmademath_pp_83*: INNER_C_UNION_handmademath_pp_78
      w*: float32

    INNER_C_STRUCT_handmademath_pp_94* {.bycopy.} = object
      r*: float32
      g*: float32
      b*: float32

    INNER_C_UNION_handmademath_pp_91* {.bycopy, union.} = object
      rgb*: Vec3
      ano_handmademath_pp_95*: INNER_C_STRUCT_handmademath_pp_94

    INNER_C_STRUCT_handmademath_pp_89* {.bycopy.} = object
      ano_handmademath_pp_96*: INNER_C_UNION_handmademath_pp_91
      a*: float32

    INNER_C_STRUCT_handmademath_pp_103* {.bycopy.} = object
      xy*: Vec2
      ignored0*: float32
      ignored1*: float32

    INNER_C_STRUCT_handmademath_pp_110* {.bycopy.} = object
      ignored2*: float32
      yz*: Vec2
      ignored3*: float32

    INNER_C_STRUCT_handmademath_pp_117* {.bycopy.} = object
      ignored4*: float32
      ignored5*: float32
      zw*: Vec2

    INNER_C_STRUCT_handmademath_pp_147* {.bycopy.} = object
      x*: float32
      y*: float32
      z*: float32

    INNER_C_UNION_handmademath_pp_144* {.bycopy, union.} = object
      xyz*: Vec3
      ano_handmademath_pp_148*: INNER_C_STRUCT_handmademath_pp_147

    INNER_C_STRUCT_handmademath_pp_142* {.bycopy.} = object
      ano_handmademath_pp_149*: INNER_C_UNION_handmademath_pp_144
      w*: float32

    Vec2* {.bycopy, union.} = object
      ano_handmademath_pp_6*: INNER_C_STRUCT_handmademath_pp_5
      ano_handmademath_pp_11*: INNER_C_STRUCT_handmademath_pp_10
      ano_handmademath_pp_16*: INNER_C_STRUCT_handmademath_pp_15
      ano_handmademath_pp_21*: INNER_C_STRUCT_handmademath_pp_20
      elements*: array[2, float32]

    IVec2XY* = object
      x*, y*: int32

    IVec2* {.bycopy, union.} = object
      xy*: IVec2XY
      elements*: array[2, int32]

    Vec3* {.bycopy, union.} = object
      ano_handmademath_pp_32*: INNER_C_STRUCT_handmademath_pp_31
      ano_handmademath_pp_37*: INNER_C_STRUCT_handmademath_pp_36
      ano_handmademath_pp_42*: INNER_C_STRUCT_handmademath_pp_41
      ano_handmademath_pp_48*: INNER_C_STRUCT_handmademath_pp_46
      ano_handmademath_pp_54*: INNER_C_STRUCT_handmademath_pp_52
      ano_handmademath_pp_60*: INNER_C_STRUCT_handmademath_pp_58
      ano_handmademath_pp_66*: INNER_C_STRUCT_handmademath_pp_64
      elements*: array[3, float32]

    Vec4* {.bycopy, union.} = object
      ano_handmademath_pp_86*: INNER_C_STRUCT_handmademath_pp_76
      ano_handmademath_pp_99*: INNER_C_STRUCT_handmademath_pp_89
      ano_handmademath_pp_106*: INNER_C_STRUCT_handmademath_pp_103
      ano_handmademath_pp_113*: INNER_C_STRUCT_handmademath_pp_110
      ano_handmademath_pp_120*: INNER_C_STRUCT_handmademath_pp_117
      elements*: array[4, float32]
      internalElementsSSE*: m128

    Mat3* {.bycopy, union.} = object
      elements*: array[3, array[3, float32]]
      columns*: array[3, Vec3]

    Mat4* {.bycopy, union.} = object
      elements*: array[4, array[4, float32]]
      raw*: array[16, float32]
      columns*: array[4, m128]
      rows*: array[4, m128]

    Quaternion* {.bycopy, union.} = object
      ano_handmademath_pp_152*: INNER_C_STRUCT_handmademath_pp_142
      elements*: array[4, float32]
      internalElementsSSE*: m128

    V2* = Vec2
    V3* = Vec3
    V4* = Vec4
    M4* = Mat4

  # Vec2
  template x*(a: Vec2): float32 =
    a.ano_handmademath_pp_6.x

  template `x=`*(a: var Vec2; b: float32) =
    a.ano_handmademath_pp_6.x = b

  template y*(a: Vec2): float32 =
    a.ano_handmademath_pp_6.y

  template `y=`*(a: var Vec2; b: float32) =
    a.ano_handmademath_pp_6.y = b

  proc `<`*(a, b: Vec2): bool =
    result = a.x < b.x and a.y < b.y

  proc `~=`*(p1: Vec2, p2: Vec2): bool = abs(p1.x - p2.x) <= epsilon(float32) and abs(p1.y - p2.y) <= epsilon(float32)

  proc cmpX*(p1, p2: Vec2): int =
    if p1.x != p2.x:
      return cmp(p1.x, p2.x)
    else:
      return cmp(p1.y, p2.y)

  proc cmpY*(p1, p2: Vec2): int =
    if p1.y != p2.y:
      return cmp(p1.y, p2.y)
    else:
      return cmp(p1.x, p2.x)

  # Vec3

  proc `[]`*(v: Vec3; idx: SomeUnsignedInt): float32 =
    result = v.elements[idx]

  template x*(a: Vec3): float32 =
    a.ano_handmademath_pp_32.x

  template `x=`*(a: var Vec3; b: float32) =
    a.ano_handmademath_pp_32.x = b

  template y*(a: Vec3): float32 =
    a.ano_handmademath_pp_32.y

  template `y=`*(a: var Vec3; b: float32) =
    a.ano_handmademath_pp_32.y = b

  template z*(a: Vec3): float32 =
    a.ano_handmademath_pp_32.z

  template `z=`*(a: var Vec3; b: float32) =
    a.ano_handmademath_pp_32.z = b

  template `*`*(v: Vec3; f: float32): Vec3 =
    multiplyVec3f(v, f)

  template `+=`*(l: var Vec3; r: Vec3) =
    l = addVec3(l, r)

  template `+`*(l, r: Vec3): Vec3 =
    addVec3(l, r)

  template `-`*(l, r: Vec3): Vec3 =
    subtractVec3(l, r)

  # Vec4

  template x*(a: Vec4): float32 =
    a.ano_handmademath_pp_86.ano_handmademath_pp_83.ano_handmademath_pp_82.x

  template `x=`*(a: var Vec4; b: float32) =
    a.ano_handmademath_pp_86.ano_handmademath_pp_83.ano_handmademath_pp_82.y = b

  template y*(a: Vec4): float32 =
    a.ano_handmademath_pp_86.ano_handmademath_pp_83.ano_handmademath_pp_82.y

  template `y=`*(a: var Vec4; b: float32) =
    a.ano_handmademath_pp_86.ano_handmademath_pp_83.ano_handmademath_pp_82.y = b

  template z*(a: Vec4): float32 =
    a.ano_handmademath_pp_86.ano_handmademath_pp_83.ano_handmademath_pp_82.z

  template `z=`*(a: var Vec4; b: float32) =
    a.ano_handmademath_pp_86.ano_handmademath_pp_83.ano_handmademath_pp_82.z = b

  template xyz*(a: Vec4): Vec3 =
    a.ano_handmademath_pp_86.ano_handmademath_pp_83.xyz

  template `xyz=`*(a: Vec4; b: Vec3) =
    a.ano_handmademath_pp_86.ano_handmademath_pp_83.xyz = b

  template w*(a: Vec4): float32 =
    a.ano_handmademath_pp_86.w

  template `w=`*(a: var Vec4; b: float32) =
    a.ano_handmademath_pp_86.w = b

  # Quaternion

  template x*(a: Quaternion): float32 =
    a.ano_handmademath_pp_152.ano_handmademath_pp_149.ano_handmademath_pp_148.x

  template y*(a: Quaternion): float32 =
    a.ano_handmademath_pp_152.ano_handmademath_pp_149.ano_handmademath_pp_148.y

  template `y=`*(a: var Quaternion; b: float32) =
    a.ano_handmademath_pp_152.ano_handmademath_pp_149.ano_handmademath_pp_148.x = b

  template z*(a: Quaternion): float32 =
    a.ano_handmademath_pp_152.ano_handmademath_pp_149.ano_handmademath_pp_148.z

  template `z=`*(a: var Quaternion; b: float32) =
    a.ano_handmademath_pp_152.ano_handmademath_pp_149.ano_handmademath_pp_148.z = b

  template xyz*(a: Quaternion): Vec3 =
    a.ano_handmademath_pp_152.ano_handmademath_pp_149.xyz

  template `xyz=`*(a: Quaternion; b: Vec3) =
    a.ano_handmademath_pp_152.ano_handmademath_pp_149.xyz = b

  template w*(a: Quaternion): float32 =
    a.ano_handmademath_pp_152.w

  template `w=`*(a: var Quaternion; b: float32) =
    a.ano_handmademath_pp_152.w = b

  template `*`*(l, r: Quaternion): Quaternion =
    multiplyQuaternion(l, r)

  # Mat3
  proc `[]`*(m: Mat3; idx: SomeUnsignedInt): Vec3 =
    result = m.columns[idx]

  # Mat4

  proc `[]`*(m: Mat4; idx: SomeUnsignedInt): Vec4 =
    let c = m.elements[idx]

    result.elements[0] = c[0]
    result.elements[1] = c[1]
    result.elements[2] = c[2]
    result.elements[3] = c[3]

  template `*`*(l, r: Mat4): Mat4 =
    multiplyMat4(l, r)

  proc sinF*(Radians: float32): float32 {.inline.} =
    var res: float32 = sin(Radians)
    return res

  proc cosF*(Radians: float32): float32 {.inline.} =
    var res: float32 = cos(Radians)
    return res

  proc tanF*(Radians: float32): float32 {.inline.} =
    var res: float32 = tan(Radians)
    return res

  proc aCosF*(Radians: float32): float32 {.inline.} =
    var res: float32 = arccos(Radians)
    return res

  proc aTanF*(Radians: float32): float32 {.inline.} =
    var res: float32 = arctan(Radians)
    return res

  proc aTan2F*(l: float32; r: float32): float32 {.inline.} =
    var res: float32 = arctan2(l, r)
    return res

  proc expF*(f: float32): float32 {.inline.} =
    var res: float32 = exp(f)
    return res

  proc logF*(f: float32): float32 {.inline.} =
    var res: float32 = ln(f)
    return res

  proc squareRootF*(f: float32): float32 {.inline.} =
    var res: float32
    var i: m128 = mm_set_ss(f)
    var o: m128 = mm_sqrt_ss(i)
    res = mm_cvtss_f32(o)
    return res

  proc rSquareRootF*(f: float32): float32 {.inline.} =
    var res: float32
    var i: m128 = mm_set_ss(f)
    var o: m128 = mm_rsqrt_ss(i)
    res = mm_cvtss_f32(o)
    return res

  proc power*(Base: float32; Exponent: cint): float32 {.importc: "HMM_Power".}
  proc powerF*(Base: float32; Exponent: float32): float32 {.inline.} =
    var res: float32 = exp(Exponent * ln(Base))
    return res

  proc toRadians*(Degrees: float32): float32 {.inline.} =
    var res: float32 = Degrees * (3.14159265359 / 180.0)
    return res

  proc lerp*(A: float32; Time: float32; B: float32): float32 {.inline.} =
    var res: float32 = (1.0 - Time) * A + Time * B
    return res

  proc clamp*(Min: float32; Value: float32; Max: float32): float32 {.inline.} =
    var res: float32 = Value
    if res < Min:
      res = Min
    if res > Max:
      res = Max
    return res

  proc vec2*(x: float32; y: float32): Vec2 {.inline.} =
    var res: Vec2
    res.ano_handmademath_pp_6.x = x
    res.ano_handmademath_pp_6.y = y
    return res

  proc ivec2i*(x, y: int32): IVec2 {.inline.} =
    result.xy.x = x
    result.xy.y = y

  proc vec2i*(x: cint; y: cint): Vec2 {.inline.} =
    var res: Vec2
    res.ano_handmademath_pp_6.x = cast[float32](x)
    res.ano_handmademath_pp_6.y = cast[float32](y)
    return res

  proc vec3*(x: float32; y: float32; z: float32): Vec3 {.inline.} =
    var res: Vec3
    res.ano_handmademath_pp_32.x = x
    res.ano_handmademath_pp_32.y = y
    res.ano_handmademath_pp_32.z = z
    return res

  proc vec3i*(x: cint; y: cint; z: cint): Vec3 {.inline.} =
    var res: Vec3
    res.ano_handmademath_pp_32.x = cast[float32](x)
    res.ano_handmademath_pp_32.y = cast[float32](y)
    res.ano_handmademath_pp_32.z = cast[float32](z)
    return res

  proc vec4*(x: float32; y: float32; z: float32; w: float32): Vec4 {.inline.} =
    var res: Vec4
    res.internalElementsSSE = mm_setr_ps(x, y, z, w)
    return res

  proc vec4*(xyz: Vec3; w: float32): Vec4 {.inline.} =
    var res: Vec4
    res.internalElementsSSE = mm_setr_ps(xyz.x, xyz.y, xyz.z, w)
    return res

  proc vec4i*(x: cint; y: cint; z: cint; w: cint): Vec4 {.inline.} =
    var res: Vec4
    res.internalElementsSSE = mm_setr_ps(cast[float32](x), cast[float32](y),
        cast[float32](z), cast[float32](w))
    return res

  proc vec4v*(v: Vec3; w: float32): Vec4 {.inline.} =
    var res: Vec4
    res.internalElementsSSE = mm_setr_ps(v.ano_handmademath_pp_32.x, v.ano_handmademath_pp_32.y, v.ano_handmademath_pp_32.z, w)
    return res

  proc addVec2*(l: Vec2; r: Vec2): Vec2 {.inline.} =
    var res: Vec2
    res.ano_handmademath_pp_6.x = l.ano_handmademath_pp_6.x + r.ano_handmademath_pp_6.x
    res.ano_handmademath_pp_6.y = l.ano_handmademath_pp_6.y + r.ano_handmademath_pp_6.y
    return res

  proc addVec3*(l: Vec3; r: Vec3): Vec3 {.inline.} =
    var res: Vec3
    res.ano_handmademath_pp_32.x = l.ano_handmademath_pp_32.x + r.ano_handmademath_pp_32.x
    res.ano_handmademath_pp_32.y = l.ano_handmademath_pp_32.y + r.ano_handmademath_pp_32.y
    res.ano_handmademath_pp_32.z = l.ano_handmademath_pp_32.z + r.ano_handmademath_pp_32.z
    return res

  proc addVec4*(l: Vec4; r: Vec4): Vec4 {.inline.} =
    var res: Vec4
    res.internalElementsSSE = mm_add_ps(l.internalElementsSSE,
                                          r.internalElementsSSE)
    return res

  proc subtractVec2*(l: Vec2; r: Vec2): Vec2 {.inline.} =
    var res: Vec2
    res.ano_handmademath_pp_6.x = l.ano_handmademath_pp_6.x - r.ano_handmademath_pp_6.x
    res.ano_handmademath_pp_6.y = l.ano_handmademath_pp_6.y - r.ano_handmademath_pp_6.y
    return res

  proc subtractVec3*(l: Vec3; r: Vec3): Vec3 {.inline.} =
    var res: Vec3
    res.ano_handmademath_pp_32.x = l.ano_handmademath_pp_32.x - r.ano_handmademath_pp_32.x
    res.ano_handmademath_pp_32.y = l.ano_handmademath_pp_32.y - r.ano_handmademath_pp_32.y
    res.ano_handmademath_pp_32.z = l.ano_handmademath_pp_32.z - r.ano_handmademath_pp_32.z
    return res

  proc subtractVec4*(l: Vec4; r: Vec4): Vec4 {.inline.} =
    var res: Vec4
    res.internalElementsSSE = mm_sub_ps(l.internalElementsSSE,
                                          r.internalElementsSSE)
    return res

  proc multiplyVec2*(l: Vec2; r: Vec2): Vec2 {.inline.} =
    var res: Vec2
    res.ano_handmademath_pp_6.x = l.ano_handmademath_pp_6.x * r.ano_handmademath_pp_6.x
    res.ano_handmademath_pp_6.y = l.ano_handmademath_pp_6.y * r.ano_handmademath_pp_6.y
    return res

  proc multiplyVec2f*(l: Vec2; r: float32): Vec2 {.inline.} =
    var res: Vec2
    res.ano_handmademath_pp_6.x = l.ano_handmademath_pp_6.x * r
    res.ano_handmademath_pp_6.y = l.ano_handmademath_pp_6.y * r
    return res

  proc multiplyVec3*(l: Vec3; r: Vec3): Vec3 {.inline.} =
    var res: Vec3
    res.x = l.x * r.x
    res.y = l.y * r.y
    res.z = l.z * r.z
    return res

  proc multiplyVec3f*(l: Vec3; r: float32): Vec3 {.inline.} =
    var res: Vec3
    res.x = l.x * r
    res.y = l.y * r
    res.z = l.z * r
    return res

  proc multiplyVec4*(l: Vec4; r: Vec4): Vec4 {.inline.} =
    var res: Vec4
    res.internalElementsSSE = mm_mul_ps(l.internalElementsSSE,
                                          r.internalElementsSSE)
    return res

  proc multiplyVec4f*(l: Vec4; r: float32): Vec4 {.inline.} =
    var res: Vec4
    var Scalar: m128 = mm_set_ps1(r)
    res.internalElementsSSE = mm_mul_ps(l.internalElementsSSE, Scalar)
    return res

  proc divideVec2*(l: Vec2; r: Vec2): Vec2 {.inline.} =
    var res: Vec2
    res.x = l.x / r.x
    res.y = l.y / r.y
    return res

  proc divideVec2f*(l: Vec2; r: float32): Vec2 {.inline.} =
    var res: Vec2
    res.x = l.x / r
    res.y = l.y / r
    return res

  proc divideVec3*(l: Vec3; r: Vec3): Vec3 {.inline.} =
    var res: Vec3
    res.x = l.x / r.x
    res.y = l.y / r.y
    res.z = l.z / r.z
    return res

  proc divideVec3f*(l: Vec3; r: float32): Vec3 {.inline.} =
    var res: Vec3
    res.x = l.x / r
    res.y = l.y / r
    res.z = l.z / r
    return res

  proc divideVec4*(l: Vec4; r: Vec4): Vec4 {.inline.} =
    var res: Vec4
    res.internalElementsSSE = mm_div_ps(l.internalElementsSSE,
                                          r.internalElementsSSE)
    return res

  proc divideVec4f*(l: Vec4; r: float32): Vec4 {.inline.} =
    var res: Vec4
    var Scalar: m128 = mm_set_ps1(r)
    res.internalElementsSSE = mm_div_ps(l.internalElementsSSE, Scalar)
    return res

  proc equalsVec2*(l: Vec2; r: Vec2): int32 {.inline.} =
    var res: int32 = int32(l.x == r.x and l.y == r.y)
    return res

  proc equalsVec3*(l: Vec3; r: Vec3): int32 {.inline.} =
    var res: int32 = int32(l.x == r.x and l.y == r.y and l.z == r.z)
    return res

  proc equalsVec4*(l: Vec4; r: Vec4): int32 {.inline.} =
    var res: int32 = int32(l.x == r.x and l.y == r.y and l.z == r.z and
        l.w == r.w)
    return res

  proc dotVec2*(VecOne: Vec2; VecTwo: Vec2): float32 {.inline.} =
    var res: float32 = (VecOne.x * VecTwo.x) + (VecOne.y * VecTwo.y)
    return res

  proc dotVec3*(VecOne: Vec3; VecTwo: Vec3): float32 {.inline.} =
    var res: float32 = (VecOne.x * VecTwo.x) + (VecOne.y * VecTwo.y) +
        (VecOne.z * VecTwo.z)
    return res

  proc dotVec4*(VecOne: Vec4; VecTwo: Vec4): float32 {.inline.} =
    var res: float32
    var SSEResultOne: m128 = mm_mul_ps(VecOne.internalElementsSSE,
                                      VecTwo.internalElementsSSE)
    var SSEResultTwo: m128 = mm_shuffle_ps(SSEResultOne, SSEResultOne, (
        ((2) shl 6) or ((3) shl 4) or ((0) shl 2) or ((1))))
    SSEResultOne = mm_add_ps(SSEResultOne, SSEResultTwo)
    SSEResultTwo = mm_shuffle_ps(SSEResultOne, SSEResultOne, (
        ((0) shl 6) or ((1) shl 4) or ((2) shl 2) or ((3))))
    SSEResultOne = mm_add_ps(SSEResultOne, SSEResultTwo)
    mm_store_ss(addr(res), SSEResultOne)
    return res

  proc cross*(VecOne: Vec3; VecTwo: Vec3): Vec3 {.inline.} =
    var res: Vec3
    res.x = (VecOne.y * VecTwo.z) - (VecOne.z * VecTwo.y)
    res.y = (VecOne.z * VecTwo.x) - (VecOne.x * VecTwo.z)
    res.z = (VecOne.x * VecTwo.y) - (VecOne.y * VecTwo.x)
    return res

  proc min*(a, b: Vec3): Vec3 =
    result = vec3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

  proc max*(a, b: Vec3): Vec3 =
    result = vec3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))

  proc lengthSquaredVec2*(A: Vec2): float32 {.inline.} =
    var res: float32 = dotVec2(A, A)
    return res

  proc lengthSquaredVec3*(A: Vec3): float32 {.inline.} =
    var res: float32 = dotVec3(A, A)
    return res

  proc lengthSquaredVec4*(A: Vec4): float32 {.inline.} =
    var res: float32 = dotVec4(A, A)
    return res

  proc lengthVec2*(A: Vec2): float32 {.inline.} =
    var res: float32 = squareRootF(lengthSquaredVec2(A))
    return res

  proc lengthVec3*(A: Vec3): float32 {.inline.} =
    var res: float32 = squareRootF(lengthSquaredVec3(A))
    return res

  proc lengthVec4*(A: Vec4): float32 {.inline.} =
    var res: float32 = squareRootF(lengthSquaredVec4(A))
    return res

  proc normalizeVec2*(A: Vec2): Vec2 {.inline.} =
    var res: Vec2
    var VectorLength: float32 = lengthVec2(A)
    if VectorLength != 0.0:
      res.x = A.x * (1.0 / VectorLength)
      res.y = A.y * (1.0 / VectorLength)
    return res

  proc normalizeVec3*(A: Vec3): Vec3 {.inline.} =
    var res: Vec3
    var VectorLength: float32 = lengthVec3(A)
    if VectorLength != 0.0:
      res.x = A.x * (1.0 / VectorLength)
      res.y = A.y * (1.0 / VectorLength)
      res.z = A.z * (1.0 / VectorLength)
    return res

  proc normalizeVec4*(A: Vec4): Vec4 {.inline.} =
    var res: Vec4
    var VectorLength: float32 = lengthVec4(A)
    if VectorLength != 0.0:
      var Multiplier: float32 = 1.0 / VectorLength
      var SSEMultiplier: m128 = mm_set_ps1(Multiplier)
      res.internalElementsSSE = mm_mul_ps(A.internalElementsSSE, SSEMultiplier)
    return res

  proc fastNormalizeVec2*(A: Vec2): Vec2 {.inline.} =
    return multiplyVec2f(A, rSquareRootF(dotVec2(A, A)))

  proc fastNormalizeVec3*(A: Vec3): Vec3 {.inline.} =
    return multiplyVec3f(A, rSquareRootF(dotVec3(A, A)))

  proc fastNormalizeVec4*(A: Vec4): Vec4 {.inline.} =
    return multiplyVec4f(A, rSquareRootF(dotVec4(A, A)))

  proc linearCombineSSE*(l: m128; r: Mat4): m128 {.inline.} =
    var res: m128
    res = mm_mul_ps(mm_shuffle_ps(l, l, 0x00000000), r.columns[0])
    res = mm_add_ps(res, mm_mul_ps(mm_shuffle_ps(l, l, 0x00000055),
                                        r.columns[1]))
    res = mm_add_ps(res, mm_mul_ps(mm_shuffle_ps(l, l, 0x000000AA),
                                        r.columns[2]))
    res = mm_add_ps(res, mm_mul_ps(mm_shuffle_ps(l, l, 0x000000FF),
                                        r.columns[3]))
    return res

  proc mat4*(): Mat4 {.inline.} =
    var res: Mat4
    return res

  proc mat4d*(Diagonal: float32): Mat4 {.inline.} =
    var res: Mat4 = mat4()
    res.elements[0][0] = Diagonal
    res.elements[1][1] = Diagonal
    res.elements[2][2] = Diagonal
    res.elements[3][3] = Diagonal
    return res

  proc transpose*(Matrix: Mat4): Mat4 {.inline.} =
    var res: Mat4 = Matrix
    var
      tmp3: m128
      tmp2: m128
      tmp1: m128
      tmp0: m128
    tmp0 = mm_shuffle_ps((res.columns[0]), (res.columns[1]), 0x00000044)
    tmp2 = mm_shuffle_ps((res.columns[0]), (res.columns[1]), 0x000000EE)
    tmp1 = mm_shuffle_ps((res.columns[2]), (res.columns[3]), 0x00000044)
    tmp3 = mm_shuffle_ps((res.columns[2]), (res.columns[3]), 0x000000EE)
    (res.columns[0]) = mm_shuffle_ps(tmp0, tmp1, 0x00000088)
    (res.columns[1]) = mm_shuffle_ps(tmp0, tmp1, 0x000000DD)
    (res.columns[2]) = mm_shuffle_ps(tmp2, tmp3, 0x00000088)
    (res.columns[3]) = mm_shuffle_ps(tmp2, tmp3, 0x000000DD)

    return res

  proc invert*(m: Mat4): Mat4 {.inline.} =
    var
      det: float32
      inv: Mat4

    inv.raw[0] = m.raw[5]  * m.raw[10] * m.raw[15] -
      m.raw[5]  * m.raw[11] * m.raw[14] -
      m.raw[9]  * m.raw[6]  * m.raw[15] +
      m.raw[9]  * m.raw[7]  * m.raw[14] +
      m.raw[13] * m.raw[6]  * m.raw[11] -
      m.raw[13] * m.raw[7]  * m.raw[10]

    inv.raw[4] = -m.raw[4]  * m.raw[10] * m.raw[15] +
      m.raw[4]  * m.raw[11] * m.raw[14] +
      m.raw[8]  * m.raw[6]  * m.raw[15] -
      m.raw[8]  * m.raw[7]  * m.raw[14] -
      m.raw[12] * m.raw[6]  * m.raw[11] +
      m.raw[12] * m.raw[7]  * m.raw[10]

    inv.raw[8] = m.raw[4]  * m.raw[9] * m.raw[15] -
      m.raw[4]  * m.raw[11] * m.raw[13] -
      m.raw[8]  * m.raw[5] * m.raw[15] +
      m.raw[8]  * m.raw[7] * m.raw[13] +
      m.raw[12] * m.raw[5] * m.raw[11] -
      m.raw[12] * m.raw[7] * m.raw[9]

    inv.raw[12] = -m.raw[4]  * m.raw[9] * m.raw[14] +
      m.raw[4]  * m.raw[10] * m.raw[13] +
      m.raw[8]  * m.raw[5] * m.raw[14] -
      m.raw[8]  * m.raw[6] * m.raw[13] -
      m.raw[12] * m.raw[5] * m.raw[10] +
      m.raw[12] * m.raw[6] * m.raw[9]

    inv.raw[1] = -m.raw[1]  * m.raw[10] * m.raw[15] +
      m.raw[1]  * m.raw[11] * m.raw[14] +
      m.raw[9]  * m.raw[2] * m.raw[15] -
      m.raw[9]  * m.raw[3] * m.raw[14] -
      m.raw[13] * m.raw[2] * m.raw[11] +
      m.raw[13] * m.raw[3] * m.raw[10]

    inv.raw[5] = m.raw[0]  * m.raw[10] * m.raw[15] -
      m.raw[0]  * m.raw[11] * m.raw[14] -
      m.raw[8]  * m.raw[2] * m.raw[15] +
      m.raw[8]  * m.raw[3] * m.raw[14] +
      m.raw[12] * m.raw[2] * m.raw[11] -
      m.raw[12] * m.raw[3] * m.raw[10]

    inv.raw[9] = -m.raw[0]  * m.raw[9] * m.raw[15] +
      m.raw[0]  * m.raw[11] * m.raw[13] +
      m.raw[8]  * m.raw[1] * m.raw[15] -
      m.raw[8]  * m.raw[3] * m.raw[13] -
      m.raw[12] * m.raw[1] * m.raw[11] +
      m.raw[12] * m.raw[3] * m.raw[9]

    inv.raw[13] = m.raw[0]  * m.raw[9] * m.raw[14] -
      m.raw[0]  * m.raw[10] * m.raw[13] -
      m.raw[8]  * m.raw[1] * m.raw[14] +
      m.raw[8]  * m.raw[2] * m.raw[13] +
      m.raw[12] * m.raw[1] * m.raw[10] -
      m.raw[12] * m.raw[2] * m.raw[9]

    inv.raw[2] = m.raw[1]  * m.raw[6] * m.raw[15] -
      m.raw[1]  * m.raw[7] * m.raw[14] -
      m.raw[5]  * m.raw[2] * m.raw[15] +
      m.raw[5]  * m.raw[3] * m.raw[14] +
      m.raw[13] * m.raw[2] * m.raw[7] -
      m.raw[13] * m.raw[3] * m.raw[6]

    inv.raw[6] = -m.raw[0]  * m.raw[6] * m.raw[15] +
      m.raw[0]  * m.raw[7] * m.raw[14] +
      m.raw[4]  * m.raw[2] * m.raw[15] -
      m.raw[4]  * m.raw[3] * m.raw[14] -
      m.raw[12] * m.raw[2] * m.raw[7] +
      m.raw[12] * m.raw[3] * m.raw[6]

    inv.raw[10] = m.raw[0]  * m.raw[5] * m.raw[15] -
      m.raw[0]  * m.raw[7] * m.raw[13] -
      m.raw[4]  * m.raw[1] * m.raw[15] +
      m.raw[4]  * m.raw[3] * m.raw[13] +
      m.raw[12] * m.raw[1] * m.raw[7] -
      m.raw[12] * m.raw[3] * m.raw[5]

    inv.raw[14] = -m.raw[0]  * m.raw[5] * m.raw[14] +
      m.raw[0]  * m.raw[6] * m.raw[13] +
      m.raw[4]  * m.raw[1] * m.raw[14] -
      m.raw[4]  * m.raw[2] * m.raw[13] -
      m.raw[12] * m.raw[1] * m.raw[6] +
      m.raw[12] * m.raw[2] * m.raw[5]

    inv.raw[3] = -m.raw[1] * m.raw[6] * m.raw[11] +
      m.raw[1] * m.raw[7] * m.raw[10] +
      m.raw[5] * m.raw[2] * m.raw[11] -
      m.raw[5] * m.raw[3] * m.raw[10] -
      m.raw[9] * m.raw[2] * m.raw[7] +
      m.raw[9] * m.raw[3] * m.raw[6]

    inv.raw[7] = m.raw[0] * m.raw[6] * m.raw[11] -
      m.raw[0] * m.raw[7] * m.raw[10] -
      m.raw[4] * m.raw[2] * m.raw[11] +
      m.raw[4] * m.raw[3] * m.raw[10] +
      m.raw[8] * m.raw[2] * m.raw[7] -
      m.raw[8] * m.raw[3] * m.raw[6]

    inv.raw[11] = -m.raw[0] * m.raw[5] * m.raw[11] +
      m.raw[0] * m.raw[7] * m.raw[9] +
      m.raw[4] * m.raw[1] * m.raw[11] -
      m.raw[4] * m.raw[3] * m.raw[9] -
      m.raw[8] * m.raw[1] * m.raw[7] +
      m.raw[8] * m.raw[3] * m.raw[5]

    inv.raw[15] = m.raw[0] * m.raw[5] * m.raw[10] -
      m.raw[0] * m.raw[6] * m.raw[9] -
      m.raw[4] * m.raw[1] * m.raw[10] +
      m.raw[4] * m.raw[2] * m.raw[9] +
      m.raw[8] * m.raw[1] * m.raw[6] -
      m.raw[8] * m.raw[2] * m.raw[5]

    det = m.raw[0] * inv.raw[0] + m.raw[1] * inv.raw[4] +
      m.raw[2] * inv.raw[8] + m.raw[3] * inv.raw[12]

    if det == 0:
      result = mat4d(0.0'f32)

    det = 1.0'f32 / det

    for i in 0 ..< 16:
      result.raw[i] = inv.raw[i] * det

  proc addMat4*(l: Mat4; r: Mat4): Mat4 {.inline.} =
    var res: Mat4
    res.columns[0] = mm_add_ps(l.columns[0], r.columns[0])
    res.columns[1] = mm_add_ps(l.columns[1], r.columns[1])
    res.columns[2] = mm_add_ps(l.columns[2], r.columns[2])
    res.columns[3] = mm_add_ps(l.columns[3], r.columns[3])
    return res

  proc subtractMat4*(l: Mat4; r: Mat4): Mat4 {.inline.} =
    var res: Mat4
    res.columns[0] = mm_sub_ps(l.columns[0], r.columns[0])
    res.columns[1] = mm_sub_ps(l.columns[1], r.columns[1])
    res.columns[2] = mm_sub_ps(l.columns[2], r.columns[2])
    res.columns[3] = mm_sub_ps(l.columns[3], r.columns[3])
    return res

  proc multiplyMat4*(l: Mat4; r: Mat4): Mat4 {.inline.} =
    result.columns[0] = linearCombineSSE(r.columns[0], l);
    result.columns[1] = linearCombineSSE(r.columns[1], l);
    result.columns[2] = linearCombineSSE(r.columns[2], l);
    result.columns[3] = linearCombineSSE(r.columns[3], l);

  proc multiplyMat4f*(Matrix: Mat4; Scalar: float32): Mat4 {.inline.} =
    var res: Mat4
    var SSEScalar: m128 = mm_set_ps1(Scalar)
    res.columns[0] = mm_mul_ps(Matrix.columns[0], SSEScalar)
    res.columns[1] = mm_mul_ps(Matrix.columns[1], SSEScalar)
    res.columns[2] = mm_mul_ps(Matrix.columns[2], SSEScalar)
    res.columns[3] = mm_mul_ps(Matrix.columns[3], SSEScalar)
    return res

  proc multiplyMat4ByVec4*(m: Mat4; v: Vec4): Vec4 {.inline.} =
    result.internalElementsSSE = linearCombineSSE(v.internalElementsSSE, m)

  proc divideMat4f*(Matrix: Mat4; Scalar: float32): Mat4 {.inline.} =
    var res: Mat4
    var SSEScalar: m128 = mm_set_ps1(Scalar)
    res.columns[0] = mm_div_ps(Matrix.columns[0], SSEScalar)
    res.columns[1] = mm_div_ps(Matrix.columns[1], SSEScalar)
    res.columns[2] = mm_div_ps(Matrix.columns[2], SSEScalar)
    res.columns[3] = mm_div_ps(Matrix.columns[3], SSEScalar)
    return res

  proc orthographic*(l: float32; r: float32; Bottom: float32; Top: float32;
                        Near: float32; Far: float32): Mat4 {.inline.} =
    var res: Mat4 = mat4()
    res.elements[0][0] = 2.0 / (r - l)
    res.elements[1][1] = 2.0 / (Top - Bottom)
    res.elements[2][2] = 2.0 / (Near - Far)
    res.elements[3][3] = 1.0
    res.elements[3][0] = (l + r) / (l - r)
    res.elements[3][1] = (Bottom + Top) / (Bottom - Top)
    res.elements[3][2] = (Far + Near) / (Near - Far)
    return res

  proc perspective*(FOV: float32; AspectRatio: float32; Near: float32; Far: float32): Mat4 {.
      inline.} =
    var res: Mat4 = mat4()
    var Cotangent: float32 = 1.0 / tanF(FOV * (3.14159265359 / 360.0))
    res.elements[0][0] = Cotangent / AspectRatio
    res.elements[1][1] = Cotangent
    res.elements[2][3] = -1.0
    res.elements[2][2] = (Near + Far) / (Near - Far)
    res.elements[3][2] = (2.0 * Near * Far) / (Near - Far)
    res.elements[3][3] = 0.0
    return res

  proc translate*(Translation: Vec3): Mat4 {.inline.} =
    var res: Mat4 = mat4d(1.0)
    res.elements[3][0] = Translation.x
    res.elements[3][1] = Translation.y
    res.elements[3][2] = Translation.z
    return res

  proc rotate*(angle: float32; axis: Vec3): Mat4 {.inline.} =
    result = mat4d(1.0'f32)

    let
      normAxis = normalizeVec3(axis)
      sinTheta = sinF(degToRad(angle))
      cosTheta = cosF(degToRad(angle))
      cosValue = 1.0'f32 - cosTheta

    result.elements[0][0] = (axis.x * axis.x * cosValue) + cosTheta;
    result.elements[0][1] = (axis.x * axis.y * cosValue) + (axis.z * sinTheta);
    result.elements[0][2] = (axis.x * axis.z * cosValue) - (axis.y * sinTheta);

    result.elements[1][0] = (axis.y * axis.x * cosValue) - (axis.z * sinTheta);
    result.elements[1][1] = (axis.y * axis.y * cosValue) + cosTheta;
    result.elements[1][2] = (axis.y * axis.z * cosValue) + (axis.x * sinTheta);

    result.elements[2][0] = (axis.z * axis.x * cosValue) + (axis.y * sinTheta);
    result.elements[2][1] = (axis.z * axis.y * cosValue) - (axis.x * sinTheta);
    result.elements[2][2] = (axis.z * axis.z * cosValue) + cosTheta;

  proc scale*(Scale: Vec3): Mat4 {.inline.} =
    var res: Mat4 = mat4d(1.0)
    res.elements[0][0] = Scale.x
    res.elements[1][1] = Scale.y
    res.elements[2][2] = Scale.z
    return res

  proc lookAt*(eye: Vec3; center: Vec3; up: Vec3): Mat4 {.inline.} =
    let
      f = normalizeVec3(subtractVec3(center, eye))
      s = normalizeVec3(cross(f, up))
      u = cross(s, f)

    result.elements[0][0] = s.x
    result.elements[0][1] = u.x
    result.elements[0][2] = -f.x
    result.elements[0][3] = 0.0'f32

    result.elements[1][0] = s.y
    result.elements[1][1] = u.y
    result.elements[1][2] = -f.y
    result.elements[1][3] = 0.0'f32

    result.elements[2][0] = s.z
    result.elements[2][1] = u.z
    result.elements[2][2] = -f.z
    result.elements[2][3] = 0.0'f32

    result.elements[3][0] = -dotVec3(s, eye)
    result.elements[3][1] = -dotVec3(u, eye)
    result.elements[3][2] = dotVec3(f, eye)
    result.elements[3][3] = 1.0'f32

  proc quaternion*(x: float32; y: float32; z: float32; w: float32): Quaternion {.inline.} =
    var res: Quaternion
    res.internalElementsSSE = mm_setr_ps(x, y, z, w)
    return res

  proc quaternionV4*(v: Vec4): Quaternion {.inline.} =
    var res: Quaternion
    res.internalElementsSSE = v.internalElementsSSE
    return res

  proc addQuaternion*(l: Quaternion; r: Quaternion): Quaternion {.
      inline.} =
    var res: Quaternion
    res.internalElementsSSE = mm_add_ps(l.internalElementsSSE,
                                          r.internalElementsSSE)
    return res

  proc subtractQuaternion*(l: Quaternion; r: Quaternion): Quaternion {.
      inline.} =
    var res: Quaternion
    res.internalElementsSSE = mm_sub_ps(l.internalElementsSSE,
                                          r.internalElementsSSE)
    return res

  proc multiplyQuaternion*(l: Quaternion; r: Quaternion): Quaternion {.
      inline.} =
    var res: Quaternion
    var SSEResultOne: m128 = mm_xor_ps(mm_shuffle_ps(l.internalElementsSSE,
        l.internalElementsSSE,
        (((0) shl 6) or ((0) shl 4) or ((0) shl 2) or ((0)))),
                                      mm_setr_ps(0.0, -0.0, 0.0, -0.0))
    var SSEResultTwo: m128 = mm_shuffle_ps(r.internalElementsSSE,
                                          r.internalElementsSSE, (
        ((0) shl 6) or ((1) shl 4) or ((2) shl 2) or ((3))))
    var SSEResultThree: m128 = mm_mul_ps(SSEResultTwo, SSEResultOne)
    SSEResultOne = mm_xor_ps(mm_shuffle_ps(l.internalElementsSSE,
        l.internalElementsSSE,
        (((1) shl 6) or ((1) shl 4) or ((1) shl 2) or ((1)))),
                            mm_setr_ps(0.0, 0.0, -0.0, -0.0))
    SSEResultTwo = mm_shuffle_ps(r.internalElementsSSE,
                                r.internalElementsSSE, (
        ((1) shl 6) or ((0) shl 4) or ((3) shl 2) or ((2))))
    SSEResultThree = mm_add_ps(SSEResultThree,
                              mm_mul_ps(SSEResultTwo, SSEResultOne))
    SSEResultOne = mm_xor_ps(mm_shuffle_ps(l.internalElementsSSE,
        l.internalElementsSSE,
        (((2) shl 6) or ((2) shl 4) or ((2) shl 2) or ((2)))),
                            mm_setr_ps(-0.0, 0.0, 0.0, -0.0))
    SSEResultTwo = mm_shuffle_ps(r.internalElementsSSE,
                                r.internalElementsSSE, (
        ((2) shl 6) or ((3) shl 4) or ((0) shl 2) or ((1))))
    SSEResultThree = mm_add_ps(SSEResultThree,
                              mm_mul_ps(SSEResultTwo, SSEResultOne))
    SSEResultOne = mm_shuffle_ps(l.internalElementsSSE, l.internalElementsSSE, (
        ((3) shl 6) or ((3) shl 4) or ((3) shl 2) or ((3))))
    SSEResultTwo = mm_shuffle_ps(r.internalElementsSSE,
                                r.internalElementsSSE, (
        ((3) shl 6) or ((2) shl 4) or ((1) shl 2) or ((0))))
    res.internalElementsSSE = mm_add_ps(SSEResultThree,
                                          mm_mul_ps(SSEResultTwo, SSEResultOne))
    return res

  proc multiplyQuaternionF*(l: Quaternion; Multiplicative: float32): Quaternion {.
      inline.} =
    var res: Quaternion
    var Scalar: m128 = mm_set_ps1(Multiplicative)
    res.internalElementsSSE = mm_mul_ps(l.internalElementsSSE, Scalar)
    return res

  proc divideQuaternionF*(l: Quaternion; Dividend: float32): Quaternion {.
      inline.} =
    var res: Quaternion
    var Scalar: m128 = mm_set_ps1(Dividend)
    res.internalElementsSSE = mm_div_ps(l.internalElementsSSE, Scalar)
    return res

  proc inverseQuaternion*(l: Quaternion): Quaternion {.importc: "HMM_InverseQuaternion".}
  proc dotQuaternion*(l: Quaternion; r: Quaternion): float32 {.inline.} =
    var res: float32
    var SSEResultOne: m128 = mm_mul_ps(l.internalElementsSSE,
                                      r.internalElementsSSE)
    var SSEResultTwo: m128 = mm_shuffle_ps(SSEResultOne, SSEResultOne, (
        ((2) shl 6) or ((3) shl 4) or ((0) shl 2) or ((1))))
    SSEResultOne = mm_add_ps(SSEResultOne, SSEResultTwo)
    SSEResultTwo = mm_shuffle_ps(SSEResultOne, SSEResultOne, (
        ((0) shl 6) or ((1) shl 4) or ((2) shl 2) or ((3))))
    SSEResultOne = mm_add_ps(SSEResultOne, SSEResultTwo)
    mm_store_ss(addr(res), SSEResultOne)
    return res

  proc normalizeQuaternion*(l: Quaternion): Quaternion {.inline.} =
    var res: Quaternion
    var Length: float32 = squareRootF(dotQuaternion(l, l))
    res = divideQuaternionF(l, Length)
    return res

  proc nLerp*(l: Quaternion; Time: float32; r: Quaternion): Quaternion {.
      inline.} =
    var res: Quaternion
    var ScalarLeft: m128 = mm_set_ps1(1.0 - Time)
    var ScalarRight: m128 = mm_set_ps1(Time)
    var SSEResultOne: m128 = mm_mul_ps(l.internalElementsSSE, ScalarLeft)
    var SSEResultTwo: m128 = mm_mul_ps(r.internalElementsSSE, ScalarRight)
    res.internalElementsSSE = mm_add_ps(SSEResultOne, SSEResultTwo)
    res = normalizeQuaternion(res)
    return res

  proc slerp*(l: Quaternion; Time: float32; r: Quaternion): Quaternion {.importc: "HMM_Slerp".}

  proc quaternionToMat4*(l: Quaternion): Mat4 {.inline.} =
    let normalizedQuat = normalizeQuaternion(l)

    var
      xx, yy, zz, xy, xz, yz, wx, wy, wz: float32

    xx = normalizedQuat.x * normalizedQuat.x
    yy = normalizedQuat.y * normalizedQuat.y
    zz = normalizedQuat.z * normalizedQuat.z
    xy = normalizedQuat.x * normalizedQuat.y
    xz = normalizedQuat.x * normalizedQuat.z
    yz = normalizedQuat.y * normalizedQuat.z
    wx = normalizedQuat.w * normalizedQuat.x
    wy = normalizedQuat.w * normalizedQuat.y
    wz = normalizedQuat.w * normalizedQuat.z

    result.elements[0][0] = 1.0'f32 - 2.0'f32 * (yy + zz)
    result.elements[0][1] = 2.0'f32 * (xy + wz)
    result.elements[0][2] = 2.0'f32 * (xz - wy)
    result.elements[0][3] = 0.0'f32

    result.elements[1][0] = 2.0'f32 * (xy - wz)
    result.elements[1][1] = 1.0'f32 - 2.0'f32 * (xx + zz)
    result.elements[1][2] = 2.0'f32 * (yz + wx)
    result.elements[1][3] = 0.0'f32

    result.elements[2][0] = 2.0'f32 * (xz + wy)
    result.elements[2][1] = 2.0'f32 * (yz - wx)
    result.elements[2][2] = 1.0'f32 - 2.0'f32 * (xx + yy)
    result.elements[2][3] = 0.0'f32

    result.elements[3][0] = 0.0'f32
    result.elements[3][1] = 0.0'f32
    result.elements[3][2] = 0.0'f32
    result.elements[3][3] = 1.0'f32

  proc mat4ToQuaternion*(m: Mat4): Quaternion {.inline} =
    var t: float32

    if m.elements[2][2] < 0.0'f32:
      if m.elements[0][0] > m.elements[1][1]:
        t = 1 + m.elements[0][0] - m.elements[1][1] - m.elements[2][2]
        result = quaternion(
          t,
          m.elements[0][1] + m.elements[1][0],
          m.elements[2][0] + m.elements[0][2],
          m.elements[1][2] - m.elements[2][1]
        )
      else:
        t = 1 - m.elements[0][0] + m.elements[1][1] - m.elements[2][2]
        result = quaternion(
          m.elements[0][1] + m.elements[1][0],
          t,
          m.elements[1][2] + m.elements[2][1],
          m.elements[2][0] - m.elements[0][2]
        )
    else:
      if m.elements[0][0] < -m.elements[1][1]:
        t = 1 - m.elements[0][0] - m.elements[1][1] + m.elements[2][2]
        result = quaternion(
          m.elements[2][0] + m.elements[0][2],
          m.elements[1][2] + m.elements[2][1],
          t,
          m.elements[0][1] - m.elements[1][0]
        )
      else:
        t = 1 + m.elements[0][0] + m.elements[1][1] + m.elements[2][2]
        result = quaternion(
          m.elements[1][2] - m.elements[2][1],
          m.elements[2][0] - m.elements[0][2],
          m.elements[0][1] - m.elements[1][0],
          t
        )

    result = multiplyQuaternionF(result, 0.5'f32 / squareRootF(t))

  proc quaternionFromAxisAngle*(axis: Vec3; angleOfRotation: float32): Quaternion {.inline.} =
    let
      normalizedAxis = normalizeVec3(axis)
      sinRot = sinF(angleOfRotation / 2.0'f32)

    result.xyz = multiplyVec3f(normalizedAxis, sinRot)

else:
  when defined(clang):
    {.pragma: arm64_type, byCopy, header:"<arm_neon.h>".}
    {.pragma: arm64, noDecl, header:"<arm_neon.h>".}

  type
    float32x4_t*{.importc: "__attribute__((neon_vector_type(4))) float32_t", byCopy.} = object

    INNER_C_STRUCT_HandmadeMath_8* {.bycopy.} = object
      x*: cfloat
      y*: cfloat

    INNER_C_STRUCT_HandmadeMath_10* {.bycopy.} = object
      U*: cfloat
      V*: cfloat

    INNER_C_STRUCT_HandmadeMath_12* {.bycopy.} = object
      Left*: cfloat
      Right*: cfloat

    INNER_C_STRUCT_HandmadeMath_14* {.bycopy.} = object
      Width*: cfloat
      Height*: cfloat

    INNER_C_STRUCT_HandmadeMath_30* {.bycopy.} = object
      x*: cfloat
      y*: cfloat
      z*: cfloat

    INNER_C_STRUCT_HandmadeMath_32* {.bycopy.} = object
      U*: cfloat
      V*: cfloat
      W*: cfloat

    INNER_C_STRUCT_HandmadeMath_34* {.bycopy.} = object
      R*: cfloat
      G*: cfloat
      B*: cfloat

    INNER_C_STRUCT_HandmadeMath_36* {.bycopy.} = object
      XY*: Vec2
      Ignored0*: cfloat

    INNER_C_STRUCT_HandmadeMath_38* {.bycopy.} = object
      Ignored1*: cfloat
      YZ*: Vec2

    INNER_C_STRUCT_HandmadeMath_40* {.bycopy.} = object
      UV*: Vec2
      Ignored2*: cfloat

    INNER_C_STRUCT_HandmadeMath_42* {.bycopy.} = object
      Ignored3*: cfloat
      VW*: Vec2

    INNER_C_STRUCT_HandmadeMath_64* {.bycopy.} = object
      X*: cfloat
      Y*: cfloat
      Z*: cfloat

    INNER_C_UNION_HandmadeMath_63* {.bycopy, union.} = object
      XYZ*: Vec3
      ano_HandmadeMath_65*: INNER_C_STRUCT_HandmadeMath_64

    INNER_C_STRUCT_HandmadeMath_62* {.bycopy.} = object
      ano_HandmadeMath_66*: INNER_C_UNION_HandmadeMath_63
      W*: cfloat

    INNER_C_STRUCT_HandmadeMath_70* {.bycopy.} = object
      R*: cfloat
      G*: cfloat
      B*: cfloat

    INNER_C_UNION_HandmadeMath_69* {.bycopy, union.} = object
      RGB*: Vec3
      ano_HandmadeMath_71*: INNER_C_STRUCT_HandmadeMath_70

    INNER_C_STRUCT_HandmadeMath_68* {.bycopy.} = object
      ano_HandmadeMath_72*: INNER_C_UNION_HandmadeMath_69
      A*: cfloat

    INNER_C_STRUCT_HandmadeMath_74* {.bycopy.} = object
      XY*: Vec2
      Ignored0*: cfloat
      Ignored1*: cfloat

    INNER_C_STRUCT_HandmadeMath_76* {.bycopy.} = object
      Ignored2*: cfloat
      YZ*: Vec2
      Ignored3*: cfloat

    INNER_C_STRUCT_HandmadeMath_78* {.bycopy.} = object
      Ignored4*: cfloat
      Ignored5*: cfloat
      ZW*: Vec2

    INNER_C_STRUCT_HandmadeMath_88* {.bycopy.} = object
      X*: cfloat
      Y*: cfloat
      Z*: cfloat

    INNER_C_UNION_HandmadeMath_87* {.bycopy, union.} = object
      XYZ*: Vec3
      ano_HandmadeMath_89*: INNER_C_STRUCT_HandmadeMath_88

    INNER_C_STRUCT_HandmadeMath_86* {.bycopy.} = object
      ano_HandmadeMath_90*: INNER_C_UNION_HandmadeMath_87
      W*: cfloat

    Vec2* {.bycopy, union.} = object
      ano_HandmadeMath_9*: INNER_C_STRUCT_HandmadeMath_8
      ano_HandmadeMath_11*: INNER_C_STRUCT_HandmadeMath_10
      ano_HandmadeMath_13*: INNER_C_STRUCT_HandmadeMath_12
      ano_HandmadeMath_15*: INNER_C_STRUCT_HandmadeMath_14
      Elements*: array[2, cfloat]

    Vec3* {.bycopy, union.} = object
      ano_HandmadeMath_31*: INNER_C_STRUCT_HandmadeMath_30
      ano_HandmadeMath_33*: INNER_C_STRUCT_HandmadeMath_32
      ano_HandmadeMath_35*: INNER_C_STRUCT_HandmadeMath_34
      ano_HandmadeMath_37*: INNER_C_STRUCT_HandmadeMath_36
      ano_HandmadeMath_39*: INNER_C_STRUCT_HandmadeMath_38
      ano_HandmadeMath_41*: INNER_C_STRUCT_HandmadeMath_40
      ano_HandmadeMath_43*: INNER_C_STRUCT_HandmadeMath_42
      Elements*: array[3, cfloat]

    HMM_Vec4* {.bycopy, union.} = object
      ano_HandmadeMath_67*: INNER_C_STRUCT_HandmadeMath_62
      ano_HandmadeMath_73*: INNER_C_STRUCT_HandmadeMath_68
      ano_HandmadeMath_75*: INNER_C_STRUCT_HandmadeMath_74
      ano_HandmadeMath_77*: INNER_C_STRUCT_HandmadeMath_76
      ano_HandmadeMath_79*: INNER_C_STRUCT_HandmadeMath_78
      Elements*: array[4, cfloat]
      NEON*: float32x4_t

    Mat2* {.bycopy, union.} = object
      Elements*: array[2, array[2, cfloat]]
      Columns*: array[2, Vec2]

    Mat3* {.bycopy, union.} = object
      Elements*: array[3, array[3, cfloat]]
      Columns*: array[3, Vec3]

    HMM_Mat4* {.bycopy, union.} = object
      Elements*: array[4, array[4, cfloat]]
      Columns*: array[4, HMM_Vec4]

    HMM_Quat* {.bycopy, union.} = object
      ano_HandmadeMath_91*: INNER_C_STRUCT_HandmadeMath_86
      Elements*: array[4, cfloat]
      NEON*: float32x4_t

    HMM_Bool* = cint

  # Vec2
  template x*(a: Vec2): float32 =
    a.ano_HandmadeMath_9.x

  template `x=`*(a: var Vec2; b: float32) =
    a.ano_HandmadeMath_9.x = b

  template y*(a: Vec2): float32 =
    a.ano_HandmadeMath_9.y

  template `y=`*(a: var Vec2; b: float32) =
    a.ano_HandmadeMath_9.y = b

  proc `<`*(a, b: Vec2): bool =
    result = a.x < b.x and a.y < b.y

  proc `~=`*(p1: Vec2, p2: Vec2): bool = abs(p1.x - p2.x) <= epsilon(float32) and abs(p1.y - p2.y) <= epsilon(float32)

  # Vec3

  proc `[]`*(v: Vec3; idx: SomeUnsignedInt): float32 =
    result = v.elements[idx]

  template x*(a: Vec3): float32 =
    a.ano_HandmadeMath_31.x

  template `x=`*(a: var Vec3; b: float32) =
    a.ano_HandmadeMath_31.x = b

  template y*(a: Vec3): float32 =
    a.ano_HandmadeMath_31.y

  template `y=`*(a: var Vec3; b: float32) =
    a.ano_HandmadeMath_31.y = b

  template z*(a: Vec3): float32 =
    a.ano_HandmadeMath_31.z

  template `z=`*(a: var Vec3; b: float32) =
    a.ano_HandmadeMath_31.z = b

  # template `*`*(v: Vec3; f: float32): Vec3 =
  #   multiplyVec3f(v, f)

  # template `+=`*(l: var Vec3; r: Vec3) =
  #   l = addVec3(l, r)

  # template `+`*(l, r: Vec3): Vec3 =
  #   addVec3(l, r)

  template `-`*(l, r: Vec3): Vec3 =
    subtractVec3(l, r)

  proc vec3*(x: float32; y: float32; z: float32): Vec3 {.inline.} =
    discard

  proc min*(a, b: Vec3): Vec3 =
    result = vec3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

  proc max*(a, b: Vec3): Vec3 =
    result = vec3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))

  proc HMM_ToRad*(Angle: cfloat): cfloat =
    discard

  proc HMM_ToDeg*(Angle: cfloat): cfloat =
    discard

  proc HMM_ToTurn*(Angle: cfloat): cfloat =
    discard

  proc HMM_SinF*(Angle: cfloat): cfloat =
    discard

  proc HMM_CosF*(Angle: cfloat): cfloat =
    discard

  proc HMM_TanF*(Angle: cfloat): cfloat =
    discard

  proc HMM_ACosF*(Arg: cfloat): cfloat =
    discard

  proc HMM_SqrtF*(Float: cfloat): cfloat =
    discard

  proc HMM_InvSqrtF*(Float: cfloat): cfloat =
    discard

  proc HMM_Lerp*(A: cfloat; Time: cfloat; B: cfloat): cfloat =
    discard

  proc HMM_Clamp*(Min: cfloat; Value: cfloat; Max: cfloat): cfloat =
    discard

  proc HMM_V2*(X: cfloat; Y: cfloat): Vec2 =
    discard

  proc HMM_V3*(X: cfloat; Y: cfloat; Z: cfloat): Vec3 =
    discard

  proc HMM_V4*(X: cfloat; Y: cfloat; Z: cfloat; W: cfloat): HMM_Vec4 =
    discard

  proc HMM_V4V*(Vector: Vec3; W: cfloat): HMM_Vec4 =
    discard

  proc HMM_AddV2*(Left: Vec2; Right: Vec2): Vec2 =
    discard

  proc HMM_AddV3*(Left: Vec3; Right: Vec3): Vec3 =
    discard

  proc HMM_AddV4*(Left: HMM_Vec4; Right: HMM_Vec4): HMM_Vec4 =
    discard

  proc subtractVec2*(Left: Vec2; Right: Vec2): Vec2 =
    discard

  proc subtractVec3*(Left: Vec3; Right: Vec3): Vec3 =
    discard

  proc HMM_SubV4*(Left: HMM_Vec4; Right: HMM_Vec4): HMM_Vec4 =
    discard

  proc HMM_MulV2*(Left: Vec2; Right: Vec2): Vec2 =
    discard

  proc HMM_MulV2F*(Left: Vec2; Right: cfloat): Vec2 =
    discard

  proc HMM_MulV3*(Left: Vec3; Right: Vec3): Vec3 =
    discard

  proc HMM_MulV3F*(Left: Vec3; Right: cfloat): Vec3 =
    discard

  proc HMM_MulV4*(Left: HMM_Vec4; Right: HMM_Vec4): HMM_Vec4 =
    discard

  proc HMM_MulV4F*(Left: HMM_Vec4; Right: cfloat): HMM_Vec4 =
    discard

  proc HMM_DivV2*(Left: Vec2; Right: Vec2): Vec2 =
    discard

  proc HMM_DivV2F*(Left: Vec2; Right: cfloat): Vec2 =
    discard

  proc HMM_DivV3*(Left: Vec3; Right: Vec3): Vec3 =
    discard

  proc HMM_DivV3F*(Left: Vec3; Right: cfloat): Vec3 =
    discard

  proc HMM_DivV4*(Left: HMM_Vec4; Right: HMM_Vec4): HMM_Vec4 =
    discard

  proc HMM_DivV4F*(Left: HMM_Vec4; Right: cfloat): HMM_Vec4 =
    discard

  proc HMM_EqV2*(Left: Vec2; Right: Vec2): HMM_Bool =
    discard

  proc HMM_EqV3*(Left: Vec3; Right: Vec3): HMM_Bool =
    discard

  proc HMM_EqV4*(Left: HMM_Vec4; Right: HMM_Vec4): HMM_Bool =
    discard

  proc HMM_DotV2*(Left: Vec2; Right: Vec2): cfloat =
    discard

  proc HMM_DotV3*(Left: Vec3; Right: Vec3): cfloat =
    discard

  proc HMM_DotV4*(Left: HMM_Vec4; Right: HMM_Vec4): cfloat =
    discard

  proc cross*(Left: Vec3; Right: Vec3): Vec3 =
    discard

  proc HMM_LenSqrV2*(A: Vec2): cfloat =
    discard

  proc HMM_LenSqrV3*(A: Vec3): cfloat =
    discard

  proc HMM_LenSqrV4*(A: HMM_Vec4): cfloat =
    discard

  proc HMM_LenV2*(A: Vec2): cfloat =
    discard

  proc HMM_LenV3*(A: Vec3): cfloat =
    discard

  proc HMM_LenV4*(A: HMM_Vec4): cfloat =
    discard

  proc HMM_NormV2*(A: Vec2): Vec2 =
    discard

  proc normalizeVec3*(A: Vec3): Vec3 =
    discard

  proc HMM_NormV4*(A: HMM_Vec4): HMM_Vec4 =
    discard

  proc HMM_LerpV2*(A: Vec2; Time: cfloat; B: Vec2): Vec2 =
    discard

  proc HMM_LerpV3*(A: Vec3; Time: cfloat; B: Vec3): Vec3 =
    discard

  proc HMM_LerpV4*(A: HMM_Vec4; Time: cfloat; B: HMM_Vec4): HMM_Vec4 =
    discard

  proc HMM_LinearCombineV4M4*(Left: HMM_Vec4; Right: HMM_Mat4): HMM_Vec4 =
    discard

  proc HMM_M2*(): Mat2 =
    discard

  proc HMM_M2D*(Diagonal: cfloat): Mat2 =
    discard

  proc HMM_TransposeM2*(Matrix: Mat2): Mat2 =
    discard

  proc HMM_AddM2*(Left: Mat2; Right: Mat2): Mat2 =
    discard

  proc HMM_SubM2*(Left: Mat2; Right: Mat2): Mat2 =
    discard

  proc HMM_MulM2V2*(Matrix: Mat2; Vector: Vec2): Vec2 =
    discard

  proc HMM_MulM2*(Left: Mat2; Right: Mat2): Mat2 =
    discard

  proc HMM_MulM2F*(Matrix: Mat2; Scalar: cfloat): Mat2 =
    discard

  proc HMM_DivM2F*(Matrix: Mat2; Scalar: cfloat): Mat2 =
    discard

  proc HMM_DeterminantM2*(Matrix: Mat2): cfloat =
    discard

  proc HMM_InvGeneralM2*(Matrix: Mat2): Mat2 =
    discard

  proc HMM_M3*(): Mat3 =
    discard

  proc HMM_M3D*(Diagonal: cfloat): Mat3 =
    discard

  proc HMM_TransposeM3*(Matrix: Mat3): Mat3 =
    discard

  proc HMM_AddM3*(Left: Mat3; Right: Mat3): Mat3 =
    discard

  proc HMM_SubM3*(Left: Mat3; Right: Mat3): Mat3 =
    discard

  proc HMM_MulM3V3*(Matrix: Mat3; Vector: Vec3): Vec3 =
    discard

  proc HMM_MulM3*(Left: Mat3; Right: Mat3): Mat3 =
    discard

  proc HMM_MulM3F*(Matrix: Mat3; Scalar: cfloat): Mat3 =
    discard

  proc HMM_DivM3F*(Matrix: Mat3; Scalar: cfloat): Mat3 =
    discard

  proc HMM_DeterminantM3*(Matrix: Mat3): cfloat =
    discard

  proc HMM_InvGeneralM3*(Matrix: Mat3): Mat3 =
    discard

  proc HMM_M4*(): HMM_Mat4 =
    discard

  proc HMM_M4D*(Diagonal: cfloat): HMM_Mat4 =
    discard

  proc HMM_TransposeM4*(Matrix: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_AddM4*(Left: HMM_Mat4; Right: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_SubM4*(Left: HMM_Mat4; Right: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_MulM4*(Left: HMM_Mat4; Right: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_MulM4F*(Matrix: HMM_Mat4; Scalar: cfloat): HMM_Mat4 =
    discard

  proc HMM_MulM4V4*(Matrix: HMM_Mat4; Vector: HMM_Vec4): HMM_Vec4 =
    discard

  proc HMM_DivM4F*(Matrix: HMM_Mat4; Scalar: cfloat): HMM_Mat4 =
    discard

  proc HMM_DeterminantM4*(Matrix: HMM_Mat4): cfloat =
    discard

  proc HMM_InvGeneralM4*(Matrix: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_Orthographic_RH_NO*(Left: cfloat; Right: cfloat; Bottom: cfloat; Top: cfloat;
                              Near: cfloat; Far: cfloat): HMM_Mat4 =
    discard

  proc HMM_Orthographic_RH_ZO*(Left: cfloat; Right: cfloat; Bottom: cfloat; Top: cfloat;
                              Near: cfloat; Far: cfloat): HMM_Mat4 =
    discard

  proc HMM_Orthographic_LH_NO*(Left: cfloat; Right: cfloat; Bottom: cfloat; Top: cfloat;
                              Near: cfloat; Far: cfloat): HMM_Mat4 =
    discard

  proc HMM_Orthographic_LH_ZO*(Left: cfloat; Right: cfloat; Bottom: cfloat; Top: cfloat;
                              Near: cfloat; Far: cfloat): HMM_Mat4 =
    discard

  proc HMM_InvOrthographic*(OrthoMatrix: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_Perspective_RH_NO*(FOV: cfloat; AspectRatio: cfloat; Near: cfloat; Far: cfloat): HMM_Mat4 =
    discard

  proc HMM_Perspective_RH_ZO*(FOV: cfloat; AspectRatio: cfloat; Near: cfloat; Far: cfloat): HMM_Mat4 =
    discard

  proc HMM_Perspective_LH_NO*(FOV: cfloat; AspectRatio: cfloat; Near: cfloat; Far: cfloat): HMM_Mat4 =
    discard

  proc HMM_Perspective_LH_ZO*(FOV: cfloat; AspectRatio: cfloat; Near: cfloat; Far: cfloat): HMM_Mat4 =
    discard

  proc HMM_InvPerspective_RH*(PerspectiveMatrix: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_InvPerspective_LH*(PerspectiveMatrix: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_Translate*(Translation: Vec3): HMM_Mat4 =
    discard

  proc HMM_InvTranslate*(TranslationMatrix: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_Rotate_RH*(Angle: cfloat; Axis: Vec3): HMM_Mat4 =
    discard

  proc HMM_Rotate_LH*(Angle: cfloat; Axis: Vec3): HMM_Mat4 =
    discard

  proc HMM_InvRotate*(RotationMatrix: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_Scale*(Scale: Vec3): HMM_Mat4 =
    discard

  proc HMM_InvScale*(ScaleMatrix: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_LookAtImpl*(F: Vec3; S: Vec3; U: Vec3; Eye: Vec3): HMM_Mat4 =
    discard

  proc HMM_LookAt_RH*(Eye: Vec3; Center: Vec3; Up: Vec3): HMM_Mat4 =
    discard

  proc HMM_LookAt_LH*(Eye: Vec3; Center: Vec3; Up: Vec3): HMM_Mat4 =
    discard

  proc HMM_InvLookAt*(Matrix: HMM_Mat4): HMM_Mat4 =
    discard

  proc HMM_Q*(X: cfloat; Y: cfloat; Z: cfloat; W: cfloat): HMM_Quat =
    discard

  proc HMM_QV4*(Vector: HMM_Vec4): HMM_Quat =
    discard

  proc HMM_AddQ*(Left: HMM_Quat; Right: HMM_Quat): HMM_Quat =
    discard

  proc HMM_SubQ*(Left: HMM_Quat; Right: HMM_Quat): HMM_Quat =
    discard

  proc HMM_MulQ*(Left: HMM_Quat; Right: HMM_Quat): HMM_Quat =
    discard

  proc HMM_MulQF*(Left: HMM_Quat; Multiplicative: cfloat): HMM_Quat =
    discard

  proc HMM_DivQF*(Left: HMM_Quat; Divnd: cfloat): HMM_Quat =
    discard

  proc HMM_DotQ*(Left: HMM_Quat; Right: HMM_Quat): cfloat =
    discard

  proc HMM_InvQ*(Left: HMM_Quat): HMM_Quat =
    discard

  proc HMM_NormQ*(Quat: HMM_Quat): HMM_Quat =
    discard

  proc HMM_MixQImpl*(Left: HMM_Quat; MixLeft: cfloat; Right: HMM_Quat; MixRight: cfloat): HMM_Quat =
    discard

  proc HMM_NLerp*(Left: HMM_Quat; Time: cfloat; Right: HMM_Quat): HMM_Quat =
    discard

  proc HMM_SLerp*(Left: HMM_Quat; Time: cfloat; Right: HMM_Quat): HMM_Quat =
    discard

  proc HMM_QToM4*(Left: HMM_Quat): HMM_Mat4 =
    discard

  proc HMM_M4ToQ_RH*(M: HMM_Mat4): HMM_Quat =
    discard

  proc HMM_M4ToQ_LH*(M: HMM_Mat4): HMM_Quat =
    discard

  proc HMM_QFromAxisAngle_RH*(Axis: Vec3; Angle: cfloat): HMM_Quat =
    discard

  proc HMM_QFromAxisAngle_LH*(Axis: Vec3; Angle: cfloat): HMM_Quat =
    discard

  proc HMM_QFromNormPair*(Left: Vec3; Right: Vec3): HMM_Quat =
    discard

  proc HMM_QFromVecPair*(Left: Vec3; Right: Vec3): HMM_Quat =
    discard

  proc HMM_RotateV2*(V: Vec2; Angle: cfloat): Vec2 =
    discard

  proc HMM_RotateV3Q*(V: Vec3; Q: HMM_Quat): Vec3 =
    discard

  proc HMM_RotateV3AxisAngle_LH*(V: Vec3; Axis: Vec3; Angle: cfloat): Vec3 =
    discard

  proc HMM_RotateV3AxisAngle_RH*(V: Vec3; Axis: Vec3; Angle: cfloat): Vec3 =
    discard
