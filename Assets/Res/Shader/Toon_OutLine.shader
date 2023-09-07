Shader "MT/Toon_OutLine"
{
	Properties
	{
		[HDR]_OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
		[HDR]_TopColor ("Top Color", Color) = (1, 1, 1, 0)
		[HDR]_ButtomColor ("Buttom Color", Color) = (0.2, 0.2, 0.2, 0)
		_Hight ("Hight", float) = 1
		_MainTex ("Texture", 2D) = "white" { }
		_Outline ("Outline", Range(0.003, 0.5)) = 0.03

		_RimPower ("Rim Power", float) = 5
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Cull Front
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			
			#include "UnityCG.cginc"
			float _Outline ;
			struct appdata
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float4 vertex: SV_POSITION;
			};

			
			v2f vert(appdata v)
			{
				v2f o;
				float3 localpos = v.vertex + v.normal * _Outline;
				o.vertex = UnityObjectToClipPos(localpos);
				return o;
			}
			half4 _OutlineColor;
			fixed4 frag(v2f i): SV_Target
			{

				return _OutlineColor;
			}
			ENDCG
			
		}

		Pass
		{
			Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
			
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "Autolight.cginc"

			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv: TEXCOORD0;
				float3 worldNormal: NORMAL;
				UNITY_FOG_COORDS(1)
				float4 pos: SV_POSITION;
				SHADOW_COORDS(2)
				float4 uvgrab: TEXCOORD3;
				float3 viewDir: TEXCOORD4;
			};

			sampler2D _MainTex;
			half4 _TopColor, _ButtomColor, _OutlineColor;
			float4 _MainTex_ST;
			half _Hight, _RimPower;
			//sampler2D _RefractionTex;
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - pos_world);

				#if UNITY_UV_STARTS_AT_TOP
					float scale = -1;
				#else
					float scale = 1;
				#endif
				// o.uvgrab.xy = (float2(o.pos.x, o.pos.y * scale) + o.pos.w) * 0.5;
				// o.uvgrab.zw = o.pos.zw;
			//	o.uvgrab = ComputeGrabScreenPos(o.pos);
				
				UNITY_TRANSFER_FOG(o, o.pos);
				TRANSFER_SHADOW(o);
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				half4 hightmask = lerp(_TopColor, _ButtomColor, saturate(1 - i.uv.y * _Hight));
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * hightmask;

				//Lighting
				float3 N = normalize(i.worldNormal);
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				fixed atten = SHADOW_ATTENUATION(i);
				//float NdL = max(0, step(0.001, dot(N, L) * atten));
				float NdL = dot(N, L) * atten;

				//Rim
				float NdotV = saturate(dot(i.worldNormal, i.viewDir));
				float3 rim = pow((1.0 - NdotV), _RimPower) * _OutlineColor;
				NdL = NdL * 0.5 + 0.5;
				half3 finalCol = col.rgb ;
				
				//
				//fixed4 RefractionCol = tex2D(_RefractionTex, i.uvgrab.xy / i.uvgrab.w);
				//finalCol.rgb = lerp(finalCol.rgb, RefractionCol.rgb, saturate( i.uv.y * _Hight)-0.5);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return half4(finalCol, 1);
			}
			ENDCG
			
		}

		pass
		{
			Tags { "LightMode" = "ShadowCaster" }
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 pos: SV_POSITION;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f o): SV_Target
			{
				SHADOW_CASTER_FRAGMENT(o)
			}
			
			ENDCG
			
		}
	}
}
