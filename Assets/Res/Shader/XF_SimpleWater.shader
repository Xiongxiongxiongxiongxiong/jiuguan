Shader "XF/XF_SimpleWater" {
	Properties {
		_Color ("Main Color", Color) = (0, 0.15, 0.115, 1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_WaveMap ("Wave Map", 2D) = "bump" {}
		_Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}
		[IntRange]_Level ("Env Level", Range(0,5)) = 1
		_WaveXSpeed ("Wave Horizontal Speed", Range(-0.1, 0.1)) = 0.01
		_WaveYSpeed ("Wave Vertical Speed", Range(-0.1, 0.1)) = 0.01		
		//_SpecularColor("Specular Color",color) = (1,1,1,1)
		//_Water03("Specular: Distort(X) Intensity(Y) Smoothness(Z)",vector) = (0.8,5,8,0)
	}
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }		
		 
		Pass
        {
			ZWrite On
			ColorMask 0
		} 

		Pass {
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			
			#pragma vertex vert
			#pragma fragment frag
			
			//float4 _Water03;
			//float4 _SpecularColor;
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _WaveMap;
			float4 _WaveMap_ST;
			samplerCUBE _Cubemap;
			float _Level;
			fixed _WaveXSpeed;
			fixed _WaveYSpeed;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT; 
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;  
				float4 TtoW1 : TEXCOORD3;  
				float4 TtoW2 : TEXCOORD4; 
				UNITY_FOG_COORDS(5)

			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.scrPos = ComputeGrabScreenPos(o.pos);
				
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _WaveMap);
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
				
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  

				
                UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				
				//float specularDistort = _Water03.x;
				//float specularIntensity = _Water03.y;
	            //float specularSmoothness = _Water03.z;
				
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldNormal = normalize(float3(i.TtoW0.z, i.TtoW1.z, i.TtoW2.z));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);
				
				// Get the normal in tangent space
				fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
				fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
				fixed3 bump = normalize(bump1 + bump2);			
				// Convert the normal to world space
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

				//水的高光
                //Specular = SpecularColor * Ks * pow(max(0,dot(N,H)), Shininess)
                //half3 N = lerp(worldNormal,bump,specularDistort);
                //half3 L = _WorldSpaceLightPos0;
                //half3 V = normalize(_WorldSpaceCameraPos.xyz - worldPos);
                //half3 H = normalize(L+V);
                //half4 specular = _SpecularColor * specularIntensity * pow(saturate(dot(N,H)),specularSmoothness);
								
				fixed4 texColor = tex2D(_MainTex, i.uv.xy + speed);
				fixed3 reflDir = reflect(-viewDir, bump);
				fixed3 reflCol = texCUBElod(_Cubemap, float4(reflDir,_Level)).rgb;// * _Color.rgb;
				
				fixed fresnel = pow(1 - saturate(dot(viewDir, bump)), 4);
				fixed3 finalColor =_Color.rgb * texColor.rgb + reflCol * fresnel;// * specular;

				UNITY_APPLY_FOG(i.fogCoord, finalColor);
				return fixed4(finalColor, _Color.a);
			}
			
			ENDCG
		}
	}
	// Do not cast shadow
	FallBack Off
}
