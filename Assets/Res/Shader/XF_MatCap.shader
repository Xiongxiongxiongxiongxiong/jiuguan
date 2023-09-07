Shader "XF/XF_Matcap"
{
    Properties
    {
        _MatcapAdd("MatcapAdd",2D)="black"{}
        _MatcapAddIntensity("MatcapAddIntensity",Float)=1.0
        _Matcap("Matcap",2D)="white"{}
        _MatcapIntensity("MatcapIntensity",Range(0,3))=1.0
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("BumpMap",2D)="bump"{}
        _RampTex("RampTex",2D)="white"{}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;  
				float4 TtoW1 : TEXCOORD2;  
				float4 TtoW2 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            sampler2D _MatcapAdd;
            sampler2D _Matcap;
            sampler2D _RampTex;
            float _MatcapIntensity;
            float _MatcapAddIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
				
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

                half4 diffuse_color=tex2D(_MainTex,i.uv);

                //matcap
                float3 viewspaceNormal=mul(UNITY_MATRIX_V,float4(bump,0.0)).xyz;
                half2 uv_matcap=viewspaceNormal.xy*0.5+float2(0.5,0.5);
                half4 matcap_color=tex2D(_Matcap,uv_matcap)*_MatcapIntensity;

                //ramp
                half NdotV=saturate(dot(bump,viewDir));
                half fresnel=1-NdotV;
                half2 uv_ramp=half2(fresnel,0.5);
                half4 rampColor=tex2D(_RampTex,uv_ramp);

                //MatcapAdd
                half4 matcapAdd_color=tex2D(_MatcapAdd,uv_matcap)*_MatcapAddIntensity;


                fixed4 finalColor =diffuse_color*matcap_color*rampColor+matcapAdd_color;
                return finalColor;
            }
            ENDCG
        }
    }
}
