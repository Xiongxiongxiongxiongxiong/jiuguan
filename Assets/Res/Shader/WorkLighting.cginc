#ifndef WORK_LIGHTING
    #define WORK_LIGHTING

    #if defined(_WRAPPED_LIGHT_CUSTOM)
        half _Wrap; //Range(-1,3)
    #endif

	#ifdef _PROP_CUBEMAP_ON
		samplerCUBE _EnvMap;
		fixed _EnvScale;
	#endif

inline fixed4 LightingWork (WorkSurfaceOutput s,half3 viewDir,UnityGI gi)
{
    s.Normal = normalize(s.Normal);

    fixed nl = dot(s.Normal, gi.light.dir);
    fixed ndl = max(0, nl);

    fixed4 c;
    c.a = s.Alpha;
    c.rgb = s.Albedo * gi.light.color * ndl;

#if !defined(_SPECULARHIGHLIGHTS_OFF)
    half3 h = normalize(gi.light.dir + viewDir);
    float ndh = max(0, dot(s.Normal, h));
    float spec = max(0,  SAFE_POW(ndh, s.Gloss*256.0) * s.Specular);
    fixed specAtten = spec;
    c.rgb += (gi.light.color * specAtten + gi.indirect.diffuse) * _SpecColor.rgb * spec;
#endif

#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
    c.rgb += s.Albedo * gi.indirect.diffuse;
#endif

#if defined(_PROP_CUBEMAP_WATER) 
    half nv = saturate(dot(s.Normal, viewDir));
#endif

#if defined(_PROP_CUBEMAP_ON)
    half3 refl = reflect(-viewDir,s.Normal);
    half4 reflColor = texCUBE(_EnvMap, refl);
    #if defined(_PROP_CUBEMAP_WATER)
        half fresnel = 1 - nv;
        fresnel = fresnel * fresnel;
        c.rgb = lerp(c.rgb,reflColor,fresnel*_EnvScale);
    #else
        c.rgb += reflColor*_EnvScale;
    #endif
#endif

    return c;
}

inline void LightingWork_GI (inout WorkSurfaceOutput s,UnityGIInput data,inout UnityGI gi)
{
    gi = UnityGI_Base(data,1.0,s.Normal);
}

#endif 
