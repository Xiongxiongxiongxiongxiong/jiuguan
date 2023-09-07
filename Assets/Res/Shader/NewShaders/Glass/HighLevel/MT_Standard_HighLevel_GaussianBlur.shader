// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MT/Builtin/Blur/HighLevel/GaussianBlur"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)][Header(Rendering)]_CullMode("CullMode", Float) = 2
		[Enum(UnityEngine.Rendering.CompareFunction)]_DepthTest("DepthTest", Float) = 4
		[Toggle]_DepthWrite("DepthWrite", Float) = 1
		_DepthOffset("DepthOffset", Float) = 0
		[Header(PBR)]_MainColor("MainColor", Color) = (1,1,1,1)
		_Albedo("Albedo", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Range( 0 , 10)) = 1
		_MSA1("R:Metallic G:Smoothness B:AO A:BlurMask", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_AO("AO", Range( 0 , 1)) = 1
		_Blur("Blur", Float) = 0
		_Mask("Mask", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		GrabPass{ }
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			half ASEVFace : VFACE;
			float4 screenPos;
		};

		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float4 _MainColor;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _Blur;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform sampler2D _MSA1;
		uniform float4 _MSA1_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _AO;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode31_g16 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 switchResult58_g16 = (((i.ASEVFace>0)?(tex2DNode31_g16):(-tex2DNode31_g16)));
			float3 NormalMap32_g16 = switchResult58_g16;
			float3 NormalTS127 = NormalMap32_g16;
			o.Normal = NormalTS127;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode35_g16 = tex2D( _Albedo, uv_Albedo );
			float3 Albedo40_g16 = ( (_MainColor).rgb * (tex2DNode35_g16).rgb );
			float Alpha38_g16 = ( _MainColor.a * tex2DNode35_g16.a );
			o.Albedo = ( Albedo40_g16 * Alpha38_g16 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 appendResult155 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
			float2 UV156 = appendResult155;
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float lerpResult146 = lerp( 0.0 , ( _Blur * 0.0625 ) , tex2D( _Mask, uv_Mask ).r);
			float Offset147 = lerpResult146;
			float2 temp_cast_0 = (Offset147).xx;
			float4 screenColor69 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( UV156 - temp_cast_0 ));
			float4 V00947416184 = float4(0.0947416,0.0947416,0.0947416,0.0947416);
			float4 leftUp162 = ( screenColor69 * V00947416184 );
			float2 appendResult173 = (float2(0.0 , Offset147));
			float4 screenColor163 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( UV156 - appendResult173 ));
			float4 V0118318187 = float4(0.118318,0.118318,0.118318,0.118318);
			float4 up168 = ( screenColor163 * V0118318187 );
			float4 screenColor175 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( UV156 + Offset147 ));
			float4 rightUp179 = ( screenColor175 * V00947416184 );
			float2 appendResult203 = (float2(Offset147 , 0.0));
			float4 screenColor196 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( UV156 - appendResult203 ));
			float4 left202 = ( screenColor196 * V0118318187 );
			float4 screenColor205 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,UV156);
			float4 V0147761213 = float4(0.147761,0.147761,0.147761,0.147761);
			float4 Middle208 = ( screenColor205 * V0147761213 );
			float2 appendResult222 = (float2(Offset147 , 0.0));
			float4 screenColor215 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( UV156 + appendResult222 ));
			float4 Right218 = ( screenColor215 * V0118318187 );
			float2 appendResult224 = (float2(-Offset147 , Offset147));
			float4 screenColor228 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( UV156 + appendResult224 ));
			float4 leftDown231 = ( screenColor228 * V00947416184 );
			float2 appendResult241 = (float2(0.0 , Offset147));
			float4 screenColor243 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( UV156 + appendResult241 ));
			float4 Down240 = ( screenColor243 * V0118318187 );
			float2 appendResult250 = (float2(Offset147 , -Offset147));
			float4 screenColor252 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( UV156 + appendResult250 ));
			float4 rightDown249 = ( screenColor252 * V0118318187 );
			float4 GaussianBlur265 = ( leftUp162 + up168 + rightUp179 + left202 + Middle208 + Right218 + leftDown231 + Down240 + rightDown249 );
			o.Emission = GaussianBlur265.rgb;
			float2 uv_MSA1 = i.uv_texcoord * _MSA1_ST.xy + _MSA1_ST.zw;
			float4 tex2DNode7_g16 = tex2D( _MSA1, uv_MSA1 );
			float Metallic19_g16 = ( tex2DNode7_g16.r * _Metallic );
			o.Metallic = Metallic19_g16;
			float Smoothness16_g16 = ( ( 1.0 - tex2DNode7_g16.g ) * _Smoothness );
			o.Smoothness = Smoothness16_g16;
			float AO14_g16 = ( tex2DNode7_g16.b * _AO );
			o.Occlusion = AO14_g16;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
2718;357;2560;1378;1251.628;684.7734;1.224176;True;True
Node;AmplifyShaderEditor.RangedFloatNode;142;-1546.573,-1767.297;Inherit;False;Property;_Blur;Blur;16;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-1365.232,-1747.634;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.0625;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;145;-1518.171,-1637.299;Inherit;True;Property;_Mask;Mask;17;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;146;-1184.982,-1655.87;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;244;1851.723,-1096.879;Inherit;False;1225.561;315.229;右下;10;254;250;253;245;246;247;252;251;248;249;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;223;-506.587,-1103.292;Inherit;False;1236;325;左下;10;231;230;229;228;232;224;234;233;225;226;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GrabScreenPosition;70;-1557.746,-1410.735;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;147;-938.0942,-1614.359;Inherit;False;Offset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;214;1570.39,-1465.508;Inherit;False;1082.561;336.429;右;8;222;221;220;219;218;217;216;215;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;193;508.5448,-1827.465;Inherit;False;1119.184;346.5623;上;8;188;172;173;168;167;164;163;166;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;253;1903.88,-883.207;Inherit;False;147;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-489.1602,-970.2283;Inherit;False;147;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;235;748.9614,-1101.433;Inherit;False;1079.561;319.429;下;8;236;243;242;241;240;239;238;237;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;195;-508.6787,-1447.635;Inherit;False;1104;315;左;8;202;201;200;196;197;199;198;203;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;155;-1280.848,-1387.489;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;-1097.848,-1395.489;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;254;2077.88,-881.207;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;236;798.9613,-914.4139;Inherit;False;147;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-482.6787,-1320.635;Inherit;False;147;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;234;-310.1602,-961.2283;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;194;1659.218,-1827.536;Inherit;False;994.5605;338.429;右上;7;175;178;189;179;182;181;174;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;245;1904.723,-958.86;Inherit;False;147;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;557.1685,-1681.269;Inherit;False;147;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;-490.587,-877.2922;Inherit;False;147;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;1620.39,-1307.489;Inherit;False;147;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;192;-509.9673,-1824.52;Inherit;False;985;348;左上;7;69;158;159;157;185;161;162;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-408.6787,-1399.635;Inherit;False;156;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;183;-1534.793,-1207.145;Inherit;False;Constant;_Vector1;Vector1;8;0;Create;True;0;0;False;0;False;0.0947416,0.0947416,0.0947416,0.0947416;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;186;-1532.793,-1032.145;Inherit;False;Constant;_Vector2;Vector2;8;0;Create;True;0;0;False;0;False;0.118318,0.118318,0.118318,0.118318;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;212;-1529.076,-847.882;Inherit;False;Constant;_Vector3;Vector3;8;0;Create;True;0;0;False;0;False;0.147761,0.147761,0.147761,0.147761;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;246;1927.283,-1053.056;Inherit;False;156;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;226;-406.587,-1055.292;Inherit;False;156;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;224;-151.3824,-937.8953;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;204;617.5909,-1455.577;Inherit;False;919.5605;325.429;中;5;208;206;207;205;211;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;250;2207.658,-954.5399;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;237;824.5212,-1038.61;Inherit;False;156;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;222;1811.325,-1292.169;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;221;1645.95,-1402.685;Inherit;False;156;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-459.9673,-1699.52;Inherit;False;147;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;173;751.1685,-1705.269;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;1709.218,-1669.517;Inherit;False;147;Offset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;1734.778,-1764.713;Inherit;False;156;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-459.9673,-1774.52;Inherit;False;156;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;166;716.7291,-1777.465;Inherit;False;156;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;241;989.8961,-928.0939;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;203;-274.4741,-1316.238;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;213;-1183.276,-834.8829;Inherit;False;V0147761;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;184;-1152.793,-1149.145;Inherit;False;V00947416;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;238;1126.64,-1031.639;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;158;-275.9673,-1760.52;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;211;638.1509,-1396.754;Inherit;False;156;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;247;2344.402,-1032.085;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;164;900.7293,-1762.465;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;219;1948.069,-1395.714;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;182;1928.897,-1737.742;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;197;-125.6787,-1377.635;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;232;-9.160156,-1013.228;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;187;-1120.793,-980.1443;Inherit;False;V0118318;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;215;2081.587,-1403.508;Inherit;False;Global;_GrabScreen6;Grab Screen 6;9;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;217;2075.311,-1223.079;Inherit;False;187;V0118318;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;252;2477.92,-1039.879;Inherit;False;Global;_GrabScreen9;Grab Screen 6;9;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;200;7.321289,-1219.635;Inherit;False;187;V0118318;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;243;1260.158,-1039.433;Inherit;False;Global;_GrabScreen8;Grab Screen 6;9;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;228;133.0496,-1047.115;Inherit;False;Global;_GrabScreen7;Grab Screen 4;9;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;69;-137.3307,-1763.343;Inherit;False;Global;_GrabScreen0;Grab Screen 0;9;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;207;847.5118,-1230.148;Inherit;False;213;V0147761;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;196;18.95789,-1387.458;Inherit;False;Global;_GrabScreen4;Grab Screen 4;9;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;242;1253.882,-859.0039;Inherit;False;187;V0118318;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;-144.9673,-1591.52;Inherit;False;184;V00947416;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;229;86.41302,-864.2922;Inherit;False;184;V00947416;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;2054.139,-1604.107;Inherit;False;184;V00947416;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;175;2065.415,-1777.536;Inherit;False;Global;_GrabScreen3;Grab Screen 3;9;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;188;1036.169,-1586.269;Inherit;False;187;V0118318;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;205;851.788,-1403.577;Inherit;False;Global;_GrabScreen5;Grab Screen 5;9;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;251;2471.645,-859.45;Inherit;False;187;V0118318;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;163;1039.366,-1765.288;Inherit;False;Global;_GrabScreen1;Grab Screen 1;9;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;248;2678.283,-990.056;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;230;348.413,-976.2922;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.0947416,0.0947416,0.0947416,0.09411765;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;1071.151,-1325.754;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;1236.729,-1683.465;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;2262.778,-1695.713;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;2281.95,-1353.685;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;232.3213,-1316.635;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.0947416,0.0947416,0.0947416,0.09411765;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;70.03271,-1688.52;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.0947416,0.0947416,0.0947416,0.09411765;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;1460.521,-989.61;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0.118318,0.118318,0.118318,0.1176471;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;1384.729,-1688.465;Inherit;False;up;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;249;2826.284,-995.056;Inherit;False;rightDown;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;232.0327,-1682.52;Inherit;False;leftUp;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;1232.152,-1334.754;Inherit;False;Middle;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;231;518.413,-979.2922;Inherit;False;leftDown;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;202;387.3213,-1315.635;Inherit;False;left;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;2429.951,-1358.685;Inherit;False;Right;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;240;1608.522,-994.61;Inherit;False;Down;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;179;2410.779,-1700.713;Inherit;False;rightUp;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-11.14526,-565.7407;Inherit;False;202;left;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;179.8547,-567.7407;Inherit;False;208;Middle;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;370.8547,-558.7407;Inherit;False;218;Right;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-13.14526,-468.7407;Inherit;False;231;leftDown;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;259;185.8547,-464.7407;Inherit;False;240;Down;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;368.8547,-458.7407;Inherit;False;249;rightDown;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;-10.80591,-661.9562;Inherit;False;162;leftUp;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;173.9331,-662.7781;Inherit;False;168;up;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;256;361.8938,-656.2134;Inherit;False;179;rightUp;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;264;638.849,-649.7302;Inherit;False;9;9;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;140;-518.288,-26.55663;Inherit;False;BlurPBR;4;;16;07fd1c1970aa6b94b9614eb3c8fcceb6;0;0;9;FLOAT3;0;FLOAT3;49;COLOR;50;FLOAT;51;FLOAT;52;FLOAT;53;FLOAT;62;FLOAT;43;FLOAT;56
Node;AmplifyShaderEditor.RegisterLocalVarNode;265;856.849,-589.7302;Inherit;False;GaussianBlur;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1178.441,-68.76704;Inherit;False;Property;_DepthTest;DepthTest;1;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1183.641,132.733;Inherit;False;Property;_DepthOffset;DepthOffset;3;0;Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1182.341,30.03297;Inherit;False;Property;_DepthWrite;DepthWrite;2;1;[Toggle];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-178.1711,220.0339;Inherit;False;NormalTS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1172.6,-156.4003;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;1;Header(Rendering);False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-115.8875,-17.45667;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;273.4565,-37.94413;Inherit;False;265;GaussianBlur;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;119;624.6185,-61.33642;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MT/Builtin/Blur/HighLevel/NormalBlur;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;Glass;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;18;-1;-1;-1;0;False;0;0;True;1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;143;0;142;0
WireConnection;146;1;143;0
WireConnection;146;2;145;1
WireConnection;147;0;146;0
WireConnection;155;0;70;1
WireConnection;155;1;70;2
WireConnection;156;0;155;0
WireConnection;254;0;253;0
WireConnection;234;0;233;0
WireConnection;224;0;234;0
WireConnection;224;1;225;0
WireConnection;250;0;245;0
WireConnection;250;1;254;0
WireConnection;222;0;220;0
WireConnection;173;1;172;0
WireConnection;241;1;236;0
WireConnection;203;0;198;0
WireConnection;213;0;212;0
WireConnection;184;0;183;0
WireConnection;238;0;237;0
WireConnection;238;1;241;0
WireConnection;158;0;157;0
WireConnection;158;1;159;0
WireConnection;247;0;246;0
WireConnection;247;1;250;0
WireConnection;164;0;166;0
WireConnection;164;1;173;0
WireConnection;219;0;221;0
WireConnection;219;1;222;0
WireConnection;182;0;174;0
WireConnection;182;1;181;0
WireConnection;197;0;199;0
WireConnection;197;1;203;0
WireConnection;232;0;226;0
WireConnection;232;1;224;0
WireConnection;187;0;186;0
WireConnection;215;0;219;0
WireConnection;252;0;247;0
WireConnection;243;0;238;0
WireConnection;228;0;232;0
WireConnection;69;0;158;0
WireConnection;196;0;197;0
WireConnection;175;0;182;0
WireConnection;205;0;211;0
WireConnection;163;0;164;0
WireConnection;248;0;252;0
WireConnection;248;1;251;0
WireConnection;230;0;228;0
WireConnection;230;1;229;0
WireConnection;206;0;205;0
WireConnection;206;1;207;0
WireConnection;167;0;163;0
WireConnection;167;1;188;0
WireConnection;178;0;175;0
WireConnection;178;1;189;0
WireConnection;216;0;215;0
WireConnection;216;1;217;0
WireConnection;201;0;196;0
WireConnection;201;1;200;0
WireConnection;161;0;69;0
WireConnection;161;1;185;0
WireConnection;239;0;243;0
WireConnection;239;1;242;0
WireConnection;168;0;167;0
WireConnection;249;0;248;0
WireConnection;162;0;161;0
WireConnection;208;0;206;0
WireConnection;231;0;230;0
WireConnection;202;0;201;0
WireConnection;218;0;216;0
WireConnection;240;0;239;0
WireConnection;179;0;178;0
WireConnection;264;0;255;0
WireConnection;264;1;257;0
WireConnection;264;2;256;0
WireConnection;264;3;263;0
WireConnection;264;4;262;0
WireConnection;264;5;261;0
WireConnection;264;6;260;0
WireConnection;264;7;259;0
WireConnection;264;8;258;0
WireConnection;265;0;264;0
WireConnection;127;0;140;49
WireConnection;134;0;140;0
WireConnection;134;1;140;43
WireConnection;119;0;134;0
WireConnection;119;1;127;0
WireConnection;119;2;266;0
WireConnection;119;3;140;51
WireConnection;119;4;140;52
WireConnection;119;5;140;53
ASEEND*/
//CHKSM=C7C560DBF1FB9D8F4AE4883802CCAEB252A22AEB