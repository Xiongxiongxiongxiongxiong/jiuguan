Shader "XingFei/PostProcess/PostProcess Moble"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "" {}
	}

	CGINCLUDE

	#include "UnityCG.cginc"
	struct v2fb {
		half4 pos : POSITION;
		half4 uv : TEXCOORD0;
	};
	struct v2f {
		half4 pos : POSITION;
		half2 uv  : TEXCOORD0;
	};

	sampler2D _MainTex;
	sampler2D _LutTex;
	sampler2D _MaskTex;
	sampler2D _BlurTex;
	uniform half _LutAmount;
	uniform half _BloomThreshold;
	uniform half _BloomAmount;
	uniform half _BlurAmount;
	uniform half4 _MainTex_TexelSize; // (1 / width, 1 / height, width, height) passed by Unity

	v2fb vertBlur(appdata_img v)
	{
		v2fb o;
		o.pos = UnityObjectToClipPos(v.vertex);
		half2 offset = (_MainTex_TexelSize.xy) * _BlurAmount;
		o.uv = half4(v.texcoord.xy - offset, v.texcoord.xy + offset); // ( offsetLeftX, offsetBottomY, offsetRightX, offsetTopY )
		return o;
	}

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 

	fixed2 GetUV(fixed4 c)
	{
		half b = floor(c.b * 256.0h);
		half by = floor(b *0.0625h);
		half bx = floor(b - by * 16.0h);
		half2 uv = c.rg *0.05859375h + 0.001953125h + half2(bx, by) *0.0625h;
		return uv;
	}
	fixed4 fragBloom(v2fb i) : COLOR 
	{
		fixed4 result = tex2D(_MainTex, i.uv.xy); // sample (offsetLeftX, offsetBottomY)
		result += tex2D(_MainTex, i.uv.xw); // sample (offsetLeftX, offsetTopY)
		result += tex2D(_MainTex, i.uv.zy); // sample (offsetRightX, offsetBottomY)
		result += tex2D(_MainTex, i.uv.zw); // sample (offsetRightX, offsetTopY)
		return max(result*0.25h - _BloomThreshold, 0.0h);
	}
	fixed4 fragBloomWill(v2fb i) : COLOR 
	{
		fixed4 result = tex2D(_MainTex, i.uv.xy); // sample (offsetLeftX, offsetBottomY)
		return max(result - _BloomThreshold, 0.0h);
	}

	fixed4 fragBlur(v2fb i) : COLOR
	{
		fixed4 result = tex2D(_MainTex, i.uv.xy); // sample (offsetLeftX, offsetBottomY)
		result += tex2D(_MainTex, i.uv.xw); // sample (offsetLeftX, offsetTopY)
		result += tex2D(_MainTex, i.uv.zy); // sample (offsetRightX, offsetBottomY)
		result += tex2D(_MainTex, i.uv.zw); // sample (offsetRightX, offsetTopY)
		return result * 0.25h;
	}

	fixed4 fragLut(v2f i) : COLOR 
	{
		fixed4 c = tex2D(_MainTex, i.uv);
		fixed4 lc= tex2D(_LutTex, GetUV(c));
		return lerp(c,lc, _LutAmount);
	}

	fixed4 fragBlurOnly(v2f i) : COLOR
	{
		fixed4 c = tex2D(_MainTex, i.uv);
		fixed4 b = tex2D(_BlurTex, i.uv);
		//fixed4 m = tex2D(_MaskTex, i.uv);
		return b; //lerp(c, b, m.r);
	}

	fixed4 fragBlurBloom(v2f i) : COLOR
	{
		fixed4 c = tex2D(_MainTex, i.uv);
		fixed4 b = tex2D(_BlurTex, i.uv) * _BloomAmount;
		return (c + b); //(c + b)*0.5h; 作者原来代码是乘以 0.5，场景会变暗
		
	}

	fixed4 fragBlurLut(v2f i) : COLOR
	{
		fixed4 c = tex2D(_MainTex, i.uv);
		fixed4 b = tex2D(_BlurTex, i.uv);
		fixed4 m = tex2D(_MaskTex, i.uv);
		fixed4 lc = lerp(c,tex2D(_LutTex, GetUV(c)), _LutAmount);
		fixed4 lb = lerp(b,tex2D(_LutTex, GetUV(b)), _LutAmount);
		return lerp(lc, lb, m.r);
	}

	fixed4 fragAll(v2f i) : COLOR
	{
		fixed4 c = tex2D(_MainTex, i.uv);
		fixed4 b = tex2D(_BlurTex, i.uv);
		fixed4 lc = lerp(c,tex2D(_LutTex, GetUV(c)), _LutAmount);
		fixed4 lb = lerp(b,tex2D(_LutTex, GetUV(b)), _LutAmount)*_BloomAmount;
		return (lc + lb)*0.5h;
	}

	ENDCG 
		
	Subshader 
	{
		Pass //0
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }      

	      CGPROGRAM
	      #pragma vertex vertBlur
	      #pragma fragment fragBlur
	      #pragma fragmentoption ARB_precision_hint_fastest
	      ENDCG
	  	}
		Pass //1
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }

		  CGPROGRAM
		  #pragma vertex vertBlur
		  #pragma fragment fragBloom
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //2
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragLut
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //3
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragBlurOnly
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //4
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragBlurBloom
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //5
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragBlurLut
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
		Pass //6
		{
		  ZTest Always Cull Off ZWrite Off
		  Fog { Mode off }
		  CGPROGRAM
		  #pragma vertex vert
		  #pragma fragment fragAll
		  #pragma fragmentoption ARB_precision_hint_fastest
		  ENDCG
		}
	}

	Fallback off
}