// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "XF/ParallaxMapping"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "black" {}
        _TexPower("TexPower",Float)=5.0
        [NoScaleOffset]_BumpMap("BumpMap",2D)="bump"{}
        _NormalScale("NormalScale", Range(-5, 5)) = 1
        
        [Space][Space][Space]
        [Header(RIM)]
        _RimMin("RimMin",Range(-1,1))=0.0
        _RimMax("RimMax",Range(0,2))=1.0
        [HDR]_InnerColor("InnerColor",Color)=(0,0,0,0)
        _InnerAlpha("InnerAlpha",Range(-1.0,1.0))=0.0
        [HDR]_RimColor("RimColor",Color)=(1,1,1,1)
        _RimIntensity("RimIntensity",Float)=1.0

        [Space][Space][Space]
        [Header(EMISS)]
        _EmissiveTex("EmissiveTex",2D)="black"{}
        [Header(R_Intensity G_ParallaxHeight B_ParallaxScale A_Speed)]
        _EmissiveValue("EmissValue",Vector)=(1.0, 0.8, 1.9, 0.0)

        _EmissiveTex1("EmissiveTex1",2D)="black"{}
         [Header(R_Intensity G_ParallaxHeight B_ParallaxScale A_Speed)]
        _EmissiveValue1("EmissValue1",Vector)=(1.0, 0.8, 1.9, 0.0)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        
        Pass
        {
			ZWrite On
			ColorMask 0
		}        
        

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 tSpace0:TEXCOORD1;
                float4 tSpace1:TEXCOORD2;
                float4 tSpace2:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;

            sampler2D _EmissiveTex;
            float4 _EmissiveTex_ST;

            sampler2D _EmissiveTex1;
            float4 _EmissiveTex1_ST;

            float _TexPower;
            float _NormalScale;
            float _RimMin;
            float _RimMax;
            float4 _InnerColor;
            float _InnerAlpha;
            float4 _RimColor;
            float _RimIntensity;
        
            float4 _EmissiveValue;
            float4 _EmissiveValue1;

            //视差UV
            float2 ParallaxMapping(float height,float scale,float2 uv,float3 viewDirTan)
            {             
                float3 viewRay=normalize(viewDirTan);
                float2 parallaxed = uv;
                parallaxed = ((height-1)*(viewRay.xy) * scale) + uv;
                return parallaxed;   
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv =v.texcoord;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 worldNormal=UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = UnityObjectToWorldDir(v.tangent);
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
                o.tSpace0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.tSpace1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.tSpace2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);
                //float3 worldNormal = normalize(float3(i.tSpace0.z,i.tSpace1.z,i.tSpace2.z));
                half3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 viewDirTan=i.tSpace0.xyz * worldViewDir.x + i.tSpace1.xyz * worldViewDir.y  + i.tSpace2.xyz * worldViewDir.z;
                viewDirTan = -normalize(viewDirTan);//这里的切线空间的视线向量是相机到物体的向量

                fixed3 bump = UnpackNormalWithScale(tex2D(_BumpMap, i.uv), _NormalScale);
				bump = normalize(half3(dot(i.tSpace0.xyz, bump), dot(i.tSpace1.xyz, bump), dot(i.tSpace2.xyz, bump)));

                half NdotV=saturate(dot(bump,worldViewDir));
                half fresnel=1.0-NdotV;
                fresnel=smoothstep(_RimMin,_RimMax,fresnel);

                fixed4 mainCol = tex2D(_MainTex, i.uv).r;
                mainCol=pow(mainCol,_TexPower);

                half final_fresnel=saturate(fresnel+mainCol);

                half3 final_rim_color=lerp(_InnerColor.xyz,_RimColor.xyz*_RimIntensity,final_fresnel);
                half final_rim_alpha=final_fresnel;

                float2 emissiveUV = TRANSFORM_TEX(i.uv, _EmissiveTex);
                float2 parallaxUV = ParallaxMapping(_EmissiveValue.y,_EmissiveValue.z,emissiveUV,viewDirTan);

                float2 emissiveUV1 = TRANSFORM_TEX(i.uv, _EmissiveTex1);
                float2 parallaxUV1 = ParallaxMapping(_EmissiveValue1.y,_EmissiveValue1.z,emissiveUV1,viewDirTan);

                float4 emissive_rgba=tex2D(_EmissiveTex,parallaxUV+_Time.y*_EmissiveValue.w)*_EmissiveValue.x;
                float4 emissive_rgba1=tex2D(_EmissiveTex1,parallaxUV1+_Time.y*_EmissiveValue1.w)*_EmissiveValue1.x;

                fixed3 final_color=final_rim_color + (emissive_rgba.xyz + emissive_rgba1.xyz) * _RimColor;
                fixed final_alpha=saturate(final_rim_alpha+_InnerAlpha);

                return fixed4(final_color,final_alpha);
            }
            ENDCG
        }
    }
}
