// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "XF/ScanRim"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "black" {}
        _TexPower("TexPower",Float)=5.0
        _BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
        _RimMin("RimMin",Range(-1,1))=0.0
        _RimMax("RimMax",Range(0,2))=1.0
        [HDR]_InnerColor("InnerColor",Color)=(0,0,0,0)
        _InnerAlpha("InnerAlpha",Range(-1.0,1.0))=0.0
        [HDR]_RimColor("RimColor",Color)=(1,1,1,1)
        _RimIntensity("RimIntensity",Float)=1.0
        [NoScaleOffset]_FlowTex("FlowTex",2D)="black"{}
        _FlowColor("FlowColor",Color)=(1,1,1,1)
        _FlowTilling("FlowTilling",Vector)=(1,1,0,0)
        _FlowSpeed("FlowSpeed",Vector)=(1,1,0,0)
        _FlowIntensity("FlowIntensity",Float)=1.0
        _WarpTex("WarpTex",2D)="white"{}
        _WarpIntensity("WapIntensity",Range(0,1))=0.0
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
                float3 normal:NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPivot:TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;  
                float4 TtoW1 : TEXCOORD3;  
                float4 TtoW2 : TEXCOORD4; 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _FlowTex;

            sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

            float _TexPower;
            float _RimMin;
            float _RimMax;
            float4 _InnerColor;
            float _InnerAlpha;
            float4 _RimColor;
            float _RimIntensity;
            float4 _FlowTilling;
            float4 _FlowSpeed;
            float4 _FlowColor;
            float _FlowIntensity;
            sampler2D _WarpTex;
            float4 _WarpTex_ST;
            float _WarpIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv =v.texcoord;

                //o.worldPivot=mul(unity_ObjectToWorld,float4(0,0,0,1)).xyz;
                o.worldPivot=v.vertex.xyz;

                TANGENT_SPACE_ROTATION;
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
                
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                half3 worldView=normalize(UnityWorldSpaceViewDir(worldPos));
                half NdotV=saturate(dot(bump,worldView));
                half fresnel=1.0-NdotV;
                fresnel=smoothstep(_RimMin,_RimMax,fresnel);

                fixed4 emissTex = tex2D(_MainTex, i.uv);
                fixed emiss=pow(emissTex.r,_TexPower);

                half final_fresnel=saturate(fresnel+emiss*emissTex.a);
                //return final_fresnel;
                half3 final_rim_color=lerp(_InnerColor.xyz,_RimColor.xyz*_RimIntensity,final_fresnel);
                half final_rim_alpha=final_fresnel;

                half2 uv_flow=(i.worldPivot.zy+float2(150,150))*_FlowTilling.xy;
                half2 uv_warp=uv_flow;
                uv_flow=uv_flow+_Time.y*_FlowSpeed.xy;

                half3 warpValue=tex2D(_WarpTex,TRANSFORM_TEX(uv_warp,_WarpTex)).rgb;
                float2 uvBias=(warpValue-0.5)*_WarpIntensity;//uv扰动

                float4 flow_rgba=tex2D(_FlowTex,uv_flow + uvBias)*_FlowColor*_FlowIntensity;
                //return flow_rgba;
                fixed3 final_color=final_rim_color+flow_rgba.xyz*fresnel;
                fixed final_alpha=saturate(final_rim_alpha+_InnerAlpha+0.1*emissTex.a);

                return fixed4(final_color,final_alpha);
            }
            ENDCG
        }
    }
}
