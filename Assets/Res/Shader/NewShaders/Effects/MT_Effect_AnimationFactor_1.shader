Shader "MT/Builtin/Effect/AnimationFactor_1"
{
    Properties
    {
        [Enum(Add,1,Alpha,10)]_Dest ("Add/Alpha", int) = 1
        [Enum(Off,0,Front,1,Back,2)]_Cull ("Cull", int) = 1
        [HDR][MainColor]_MainColor("MainColor",Color) = (1,1,1,1)
        [MainTex]_MainTex ("MainTex", 2D) = "white" {}
        [Header(Billboard)]
        _VerticalBillboard("Y轴转向控制",range(0,1)) = 0
        [Header(FlipBook)]
        _FlipBookPara("FlipBookSetting XY:Width Height Count Z:Speed W:StopTime",vector) = (1,1,0,0)
        _FlipBookTilingOffset("TilingOffset",vector) = (1,1,0,0)
        [Header(Dissolve)]
        [HDR]_DissolveColor("DissolveColor",Color) = (1,1,1,1)
        _DissolveMap("DissolveTex",2D)="white"{}
        _DissolveRange("DissolveRange",range(0,1)) = 0
        _DissolvePara("DissolvePara",range(0,1)) = 0
        _Index("Index",range(0,1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue" = "Transparent"
        }
        LOD 100
        Cull [_Cull]
        Blend SrcAlpha [_Dest]
        //blend one zero
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                float2 dissolveUV:TEXCOORD1;
            };

            float4 _MainColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            // #ifdef _FLIPBOOK_ON
            float4 _FlipBookPara;
            float4 _FlipBookTilingOffset;
            // #endif

            // #ifdef _FACECAMERA_ON
            fixed _VerticalBillboard;
            // #endif

            // #ifdef _DISSOLVE_ON
            float4 _DissolveColor;
            sampler2D _DissolveMap;
            float4 _DissolveMap_ST;
            fixed _DissolveRange;
            fixed _DissolvePara;
            // #endif
            fixed _Start;
            float _Index;

            float2 Flipbook(float2 UV, float Width, float Height, float Tile, float2 Invert)
            {
                float2 Out = 0;
                Tile = floor(fmod(Tile + 0.00001, Width * Height));
                float2 tileCount = float2(1.0, 1.0) / float2(Width, Height);
                float base = floor((Tile + 0.5) * tileCount.x);
                float tileX = Tile - Width * base;
                float tileY = Invert.y * Height - (base + Invert.y * 1);
                Out = (UV + float2(tileX, tileY)) * tileCount;
                return Out;
            }

            float4 Billboard(float3 positionOS, float verticalBillboard)
            {
                float3 center = float3(0, 0, 0);
                float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                float3 normalDir = center - viewer;
                // float3 normalDir = viewer - center;
                normalDir.y = normalDir.y * verticalBillboard;
                normalDir = normalize(normalDir);
                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
                float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = normalize(cross(normalDir, rightDir));
                float3 centerOffs = positionOS - center;
                float3 localPos = rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
                return float4(localPos, 1);
            }

            half remap(half x, half t1, half t2, half s1, half s2)
            {
                return (x - t1) / (t2 - t1) * (s2 - s1) + s1;
            }


            v2f vert(appdata v)
            {
                v2f o;
                float4 positionOS = Billboard(v.vertex.xyz, _VerticalBillboard);
                o.vertex = UnityObjectToClipPos(positionOS);
                _Index *= _FlipBookPara.x * _FlipBookPara.y;
                float tile = _Index;
                o.uv.z = tile;
                o.uv.xy = v.uv;
                o.dissolveUV = TRANSFORM_TEX(v.uv, _DissolveMap);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half2 uv = i.uv;
                float mask = 0;
                float4 outline = 0;
                fixed2 unit = fixed2(0.5 / _FlipBookPara.x, 0.5 / _FlipBookPara.y);
                fixed horIndex = floor(i.uv.z % _FlipBookPara.x) * 2 + 1;
                fixed verIndex = floor((_FlipBookPara.x * _FlipBookPara.y - i.uv.z) / _FlipBookPara.x) * 2 + 1;
                float dissolveIntensity = 0;
                float time = _Index;
                float interval = 1 / _FlipBookPara.x / _FlipBookPara.y;
                float index = floor(time * _FlipBookPara.x * _FlipBookPara.y);
                if (time < interval / 2 + interval * index - _FlipBookPara.z * interval / 2)
                {
                    float tempTime = 1 - remap(time, 0, interval / 2 + interval * index - _FlipBookPara.z * interval / 2, 0, 1);
                    dissolveIntensity = -2*tempTime;
                }
                else if (time >= interval / 2 + interval * index + _FlipBookPara.z * interval / 2)
                {
                    float tempTime = 1 - remap(time, interval / 2 + interval * index + _FlipBookPara.z * interval / 2,
                                               interval / 2 + interval * (index + 1) - _FlipBookPara.z * interval / 2, 1, 0);
                    dissolveIntensity = -tempTime;
                }
                else
                {
                    dissolveIntensity = 0;
                }

                uv = Flipbook(frac(i.uv), _FlipBookPara.x, _FlipBookPara.y, i.uv.z,fixed2(0, 1));
                mask = saturate(distance(max(0, abs(uv - unit * fixed2(horIndex, verIndex)) - _DissolvePara), half2(0, 0)) / _DissolveRange);
                _FlipBookTilingOffset.z += dissolveIntensity;
                fixed dissolveMask = tex2D(_DissolveMap, i.dissolveUV).r;
                dissolveMask = step(abs(dissolveIntensity), dissolveMask);
                uv = Flipbook(frac(i.uv * _FlipBookTilingOffset.xy + _FlipBookTilingOffset.zw), _FlipBookPara.x, _FlipBookPara.y, i.uv.z,fixed2(0, 1));
                uv.x = lerp(uv.x, dissolveMask - 1 / _FlipBookPara.x, dissolveIntensity * 0.1);
                fixed4 col = tex2D(_MainTex, uv) * _MainColor * step(0.033,time) * (1-mask);
                outline = _DissolveColor * mask * step(0.001,time) * step(time,0.999);
                clip(min(col.a, dissolveMask) - 0.5);
                return lerp(col, outline, mask * 3);
            }
            ENDCG
        }
    }
}