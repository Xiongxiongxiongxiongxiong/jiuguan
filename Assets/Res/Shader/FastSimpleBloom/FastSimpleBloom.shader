Shader "Hidden/FastSimpleBloom"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
		_LuminanceThreshold ("Luminance Threshold", Range(0, 4)) = 0.6
        _Iterations ("Iterations", Range(0, 4)) = 1
		_BlurSize ("Blur Size", Range(0, 0.5)) = 0.05
        _BlurSpread ("Blur Spread", Float) = 1
        _Glow ("Glow", Float) = 128
        _Adapted_lum("Adapted Lum", float) = 0.6
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
		    half4 _MainTex_TexelSize;
		    float _LuminanceThreshold;
            float _Iterations;
		    float _BlurSize;
            float _BlurSpread;
            float _Glow;
            float _Adapted_lum;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };

            fixed luminance(fixed4 color) {
			    return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
		    }

            float4 GetBloom (float2 uv, float4 inColor )
            {
	            float numSamples = 1;
                float4 color = inColor;

	            for (float x = -8.0; x <= 8.0; x += 1.0)
	            {
		            for (float y = -8.0; y <= 8.0; y += 1.0)
		            {
			            float4 addColor = tex2D(_MainTex, uv + (float2(x, y) / _ScreenParams.xy));
                        //if (max(addColor.r, max(addColor.g, addColor.b)) > _LuminanceThreshold)
			            if (Luminance(addColor) > _LuminanceThreshold)
			            {
				            float dist = length(float2(x,y))+_BlurSpread;
				            float4 glowColor = max((addColor * _Glow) / pow(dist, _Iterations), (0.0));
				            if (Luminance(addColor) > 0.0)
				            {
					            color += glowColor;
					            numSamples += 1.0;
				            }
			            }
		            }
	            }
    
	            return color / numSamples;
            }

            // ACES tone mapping curve fit to go from HDR to LDR
            // Reference: https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
            float3 ACESFilm(float3 x, float adapted_lum)
            {                
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                x *= adapted_lum;
                return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.uv = v.uv.xy;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv.xy);
                c.rgb = ACESFilm(c.rgb, _Adapted_lum);
                c = lerp(c, GetBloom(i.uv.xy, c), _BlurSize);
                
                return half4(c.rgb,1);
            }
            ENDCG
        }
    }
}
