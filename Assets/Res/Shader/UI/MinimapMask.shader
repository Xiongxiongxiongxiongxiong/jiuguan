Shader "XingFei/MinimapMask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // 小地图
        [Header(Maps)]
        [NoScaleOffset]_MapTex00 ("MapTex00", 2D) = "white" {}
        [NoScaleOffset]_MapTex01 ("MapTex01", 2D) = "white" {}
        [NoScaleOffset]_MapTex02 ("MapTex02", 2D) = "white" {}
        [NoScaleOffset]_MapTex03 ("MapTex03", 2D) = "white" {}
        
        // 帮战范围圈等
        [Header(Images)]
        ImageColor("ImageColor", Color) = (1,0,0,0.5)
        [NoScaleOffset]_MapTex04 ("ImageTex04", 2D) = "white" {}
        [NoScaleOffset]_MapTex05 ("ImageTex05", 2D) = "white" {}

        _UvOffset("Uv Offset", Float) = 0.0
    }
    SubShader
    {
        Tags 
        { 
            "Queue"="Transparent-1" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
        }

        Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _SAMPLE_MAP0 _SAMPLE_MAP1 _SAMPLE_MAP2 _SAMPLE_MAP3

            #pragma multi_compile _ _SAMPLE_IMAGE0 _SAMPLE_IMAGE1

            #pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu

            #include "UnityCG.cginc"
            #include "../DataTypes.cginc"

            struct appdata
            {
                HighPrec4 vertex : POSITION;
                HighPrec2 uv : TEXCOORD0;
            };

            struct v2f
            {
                HighPrec2 uv : TEXCOORD0;
                HighPrec4 vertex : SV_POSITION;
#if _SAMPLE_MAP0
                HighPrec2 mapUv0 : TEXCOORD1;
#endif

#if _SAMPLE_MAP1
                HighPrec2 mapUv0 : TEXCOORD1;     
                HighPrec2 mapUv1 : TEXCOORD2;
#endif

#if _SAMPLE_MAP2
                HighPrec2 mapUv0 : TEXCOORD1;
                HighPrec2 mapUv1 : TEXCOORD2;
                HighPrec2 mapUv2 : TEXCOORD3;
#endif

#if _SAMPLE_MAP3
                HighPrec2 mapUv0 : TEXCOORD1;
                HighPrec2 mapUv1 : TEXCOORD2;
                HighPrec2 mapUv2 : TEXCOORD3;
                HighPrec2 mapUv3 : TEXCOORD4;
#endif

#if _SAMPLE_IMAGE0
                HighPrec2 mapUv4 : TEXCOORD5;
#endif

#if _SAMPLE_IMAGE1
                HighPrec2 mapUv4 : TEXCOORD5;
                HighPrec2 mapUv5 : TEXCOORD6;
#endif
            };

            sampler2D _MainTex;
            HighPrec4 _MainTex_ST;

            HighPrec _UvOffset;

#if _SAMPLE_MAP0
            sampler2D _MapTex00;
            HighPrec _Width00;
            HighPrec _Height00;
            float4x4 _MapMatrix00;
#endif            

#if _SAMPLE_MAP1
            sampler2D _MapTex00;
            HighPrec _Width00;
            HighPrec _Height00;
            float4x4 _MapMatrix00;

            sampler2D _MapTex01;
            HighPrec _Width01;
            HighPrec _Height01;
            float4x4 _MapMatrix01;
#endif

#if _SAMPLE_MAP2
            sampler2D _MapTex00;
            HighPrec _Width00;
            HighPrec _Height00;
            float4x4 _MapMatrix00;

            sampler2D _MapTex01;
            HighPrec _Width01;
            HighPrec _Height01;
            float4x4 _MapMatrix01;

            sampler2D _MapTex02;
            HighPrec _Width02;
            HighPrec _Height02;
            float4x4 _MapMatrix02;
#endif

#if _SAMPLE_MAP3
            sampler2D _MapTex00;
            HighPrec _Width00;
            HighPrec _Height00;
            float4x4 _MapMatrix00;

            sampler2D _MapTex01;
            HighPrec _Width01;
            HighPrec _Height01;
            float4x4 _MapMatrix01;
            
            sampler2D _MapTex02;
            HighPrec _Width02;
            HighPrec _Height02;
            float4x4 _MapMatrix02;

            sampler2D _MapTex03;
            HighPrec _Width03;
            HighPrec _Height03;
            float4x4 _MapMatrix03;
#endif

#if _SAMPLE_IMAGE0
            sampler2D _MapTex04;
            HighPrec _Width04;
            HighPrec _Height04;
            float4x4 _MapMatrix04;
            MidPrec4 ImageColor;
#endif 

#if _SAMPLE_IMAGE1
            sampler2D _MapTex04;
            HighPrec _Width04;
            HighPrec _Height04;
            float4x4 _MapMatrix04;

            sampler2D _MapTex05;
            HighPrec _Width05;
            HighPrec _Height05;
            float4x4 _MapMatrix05;
            MidPrec4 ImageColor;
#endif 

            MidPrec4 customStep(HighPrec x)
            {
                return step(0.000001, x) * (1 - step(1.0, x));
            }

            MidPrec customStep(HighPrec x, HighPrec y)
            {
                MidPrec lr = step(0.000001, x) * (1 - step(1.0, x));
                MidPrec tb = step(0.000001, y) * (1 - step(1.0, y));
                return lr * tb;
            }


            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                HighPrec4 worldPos = mul(unity_ObjectToWorld, v.vertex);

                // 有些图片原点在中心，所以需要偏移0.5
#if _SAMPLE_MAP0
                o.mapUv0 = mul(_MapMatrix00, worldPos).xy / HighPrec2(_Width00, _Height00) + _UvOffset;
#endif

#if _SAMPLE_MAP1
                o.mapUv0 = mul(_MapMatrix00, worldPos).xy / HighPrec2(_Width00, _Height00) + _UvOffset;
                o.mapUv1 = mul(_MapMatrix01, worldPos).xy / HighPrec2(_Width01, _Height01) + _UvOffset;
#endif

#if _SAMPLE_MAP2
                o.mapUv0 = mul(_MapMatrix00, worldPos).xy / HighPrec2(_Width00, _Height00) + _UvOffset;
                o.mapUv1 = mul(_MapMatrix01, worldPos).xy / HighPrec2(_Width01, _Height01) + _UvOffset;
                o.mapUv2 = mul(_MapMatrix02, worldPos).xy / HighPrec2(_Width02, _Height02) + _UvOffset;
#endif

#if _SAMPLE_MAP3
                o.mapUv0 = mul(_MapMatrix00, worldPos).xy / HighPrec2(_Width00, _Height00) + _UvOffset;
                o.mapUv1 = mul(_MapMatrix01, worldPos).xy / HighPrec2(_Width01, _Height01) + _UvOffset;
                o.mapUv2 = mul(_MapMatrix02, worldPos).xy / HighPrec2(_Width02, _Height02) + _UvOffset;
                o.mapUv3 = mul(_MapMatrix03, worldPos).xy / HighPrec2(_Width03, _Height03) + _UvOffset;
#endif

#if _SAMPLE_IMAGE0
                o.mapUv4 = mul(_MapMatrix04, worldPos).xy / HighPrec2(_Width04, _Height04) + 0.5;
#endif

#if _SAMPLE_IMAGE1
                o.mapUv4 = mul(_MapMatrix04, worldPos).xy / HighPrec2(_Width04, _Height04) + 0.5;
                o.mapUv5 = mul(_MapMatrix05, worldPos).xy / HighPrec2(_Width05, _Height05) + 0.5;
#endif

                return o;
            }

            MidPrec4 frag (v2f i) : SV_Target
            {
                // sample the texture
                MidPrec4 col = tex2D(_MainTex, i.uv);
                col.a = col.rgb;

                MidPrec4 map00Col = MidPrec4(0.0, 0.0, 0.0, 0.0);
                MidPrec4 map01Col = MidPrec4(0.0, 0.0, 0.0, 0.0);
                MidPrec4 map02Col = MidPrec4(0.0, 0.0, 0.0, 0.0);
                MidPrec4 map03Col = MidPrec4(0.0, 0.0, 0.0, 0.0);
                
#if _SAMPLE_MAP0
                map00Col = tex2D(_MapTex00, i.mapUv0);
                map00Col *= customStep(i.mapUv0.x);
                map00Col *= customStep(i.mapUv0.y);
                // return MidPrec4(1,1,1,1);
#endif

#if _SAMPLE_MAP1
                map00Col = tex2D(_MapTex00, i.mapUv0);
                map00Col *= customStep(i.mapUv0.x);
                map00Col *= customStep(i.mapUv0.y);

                map01Col = tex2D(_MapTex01, i.mapUv1);
                map01Col *= customStep(i.mapUv1.x);
                map01Col *= customStep(i.mapUv1.y);

                // return MidPrec4(map01Col.rgb,1);
#endif

#if _SAMPLE_MAP2
                map00Col = tex2D(_MapTex00, i.mapUv0);
                map00Col *= customStep(i.mapUv0.x);
                map00Col *= customStep(i.mapUv0.y);

                map01Col = tex2D(_MapTex01, i.mapUv1);
                map01Col *= customStep(i.mapUv1.x);
                map01Col *= customStep(i.mapUv1.y);

                map02Col = tex2D(_MapTex02, i.mapUv2);
                map02Col *= customStep(i.mapUv2.x);
                map02Col *= customStep(i.mapUv2.y);
                // return map02Col;
#endif                

#if _SAMPLE_MAP3
                map00Col = tex2D(_MapTex00, i.mapUv0);
                map00Col *= customStep(i.mapUv0.x);
                map00Col *= customStep(i.mapUv0.y);

                map01Col = tex2D(_MapTex01, i.mapUv1);
                map01Col *= customStep(i.mapUv1.x);
                map01Col *= customStep(i.mapUv1.y);

                map02Col = tex2D(_MapTex02, i.mapUv2);
                map02Col *= customStep(i.mapUv2.x);
                map02Col *= customStep(i.mapUv2.y);
                
                map03Col = tex2D(_MapTex03, i.mapUv3);
                map03Col *= customStep(i.mapUv3.x);
                map03Col *= customStep(i.mapUv3.y);
                // return map03Col;
#endif
                col.rgb = map00Col.rgb + map01Col.rgb + map02Col.rgb + map03Col.rgb;
                // 没有采样到贴图时，完全透明
                col.a *= saturate(map00Col.a + map01Col.a + map02Col.a + map03Col.a);

                MidPrec4 imageCol = MidPrec4(0.0, 0.0, 0.0, 0.0);
#if _SAMPLE_IMAGE0
                MidPrec4 image00Col = tex2D(_MapTex04, i.mapUv4);
                image00Col *= customStep(i.mapUv4.x, i.mapUv4.y);
                col.rgb = col.rgb * (1 - image00Col.a) + image00Col.rgb * image00Col.a;

                // MidPrec range = customStep(i.mapUv4.x) * customStep(i.mapUv4.y);
                // imageCol = lerp(0, ImageColor, range);

                // col.rgb = col.rgb * lerp(1, (1 - ImageColor.a), range) + imageCol.rgb * ImageColor.a;
#endif

               

#if _SAMPLE_IMAGE1
                MidPrec4 image00Col = tex2D(_MapTex04, i.mapUv4);
                MidPrec4 image01Col = tex2D(_MapTex04, i.mapUv5);
                MidPrec range0 = customStep(i.mapUv4.x, i.mapUv4.y);
                MidPrec range1 = customStep(i.mapUv5.x, i.mapUv5.y);

                imageCol.rgb = image00Col.rgb * image00Col.a * range0 + image01Col.rgb * image01Col.a * range1;
                imageCol.a = image00Col.a * range0 + image01Col.a * range1;
                
                col.rgb = col.rgb * (1 - imageCol.a) + imageCol.rgb;
                
                // 不采样贴图，直接算出矩形区域，节省带宽
                // MidPrec range = customStep(i.mapUv4.x) * customStep(i.mapUv4.y) + customStep(i.mapUv5.x) * customStep(i.mapUv5.y);
                // 虚线，计算量大
                // MidPrec3 edgeColor = lerp(ImageColor.rgb, 1, floor(i.mapUv4.x * 100 / 2) % 2 * (1 - floor(i.mapUv4.y * 100 / 2) % 2));
                // 直线
                // imageCol.rgb = lerp(1, ImageColor.rgb, customStep(i.mapUv4.x, i.mapUv4.y) + customStep(i.mapUv5.x, i.mapUv5.y));

                // imageCol = lerp(0, imageCol, range);
                // col.rgb = col.rgb * lerp(1, (1 - ImageColor.a), range) + imageCol.rgb * ImageColor.a;
#endif
                col.rgb *= col.a;

                return col;
            }
            ENDCG
        }
    }
}
