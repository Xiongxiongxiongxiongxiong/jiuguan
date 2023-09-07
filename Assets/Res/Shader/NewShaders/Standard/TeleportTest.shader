Shader "Unlit/TeleportTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("NoiseTex",2D) = "white" {}
		_DissolveAmount("_DissolveAmount",float) = 1		
		_DissolveOffset("_DissolveOffset",float) = 1		
		_DissolveSpread("_DissolveSpread",float) = 1	
		_DissolveEdgeColor("_DissolveEdgeColor",Color) = (0.5,1,0.5,1)	
		_DissolveEdgeOffset("_DissolveEdgeOffset",range(-1,1)) = 0.5


		_VertexOffset("_VertexOffset",float) = 1		
		_VertexSpread("_VertexSpread",float) = 1	
		_VertexOffetIntensity("_VertexOffetIntensity",float) = 5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="AlphaTest" }
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				float3 pivotPos : TEXCOORD2;
			};

			sampler2D _MainTex,_NoiseTex;
			float4 _MainTex_ST;
			float _DissolveAmount;
			float _DissolveOffset;
			float _DissolveSpread;
			float _DissolveEdgeOffset;
			float4 _DissolveEdgeColor;
			float _VertexOffetIntensity;
			float _VertexOffset,_VertexSpread;


			//  暂时使用白噪声  将uv的v方向的值不变 做个拉伸 成无数细小的长条状
            float whiteNoise(int seed, int i, int j)
            {
                //return  frac(sin(dot(float2(i,cos(j)),float2(seed+12.9898,seed + 78.233)))*43758.5453);
                return frac(sin(dot(float2(i, cos(j)), float2(float(seed) + 12.9898, float(seed) + 78.233))) * 43758.5453);
            }


			v2f vert (appdata v)
			{
				v2f o;
				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
				float3 pivotPos = mul(unity_ObjectToWorld,float4(0,0,0,1));
				o.worldPos = worldPos;
				o.pivotPos = pivotPos;	


				// vertex Animation  顶点动画
				float vertexAni = (worldPos.y - pivotPos.y) + _DissolveAmount - _VertexOffset;
				float vertexAniDivide = vertexAni / _VertexSpread;
				// 因为想要的结果是向上偏移  所以不能小于0
				vertexAniDivide = step(0,vertexAniDivide) * vertexAniDivide;
				//  向上偏移 所以乘以（0，1，0）
				float3 vertexOffset = vertexAniDivide * float3(0,1,0) * _VertexOffetIntensity;			
				float3 endPos = (worldPos + vertexOffset);
				v.vertex = mul(unity_WorldToObject,float4(endPos,1));
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldPos = i.worldPos;
				float3 pivotPos = i.pivotPos;
				// 求出Alpha的值
				float alpha  =  1 -  (worldPos.y - pivotPos.y) -  _DissolveAmount - _DissolveOffset;
				float alphaDivide = alpha / _DissolveSpread; 			
				float noise = whiteNoise(500,i.uv.x * 100,i.uv.y);   //tex2D(_NoiseTex,i.uv).r;
				alpha = saturate( (alphaDivide - noise) + (smoothstep(0.8,1.0,alphaDivide))); 

				clip(alpha - 0.5);
				//溶解边缘的 高光颜色区域的遮罩（ 中间白色   ，两边都是黑色）
				float edge = 1 - distance(alphaDivide,_DissolveEdgeOffset);
				// edge   的颜色 pow一下
				// edge = pow(edge,3) - noise.r;
				edge = pow(edge,3) - noise;
				float4 edgeColor = smoothstep(0,1,edge) * _DissolveEdgeColor;
				return edgeColor;
			}
			ENDCG
		}
	}
}