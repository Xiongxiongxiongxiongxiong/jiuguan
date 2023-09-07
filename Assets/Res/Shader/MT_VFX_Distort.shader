Shader "MT/MT_VFX_Distort"
{
    Properties
    {
        //[Toggle]_BlendMode ("Alpha/ADD", int) = 0
        [Header(Distort)]
        [Toggle]_DistortOn ("Distort On", int) = 0

        _MainTex ("DistortTex", 2D) = "white" {}
        [HideInInspector]_MainTex_ST("DistortTex_ST", Vector) = (1,1,0,0)
        _DistortTex_Uspeed("DistortTex_Uspeed", Float) = 0
		_DistortTex_Vspeed("DistortTex_Vspeed", Float) = 0
        _DistortFactor("DistortFactor", Range( 0 , 1)) = 0
        _DistortMaskTex ("DistortMaskTex", 2D) = "white" {}
		[HideInInspector]_DistortMaskTex_ST("DistortMaskTex_ST", Vector) = (1,1,0,0)
        _DistortMaskTex_Uspeed("DistortTex_Uspeed", Float) = 0
		_DistortMaskTex_Vspeed("DistortTex_Vspeed", Float) = 0
    }
    SubShader
    {
        Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
        Cull back
        //ZTest Off
        ZWrite Off
        //Blend SrcAlpha One
        /*#ifdef _BLENDMODE_ON
            Blend SrcAlpha One
        #else
            Blend SrcAlpha OneMinusSrcAlpha
        #endif*/

        GrabPass { "_BackgroundTex" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _DISTORTON_ON 
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 vertexColor :COLOR;
                float3 noraml: NORMAL;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 normal: NORMAL;
                float3 worldPos : TEXCOORD2;
                float4 grabUV : TEXCOORD3;
                float4 vertexColor :COLOR0;
            };

            sampler2D _BackgroundTex;

            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _MaskTex_Uspeed, _MaskTex_Vspeed;

            float2 GetUV(float2 uv,float4 ST,float Uspeed,float Vspeed){
                float2 newUV = uv * ST.xy + ST.zw + float2(Uspeed, Vspeed) * _Time.y;
                return newUV;
            }

            #ifdef _DISTORTON_ON
                sampler2D _MainTex, _DistortMaskTex;
                float4 _MainTex_ST, _DistortMaskTex_ST;
                float _DistortTex_Uspeed, _DistortTex_Vspeed;
                float _DistortMaskTex_Uspeed, _DistortMaskTex_Vspeed;
                float _DistortFactor;
                float2 DoDistort(float2 uv,float FactorOffset){
                    float2 DistortUV = GetUV(uv,_MainTex_ST,_DistortTex_Uspeed,_DistortTex_Vspeed);
                    float2 Distort = tex2D(_MainTex, DistortUV) * (_DistortFactor + FactorOffset);
                    float2 DistortMaskUV = GetUV(uv,_DistortMaskTex_ST,_DistortMaskTex_Uspeed,_DistortMaskTex_Vspeed);
                    float DistortMask = tex2D(_DistortMaskTex, DistortMaskUV);
                    Distort *= DistortMask;
                    return Distort;
                }
            #endif

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.grabUV = UNITY_PROJ_COORD(ComputeGrabScreenPos(o.vertex));
                o.uv = v.uv;
                o.texcoord1 = v.texcoord1;
                o.normal = normalize(UnityObjectToWorldNormal(v.noraml));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertexColor = v.vertexColor;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 uvoff = 0;
                #ifdef _DISTORTON_ON
                    uvoff = DoDistort(i.uv.xy,i.texcoord1.z);
                #endif
                float2 projUV = i.grabUV.xy/i.grabUV.w;
                fixed4 col = tex2D(_BackgroundTex, projUV + uvoff);
                col *= i.vertexColor;
                return col;
            }
            ENDCG
        }
    }
}
