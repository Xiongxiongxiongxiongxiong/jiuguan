// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.2108564,fgcg:0.3011127,fgcb:0.4779412,fgca:1,fgde:0.01,fgrn:1,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33228,y:32761,varname:node_3138,prsc:2|normal-9828-RGB,emission-9232-OUT,alpha-6399-OUT;n:type:ShaderForge.SFN_Tex2d,id:6273,x:32353,y:32959,ptovrint:False,ptlb:D,ptin:_D,varname:node_6273,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-825-UVOUT;n:type:ShaderForge.SFN_Fresnel,id:2135,x:32064,y:32552,varname:node_2135,prsc:2|EXP-964-OUT;n:type:ShaderForge.SFN_Multiply,id:5922,x:32759,y:32512,varname:node_5922,prsc:2|A-174-OUT,B-2477-RGB;n:type:ShaderForge.SFN_Color,id:2477,x:32463,y:32583,ptovrint:False,ptlb:Fresnel color,ptin:_Fresnelcolor,varname:node_2477,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Slider,id:964,x:31647,y:32641,ptovrint:False,ptlb:Exp,ptin:_Exp,varname:node_964,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:8,max:20;n:type:ShaderForge.SFN_Multiply,id:5846,x:32631,y:32942,varname:node_5846,prsc:2|A-6273-RGB,B-2779-RGB;n:type:ShaderForge.SFN_Color,id:2779,x:32489,y:33158,ptovrint:False,ptlb:D_color,ptin:_D_color,varname:node_2779,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Add,id:174,x:32234,y:32436,varname:node_174,prsc:2|A-2135-OUT,B-2135-OUT;n:type:ShaderForge.SFN_TexCoord,id:825,x:32130,y:33013,varname:node_825,prsc:2,uv:1,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:9828,x:32388,y:32759,ptovrint:False,ptlb:N,ptin:_N,varname:node_9828,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:True;n:type:ShaderForge.SFN_Add,id:9232,x:32899,y:32845,varname:node_9232,prsc:2|A-5922-OUT,B-5846-OUT;n:type:ShaderForge.SFN_Multiply,id:6399,x:32917,y:33043,varname:node_6399,prsc:2|A-174-OUT,B-6273-A;proporder:2477-964-6273-2779-9828;pass:END;sub:END;*/

Shader "Shader Forge/maotai_glow_01" {
    Properties {
        _Fresnelcolor ("Fresnel color", Color) = (1,1,1,1)
        _Exp ("Exp", Range(0, 20)) = 8
        _D ("D", 2D) = "white" {}
        _D_color ("D_color", Color) = (0,0,0,1)
        _N ("N", 2D) = "bump" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _D; uniform float4 _D_ST;
            uniform float4 _Fresnelcolor;
            uniform float _Exp;
            uniform float4 _D_color;
            uniform sampler2D _N; uniform float4 _N_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                float3 normalDir : TEXCOORD3;
                float3 tangentDir : TEXCOORD4;
                float3 bitangentDir : TEXCOORD5;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _N_var = UnpackNormal(tex2D(_N,TRANSFORM_TEX(i.uv0, _N)));
                float3 normalLocal = _N_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
////// Lighting:
////// Emissive:
                float node_2135 = pow(1.0-max(0,dot(normalDirection, viewDirection)),_Exp);
                float node_174 = (node_2135+node_2135);
                float4 _D_var = tex2D(_D,TRANSFORM_TEX(i.uv1, _D));
                float3 emissive = ((node_174*_Fresnelcolor.rgb)+(_D_var.rgb*_D_color.rgb));
                float3 finalColor = emissive;
                return fixed4(finalColor,(node_174*_D_var.a));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
