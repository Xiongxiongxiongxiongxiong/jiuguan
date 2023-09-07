
#ifndef CUSTOMBRDF_SHADER_HEARDER_INCLUDE
#define CUSTOMBRDF_SHADER_HEARDER_INCLUDE

#include "AutoLight.cginc"
#include "DataTypes.cginc"
#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityPBSLighting.cginc" 
#include "UtilHeader.cginc"
#include "WorkCommon.cginc"


// 基于 BRDF2_Unity_PBS 进行效果优化
// Based on Minimalist CookTorrance BRDF
// Implementation is slightly different from original derivation: http://www.thetenthplanet.de/archives/255
//
// * NDF (depending on UNITY_BRDF_GGX):
//  a) BlinnPhong
//  b) [Modified] GGX
// * Modified Kelemen and Szirmay-​Kalos for Visibility term
// * Fresnel approximated with 1/LdotH
half4 BRDF2_Will_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

    half nl = saturate(dot(normal, light.dir));
    float2 nh = saturate( float2(dot(normal, halfDir), dot(normal,viewDir))); // 第二层高光从相机出发
    half nv = saturate(dot(normal, viewDir));
    float2 lh = saturate(float2( dot(light.dir, halfDir), 1 )); // y分量是虚拟出一个视角方向的光求出的值。halfDir2 = viewDir, dot(viewDir,halfDir2) = 1。这个光用来让相机看过去总是容易看到一个高光。看到《天谕》有这样的效果（有个跟着眼睛走的高光，即便背光仍然存在）。这个高光能够显著提升材质油亮的质感，虽然物理不正确。注：《原神》和《天刀》没有这个

    // Specular term
    half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

    //-------------------------
    // GGX
    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155
    half a = roughness;
    float a2 = a * a;

    float2 d = nh * nh * (a2 - 1.f) + 1.00001f;
    
    float2 specularTerm = a2 / (max(0.1f, lh*lh) * (a + 0.5f) * (d * d) * 4);
    // float specularTerm2 = a2 / (max(0.1f, lh2*lh2) * (roughness + 0.5f) * (d * d) * 4);
    
    // 第二层高光，跟着眼睛走。
    //half roughness2 = saturate(2.0 * roughness - roughness * roughness);
    specularTerm.y = specularTerm.y * 0.2; // 压暗这个高光以减少失真的感觉。

    // on mobiles (where half actually means something) denominator have risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
    #if defined (SHADER_API_MOBILE)
        specularTerm = specularTerm - 1e-4f;
    #endif

    // GGX
    //-----------------------


    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles. 为了统一效果，PC平台也加了这个，避免出现bloom后fireflies的闪烁问题。


    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)

    // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
    // 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
#ifdef UNITY_COLORSPACE_GAMMA
    half surfaceReduction = 0.28;
#else
    half surfaceReduction = (0.6-0.08*perceptualRoughness);
#endif

    surfaceReduction = 1.0 - roughness*perceptualRoughness*surfaceReduction;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   (diffColor + specularTerm.x * specColor) * light.color * nl
                    + specularTerm.y * specColor * oneMinusReflectivity  //_LightColor0.rgb 用主光和环境光颜色都不合适。金属减弱该项，因为金属高光反射太强在场景中常常显得过于突兀
                    + gi.diffuse * diffColor
                    + surfaceReduction * gi.specular * FresnelLerpFast (specColor, grazingTerm, nv);

    return half4( color, 1);
}


// 这是直接从built-in shader 里拷贝出来的，目的是避免spec过亮导致闪烁等问题。
// Based on Minimalist CookTorrance BRDF
// Implementation is slightly different from original derivation: http://www.thetenthplanet.de/archives/255
//
// * NDF (depending on UNITY_BRDF_GGX):
//  a) BlinnPhong
//  b) [Modified] GGX
// * Modified Kelemen and Szirmay-​Kalos for Visibility term
// * Fresnel approximated with 1/LdotH
half4 BRDF2_Unity_PBS_Custom (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

    half nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));
    half nv = saturate(dot(normal, viewDir));
    float lh = saturate(dot(light.dir, halfDir));

    // Specular term
    half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

#if UNITY_BRDF_GGX

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155
    half a = roughness;
    float a2 = a*a;

    float d = nh * nh * (a2 - 1.f) + 1.00001f;
#ifdef UNITY_COLORSPACE_GAMMA
    // Tighter approximation for Gamma only rendering mode!
    // DVF = sqrt(DVF);
    // DVF = (a * sqrt(.25)) / (max(sqrt(0.1), lh)*sqrt(roughness + .5) * d);
    float specularTerm = a / (max(0.32f, lh) * (1.5f + roughness) * d);
#else
    float specularTerm = a2 / (max(0.1f, lh*lh) * (roughness + 0.5f) * (d * d) * 4);
#endif

    // on mobiles (where half actually means something) denominator have risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
#if defined (SHADER_API_MOBILE)
    specularTerm = specularTerm - 1e-4f;
#endif

#else

    // Legacy
    half specularPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
    // Modified with approximate Visibility function that takes roughness into account
    // Original ((n+1)*N.H^n) / (8*Pi * L.H^3) didn't take into account roughness
    // and produced extremely bright specular at grazing angles

    half invV = lh * lh * smoothness + perceptualRoughness * perceptualRoughness; // approx ModifiedKelemenVisibilityTerm(lh, perceptualRoughness);
    half invF = lh;

    half specularTerm = ((specularPower + 1) * pow (nh, specularPower)) / (8 * invV * invF + 1e-4h);

#ifdef UNITY_COLORSPACE_GAMMA
    specularTerm = sqrt(max(1e-4f, specularTerm));
#endif

#endif

    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles. 为了统一效果，PC平台也加了这个，避免出现bloom后fireflies的闪烁问题。

#if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
#endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)

    // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
    // 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
#ifdef UNITY_COLORSPACE_GAMMA
    half surfaceReduction = 0.28;
#else
    half surfaceReduction = (0.6-0.08*perceptualRoughness);
#endif

    surfaceReduction = 1.0 - roughness*perceptualRoughness*surfaceReduction;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   (diffColor + specularTerm * specColor) * light.color * nl
                    + gi.diffuse * diffColor
                    + surfaceReduction * gi.specular * FresnelLerpFast (specColor, grazingTerm, nv);

    return half4(color, 1);
}



#endif // CUSTOMBRDF_SHADER_HEARDER_INCLUDE
