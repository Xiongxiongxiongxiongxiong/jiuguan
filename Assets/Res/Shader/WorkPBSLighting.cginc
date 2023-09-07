#include "PbrHeader.cginc"
#include "UtilHeader.cginc"

#ifndef WORK_PBS_LIGHTING
    #define WORK_PBS_LIGHTING

    #if defined(_WRAPPED_LIGHT_CUSTOM)
        half _Wrap; 
    #endif

	#ifdef _PROP_CUBEMAP_ON
		samplerCUBE _EnvMap;
		fixed _EnvScale;
	#endif

#define EPSILON 1e-4h
inline half GGX(half NdotH, half roughness) // 公式说明 https://www.jianshu.com/p/fd7f2609435e
{
    half a2 = roughness * roughness;
    half d = (NdotH * a2 - NdotH) * NdotH + 1.0h;
    return max(0.0h, 0.25h * a2 / (d * d + EPSILON));
}

// util for specular

inline half3 WorkGI_IndirectSpecular(UnityGIInput data, half occlusion, Unity_GlossyEnvironmentData glossIn)
{
	half3 specular;

#ifdef _GLOSSYREFLECTIONS_OFF
	specular = unity_IndirectSpecColor.rgb;
#else
#ifdef _PROP_CUBEMAP_ON
	half perceptualRoughness = glossIn.roughness;
	perceptualRoughness = perceptualRoughness * (1.7 - 0.7*perceptualRoughness);
	half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);
	specular = texCUBElod(_EnvMap, half4(glossIn.reflUVW, mip)).rgb;// * _EnvScale;
// #else
// 	specular = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), data.probeHDR[0], glossIn);
#endif
#endif

	return specular * occlusion;
}

//------------------------------------------------------------------------
// PBRScene Shader
// Author: Will
inline half4 LightingPBRScene(WorkSurfaceOutputStandard s,half3 viewDir,UnityGI gi)
{
    s.Normal = normalize(s.Normal);
    half ndl = saturate(dot(s.Normal, gi.light.dir));

    half metalness = 1 - s.Metallic;
    half oneMinusReflectivity = unity_ColorSpaceDielectricSpec.a * metalness;
    half3 diffColor = s.Albedo * oneMinusReflectivity;
    half3 specColor = unity_ColorSpaceDielectricSpec.rgb * metalness + s.Albedo * s.Metallic;
    half4 c;
    c.a = s.Alpha;
    // 模仿 BRDF2_Unity_PBS， 直接光漫反射部分使用 Blinn-Phong，故不用除以PI。
    c.rgb = diffColor * gi.light.color *ndl; // [直接光diffuse项]

// 与standard一样，如果不定义 _SPECULARHIGHLIGHTS_OFF，那么就会计算高光，这里的高光计算会同时计算直接光和间接光。
// 注意，如果不做IBL，那这里的高光就只有直射光的高光，虽然无法表现金属质感，但能够表现非金属的粗糙度
#if !defined(_SPECULARHIGHLIGHTS_OFF)
    half3 h = SafeNormalize_Mid(gi.light.dir + viewDir);
    half ndh = saturate(dot(s.Normal, h));
    half perceptualRoughness = 1 - s.Smoothness;
    half roughness = perceptualRoughness*perceptualRoughness;
    half spec = GGX(ndh, roughness); // 高光强度使用GGX计算。看来这里Spec项只考虑了D，没有考虑F和G。很早的时候就是这样，效果还好，故不增加F和G了。而如果直接使用角色的GetBRDFSpecular()会导致某些点过曝，暂也不打算研究具体原因。维持现有效果也能避免美术资源的返工。
    half specAtten = ndl;

    c.rgb += gi.light.color * specAtten * specColor * spec;  // [直接光Spec项]
    // half3 mainLightSpec = GetBRDFSpecular(specColor,roughness,ndh,NdotV,ndl,VdotH); // 这个角色的高光计算会导致某些点过曝
#endif

   
#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
    c.rgb += diffColor * gi.indirect.diffuse; // [间接光diffuse项]
#endif


#if defined(_PROP_CUBEMAP_ON)
    half nv = saturate(dot(s.Normal, viewDir));
    #ifdef UNITY_COLORSPACE_GAMMA
        half surfaceReduction = 0.28h;
    #else
        half surfaceReduction = (0.6h-0.08h*perceptualRoughness);
    #endif
    surfaceReduction = 1 - roughness*perceptualRoughness*surfaceReduction;
    half grazingTerm = saturate(s.Smoothness + (1-oneMinusReflectivity));
    c.rgb += surfaceReduction * gi.indirect.specular * FresnelLerpFast (specColor, grazingTerm, nv); // [间接光Spec项]
#endif

    // 自发光
    c.rgb += s.Emission.rgb;

    return c;
}


inline void LightingWorkPBS_GI (inout WorkSurfaceOutputStandard s,UnityGIInput data,inout UnityGI gi)
{
    gi = UnityGI_Base_RealtimeOrShadowMask( data.lightmapUV.xy, data.light.dir, data.worldPos, data.atten, s.Normal, gi.light.color ); // 现在统一用 PBRHeader中定义的全局光照计算GI
    gi.indirect.diffuse *= s.Occlusion;
   
    #if defined(_PROP_CUBEMAP_ON)
        Unity_GlossyEnvironmentData glossIn = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
        gi.indirect.specular = WorkGI_IndirectSpecular(data, s.Occlusion, glossIn);
    #endif

}

#endif