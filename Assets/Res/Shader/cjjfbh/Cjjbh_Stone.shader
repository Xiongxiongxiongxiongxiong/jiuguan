// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Cjjfbh/Cjjbh_Stone"
{
	Properties
	{
		_cUTilling("cUTilling", Float) = 1
		_T_StoneMask_D("T_StoneMask_D", 2D) = "white" {}
		_cVTilling("cVTilling", Float) = 1
		_T_StoneG_D("T_StoneG_D", 2D) = "white" {}
		_cColorIntensity01("cColorIntensity01", Float) = 3
		_cColorIntensity02("cColorIntensity02", Float) = 3
		_cMaskSharp("cMaskSharp", Float) = 3
		_T_StoneG_N("T_StoneG_N", 2D) = "bump" {}
		_T_StoneGlass_D("T_StoneGlass_D", 2D) = "white" {}
		_cBasecolor01("cBasecolor01", Color) = (1,1,1,0)
		_cBasecolor02("cBasecolor02", Color) = (1,1,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _T_StoneG_N;
		uniform float4 _T_StoneG_N_ST;
		uniform sampler2D _T_StoneG_D;
		uniform float4 _T_StoneG_D_ST;
		uniform float4 _cBasecolor01;
		uniform float _cColorIntensity01;
		uniform sampler2D _T_StoneGlass_D;
		uniform float _cUTilling;
		uniform float _cVTilling;
		uniform float4 _cBasecolor02;
		uniform float _cColorIntensity02;
		uniform sampler2D _T_StoneMask_D;
		uniform float4 _T_StoneMask_D_ST;
		uniform float _cMaskSharp;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_T_StoneG_N = i.uv_texcoord * _T_StoneG_N_ST.xy + _T_StoneG_N_ST.zw;
			o.Normal = UnpackNormal( tex2D( _T_StoneG_N, uv_T_StoneG_N ) );
			float2 uv_T_StoneG_D = i.uv_texcoord * _T_StoneG_D_ST.xy + _T_StoneG_D_ST.zw;
			float4 appendResult4 = (float4(_cUTilling , _cVTilling , 0.0 , 0.0));
			float2 uv_T_StoneMask_D = i.uv_texcoord * _T_StoneMask_D_ST.xy + _T_StoneMask_D_ST.zw;
			float4 temp_cast_2 = (_cMaskSharp).xxxx;
			float4 temp_output_12_0 = pow( tex2D( _T_StoneMask_D, uv_T_StoneMask_D ) , temp_cast_2 );
			float4 lerpResult11 = lerp( ( ( tex2D( _T_StoneG_D, uv_T_StoneG_D ) * _cBasecolor01 ) * _cColorIntensity01 ) , ( ( tex2D( _T_StoneGlass_D, ( float4( i.uv_texcoord, 0.0 , 0.0 ) * appendResult4 ).xy ) * _cBasecolor02 ) * _cColorIntensity02 ) , temp_output_12_0);
			o.Albedo = lerpResult11.rgb;
			o.Smoothness = temp_output_12_0.r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18930
2126;229;1920;1006;1965.107;157.9991;1.333372;True;True
Node;AmplifyShaderEditor.RangedFloatNode;1;-1669.923,207.7033;Float;False;Property;_cVTilling;cVTilling;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1677.724,107.6033;Float;False;Property;_cUTilling;cUTilling;0;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1736.006,-50.81318;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;4;-1438.523,168.7033;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-1307.223,90.70348;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;21;-791.9196,438.4386;Float;False;Property;_cBasecolor02;cBasecolor02;10;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-1045.439,38.65302;Inherit;True;Property;_T_StoneG_D;T_StoneG_D;3;0;Create;True;0;0;0;False;0;False;-1;d6e1ae5585978da4ca965212c0e94533;bea6df0f590f2ce4091d11147f291748;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;19;-676.4586,-13.5918;Float;False;Property;_cBasecolor01;cBasecolor01;9;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-1079.857,316.9421;Inherit;True;Property;_T_StoneGlass_D;T_StoneGlass_D;8;0;Create;True;0;0;0;False;0;False;-1;807f6a7638ad3594ea98b399f4b56056;4ed2cb4100c77244180a80e3e4f25355;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;-530.6256,437.7118;Float;False;Property;_cColorIntensity02;cColorIntensity02;5;0;Create;True;0;0;0;False;0;False;3;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-604.9196,303.4386;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-489.4586,-148.5918;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;6;-790.799,672.4821;Inherit;True;Property;_T_StoneMask_D;T_StoneMask_D;1;0;Create;True;0;0;0;False;0;False;-1;cbc93391224471148b913b06e97d8c4e;ca7363a8b9f775f49ba89c13c50dfd20;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-406.7625,20.97811;Float;False;Property;_cColorIntensity01;cColorIntensity01;4;0;Create;True;0;0;0;False;0;False;3;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-474.5132,867.5659;Float;False;Property;_cMaskSharp;cMaskSharp;6;0;Create;True;0;0;0;False;0;False;3;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;12;-305.6034,669.0108;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-204.5115,-78.54796;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-328.3746,338.1857;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;8;-1197.9,649.1996;Inherit;True;Property;_T_StoneG_N;T_StoneG_N;7;0;Create;True;0;0;0;False;0;False;-1;a7bc827558951704f9173f48f977ccda;a7bc827558951704f9173f48f977ccda;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;11;-43.71158,101.1515;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;454.6212,603.1832;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Cjjfbh/Cjjbh_Stone;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;2;0
WireConnection;4;1;1;0
WireConnection;5;0;3;0
WireConnection;5;1;4;0
WireConnection;9;1;5;0
WireConnection;22;0;9;0
WireConnection;22;1;21;0
WireConnection;16;0;7;0
WireConnection;16;1;19;0
WireConnection;12;0;6;0
WireConnection;12;1;20;0
WireConnection;14;0;16;0
WireConnection;14;1;15;0
WireConnection;23;0;22;0
WireConnection;23;1;24;0
WireConnection;11;0;14;0
WireConnection;11;1;23;0
WireConnection;11;2;12;0
WireConnection;0;0;11;0
WireConnection;0;1;8;0
WireConnection;0;4;12;0
ASEEND*/
//CHKSM=3FFC1AD50519C409EED01482BAAAAE7B13541B96