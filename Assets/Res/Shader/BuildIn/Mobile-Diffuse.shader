// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Simplified Diffuse shader. Differences from regular Diffuse one:
// - no Main Color
// - fully supports only 1 directional light. Other lights can affect it, but it will be per-vertex/SH.

// 这个用来做Fallback ，实际上是 Mobile-Diffuse
Shader "BuildIn/Diffuse" {
Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}

    }

    SubShader
    {
        Tags { "RenderType"="Opaque"  }

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma target 3.0

            #pragma exclude_renderers vulkan xboxone ps4 psp2 n3ds wiiu 

            #pragma multi_compile_fwdbase

            #pragma skip_variants DIRLIGHTMAP_COMBINED DYNAMICLIGHTMAP_ON FOG_EXP FOG_EXP2 FOG_LINEAR LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK VERTEXLIGHT_ON DIRECTIONAL_COOKIE POINT_COOKIE LIGHTMAP_ON LIGHTPROBE_SH
            // 除了自定义的 shader keywords 外，剩下的还在生效的 keywords 有：DIRECTIONAL 
            #pragma skip_variants SHADOWS_CUBE SHADOWS_DEPTH 

            #include "UnityCG.cginc"


            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct AppInput{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };

            struct VertexOut{
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;

            };

            VertexOut vertBaseWill( AppInput i ){

                VertexOut o = (VertexOut)0;
                o.pos = UnityObjectToClipPos( i.vertex.xyz );
                o.uv0 = i.texcoord0.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                o.worldNormal = UnityObjectToWorldNormal( i.normal );

                return o;
            }
            

            half4 fragBaseWill (VertexOut i) : SV_Target { 

                float4 texColor = tex2D( _MainTex, i.uv0 );
                float lambert = dot( i.worldNormal, _WorldSpaceLightPos0.xyz );
                lambert = lambert * 0.5 + 0.5;
                float3 diffuse = _Color.rgb * texColor.rgb * lambert;

                return float4( diffuse.xyz,1.0); 
            }


            #pragma vertex vertBaseWill
            #pragma fragment fragBaseWill

            ENDCG
        }
   
    }
}
