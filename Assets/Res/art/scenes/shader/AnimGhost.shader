Shader "XH/AnimGhost"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _ScaleParams    ("天使圈缩放 X:强度 Y:速度 Z:校正", vector) = (0.2, 1.0, 4.5, 0.0)
        _SwingXParams   ("X轴扭动 X:强度 Y:速度 Z:波长", vector) = (1.0, 3.0, 1.0, 0.0)
        _SwingZParams   ("Z轴扭动 X:强度 Y:速度 Z:波长", vector) = (1.0, 3.0, 1.0, 0.0)
        _SwingYParams   ("Y轴起伏 X:强度 Y:速度 Z:滞后", vector) = (1.0, 3.0, 0.3, 0.0)
        _ShakeYParams   ("Y轴摇头 X:强度 Y:速度 Z:滞后", vector) = (20.0, 3.0, 0.3, 0.0)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                
                float4 color : COLOR;          
            };
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                
                float4 color : COLOR;           
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform float4 _ScaleParams;
            uniform float3 _SwingXParams;
            uniform float3 _SwingZParams;
           // uniform float3 _SwingYParams;
            uniform float3 _ShakeYParams;

void AnimGhost (inout float3 vertex, inout float3 color)
            {

                // 幽灵摆动
                float swingX = _SwingXParams.x * sin(frac(_Time.z * _SwingXParams.y + vertex.y * _SwingXParams.z) * 3.1415926*2);
                float swingZ = _SwingZParams.x * sin(frac(_Time.z * _SwingZParams.y + vertex.y * _SwingZParams.z) * 3.1415926*2);
                vertex.xz += float2(swingX, swingZ) * color.r;
                // 幽灵摇头
              float radY = radians(_ShakeYParams.x) *  color.r * sin(frac(_Time.z * _ShakeYParams.y - color.r * _ShakeYParams.z) * 3.1415926*2);
              float sinY, cosY = 0;
              sincos(radY, sinY, cosY);
              vertex.xz = float2(
              vertex.x * cosY - vertex.z * sinY,
              vertex.x * sinY + vertex.z * cosY
                );
                // 幽灵起伏
             //   float swingY = _SwingYParams.x * sin(frac(_Time.z * _SwingYParams.y - color.r * _SwingYParams.z) * 3.1415926*2);
              //  vertex.y += swingY;
                // 处理顶点色
             //   float lightness = 1.0 + color.g * 1.0 + scale * 2.0;
              //  color = float3(lightness, lightness, lightness);
            }
            v2f vert (appdata v)
            {
                v2f o;
    
                AnimGhost(v.vertex.xyz, v.color.rgb);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
