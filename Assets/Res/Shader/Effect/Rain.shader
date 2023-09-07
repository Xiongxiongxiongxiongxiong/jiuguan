/**
  * @file       Rain.shader
  * @brief      下雨特效，可以开启雨雾特效
  */
Shader "XF/Effect/Rain"
{
    Properties
    {
        [Header(Size)]
        _Scale("体积缩放",Vector) = (2,5,2,1)

        [Header(Rain)]
        _MainTex ("雨滴贴图 (注意FilterMode)", 2D) = "white" {}
        _RainAmount("降雨量", Range(0,1)) =0.3
        _RainAlphaTop("雨开始消隐的高度",Range(0,1)) = 0.431
        _RainAlphaBottom("雨彻底消隐的高度",Range(0,1)) = 0.18

        [Header(First Rain)]
        _FirstColor("Color, a:雨透明度",Color) = (1,1,1,0.8)
        _FirstRainDensity("第一层雨的密度",Float) = 2.08
        _FirstRainLength("第一层雨滴长度(值越大越短)",Float) = 0.19
        _FirstRainSpeed("第一层雨的速度",Float) = 1.62
        _SecRainSpeed("第一层雨的横向速度",Float) = 1.62

        [Header(Second Rain)]
        _SecondColor("Color, a:雨透明度",Color) = (1,1,1,0.65)
        _SecondRainDensity("第二层雨的密度",Float) = 2.81
        _SecondRainLength("第二层雨滴长度(值越大越短)",Float) = 1.5
        _SecondRainSpeed("第二层雨的速度",Float) = 1.31
        [Header(Third Rain)]
        _ThirdColor("Color, a:雨透明度",Color) = (1,1,1,0.5)
        _ThirdRainDensity("第三层雨的密度",Float) = 3.66
        _ThirdRainLength("第三层雨滴长度(值越大越短)",Float) = 4.3
        _ThirdRainSpeed("第三层雨的速度",Float) = 1.1

        [Space]
        [Header(Fog)]
        [Toggle]_NoiseFog("启用噪声雾",Float) = 0.0
        _FogColor("Color",Color) = (1,1,1,1)
        _FogTex("雾噪声",2D) = "white" {}
        _FogDensity("雾浓度",Range(0,5)) = 2.25
        _FogAttenThreshold("雾消隐高度", Range(-0.5,0.5) ) = 0.034
        _FogSizeVelocity1("雾1 xy:尺寸 zw:速度(水平,垂直)", Vector) = (1,1,-0.03,0.1)
        _FogSizeVelocity2("雾2 xy:尺寸 zw:速度(水平,垂直)", Vector) = (0.7, 0.7,0.02, 0.12)
    }
    SubShader
    {
        Tags {
			"IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100

        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM

            //#pragma only_renderers d3d9 d3d11 glcore gles
            #pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu

            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile _ _NOISEFOG_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 uv1 :TEXCOORD1;
                float4 uv2 :TEXCOORD2;
                float2 meshUV:TEXCOORD3;
                float4 vertex : SV_POSITION;
            };

            float4 _Scale;

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _RainAmount;
            fixed _RainAlphaTop;
            fixed _RainAlphaBottom;
            
            fixed4 _FirstColor;
            float _FirstRainDensity;
            float _FirstRainLength;
            float _FirstRainSpeed;
            float _SecRainSpeed;

            fixed4 _SecondColor;
            float _SecondRainDensity;
            float _SecondRainLength;
            float _SecondRainSpeed;

            fixed4 _ThirdColor;
            float _ThirdRainDensity;
            float _ThirdRainLength;
            float _ThirdRainSpeed;

            fixed4 _FogColor;
            fixed _FogDensity;
            sampler2D _FogTex;
            float4 _FogTex_ST;
            float4 _FogSizeVelocity1;
            float4 _FogSizeVelocity2;
            fixed _FogAttenThreshold;

            inline fixed4 calcRain( fixed4 col,  fixed4 color, fixed rainAmount ){
                col.rgb *= color.rgb;
                fixed lum = Luminance(col.rgb);
                fixed clipValue = step( lum, rainAmount );
                col.a = lum * clipValue * color.a;
                col.rgb *= clipValue* color.a;
                return col;
            }

            inline fixed linearLerp( fixed left, fixed right, fixed factor ){
                return saturate( ( factor - left ) / ( max( 0.01, right - left ) ));
            }


            v2f vert (appdata v)
            {
                v2f o;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                float4x4  modelMatrix = float4x4(
                    _Scale.x, 0, 0, UNITY_MATRIX_M._14,
                    0, _Scale.y, 0, UNITY_MATRIX_M._24,
                    0, 0, _Scale.z, UNITY_MATRIX_M._34,
                    0.0f, 0.0f, 0.0f, 1.0f
                );
                o.vertex = mul( UNITY_MATRIX_VP, mul( modelMatrix, v.vertex ));

                // Rain

                float2 originUV = TRANSFORM_TEX(v.uv, _MainTex);

                o.uv.x = originUV.x * _FirstRainDensity + _Time.y * _SecRainSpeed;
                o.uv.y = originUV.y * _FirstRainLength + _Time.y * _FirstRainSpeed;
                
                o.uv.z = originUV.x * _SecondRainDensity + 0.0123;
                o.uv.w = originUV.y * _SecondRainLength + _Time.y * _SecondRainSpeed;
                
                o.uv1.x = originUV.x * _ThirdRainDensity + 0.0652;
                o.uv1.y = originUV.y * _ThirdRainLength + _Time.y * _ThirdRainSpeed;
                o.uv1.zw = 0;

                // Fog
                float2 fogOriginUV = TRANSFORM_TEX(v.uv, _FogTex);
                o.uv2.xy = fogOriginUV * _FogSizeVelocity1.xy + _Time.yy * _FogSizeVelocity1.zw;
                o.uv2.zw = fogOriginUV * _FogSizeVelocity2.xy + _Time.yy * _FogSizeVelocity2.zw;
                o.meshUV.xy = v.uv.xy;

                return o;
            }
            

            fixed4 frag (v2f i) : SV_Target
            {
                // 多层雨
                fixed4 texCol = tex2D(_MainTex,  i.uv.xy);
                fixed4 col = calcRain( fixed4(texCol.rrr, texCol.a), _FirstColor, _RainAmount );
                texCol = tex2D(_MainTex,  i.uv.zw);
                col += calcRain(fixed4(texCol.ggg, texCol.a), _SecondColor, _RainAmount);
                texCol = tex2D(_MainTex,  i.uv1.xy);
                col += calcRain(fixed4(texCol.bbb, texCol.a), _ThirdColor, _RainAmount);
                col *= linearLerp( _RainAlphaBottom, _RainAlphaTop, i.meshUV.y );
                fixed rainTopAtten = saturate( 2.0 * ( 1.0 - i.meshUV.y * i.meshUV.y ) );
                col *= rainTopAtten;

#if _NOISEFOG_ON
                // 限定垂直方向上雾效的区域
                fixed fogDownAtten = i.meshUV.y + _FogAttenThreshold;
                fogDownAtten = linearLerp( 0.47, 0.55, fogDownAtten );
                fixed fogAtten = 1.0 - i.meshUV.y;
                fogAtten = linearLerp( 0.25, 0.4, fogAtten );
                fogAtten *= fogDownAtten;

                // 隐藏在UV接缝处的雾效，因为接缝对雾效很明显
                fixed fogHoriAtten = abs( i.meshUV.x * 2.0 - 1.0 );
                fogAtten *= 1.0 - fogHoriAtten * fogHoriAtten* fogHoriAtten* fogHoriAtten* fogHoriAtten ;

                // 多层雾效
                fixed4 fog = tex2D(_FogTex, 1 - i.uv2.xy) * _FogColor * fogAtten;
                fixed4 fog2 = tex2D(_FogTex, 1 - i.uv2.zw) * _FogColor * fogAtten;
                col.rgb = saturate( col.rgb + (fog.rgb + fog2.rgb) * _FogDensity );
                col.a = max( col.a, Luminance(fog.rgb + fog2.rgb) * _FogDensity );    

#endif
                return col;
            }
            ENDCG
        }
    }
}
