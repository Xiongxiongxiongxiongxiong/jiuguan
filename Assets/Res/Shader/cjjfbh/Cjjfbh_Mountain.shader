// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Cjjfbh/Cjjfbh_Mountain"
{
	Properties
	{
		_T_Prop_MountainTop_D("T_Prop_MountainTop_D", 2D) = "white" {}
		_cTop_Mask("cTop_Mask", Float) = 0
		_cButton_Mask("cButton_Mask", Float) = 0
		_cTop_Sharp("cTop_Sharp", Float) = 0
		_cButton_Sharp("cButton_Sharp", Float) = 0
		_cTop_Basecolor("cTop_Basecolor", Color) = (0,0,0,0)
		_cButton_Basecolor("cButton_Basecolor", Color) = (0,0,0,0)
		_T_Prop_MountainMask_D("T_Prop_MountainMask_D", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _cTop_Basecolor;
		uniform sampler2D _T_Prop_MountainTop_D;
		uniform float4 _T_Prop_MountainTop_D_ST;
		uniform float _cTop_Mask;
		uniform float _cTop_Sharp;
		uniform float4 _cButton_Basecolor;
		uniform float _cButton_Mask;
		uniform float _cButton_Sharp;
		uniform sampler2D _T_Prop_MountainMask_D;
		uniform float4 _T_Prop_MountainMask_D_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_T_Prop_MountainTop_D = i.uv_texcoord * _T_Prop_MountainTop_D_ST.xy + _T_Prop_MountainTop_D_ST.zw;
			float4 tex2DNode1 = tex2D( _T_Prop_MountainTop_D, uv_T_Prop_MountainTop_D );
			float4 lerpResult8 = lerp( _cTop_Basecolor , float4( 1,1,1,0 ) , ( pow( tex2DNode1.r , _cTop_Mask ) - _cTop_Sharp ));
			float4 lerpResult17 = lerp( _cButton_Basecolor , float4( 1,1,1,0 ) , ( pow( ( 1.0 - tex2DNode1.r ) , _cButton_Mask ) - _cButton_Sharp ));
			float2 uv_T_Prop_MountainMask_D = i.uv_texcoord * _T_Prop_MountainMask_D_ST.xy + _T_Prop_MountainMask_D_ST.zw;
			o.Albedo = ( ( lerpResult8 * lerpResult17 ) + tex2D( _T_Prop_MountainMask_D, uv_T_Prop_MountainMask_D ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18930
0;0;1920;1018;2930.655;637.8234;1.6753;True;True
Node;AmplifyShaderEditor.SamplerNode;1;-2214.518,-114.8413;Inherit;True;Property;_T_Prop_MountainTop_D;T_Prop_MountainTop_D;0;0;Create;True;0;0;0;False;0;False;-1;3e5aa211f00890e43898815dc95e69c2;3e5aa211f00890e43898815dc95e69c2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-1539.092,41.3976;Float;False;Property;_cTop_Mask;cTop_Mask;1;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;12;-1790.779,712.6509;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1627.554,901.1943;Float;False;Property;_cButton_Mask;cButton_Mask;2;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;2;-1367.153,-121.9444;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1295.363,115.2396;Float;False;Property;_cTop_Sharp;cTop_Sharp;4;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;14;-1462.187,736.2097;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1390.397,973.3931;Float;False;Property;_cButton_Sharp;cButton_Sharp;5;0;Create;True;0;0;0;False;0;False;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-1350.851,-359.6653;Float;False;Property;_cTop_Basecolor;cTop_Basecolor;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.03529412,0.1294117,0.9137255,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;18;-1255.392,545.0306;Float;False;Property;_cButton_Basecolor;cButton_Basecolor;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.8185394,0.9811321,0.6062656,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;16;-1084.486,809.5516;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;6;-986.0919,-48.60243;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;8;-747.3627,-100.7604;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;17;-897.9122,662.2235;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;20;-175.1034,873.0637;Inherit;True;Property;_T_Prop_MountainMask_D;T_Prop_MountainMask_D;8;0;Create;True;0;0;0;False;0;False;-1;e1244932ce21d4a4abe75bcc941fbb09;e1244932ce21d4a4abe75bcc941fbb09;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-287.9438,36.68468;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;23;-2721.912,1540.797;Inherit;True;Property;_T_Prop_MountainMiddle_D;T_Prop_MountainMiddle_D;9;0;Create;True;0;0;0;False;0;False;-1;e0fdd716b3b1d744dbd1e176b05bf319;e0fdd716b3b1d744dbd1e176b05bf319;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;24;-2332.729,1536.044;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;39;-2219.355,-775.9974;Inherit;True;Property;_T_Prop_MountainMiddle_D1;T_Prop_MountainMiddle_D;10;0;Create;True;0;0;0;False;0;False;-1;e0fdd716b3b1d744dbd1e176b05bf319;e0fdd716b3b1d744dbd1e176b05bf319;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;22;60.19971,581.8387;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-2128.124,1586.822;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;25;-1752.023,1553.038;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1964.128,1820.161;Float;False;Property;_cMiddle_Mask;cMiddle_Mask;3;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;40;-1830.172,-780.7505;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;28;-1456.836,1389.373;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;343.6176,528.8788;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Cjjfbh/Cjjfbh_Mountain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;0;1;1
WireConnection;2;0;1;1
WireConnection;2;1;5;0
WireConnection;14;0;12;0
WireConnection;14;1;13;0
WireConnection;16;0;14;0
WireConnection;16;1;15;0
WireConnection;6;0;2;0
WireConnection;6;1;7;0
WireConnection;8;0;11;0
WireConnection;8;2;6;0
WireConnection;17;0;18;0
WireConnection;17;2;16;0
WireConnection;19;0;8;0
WireConnection;19;1;17;0
WireConnection;24;0;23;1
WireConnection;22;0;19;0
WireConnection;22;1;20;0
WireConnection;26;0;24;0
WireConnection;25;0;24;0
WireConnection;25;1;30;0
WireConnection;40;0;39;1
WireConnection;28;2;25;0
WireConnection;0;0;22;0
ASEEND*/
//CHKSM=D96511A6A26954EF7430DDC5C3BC5395C96A39C3