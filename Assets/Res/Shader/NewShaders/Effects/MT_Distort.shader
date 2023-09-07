Shader "MT/Builtin/Effect/Distort"
{
    Properties
    {
        [NoScaleOffset]_DistortTex("R:Distort Map 1 , G:Distort Map 2 , B:Mask Map",2D)="Black"{}
        _DistortMap1TilingOffset("Distort 1, xy:Tiling,zw:offset",vector) = (1,1,0,0)
        _DistortMap2TilingOffset("Distort 2, xy:Tiling,zw:offset",vector) = (1,1,0,0)
        _MaskMapTilingOffset("Mask Map, xy:Tiling,zw:offset",vector) = (1,1,0,0)
        [PowerSlider(5)]_Distort1Factor("Distort 1 Factor",range(0,0.3)) = 0
        [PowerSlider(5)]_Distort2Factor("Distort 2 Factor",range(0,0.3)) = 0
        _DistortSpeed("xy:Distort 1 Speed,zw:Distort 2 Speed",vector) = (0,0,0,0)
        _FinalXOffset("X Offset",range(-0.1,0.1))= 0
        _FinalYOffset("Y Offset",range(-0.1,0.1))= 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent+0" "IsEmissive" = "true"
        }
        LOD 100
        GrabPass
        {
             "_GrabTexture"
        }
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float _Distort1Factor : TEXCOORD1;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0; //xy: distort1 zw:distort2
                float4 vertex : SV_POSITION;
                float2 uvMask:TEXCOORD1;
                float _Distort1Factor :TEXCOORD2;
            };

            sampler2D _GrabTexture;

            sampler2D _DistortTex;
            float4 _DistortMap1TilingOffset;
            float4 _DistortMap2TilingOffset;
            float4 _MaskMapTilingOffset;
            float _Distort1Factor;
            float _Distort2Factor;
            float4 _DistortSpeed;
            float _FinalXOffset,_FinalYOffset;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv * _DistortMap1TilingOffset.xy + _DistortMap1TilingOffset.zw + _Time.y * _DistortSpeed.xy;
                o.uv.zw = v.uv * _DistortMap2TilingOffset.xy + _DistortMap2TilingOffset.zw + _Time.y * _DistortSpeed.zw;
                o.uvMask = v.uv * _MaskMapTilingOffset.xy + _MaskMapTilingOffset.zw;
                o._Distort1Factor = v._Distort1Factor;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float mask = tex2D(_DistortTex, i.uvMask).b;
                float2 screenUV = i.vertex.xy / _ScreenParams.xy;
                float distort1 = tex2D(_DistortTex, i.uv.xy).r * mask;
                float distort2 = tex2D(_DistortTex, i.uv.zw).g * mask;
                // screenUV = lerp(screenUV, (screenUV+distort1)/2, _Distort1Factor);
                // screenUV = lerp(screenUV, (screenUV+distort2)/2, _Distort2Factor);
                screenUV += distort1*i._Distort1Factor+distort2*_Distort2Factor;
                fixed4 col = saturate(tex2D(_GrabTexture, screenUV+fixed2(_FinalXOffset,_FinalYOffset)));
                return col;
            }
            ENDCG
        }
    }
}