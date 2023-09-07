/**
  * @file       PostProcessTestorShader.shader
  * @author     GuoYi<guoyi@xingfeiinc.com>
  * @date       2018/11/28

  这个 Shader 不使用！！！！！！！！！！！！！！
  */

Shader "XingFei/Test/PostProcessTestor"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RandomTex("RandomTex", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off
		ZWrite Off
		ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#pragma target 3.0

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				// float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v, out float4 vertex : SV_POSITION)
			{
				v2f o;
				// o.vertex = UnityObjectToClipPos(v.vertex);
				vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			uniform sampler2D _MainTex;
			uniform sampler2D _RandomTex;

			half4 frag (v2f i, UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);

				half screenPosX = round(screenPos.x);
				half screenPosY = round(screenPos.y);

				// if( screenPosX < 100 )
				// 	return half4(1,0,0,1);

				half randomValue = tex2D(_RandomTex, i.uv).r;
				randomValue = tex2D( _RandomTex, half2(screenPosX/512, screenPosY/512) ).r;

				randomValue = randomValue * 0.5h + 0.5h;

				// return half4(randomValue.rrr, 1);

				half4 res = half4(0,0,0,col.a);

				res.r = col.r * 0.393h + col.g * 0.769h + col.b * 0.189h;
				res.g = col.r * 0.349h + col.g * 0.686h + col.b * 0.168h;
				res.b = col.r * 0.272h + col.g * 0.534h + col.b * 0.131h;

				res.rgb = randomValue * res.rgb + (1-randomValue) * col.rgb;
				// res.rgb = randomValue * res.rgb + (1-randomValue) * 0.1h * col.rgb;

				return res;
			}
			ENDCG
		}
	}
}
