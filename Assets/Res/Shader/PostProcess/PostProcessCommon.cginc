/**
  * @file       PostProcessCommon.cginc
  * @author     GuoYi<guoyi@xingfeiinc.com>
  * @date       2018/04/26
  */

#ifndef __POSTPROCESSCOMMON__
#define __POSTPROCESSCOMMON__

// -------------------------------------------------------------------

inline half Max3(half3 x) { return max(x.x, max(x.y, x.z)); }
inline half Max3(half x, half y, half z) { return max(x, max(y, z)); }

// Brightness function : todo:修改一下，bloom的亮度不应该是直接取 rgb 的最大值?
half Brightness(half3 c)
{
    return Max3(c);
}

#define EPSILON         1.0e-4

// 前提假设： color.r, color.g, color.b 都在[0,1]范围内(tone mapping做完之后)
float3 RgbToHsi(float3 color) {
  float R = color.r;
  float G = color.g;
  float B = color.b;

  float intensity = (R+G+B) / 3;
  float saturation = 1 - 3 * min(R, min(G,B)) / (R+G+B);

  float RmG = R-G;
  float RmB = R-B;
  float GmB = G-B;
  float theta = acos( 0.5*(RmG+RmB) / (sqrt(RmG*RmG+RmB*GmB)+EPSILON) );

  float hue = 0;
  if( B<=G ) {
    hue = theta;
  } else {
    hue = 360-theta;
  }

  hue /= 360; // from [0,360] to [0,1]

  return float3( hue, saturation, intensity );
}


float3 HsiToRgb(float3 hsi) {
  float H = hsi.r * 360; // from [0,1] to [0,360]
  float S = hsi.g;
  float I = hsi.b;

  float R = 0;
  float G = 0;
  float B = 0;
  if( H>0 && H<=120 ) {
    B = I * (1-S);
    R = I * ( 1 + S * cos(H) / (cos(60-H)) );
    G = 3*I - (R+B);
  } else if( H>120 && H<=240 ) {
    H = H-120;
    R = I * (1-S);
    G = I * ( 1+ S * cos(H) / (cos(60-H)) );
    B = 3*I - (R+G);
  } else if( H>240 && H<=360 ) {
    H = H-240;
    G = I * (1-S);
    B = I * (1+ S * cos(H) / (cos(60-H)) );
    R = 3*I - (G+B);
  }

  return float3(R,G,B);
}

//
// Hue, Saturation, Value
// Ranges:
//  Hue [0.0, 1.0]
//  Sat [0.0, 1.0]
//  Lum [0.0, HALF_MAX]
//
float3 RgbToHsv(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = EPSILON;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 HsvToRgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

// -------------------------------------------------------------------

#include "UnityCG.cginc"

struct vertInput {
	float4 pos : POSITION;
	float2 uv : TEXCOORD0;
};

struct vertOutput {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
  //float4 projPos : TEXCOORD1;
#if _FOG
  float4 interpolatedRayWS : TEXCOORD1;
#endif
};

#if _FOG
    uniform float4x4 _FrustumCornersWS; // frustum corners (far clipping plane, world space)
#endif

vertOutput VertDefault(vertInput input) {
    vertOutput o = (vertOutput)0;

#if _FOG
    half index = input.pos.z;
    input.pos.z = 0;
    o.interpolatedRayWS.rgb = _FrustumCornersWS[(int)index];
    // o.interpolatedRayWS.w = index;
    o.interpolatedRayWS.w = 0;
#endif

    o.pos = UnityObjectToClipPos(input.pos);
    o.uv = input.uv;
    //o.projPos = ComputeScreenPos (o.pos); // projPos中的x,y从[-1,1]转成[0,1]；用于sample depthBuffer

    return o;
}

// -------------------------------------------------------------------

#define USE_RGBM defined(SHADER_API_MOBILE)

half4 EncodeHDR(float3 rgb) // HDR -> LDR
{
#if USE_RGBM
    rgb *= 1.0 / 8.0; // 标准rgbm用的是6.0，这里用8.0压得更狠
    float m = max(max(rgb.r, rgb.g), max(rgb.b, 1e-6));
    m = ceil(m * 255.0) / 255.0;
    return half4(rgb / m, m);
#else
    return half4(rgb, 0.0);
#endif
}

float3 DecodeHDR(half4 rgba) // LDR -> HDR
{
#if USE_RGBM
    return rgba.rgb * rgba.a * 8.0;
#else
    return rgba.rgb;
#endif
}



#define SKYBOX_THREASHOLD_VALUE 0.9999999

inline fixed DepthIsSkybox(float depth) {
#if defined(UNITY_REVERSED_Z)
    return (1-depth) < SKYBOX_THREASHOLD_VALUE;
#else
    return depth < SKYBOX_THREASHOLD_VALUE;
#endif
}

// -------------------------------------------------------------------

#define HALF_MAX        65504.0

// Clamp HDR value within a safe range
inline half  SafeHDR(half  c) { return min(c, HALF_MAX); }
inline half2 SafeHDR(half2 c) { return min(c, HALF_MAX); }
inline half3 SafeHDR(half3 c) { return min(c, HALF_MAX); }
inline half4 SafeHDR(half4 c) { return min(c, HALF_MAX); }

#endif // __POSTPROCESSCOMMON__