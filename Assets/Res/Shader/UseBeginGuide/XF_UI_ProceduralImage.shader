﻿Shader "XF/UI/XF_ProceduralImage"
{
	Properties
	{
		[PerRendererData]_MainTex ("Base (RGB)", 2D) = "white" {}
		_Center("Center",Vector) = (0,0,0,0)
		_Width("Width", Float) = 100
		_Height("Height", Float) = 100
		_Radius("Radius", Vector) = (0,0,0,0)
		_PixelWorldScale("Pixel world scale", float) = 1
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		// required for UI.Mask
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        
        _ColorMask ("Color Mask", Float) = 15
	}
	SubShader
	{
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
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]
        
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			
			#pragma target 2.0

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				
			};

			struct v2f
			{
				float4 vertex   : POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};			
	
			fixed4 _TextureSampleAdd;
			
			float4 _ClipRect;
			
			half4 _Center;
			half _Width;
			half _Height;
			half _PixelWorldScale;
			half4 _Radius;
			half _LineWeight;
			sampler2D _MainTex;;
			
			v2f vert(appdata_t IN){
				v2f OUT;
				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
				OUT.texcoord = IN.texcoord;
				OUT.uv = IN.texcoord;
				#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
				#endif
				OUT.color = IN.color * (1 + _TextureSampleAdd);
				return OUT;
			}

			/*
			half visible(half2 pos,half4 r){
				half4 p = half4(pos,_Width-pos.x,_Height-pos.y);
				half v = min(min(min(p.x,p.y),p.z),p.w);
				if(all(p.xw<r[0])){
					//v = min(r[0]-distance(p.xw,half2(r[0],r[0])),v);
					v = min(r[0]-length(p.xw-r[0]),v);
				}
				else if(all(p.zw<r[1])){
					//v = min(r[1]-distance(p.zw,half2(r[1],r[1])),v);
					v = min(r[1]-length(p.zw-r[1]),v);
				}
				if(all(p.zy<r[2])){
					//v = min(r[2]-distance(p.zy,half2(r[2],r[2])),v);
					v = min(r[2]-length(p.zy-r[2]),v);
				}
				else if(all(p.xy<r[3])){
					//v = min(r[3]-distance(p.xy,half2(r[3],r[3])),v);
					v = min(r[3]-length(p.xy-r[3]),v);
				}
				return v;
			}
			*/

			//more optmised version without dynamic branching
			half visible(half2 pos,half4 r){
				half4 p = half4(pos,_Width-pos.x,_Height-pos.y);
				half v = min(min(min(p.x,p.y),p.z),p.w);
				bool4 b = bool4(all(p.xw<r[0]),all(p.zw<r[1]),all(p.zy<r[2]),all(p.xy<r[3]));
				half4 vis = r-half4(length(p.xw-r[0]),length(p.zw-r[1]),length(p.zy-r[2]),length(p.xy-r[3]));
				half4 foo = min(b*max(vis,0),v)+(1-b)*v;
				v = any(b)*min(min(min(foo.x,foo.y),foo.z),foo.w)+v*(1-any(b));
				return v;
			}

			fixed4 frag (v2f IN) : SV_Target
			{
				//half4 color = IN.color;
				half4 color = tex2D(_MainTex, IN.uv)*IN.color;

				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

				float2 dis = IN.worldPosition.xy - _Center.xy + float2(_Width/2, _Height/2);
                color.a *= 1-saturate(visible(dis,_Radius)*_PixelWorldScale);

				color.rgb *= color.a;

				return color;
			}
			ENDCG
		}
	}
}

