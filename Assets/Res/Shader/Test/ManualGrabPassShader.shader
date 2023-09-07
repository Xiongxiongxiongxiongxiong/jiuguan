
Shader "XingFei/Test/ManualGrabPassShader" {
	Properties {
		_MainTex("MainTex", 2D) = "white" {} // Unity潜规则：必须叫"_MainTex"，否则可能无法正确读取src render texture
	}
	SubShader {
		Tags {
			"RenderType" = "Opaque"
			"Queue" = "Geometry+1"
		}

		Pass { // pass 0: clear render texture
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
				#pragma target 3.0
				#include "UnityCG.cginc"
				#pragma vertex vert_img
				#pragma fragment frag

				float4 frag(v2f_img i) : SV_Target {
					return float4(0,0,0,1);
				}
			ENDCG
		}

		// pass 1: characters
		Pass {
			Stencil{
				Ref 2
				ReadMask 6
				Comp Equal
				Pass Keep
				Fail Keep
				ZFail Keep
			}
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
				#pragma target 3.0
				#include "UnityCG.cginc"
				#pragma vertex vert_img
				#pragma fragment frag

				uniform sampler2D _MainTex;

				float4 frag(v2f_img i) : SV_Target {
					float4 mainC = tex2D(_MainTex, i.uv);
					return mainC;
				}
			ENDCG
		}

		// pass 2: scene
		Pass {
			Stencil{
				Ref 4
				ReadMask 6
				Comp Equal

				// Ref 2
				// ReadMask 6
				// Comp NotEqual

				Pass Keep
				Fail Keep
				ZFail Keep
			}
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
				#pragma target 3.0
				#include "UnityCG.cginc"
				#pragma vertex vert_img
				#pragma fragment frag

				uniform sampler2D _MainTex;

				float4 frag(v2f_img i) : SV_Target {
					float4 mainC = tex2D(_MainTex, i.uv);
					return mainC;
				}
			ENDCG
		}

		// pass 3: test
		Pass {

			CGPROGRAM
				#pragma target 3.0
				#include "UnityCG.cginc"
				#pragma vertex vert_img
				#pragma fragment frag

				uniform sampler2D _MainTex;
				uniform sampler2D _CharTex;
				uniform sampler2D _SceneTex;

				float4 frag(v2f_img i) : SV_Target {
					float4 mainC = tex2D(_MainTex, i.uv);
					float4 charC = tex2D(_CharTex, i.uv);
					float4 sceneC = tex2D(_SceneTex, i.uv);

					return charC;
					// return sceneC;

					// float grayChar = charC.r * .3 + charC.g * .59 + charC.b * .11;
					// float4 res = float4(0,0,0,1);
					// res.rgb = float3(grayChar,grayChar,grayChar) + sceneC.rgb;
					// return res;
				}
			ENDCG
		}
	}
	FallBack Off
}
