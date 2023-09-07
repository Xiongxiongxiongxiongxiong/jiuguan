/**
  * @file       UI-Sepia.shader
  * @author     GuoYi<guoyi@xingfeiinc.com>
  * @date       2018/11/28
  */

Shader "XingFei/UI/UI-Sepia" {
	Properties {
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		[PerRendererData] _AlphaTex("Sprite Alpha Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}
	SubShader {
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass {
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				#include "UnityUI.cginc"

				#pragma multi_compile __ UNITY_UI_ALPHACLIP

				struct appdata_t
				{
					float4 vertex   : POSITION;
					half4 color    : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex   : SV_POSITION;
					half4 color    : COLOR;
					half2 texcoord  : TEXCOORD0;
					float4 objpos : TEXCOORD1;
				};

				uniform half4 _Color;
				uniform half4 _TextureSampleAdd;
				uniform float4 _ClipRect;
				uniform sampler2D _MainTex;
				uniform sampler2D _AlphaTex;

				inline half4 RKT_GetUIDiffuseColor(in float2 position, in sampler2D mainTexture, in sampler2D alphaTexture, half4 textureSampleAdd)
				{
					half4 col = tex2D(mainTexture, position);
					col.rgb += textureSampleAdd.rgb ;
					col.a *= tex2D(alphaTexture, position).r + textureSampleAdd.a ;  // 兼容非ETC模式
					return col;
				}

				v2f vert(appdata_t IN)
				{
					v2f OUT;
					OUT.objpos = IN.vertex;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);
					OUT.texcoord = IN.texcoord;
	#ifdef UNITY_HALF_TEXEL_OFFSET
					OUT.vertex.xy += (_ScreenParams.zw-1.0) * float2(-1,1) * OUT.vertex.w;
	#endif
					OUT.color = IN.color * _Color;
					return OUT;
				}

				half4 frag(v2f IN) : SV_Target
				{
					// half4 color = tex2D(_MainTex, IN.texcoord) * IN.color;
					half4 color = RKT_GetUIDiffuseColor(IN.texcoord, _MainTex, _AlphaTex, _TextureSampleAdd);

					color.a *= UnityGet2DClipping(IN.objpos.xy, _ClipRect);
#ifdef UNITY_UI_ALPHACLIP
					clip (color.a - 0.01);
#endif

					half4 res = half4(0, 0, 0, color.a);
					res.r = color.r * 0.393h + color.g * 0.769h + color.b * 0.189h;
					res.g = color.r * 0.349h + color.g * 0.686h + color.b * 0.168h;
					res.b = color.r * 0.272h + color.g * 0.534h + color.b * 0.131h;
					res.rgb = color.rgb * 0.05h + res.rgb * 0.95h; // TODO: 改成采样 random noise texture，老照片效果
					res.rgb *=  IN.color.rgb;
					return res;
				}
			ENDCG
		}
	}
}
