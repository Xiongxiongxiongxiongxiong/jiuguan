// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MT/Builtin/Standard_Teleport"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)][Header(Rendering)]_CullMode("CullMode", Float) = 2
		[Enum(UnityEngine.Rendering.BlendMode)]_Src("Src", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)]_Dst("Dst", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_DepthTest("DepthTest", Float) = 4
		[Toggle]_DepthWrite("DepthWrite", Float) = 1
		_DepthOffset("DepthOffset", Float) = 0
		_Cutout("Cutout", Range( 0 , 1)) = 0
		[Header(PBR)]_MainColor("MainColor", Color) = (1,1,1,1)
		_Albedo("Albedo", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Range( 0 , 10)) = 1
		_MSA1("R:Metallic G:Smoothness B:AO", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_AO("AO", Range( 0 , 1)) = 1
		_EmissionMap("EmissionMap", 2D) = "white" {}
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		[Header(Dissolve)]_DissolveEdgeWidth("DissolveEdgeWidth", Range( 0 , 1)) = 0.3
		_DissolveEdgeTex("DissolveEdgeTex", 2D) = "white" {}
		_NoiseXYZTilingwScale("Noise(XYZ:Tiling w:Scale)", Vector) = (100,100,100,1)
		_DissolveEdgeTexIntensity("DissolveEdgeTexIntensity", Float) = 1
		_DissolveCutout("DissolveCutout", Float) = 1
		_DissolveProcess("DissolveProcess", Float) = -1
		_VertexSpeed("VertexSpeed", Float) = 10
		[HDR]_VertexColor("VertexColor", Color) = (0,0,0,0)
		_VertexMaxOffset("VertexMaxOffset", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull [_CullMode]
		ZWrite [_DepthWrite]
		ZTest [_DepthTest]
		Offset  [_DepthOffset] , 0
		Blend [_Src] [_Dst]
		
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			half ASEVFace : VFACE;
		};

		uniform float _DissolveProcess;
		uniform float _DissolveEdgeWidth;
		uniform float _VertexMaxOffset;
		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float4 _MainColor;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float _DissolveCutout;
		uniform float4 _NoiseXYZTilingwScale;
		uniform float _VertexSpeed;
		uniform float4 _EmissionColor;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform sampler2D _DissolveEdgeTex;
		uniform float _DissolveEdgeTexIntensity;
		uniform float4 _VertexColor;
		uniform sampler2D _MSA1;
		uniform float4 _MSA1_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _AO;
		uniform float _Cutout;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 objToWorld269 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float YDir273 = ( ase_worldPos.y - objToWorld269.y );
			float DissolveEdgeWidth166 = _DissolveEdgeWidth;
			float DissolveProcess181 = (( DissolveEdgeWidth166 * -1.0 ) + (_DissolveProcess - 0.0) * (1.000001 - ( DissolveEdgeWidth166 * -1.0 )) / (1.0 - 0.0));
			float temp_output_56_0 = ( ( 0.5 + ( YDir273 * -1.0 ) ) - DissolveProcess181 );
			float Clip118 = temp_output_56_0;
			float temp_output_280_0 = saturate( -Clip118 );
			float VertexOffset281 = ( temp_output_280_0 * _VertexMaxOffset );
			float DissolveDirY62 = sign( 1.0 );
			float3 appendResult254 = (float3(0.0 , ( VertexOffset281 * DissolveDirY62 ) , 0.0));
			float3 FinalVertexOffset398 = appendResult254;
			v.vertex.xyz += FinalVertexOffset398;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode31_g7 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 switchResult58_g7 = (((i.ASEVFace>0)?(tex2DNode31_g7):(-tex2DNode31_g7)));
			float3 NormalMap32_g7 = switchResult58_g7;
			o.Normal = NormalMap32_g7;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode35_g7 = tex2D( _Albedo, uv_Albedo );
			float3 Albedo40_g7 = ( (_MainColor).rgb * (tex2DNode35_g7).rgb );
			float3 PBRAlbedo389 = Albedo40_g7;
			float Alpha38_g7 = ( _MainColor.a * tex2DNode35_g7.a );
			float PBRAlpha391 = Alpha38_g7;
			float DissolveEdgeWidth166 = _DissolveEdgeWidth;
			float DissolveProcess181 = (( DissolveEdgeWidth166 * -1.0 ) + (_DissolveProcess - 0.0) * (1.000001 - ( DissolveEdgeWidth166 * -1.0 )) / (1.0 - 0.0));
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld269 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float YDir273 = ( ase_worldPos.y - objToWorld269.y );
			float temp_output_56_0 = ( ( 0.5 + ( YDir273 * -1.0 ) ) - DissolveProcess181 );
			float Clip118 = temp_output_56_0;
			float temp_output_162_0 = ( DissolveEdgeWidth166 * -1.0 );
			float smoothstepResult153 = smoothstep( 0.0 , temp_output_162_0 , ( Clip118 + temp_output_162_0 ));
			float ifLocalVar154 = 0;
			if( smoothstepResult153 > 1.0 )
				ifLocalVar154 = 0.0;
			else if( smoothstepResult153 < 1.0 )
				ifLocalVar154 = smoothstepResult153;
			float TransitionSoftMask326 = ifLocalVar154;
			float XDir272 = ( ase_worldPos.x - objToWorld269.x );
			float zDir437 = ( ase_worldPos.z - objToWorld269.z );
			float3 appendResult432 = (float3(XDir272 , YDir273 , zDir437));
			float3 appendResult346 = (float3(_NoiseXYZTilingwScale.x , _NoiseXYZTilingwScale.y , _NoiseXYZTilingwScale.z));
			float3 temp_output_371_0 = ( appendResult432 * appendResult346 );
			float2 temp_output_353_0 = ( float2( 0,1 ) * ( _VertexSpeed * DissolveProcess181 ) );
			float simplePerlin3D237 = snoise( ( temp_output_371_0 + float3( temp_output_353_0 ,  0.0 ) )*_NoiseXYZTilingwScale.w );
			simplePerlin3D237 = simplePerlin3D237*0.5 + 0.5;
			float Noise243 = simplePerlin3D237;
			float TransitionUpMask300 = step( 1.0 , smoothstepResult153 );
			float TransitionMask174 = step( 1E-06 , ifLocalVar154 );
			clip( PBRAlpha391 - ( step( 1.0 , DissolveProcess181 ) + ( ( ( PBRAlpha391 - Clip118 ) + ( step( 1.0 , TransitionSoftMask326 ) + _DissolveCutout ) ) * Noise243 * ( TransitionUpMask300 + TransitionMask174 ) ) ));
			float3 FinalColor387 = PBRAlbedo389;
			o.Albedo = FinalColor387;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			float4 tex2DNode13_g7 = tex2D( _EmissionMap, uv_EmissionMap );
			float4 Emission18_g7 = ( _EmissionColor * tex2DNode13_g7 );
			float4 PBREmission395 = Emission18_g7;
			float2 appendResult133 = (float2(1.0 , ifLocalVar154));
			float4 DissolveColor176 = ( tex2D( _DissolveEdgeTex, appendResult133 ) * _DissolveEdgeTexIntensity );
			float4 lerpResult139 = lerp( PBREmission395 , DissolveColor176 , TransitionSoftMask326);
			float4 temp_output_334_0 = ( lerpResult139 + ( TransitionUpMask300 * _VertexColor ) );
			float4 FinalEmission400 = temp_output_334_0;
			o.Emission = FinalEmission400.rgb;
			float2 uv_MSA1 = i.uv_texcoord * _MSA1_ST.xy + _MSA1_ST.zw;
			float4 tex2DNode7_g7 = tex2D( _MSA1, uv_MSA1 );
			float Metallic19_g7 = ( tex2DNode7_g7.r * _Metallic );
			o.Metallic = Metallic19_g7;
			float Smoothness16_g7 = ( ( 1.0 - tex2DNode7_g7.g ) * _Smoothness );
			o.Smoothness = Smoothness16_g7;
			float AO14_g7 = ( tex2DNode7_g7.b * _AO );
			o.Occlusion = AO14_g7;
			float temp_output_394_0 = PBRAlpha391;
			o.Alpha = temp_output_394_0;
			clip( temp_output_394_0 - _Cutout );
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers xbox360 xboxone ps4 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
2560;0;2560;1378;3935.495;491.2501;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;404;-3582.008,-706.0048;Inherit;False;627.8656;174.933;传送边缘宽度;2;166;75;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-3532.008,-656.0048;Inherit;False;Property;_DissolveEdgeWidth;DissolveEdgeWidth;19;0;Create;True;0;0;False;1;Header(Dissolve);False;0.3;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;403;-2850.171,-632.2708;Inherit;False;1004.083;393.9999;计算顶点世界坐标 - 轴心点的X与Y轴的方向;8;268;269;270;271;273;272;436;437;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;269;-2800.171,-422.2706;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;268;-2768.171,-582.2708;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;-3228.066,-655.3138;Inherit;False;DissolveEdgeWidth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;408;-3586.323,492.0095;Inherit;False;1420.13;452.5285;根据传送方向，计算溶解进度;10;102;101;103;172;173;168;169;55;85;181;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;270;-2321.744,-435.4439;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;-3127.556,627.4797;Inherit;False;166;DissolveEdgeWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-2862.377,634.6667;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-3041.177,542.0098;Inherit;False;Property;_DissolveProcess;DissolveProcess;24;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;273;-2089.087,-405.5516;Inherit;False;YDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;405;-5735.684,-697.9045;Inherit;False;2006.359;674.0714;根据移动方向计算移动遮罩;25;67;69;88;275;274;89;70;117;68;110;111;116;53;183;71;56;115;112;72;114;113;96;118;47;182;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-5459.833,-433.0267;Inherit;False;273;YDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;85;-2664.475,584.1097;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.05;False;4;FLOAT;1.000001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;-2425.193,604.5977;Inherit;False;DissolveProcess;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-5188.684,-391.9051;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-4972.683,-380.9051;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-5060,-241.8163;Inherit;False;181;DissolveProcess;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;56;-4780.683,-351.9044;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;407;-3587.59,-159.9207;Inherit;False;1999.205;603.6011;计算传送边缘贴图采样与边缘遮罩，注意，如果想按照uv双方向采样，需要按照传送方向的UV保持一直;18;176;164;74;341;355;333;300;155;174;156;326;133;154;153;161;165;162;167;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-3541.49,62.16665;Inherit;False;166;DissolveEdgeWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-3972.327,-327.4665;Inherit;False;Clip;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-3329.59,-24.2333;Inherit;False;118;Clip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-3269.59,80.76669;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;271;-2320.172,-534.2703;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;436;-2321.887,-327.4624;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;406;-1275.625,-624.9248;Inherit;False;1561.825;916.9999;计算噪点;18;349;350;352;346;356;351;354;371;353;348;237;243;414;430;431;432;433;434;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;161;-3105.59,-8.233329;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;437;-2094.887,-312.4624;Inherit;False;zDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;-2126.087,-530.5513;Inherit;False;XDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;153;-2945.59,7.766666;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;155;-3014.286,173.6895;Inherit;False;Constant;_Float7;Float 7;13;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;354;-1144.104,171.8628;Inherit;False;181;DissolveProcess;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;352;-1193.624,49.07486;Inherit;False;Property;_VertexSpeed;VertexSpeed;25;0;Create;True;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;435;-1214.31,-397.9059;Inherit;False;437;zDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;430;-1207.108,-579.9292;Inherit;False;272;XDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;431;-1216.108,-487.9292;Inherit;False;273;YDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;434;-1231.31,-304.9059;Inherit;False;Property;_NoiseXYZTilingwScale;Noise(XYZ:Tiling w:Scale);21;0;Create;True;0;0;False;0;False;100,100,100,1;100,1,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;356;-866.3228,6.605256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;414;-856.7715,-146.8135;Inherit;False;Constant;_Vector0;Vector 0;17;0;Create;True;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ConditionalIfNode;154;-2754.59,7.766666;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;409;-3588.415,998.929;Inherit;False;1134.595;357.5034;计算顶点偏移值，不含方向;7;262;279;249;280;255;281;289;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;432;-930.1079,-482.9292;Inherit;False;FLOAT3;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;346;-905.6245,-302.9252;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;-2481.055,12.30063;Inherit;False;TransitionSoftMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;353;-630.6246,-103.925;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;45;-764.8323,873.9789;Inherit;False;PBR;7;;7;1bdad994f2fe8074b907eff23b7831db;0;0;8;FLOAT3;0;FLOAT3;49;COLOR;50;FLOAT;51;FLOAT;52;FLOAT;53;FLOAT;43;FLOAT;56
Node;AmplifyShaderEditor.CommentaryNode;412;-5787.598,695.6711;Inherit;False;2069.442;667.849;计算最终的Albedo，根据噪点图、边缘遮罩、移动遮罩;20;357;119;385;393;386;380;376;384;382;378;344;245;383;369;343;345;392;390;57;387;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;-3538.415,1124.848;Inherit;False;118;Clip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;371;-681.6246,-382.9252;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;333;-2721.823,332.5168;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;402;-3582.215,-485.441;Inherit;False;625.1931;269.7899;获取顶点移动方向;6;65;66;63;61;64;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;433;-425.1079,-222.9292;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;279;-3328.259,1131.407;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;357;-5737.598,949.9568;Inherit;False;326;TransitionSoftMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;156;-2522.13,-103.4613;Inherit;False;2;0;FLOAT;1E-06;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;133;-2462.59,122.7667;Inherit;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;391;-498.8778,1059.49;Inherit;False;PBRAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;341;-2297.379,334.3568;Inherit;False;Property;_DissolveEdgeTexIntensity;DissolveEdgeTexIntensity;22;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;393;-5373.061,745.6711;Inherit;False;391;PBRAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;280;-3173.656,1138.047;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;237;-203.6234,-368.9252;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;385;-5548.014,1113.52;Inherit;False;Property;_DissolveCutout;DissolveCutout;23;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;386;-5442.013,994.52;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-2346.126,-109.9207;Inherit;False;TransitionMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;249;-3218.992,1241.433;Inherit;False;Property;_VertexMaxOffset;VertexMaxOffset;27;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-3532.215,-330.6512;Inherit;False;Constant;_DissolveDirY;DissolveDirY;24;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-5499.318,849.8627;Inherit;False;118;Clip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;-2575.128,341.8347;Inherit;False;TransitionUpMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;74;-2309.534,106.2482;Inherit;True;Property;_DissolveEdgeTex;DissolveEdgeTex;20;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SignOpNode;61;-3335.375,-329.3917;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;164;-1966.795,219.0128;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;-2904.873,1162.817;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;243;43.20276,-368.7894;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;376;-5177.048,886.7978;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;382;-5140.013,1159.52;Inherit;False;300;TransitionUpMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-5122.013,1248.52;Inherit;False;174;TransitionMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;380;-5249.942,1049.937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;410;-2388.646,1005.997;Inherit;False;952.6313;346.2793;计算顶点偏移，含方向;7;286;285;398;254;284;282;283;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;378;-4960.686,965.4748;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-3200.021,-334.9416;Inherit;False;DissolveDirY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;395;-502.9919,919.7955;Inherit;False;PBREmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;245;-5009.058,1081.984;Inherit;False;243;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;383;-4846.013,1209.52;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;281;-2696.82,1186.265;Inherit;False;VertexOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;411;-5759.764,45.81637;Inherit;False;2030.576;617.204;计算最终的自发光，根据传送边缘与移动遮罩;16;330;175;332;400;334;139;337;328;177;163;399;306;419;424;425;426;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;-5062.093,820.5991;Inherit;False;181;DissolveProcess;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;176;-1803.612,159.6705;Inherit;False;DissolveColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;389;-520.8723,823.6342;Inherit;False;PBRAlbedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-5437.54,190.8503;Inherit;False;176;DissolveColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;-2330.646,1140.388;Inherit;False;281;VertexOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;283;-2338.646,1268.388;Inherit;False;62;DissolveDirY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;343;-4770.382,850.5822;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;369;-4773.857,1033.169;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;328;-5732.738,169.7237;Inherit;False;326;TransitionSoftMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;163;-5156.632,422.0946;Inherit;False;Property;_VertexColor;VertexColor;26;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;306;-5165.666,321.6259;Inherit;False;300;TransitionUpMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;399;-5427.75,97.11626;Inherit;False;395;PBREmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;345;-4444.516,945.5611;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;392;-4496.861,1226.671;Inherit;False;391;PBRAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;390;-4514.955,1112.115;Inherit;False;389;PBRAlbedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;-4887.14,330.3526;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;286;-2069.648,1202.388;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;139;-5183.928,176.3331;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;254;-1901.749,1132.41;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClipNode;57;-4186.748,1106.846;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;334;-4715.148,178.6586;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;400;-4228.595,154.6456;Inherit;False;FinalEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;387;-3961.157,1162.816;Inherit;False;FinalColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;398;-1709.082,1127.694;Inherit;False;FinalVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;413;-1259.297,438.6117;Inherit;False;1528.176;170.7705;Renderering;7;1;5;6;10;9;8;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;111;-4798.683,-464.9054;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-5220.684,-647.9044;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-4389.034,-510.5845;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-5684.685,-615.9051;Inherit;False;64;DissolveDirX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-5017.034,-138.8337;Inherit;False;62;DissolveDirY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-3535.323,829.5383;Inherit;False;62;DissolveDirY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;401;-236.1534,941.3796;Inherit;False;400;FinalEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-3536.323,748.5378;Inherit;False;64;DissolveDirX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;424;-5522.071,449.2462;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;350;-1205.624,-44.92493;Inherit;False;62;DissolveDirY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;348;-474.6249,-510.9252;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;47;-5685.684,-516.9054;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-5012.683,-647.9044;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1209.297,494.3822;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;1;Header(Rendering);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1039.748,491.3746;Inherit;False;Property;_Src;Src;1;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;394;-126.1354,1075.794;Inherit;False;391;PBRAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;116;-4766.034,-187.8336;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;355;-2719.646,201.0666;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;5,5;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;112;-4586.033,-484.5847;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;63;-3339.623,-431.2409;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;72;-4615.282,-647.2046;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;115;-4592.033,-210.8336;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;419;-4567.542,304.6484;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-5684.685,-301.9052;Inherit;False;62;DissolveDirY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;426;-5704.078,442.7463;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;89;-5428.684,-615.9051;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;330;-5720.818,318.5331;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;425;-5568.874,343.9465;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;285;-2066.649,1091.388;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-4161.834,-440.8836;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;351;-983.6245,-123.925;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;88;-5401.684,-282.905;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;397;-161.0246,1194.788;Inherit;False;398;FinalVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;172;-3139.784,771.8993;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;182;-4895.227,-561.9456;Inherit;False;181;DissolveProcess;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-255.6288,490.6138;Inherit;False;Property;_DepthOffset;DepthOffset;5;0;Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;429;-166.6924,740.7321;Inherit;False;243;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-5092.683,-475.9053;Inherit;False;64;DissolveDirX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;173;-2983.784,773.8993;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-3530.914,-434.6506;Inherit;False;Constant;_DissolveDirX;DissolveDirX;24;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;282;-2333.216,1055.997;Inherit;False;64;DissolveDirX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-863.5328,489.1318;Inherit;False;Property;_Dst;Dst;2;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-3201.218,-435.441;Inherit;False;DissolveDirX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-476.3778,490.2646;Inherit;False;Property;_DepthWrite;DepthWrite;4;1;[Toggle];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;332;-5390.092,537.0835;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;-5727.262,566.068;Inherit;False;174;TransitionMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;289;-2894.275,1048.929;Inherit;False;VertexOffsetMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-684.1185,488.6117;Inherit;False;Property;_DepthTest;DepthTest;3;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-4395.034,-255.8336;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-33.12057,490.0604;Inherit;False;Property;_Cutout;Cutout;6;0;Fetch;True;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;349;-1200.624,-131.925;Inherit;False;64;DissolveDirX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;103;-3319.323,776.5383;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;388;-148.716,849.0342;Inherit;False;387;FinalColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;-5447.833,-524.0266;Inherit;False;272;XDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;122.5563,865.8885;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MT/Builtin/Standard_Teleport;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;9;0;True;10;True;0;True;8;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;8;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;True;True;True;True;0;False;-1;False;1;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;True;5;10;True;6;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.01;1,0,0,0;VertexScale;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;1;-1;0;True;28;0;0;0;False;0.01;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;166;0;75;0
WireConnection;270;0;268;2
WireConnection;270;1;269;2
WireConnection;169;0;168;0
WireConnection;273;0;270;0
WireConnection;85;0;55;0
WireConnection;85;3;169;0
WireConnection;181;0;85;0
WireConnection;68;0;275;0
WireConnection;53;1;68;0
WireConnection;56;0;53;0
WireConnection;56;1;183;0
WireConnection;118;0;56;0
WireConnection;162;0;167;0
WireConnection;271;0;268;1
WireConnection;271;1;269;1
WireConnection;436;0;268;3
WireConnection;436;1;269;3
WireConnection;161;0;165;0
WireConnection;161;1;162;0
WireConnection;437;0;436;0
WireConnection;272;0;271;0
WireConnection;153;0;161;0
WireConnection;153;2;162;0
WireConnection;356;0;352;0
WireConnection;356;1;354;0
WireConnection;154;0;153;0
WireConnection;154;2;155;0
WireConnection;154;4;153;0
WireConnection;432;0;430;0
WireConnection;432;1;431;0
WireConnection;432;2;435;0
WireConnection;346;0;434;1
WireConnection;346;1;434;2
WireConnection;346;2;434;3
WireConnection;326;0;154;0
WireConnection;353;0;414;0
WireConnection;353;1;356;0
WireConnection;371;0;432;0
WireConnection;371;1;346;0
WireConnection;333;1;153;0
WireConnection;433;0;371;0
WireConnection;433;1;353;0
WireConnection;279;0;262;0
WireConnection;156;1;154;0
WireConnection;133;1;154;0
WireConnection;391;0;45;43
WireConnection;280;0;279;0
WireConnection;237;0;433;0
WireConnection;237;1;434;4
WireConnection;386;1;357;0
WireConnection;174;0;156;0
WireConnection;300;0;333;0
WireConnection;74;1;133;0
WireConnection;61;0;66;0
WireConnection;164;0;74;0
WireConnection;164;1;341;0
WireConnection;255;0;280;0
WireConnection;255;1;249;0
WireConnection;243;0;237;0
WireConnection;376;0;393;0
WireConnection;376;1;119;0
WireConnection;380;0;386;0
WireConnection;380;1;385;0
WireConnection;378;0;376;0
WireConnection;378;1;380;0
WireConnection;62;0;61;0
WireConnection;395;0;45;50
WireConnection;383;0;382;0
WireConnection;383;1;384;0
WireConnection;281;0;255;0
WireConnection;176;0;164;0
WireConnection;389;0;45;0
WireConnection;343;1;344;0
WireConnection;369;0;378;0
WireConnection;369;1;245;0
WireConnection;369;2;383;0
WireConnection;345;0;343;0
WireConnection;345;1;369;0
WireConnection;337;0;306;0
WireConnection;337;1;163;0
WireConnection;286;0;284;0
WireConnection;286;1;283;0
WireConnection;139;0;399;0
WireConnection;139;1;177;0
WireConnection;139;2;328;0
WireConnection;254;1;286;0
WireConnection;57;0;390;0
WireConnection;57;1;392;0
WireConnection;57;2;345;0
WireConnection;334;0;139;0
WireConnection;334;1;337;0
WireConnection;400;0;334;0
WireConnection;387;0;57;0
WireConnection;398;0;254;0
WireConnection;111;0;110;0
WireConnection;70;0;89;0
WireConnection;70;1;274;0
WireConnection;113;0;72;0
WireConnection;113;1;112;0
WireConnection;424;0;426;0
WireConnection;348;0;371;0
WireConnection;348;1;353;0
WireConnection;71;0;70;0
WireConnection;116;0;117;0
WireConnection;112;1;111;0
WireConnection;63;0;65;0
WireConnection;72;0;71;0
WireConnection;72;1;182;0
WireConnection;115;1;116;0
WireConnection;419;0;334;0
WireConnection;426;0;425;0
WireConnection;89;0;69;0
WireConnection;330;0;328;0
WireConnection;425;0;330;0
WireConnection;285;0;282;0
WireConnection;96;0;113;0
WireConnection;96;1;56;0
WireConnection;351;0;349;0
WireConnection;351;1;350;0
WireConnection;88;0;67;0
WireConnection;172;1;103;0
WireConnection;173;0;172;0
WireConnection;64;0;63;0
WireConnection;332;0;424;0
WireConnection;332;1;175;0
WireConnection;289;0;280;0
WireConnection;114;0;56;0
WireConnection;114;1;115;0
WireConnection;103;0;101;0
WireConnection;103;1;102;0
WireConnection;0;0;388;0
WireConnection;0;1;45;49
WireConnection;0;2;401;0
WireConnection;0;3;45;51
WireConnection;0;4;45;52
WireConnection;0;5;45;53
WireConnection;0;9;394;0
WireConnection;0;10;394;0
WireConnection;0;11;397;0
ASEEND*/
//CHKSM=02E68895623F284B2917D3C06DE740D55FD1B76A