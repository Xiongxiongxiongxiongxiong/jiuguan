/**
  * @file       CaptureMapPostProcess.shader
  * @author     GuoYi<guoyi@xingfeiinc.com>
  * @date       2018/11/16
  */

Shader "XingFei/PostProcess/CaptureMap" {
	Properties {
		_MainTex("MainTex", 2D) = "white" {}

		_ContourStartHeight("ContourStartHeight", Float) = 100 // 从这个高度开始绘制等高线
		_ContourEndHeight("ContourEndHeight", Float) = 600 // 超过这个高度以后不再绘制等高线
		_ContourHeightStep("ContourHeightStep", Float) = 30 // 等高线绘制步长（每隔这样一段高度差，绘制一条等高线）
		_ContourHeightRadius("ContourHeightRadius", Float) = 5 // 等高线绘制半径（eg，取值为5时，在高度h处，在高度[h-5,h+5]的区间内，绘制一条厚度为10的等高线）
	}

	SubShader {
		ZTest Always
		Cull Off
		ZWrite Off

		Pass {
			CGPROGRAM

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			#pragma skip_variants DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON FOG_EXP FOG_EXP2 LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL_COOKIE POINT_COOKIE DIRECTIONAL FOG_LINEAR LIGHTMAP_ON LIGHTPROBE_SH
			#pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH SHADOWS_SCREEN

			uniform sampler2D _MainTex;
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

			uniform half _ContourStartHeight;
			uniform half _ContourEndHeight;
			uniform half _ContourHeightStep;
			uniform half _ContourHeightRadius;

			struct VertexInput {
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct VertexOutput {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			VertexOutput vert(VertexInput input) {
				VertexOutput o = (VertexOutput)0;
				o.pos = UnityObjectToClipPos(input.pos);
				o.uv = input.uv;
				return o;
			}
			half4 frag(VertexOutput input) : SV_Target {
				float depth = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, input.uv );

#if defined(UNITY_REVERSED_Z) // z-buffer 的取值范围、从near plane到far plane、不是[0,1]、是[1,0]
				depth = saturate(1-depth);
#endif

				depth = (_ProjectionParams.z-_ProjectionParams.y) * depth + _ProjectionParams.y; // z-buffer value: [0,1] -> [near,far]

				float cameraPosY = _WorldSpaceCameraPos.y;
				float pixelPosY = cameraPosY - depth; // pixel在 world space coordinate 的高度

				half4 texColor = tex2D(_MainTex, input.uv);
				half4 res = texColor;
				// res.rgb = texColor.rrr;
				res.rgb *= 0.5f;
				res.a = 0;

				for( float perH = _ContourStartHeight; perH <= _ContourEndHeight; perH = perH+_ContourHeightStep ) {
					if( pixelPosY >= perH-_ContourHeightRadius && pixelPosY <= perH+_ContourHeightRadius ) {
						res = half4(1,0,0,1);
					}
				}

				return res;
			}

			ENDCG
		}
	}
}