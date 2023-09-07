Shader "HW/Special/None" {
Properties
	{
	}
	
	SubShader
	{
		LOD 100
		Tags { "RenderType"="Opaque" }
		
		Pass
		{
			Lighting Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest 
			#include "UnityCG.cginc"
			
			struct v2f { 
				float4 vertex : POSITION;
			} ;
		
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = 	o.vertex = float4(v.vertex.x,v.vertex.y,-2,1);
				return o;
			}
			
			float4 frag( v2f i ) : SV_Target
			{
				return float4(0,0,0,0);
			}
			ENDCG
			
		}
	}
}
