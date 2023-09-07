﻿Shader "Custom/Alpha" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		[Enum(Off,0,On,1)]_Zwrite("Zwrite",int) = 1
	}
		SubShader{
			Tags { "Queue" = "Transparent" "RenderType" = "Transparent"}


			Pass
			{
				ZWrite [_Zwrite]
				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct v2f
				{
					float4 vertex : SV_POSITION;
				};


				fixed4 _Color;

				v2f vert(appdata_base v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					return _Color;
				}
				ENDCG
			}
	}
		FallBack "Diffuse"
}