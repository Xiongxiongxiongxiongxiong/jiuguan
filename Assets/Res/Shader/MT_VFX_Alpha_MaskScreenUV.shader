Shader "MT/MT_VFX_Alpha_MaskScreenUV"
{
    Properties
    {
        //[Toggle]_BlendMode ("Alpha/ADD", int) = 0
        [Header(Main)]
        _MainTex ("MainTex", 2D) = "white" {}
        [HideInInspector]_MainTex_ST("MainTex_ST", Vector) = (1,1,0,0)
        _MainTex_Uspeed("MainTex_Uspeed", Float) = 0
		_MainTex_Vspeed("MainTex_Vspeed", Float) = 0
        [HDR]_MainColor("MainColor", Color) = (1,1,1,1)
        [Header(Mask)]
        _MaskTex ("MaskTex", 2D) = "white" {}
        [HideInInspector]_MainTex_ST("MaskTex_ST", Vector) = (1,1,0,0)
        _MaskTex_Uspeed("Mask_Uspeed", Float) = 0
		_MaskTex_Vspeed("Mask_Vspeed", Float) = 0
        [Header(Distort)]
        [Toggle]_DistortOn ("Distort On", int) = 0
        _DistortTex ("DistortTex", 2D) = "white" {}
        [HideInInspector]_DistortTex_ST("DistortTex_ST", Vector) = (1,1,0,0)
        _DistortTex_Uspeed("DistortTex_Uspeed", Float) = 0
		_DistortTex_Vspeed("DistortTex_Vspeed", Float) = 0
        _DistortFactor("DistortFactor", Range( 0 , 1)) = 0
        _DistortMaskTex ("DistortMaskTex", 2D) = "white" {}
		[HideInInspector]_DistortMaskTex_ST("DistortMaskTex_ST", Vector) = (1,1,0,0)
        _DistortMaskTex_Uspeed("DistortTex_Uspeed", Float) = 0
		_DistortMaskTex_Vspeed("DistortTex_Vspeed", Float) = 0
        [Header(DIsslove)]
        [Toggle]_DIssloveOn ("DIsslove On", int) = 0
        _DIssloveTex ("DIssloveTex", 2D) = "white" {}
        [HideInInspector]_DissloveTex_ST("DissloveTex_ST", Vector) = (1,1,0,0)
        _DIssloveTex_Uspeed("DIssloveTex_Uspeed", Float) = 0
		_DIssloveTex_Vspeed("DIssloveTex_Vspeed", Float) = 0
		_DIssloveFactor("DIssloveFactor", Range( 0 , 1)) = 0.5
		_DIssloveWide("DIssloveWide", Range( 0 , 1)) = 0.1
		_DIssloveSoft("DIssloveSoft", Range( 0 , 1)) = 0.5
		[HDR]_DIssloveColor("DIssloveColor", Color) = (1,1,1,1)
        _DIssloveMaskTex ("DIssloveMaskTex", 2D) = "white" {}
        [HideInInspector]_DIssloveMaskTex_ST("DIssloveMaskTex_ST", Vector) = (1,1,0,0)
        _DIssloveMaskTex_Uspeed("DistortTex_Uspeed", Float) = 0
		_DIssloveMaskTex_Vspeed("DistortTex_Vspeed", Float) = 0
        [Header(Fnl)]
        [Toggle]_UseRim ("fnl On", int) = 0
        [Toggle]_fnl_Inv("fnl Inv",int) = 0
        _fnl_power("fnl power", Range( 1 , 10)) = 1
        _fnl_Base("fnl Base", Range( 0 , 1)) = 1
		_fnl_sacle("fnl sacle", Range( 0 , 1)) = 1
		[HDR]_fnl_color("fnl color", Color) = (1,1,1,0) 
    }
    SubShader
    {
        Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
        Cull back
        ZWrite Off
        //ZTest Off
        Blend SrcAlpha OneMinusSrcAlpha
        /*#ifdef _BLENDMODE_ON
            Blend SrcAlpha One
        #else
            Blend SrcAlpha OneMinusSrcAlpha
        #endif*/
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _BLENDMODE_ON 
            #pragma shader_feature _DISTORTON_ON 
            #pragma shader_feature _DISSLOVEON_ON
            #pragma shader_feature _USERIM_ON 
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor :COLOR;
                float3 noraml: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal: NORMAL;
                float3 worldPos: TEXCOORD2;
                float4 vertexColor :COLOR0;
                float4 screenPos :TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _MainTex_Uspeed, _MainTex_Vspeed;
            half4 _MainColor;

            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _MaskTex_Uspeed, _MaskTex_Vspeed;

            float2 GetUV(float2 uv,float4 ST,float Uspeed,float Vspeed){
                float2 newUV = uv * ST.xy + ST.zw + float2(Uspeed, Vspeed) * _Time.y;
                return newUV;
            }

            #ifdef _DISTORTON_ON
                sampler2D _DistortTex, _DistortMaskTex;
                float4 _DistortTex_ST, _DistortMaskTex_ST;
                float _DistortTex_Uspeed, _DistortTex_Vspeed;
                float _DistortMaskTex_Uspeed, _DistortMaskTex_Vspeed;
                float _DistortFactor;
                float2 DoDistort(float2 uv){
                    float2 DistortUV = GetUV(uv,_DistortTex_ST,_DistortTex_Uspeed,_DistortTex_Vspeed);
                    float2 Distort = tex2D(_DistortTex, DistortUV) * _DistortFactor;
                    float2 DistortMaskUV = GetUV(uv,_DistortMaskTex_ST,_DistortMaskTex_Uspeed,_DistortMaskTex_Vspeed);
                    float DistortMask = tex2D(_DistortMaskTex, DistortMaskUV);
                    Distort *= DistortMask;
                    return Distort;
                }
            #endif

            #ifdef _DISSLOVEON_ON
                sampler2D _DIssloveTex, _DIssloveMaskTex;
                float4 _DIssloveTex_ST, _DIssloveMaskTex_ST;
                float _DIssloveTex_Uspeed, _DIssloveTex_Vspeed;
                float _DIssloveMaskTex_Uspeed, _DIssloveMaskTex_Vspeed;
                float _DIssloveFactor, _DIssloveSoft, _DIssloveWide;
                half4 _DIssloveColor;
                float DoDIsslove(float2 uv){
                    float2 DIssloveUV = GetUV(uv,_DIssloveTex_ST,_DIssloveTex_Uspeed,_DIssloveTex_Vspeed);
                    float DIsslove = 1 + tex2D(_DIssloveTex, DIssloveUV);
                    DIsslove -= _DIssloveFactor * 2;
                    float2 DIssloveMaskUV = GetUV(uv,_DIssloveMaskTex_ST,_DIssloveMaskTex_Uspeed,_DIssloveMaskTex_Vspeed);
                    float DIssloveMask = tex2D(_DIssloveMaskTex, DIssloveMaskUV);
                    DIsslove = lerp(2,DIsslove,DIssloveMask);
                    return saturate(DIsslove);
                }
            #endif

            #ifdef _USERIM_ON
                float _fnl_power, _fnl_sacle, _fnl_Base;
                half3 _fnl_color;
                int _fnl_Inv;
                float3 FresnelSchlick(float NdotV)
                {
                    NdotV = lerp(NdotV,1 - NdotV,_fnl_Inv);
                    float3 fresnel = _fnl_Base + (1.0 - _fnl_Base) * pow(1.0 - NdotV, _fnl_power);
                    fresnel = fresnel *  _fnl_sacle * _fnl_color;
                    return fresnel;
                }
            #endif

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.screenPos = ComputeScreenPos(o.vertex);
                o.normal = normalize(UnityObjectToWorldNormal(v.noraml));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertexColor = v.vertexColor;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 mainUV = GetUV(i.uv,_MainTex_ST,_MainTex_Uspeed,_MainTex_Vspeed);
                
                float2 screenPosUV = i.screenPos.xy / i.screenPos.w;
                float2 maskUV = GetUV(screenPosUV,_MaskTex_ST,_MaskTex_Uspeed,_MaskTex_Vspeed);
                float mask = tex2D(_MaskTex, maskUV).r;
                #ifdef _DISTORTON_ON
                    mainUV += DoDistort(i.uv);
                #endif

                fixed4 col = tex2D(_MainTex, mainUV) * _MainColor;
                col.a *= mask;
                col *= i.vertexColor;
                #ifdef _DISSLOVEON_ON
                    float disslove = DoDIsslove(i.uv);
                    float disslove_hard = step(0.5, disslove);
                    float disslove_sort = lerp(disslove_hard,disslove,_DIssloveSoft);
                    float rim = smoothstep(_DIssloveWide,0,disslove - lerp(0.5,0,_DIssloveSoft)) * step(0.0001,_DIssloveFactor);
                    col = lerp(col,_DIssloveColor,rim);
                    col.a *= disslove_sort;
                #endif
                #ifdef _USERIM_ON
                    float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                    float NdotV = dot(i.normal,V);
                    float3 fresnel = FresnelSchlick(NdotV);
                    //fresnel = lerp(fresnel,1 - fresnel,_fnl_Inv);
                    col.a *= fresnel;
                #endif
                
                return col;
            }
            ENDCG
        }
    }
}
