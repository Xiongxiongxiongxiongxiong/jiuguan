// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Cjjfbh/Cjjfbh_Grass"
{
	Properties
	{
		_T_GrassGradient("T_GrassGradient", 2D) = "white" {}
		_cGradientPower("cGradientPower", Float) = 2
		_cEmissionPower("cEmissionPower", Float) = 1
		_cBaseColor("cBaseColor", Color) = (0.1832768,0.4150943,0.08810966,0)
		_cWaveColor("cWaveColor", Color) = (0.1302556,0.2264151,0.09077964,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _cBaseColor;
		uniform sampler2D _T_GrassGradient;
		uniform float4 _T_GrassGradient_ST;
		uniform float _cGradientPower;
		uniform float4 _cWaveColor;
		uniform float _cEmissionPower;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_T_GrassGradient = i.uv_texcoord * _T_GrassGradient_ST.xy + _T_GrassGradient_ST.zw;
			float4 temp_cast_0 = (_cGradientPower).xxxx;
			o.Albedo = ( _cBaseColor * pow( tex2D( _T_GrassGradient, uv_T_GrassGradient ) , temp_cast_0 ) ).rgb;
			o.Emission = ( _cWaveColor * _cEmissionPower ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18930
1920;32;2560;1366;1935.082;-19.40146;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;3;-1434.599,-345.7552;Float;False;Property;_cGradientPower;cGradientPower;2;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1506.009,-571.6339;Inherit;True;Property;_T_GrassGradient;T_GrassGradient;1;0;Create;True;0;0;0;False;0;False;-1;ac0e5a2e98f16254d8b9fedd81ccb9b8;ac0e5a2e98f16254d8b9fedd81ccb9b8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;40;-1635.045,239.027;Inherit;False;959.9028;475.1613;simply apply vertex transformation;5;47;46;43;42;45;new vertex position;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-1045.967,89.32458;Float;False;Property;_cEmissionPower;cEmissionPower;3;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;2;-1143.812,-492.7511;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;4;-1411.599,-843.7554;Float;False;Property;_cBaseColor;cBaseColor;5;0;Create;True;0;0;0;False;0;False;0.1832768,0.4150943,0.08810966,0;0.3294116,0.7019608,0.1764704,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;107;-1073.053,-157.684;Float;False;Property;_cWaveColor;cWaveColor;6;0;Create;True;0;0;0;False;0;False;0.1302556,0.2264151,0.09077964,0;0.1302554,0.2264149,0.09077949,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-910.5998,-627.7554;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-899.0472,319.027;Float;False;newVertexPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;112;-2861.62,821.951;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;113;-2601.369,848.3724;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-2880.683,990.4697;Float;False;Property;_cWaveScale;cWaveScale;4;0;Create;True;0;0;0;False;0;False;0;3000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-1636.827,1056.644;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;117;-2013.295,1099.735;Float;False;Property;_cGrassoffest;cGrassoffest;7;0;Create;True;0;0;0;False;0;False;0.1302556,0.2264151,0.09077964,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;116;-2457.683,877.4697;Inherit;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-706.967,-67.67542;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;105;-2052.124,867.5546;Inherit;True;Property;_T_NoiseMask3;T_NoiseMask3;8;0;Create;True;0;0;0;False;0;False;-1;e6f90b7ed33863042814759b9a11f575;e6f90b7ed33863042814759b9a11f575;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;46;-1160.046,320.027;Inherit;True;Waving Vertex;-1;;19;872b3757863bb794c96291ceeebfb188;0;3;1;FLOAT3;0,0,0;False;12;FLOAT;5;False;13;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1299.046,463.027;Inherit;False;2;2;0;FLOAT;0.05;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;45;-1576.817,303.8533;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;42;-1539.045,543.027;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;111;-2230.118,875.5674;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0.01,0.01;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-354,-186;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Cjjfbh/Cjjfbh_Grass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.1;True;True;0;True;Opaque;;AlphaTest;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;1;0
WireConnection;2;1;3;0
WireConnection;5;0;4;0
WireConnection;5;1;2;0
WireConnection;47;0;46;0
WireConnection;113;0;112;0
WireConnection;113;1;115;0
WireConnection;118;0;105;0
WireConnection;118;1;117;0
WireConnection;116;0;113;0
WireConnection;108;0;107;0
WireConnection;108;1;109;0
WireConnection;105;1;111;0
WireConnection;46;1;45;0
WireConnection;46;13;43;0
WireConnection;43;1;42;1
WireConnection;111;0;116;0
WireConnection;0;0;5;0
WireConnection;0;2;108;0
ASEEND*/
//CHKSM=ECCF63A23D38AE2867D6444A3668880D530C269A