Shader "XF/XF_MetalReflection" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_Specular ("Specular Color", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20

		[Space][Space][Space][Space]
		[Header(Reflection)]
		_ReflectColor ("Reflection Color", Color) = (1, 1, 1, 1)
		_ReflectColorStrength("Reflection Color Strength", Range(1, 5)) = 1
		_ReflectAmount ("Reflect Amount", Range(0, 1)) = 1
		_Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
		[IntRange]_MipLevel("MipLevel", Range(0, 8)) = 0

		[Space][Space][Space][Space]
		[Header(Rim)]
		_RimColor ("Rim Color", Color) = (0.17, 0.36, 0.81, 0.0)
        _RimPower ("Rim Power", Range(0.6, 36.0)) = 8.0
        _RimIntensity ("Rim Intensity", Range(0.0, 100.0)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass { 
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			
			#pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
			fixed4 _ReflectColor;
			fixed _ReflectColorStrength;
			fixed _ReflectAmount;
			samplerCUBE _Cubemap;
			float _MipLevel;

			half4 _RimColor;
            half _RimPower;
            half _RimIntensity;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;  
                float4 TtoW1 : TEXCOORD2;  
                float4 TtoW2 : TEXCOORD3; 
			};
			
			v2f vert(a2v v) {
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;			 	
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

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
			
			fixed4 frag(v2f i) : SV_Target {				
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				
				fixed3 worldRefl = reflect(-viewDir, bump);

				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

				//fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo * (max(0, dot(bump, lightDir)) * 0.5 +0.5);

				fixed3 halfDir = normalize(lightDir + viewDir);
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);
				
				// Use the reflect dir in world space to access the cubemap
				fixed3 reflection = texCUBElod(_Cubemap, half4(worldRefl, _MipLevel)).rgb * _ReflectColor.rgb * _ReflectColorStrength;


				//rim
                half rim = (1.0 - saturate(dot(viewDir, bump))) * _RimIntensity;
                half3 rimCol = pow(rim, _RimPower) * _RimColor;
				
				// Mix the diffuse color with the reflected color
				fixed3 color =  diffuse + saturate(rimCol) + (lerp(0, reflection, _ReflectAmount) + specular);
				
				return fixed4(color, 1.0);
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}
