// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Cjjfbh/Cjjfbh_Ground"
{
	Properties
	{
		_T_CleanJade_D("T_CleanJade_D", 2D) = "white" {}
		_T_CleanJade_MRA("T_CleanJade_MRA", 2D) = "white" {}
		_cUTilling("cUTilling", Float) = 1
		_cVTilling("cVTilling", Float) = 1
		_cFresnelBias("cFresnelBias", Float) = 0
		_cFresnelScale("cFresnelScale", Float) = 1
		_cFresnelPower("cFresnelPower", Float) = 5
		_cEmissivePower("cEmissivePower", Float) = 0
		_cRoughness("cRoughness", Float) = 0
		_cBaseColorIndensity("cBaseColorIndensity", Float) = 0
		_cBasecolor("cBasecolor", Color) = (1,1,1,0)
		_cEmissive("cEmissive", Color) = (1,1,1,0)
		_T_RedMarble_ORM("T_RedMarble_ORM", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float4 _cBasecolor;
		uniform sampler2D _T_RedMarble_ORM;
		uniform float _cUTilling;
		uniform float _cVTilling;
		uniform float _cBaseColorIndensity;
		uniform sampler2D _T_CleanJade_D;
		uniform float4 _cEmissive;
		uniform float _cFresnelBias;
		uniform float _cFresnelScale;
		uniform float _cFresnelPower;
		uniform float _cEmissivePower;
		uniform sampler2D _T_CleanJade_MRA;
		uniform float _cRoughness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 appendResult10 = (float4(_cUTilling , _cVTilling , 0.0 , 0.0));
			float4 temp_output_6_0 = ( float4( i.uv_texcoord, 0.0 , 0.0 ) * appendResult10 );
			o.Albedo = ( ( _cBasecolor * pow( tex2D( _T_RedMarble_ORM, temp_output_6_0.xy ).g , 0.45 ) ) * _cBaseColorIndensity ).rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV18 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode18 = ( _cFresnelBias + _cFresnelScale * pow( 1.0 - fresnelNdotV18, _cFresnelPower ) );
			o.Emission = ( ( ( tex2D( _T_CleanJade_D, temp_output_6_0.xy ) + _cEmissive ) * fresnelNode18 ) * _cEmissivePower ).rgb;
			float4 tex2DNode2 = tex2D( _T_CleanJade_MRA, temp_output_6_0.xy );
			o.Metallic = tex2DNode2.r;
			float temp_output_26_0 = _cRoughness;
			o.Smoothness = temp_output_26_0;
			o.Occlusion = tex2DNode2.b;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18930
646;434;1399;607;1360.061;706.3283;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;9;-1758.046,-61.17733;Float;False;Property;_cVTilling;cVTilling;3;0;Create;True;0;0;0;False;0;False;1;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1765.847,-161.2773;Float;False;Property;_cUTilling;cUTilling;2;0;Create;True;0;0;0;False;0;False;1;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1824.129,-319.6938;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;10;-1526.646,-100.1773;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-1397.946,-279.5771;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-856.9847,-85.14511;Float;False;Property;_cFresnelBias;cFresnelBias;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-900.9847,62.25489;Float;False;Property;_cFresnelPower;cFresnelPower;6;0;Create;True;0;0;0;False;0;False;5;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-720,-256;Float;False;Property;_cEmissive;cEmissive;12;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.8855209,1,0.5613207,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;30;-994.4183,-877.9172;Inherit;True;Property;_T_RedMarble_ORM;T_RedMarble_ORM;13;0;Create;True;0;0;0;False;0;False;-1;06e9658ddb10b8d42806ce71e15bf5eb;23a71cde71e66c7489ba6f8c310c6c63;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1135.67,-410.6188;Inherit;True;Property;_T_CleanJade_D;T_CleanJade_D;0;0;Create;True;0;0;0;False;0;False;-1;4ed2cb4100c77244180a80e3e4f25355;807f6a7638ad3594ea98b399f4b56056;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-861.9847,-9.145111;Float;False;Property;_cFresnelScale;cFresnelScale;5;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-362.9871,-706.7556;Float;False;Property;_cBasecolor;cBasecolor;11;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.7645528,0.9245283,0.2747419,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;29;-855.5839,-627.0314;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0.45;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;18;-569.1953,-84.19;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-486.0455,-278.2973;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-318.1953,-199.9901;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-53.18884,-475.9344;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-158.5513,-288.5587;Float;False;Property;_cBaseColorIndensity;cBaseColorIndensity;9;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-294.4358,59.64744;Float;False;Property;_cEmissivePower;cEmissivePower;7;0;Create;True;0;0;0;False;0;False;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-242.4575,286.1371;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1095.444,151.5189;Inherit;True;Property;_T_CleanJade_MRA;T_CleanJade_MRA;1;0;Create;True;0;0;0;False;0;False;-1;4038b9bb96ece29469fb29f8ffafbba1;4038b9bb96ece29469fb29f8ffafbba1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-104.972,-99.91199;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;-1101.677,387.4575;Inherit;True;Property;_T_CleanJade_N;T_CleanJade_N;10;0;Create;True;0;0;0;False;0;False;-1;ecea83512c80d7546be5215bd850afe8;ecea83512c80d7546be5215bd850afe8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;229.4487,-373.5587;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-250.5369,182.5307;Float;False;Property;_cRoughness;cRoughness;8;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;28;230.568,-26.73516;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Cjjfbh/Cjjfbh_Ground;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;7;0
WireConnection;10;1;9;0
WireConnection;6;0;5;0
WireConnection;6;1;10;0
WireConnection;30;1;6;0
WireConnection;1;1;6;0
WireConnection;29;0;30;2
WireConnection;18;1;20;0
WireConnection;18;2;21;0
WireConnection;18;3;22;0
WireConnection;13;0;1;0
WireConnection;13;1;16;0
WireConnection;17;0;13;0
WireConnection;17;1;18;0
WireConnection;11;0;4;0
WireConnection;11;1;29;0
WireConnection;25;0;2;2
WireConnection;25;1;26;0
WireConnection;2;1;6;0
WireConnection;23;0;17;0
WireConnection;23;1;24;0
WireConnection;3;1;6;0
WireConnection;31;0;11;0
WireConnection;31;1;32;0
WireConnection;28;0;31;0
WireConnection;28;2;23;0
WireConnection;28;3;2;1
WireConnection;28;4;26;0
WireConnection;28;5;2;3
ASEEND*/
//CHKSM=32283319B2EB906068065AF2D8FD7B656B9EC5D1