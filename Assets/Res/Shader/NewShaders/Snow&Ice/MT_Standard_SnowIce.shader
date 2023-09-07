// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MT/Builtin/Standard_SnowIce"
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
		_MSA("R:Metallic G:Smoothness B:AO", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_AO("AO", Range( 0 , 1)) = 1
		_EmissionMapAMask("EmissionMap(A:Mask)", 2D) = "white" {}
		_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		[Header(Snow Ice)]_ASnowMaskGIceMaskBIceVertexOffset("A:SnowMask G:IceMask B:IceVertexOffset", 2D) = "white" {}
		_IceIntensity("IceIntensity", Range( 0 , 1)) = 0
		_IceAlpha("IceAlpha", Range( 0 , 1)) = 0
		_IceMap("IceMap", 2D) = "white" {}
		_IceNormal("IceNormal", 2D) = "white" {}
		_IceNormalScale("IceNormalScale", Range( 0 , 10)) = 1
		[HDR]_IceTint("IceTint", Color) = (0.2839088,0.3994353,0.4150943,0)
		_IceLength("IceLength", Range( 0 , 1)) = 0
		_IceMaskTile("IceMaskTile", Range( 0 , 1)) = 0
		_SnowRange("SnowRange", Range( 0 , 1)) = 0
		_SnowThickness("SnowThickness", Range( 0 , 0.1)) = 0
		_SnowThicknessEdge("SnowThicknessEdge", Range( 0 , 1)) = 0
		_SnowMap("SnowMap", 2D) = "white" {}
		_SnowNormal("SnowNormal", 2D) = "bump" {}
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		_RefractionIntensity("RefractionIntensity", Float) = 0
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
		
		GrabPass{ }
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float4 screenPos;
		};

		uniform sampler2D _ASnowMaskGIceMaskBIceVertexOffset;
		uniform float _IceMaskTile;
		uniform float _IceIntensity;
		uniform float _IceLength;
		uniform float _SnowRange;
		uniform float _SnowThickness;
		uniform float _SnowThicknessEdge;
		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _IceNormal;
		uniform float _IceNormalScale;
		uniform sampler2D _SnowNormal;
		uniform float4 _SnowNormal_ST;
		uniform float4 _MainColor;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _IceMap;
		uniform float4 _IceMap_ST;
		uniform float4 _ASnowMaskGIceMaskBIceVertexOffset_ST;
		uniform sampler2D _SnowMap;
		uniform float4 _SnowMap_ST;
		uniform float4 _EmissionColor;
		uniform sampler2D _EmissionMapAMask;
		uniform float4 _EmissionMapAMask_ST;
		uniform float4 _IceTint;
		uniform sampler2D _MSA;
		uniform float4 _MSA_ST;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _AO;
		uniform float _IceAlpha;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _RefractionIntensity;
		uniform float _Cutout;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float2 appendResult85 = (float2(ase_worldNormal.x , ase_worldNormal.z));
			float2 IceOffsetUV135 = (( appendResult85 * _IceMaskTile )*1.0 + 0.5);
			float OffsetMask89 = tex2Dlod( _ASnowMaskGIceMaskBIceVertexOffset, float4( IceOffsetUV135, 0, 0.0) ).g;
			float WorldNormalY137 = ase_worldNormal.y;
			float IceIntensity72 = _IceIntensity;
			float YMask75 = saturate( ( WorldNormalY137 * -0.3 * IceIntensity72 ) );
			float temp_output_114_0 = ( OffsetMask89 * YMask75 * _IceLength );
			float IceVertexOffset216 = temp_output_114_0;
			float YMaskTop112 = saturate( ( WorldNormalY137 * 3.0 ) );
			float SnowVertexOffset215 = ( (0.0 + (_SnowRange - 0.0) * (_SnowThickness - 0.0) / (1.0 - 0.0)) * YMaskTop112 );
			float smoothstepResult164 = smoothstep( ( 1.0 - ( _SnowRange * 2.0 ) ) , 1.0 , ( ( WorldNormalY137 + 1.0 ) * 0.5 ));
			float SnowRange157 = smoothstepResult164;
			float smoothstepResult224 = smoothstep( _SnowThicknessEdge , 1.0 , SnowRange157);
			float lerpResult221 = lerp( IceVertexOffset216 , SnowVertexOffset215 , smoothstepResult224);
			float3 FinalVertexOffset262 = ( ase_vertexNormal * lerpResult221 );
			v.vertex.xyz += FinalVertexOffset262;
		}

		inline float4 Refraction( Input i, SurfaceOutputStandard o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) );
			float2 cameraRefraction = float2( refractionOffset.x, refractionOffset.y );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandard o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			color.rgb = color.rgb + Refraction( i, o, _RefractionIntensity, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 NormalMap43 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float2 temp_cast_1 = (_IceNormalScale).xx;
			float IceIntensity72 = _IceIntensity;
			float4 lerpResult105 = lerp( float4( NormalMap43 , 0.0 ) , tex2D( _IceNormal, temp_cast_1 ) , IceIntensity72);
			float4 BlendIceNormal107 = lerpResult105;
			float2 uv_SnowNormal = i.uv_texcoord * _SnowNormal_ST.xy + _SnowNormal_ST.zw;
			float3 SnowNormal169 = UnpackNormal( tex2D( _SnowNormal, uv_SnowNormal ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float WorldNormalY137 = ase_worldNormal.y;
			float smoothstepResult164 = smoothstep( ( 1.0 - ( _SnowRange * 2.0 ) ) , 1.0 , ( ( WorldNormalY137 + 1.0 ) * 0.5 ));
			float SnowRange157 = smoothstepResult164;
			float4 lerpResult196 = lerp( BlendIceNormal107 , float4( SnowNormal169 , 0.0 ) , SnowRange157);
			float4 FinalNormal251 = lerpResult196;
			o.Normal = FinalNormal251.rgb;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode2 = tex2D( _Albedo, uv_Albedo );
			float3 Albedo38 = ( (_MainColor).rgb * (tex2DNode2).rgb );
			float2 uv_IceMap = i.uv_texcoord * _IceMap_ST.xy + _IceMap_ST.zw;
			float2 uv_ASnowMaskGIceMaskBIceVertexOffset = i.uv_texcoord * _ASnowMaskGIceMaskBIceVertexOffset_ST.xy + _ASnowMaskGIceMaskBIceVertexOffset_ST.zw;
			float4 tex2DNode285 = tex2D( _ASnowMaskGIceMaskBIceVertexOffset, uv_ASnowMaskGIceMaskBIceVertexOffset );
			float IceMask287 = tex2DNode285.g;
			float4 temp_output_288_0 = ( tex2D( _IceMap, uv_IceMap ) * IceMask287 );
			float YMask75 = saturate( ( WorldNormalY137 * -0.3 * IceIntensity72 ) );
			float4 lerpResult64 = lerp( float4( Albedo38 , 0.0 ) , temp_output_288_0 , saturate( ( YMask75 * 8.0 ) ));
			float4 lerpResult187 = lerp( lerpResult64 , temp_output_288_0 , IceIntensity72);
			float4 IceAlbedo66 = lerpResult187;
			float2 uv_SnowMap = i.uv_texcoord * _SnowMap_ST.xy + _SnowMap_ST.zw;
			float SnowMask286 = tex2DNode285.r;
			float4 SnowAlbedo143 = ( tex2D( _SnowMap, uv_SnowMap ) * SnowMask286 );
			float4 lerpResult199 = lerp( IceAlbedo66 , SnowAlbedo143 , SnowRange157);
			float4 FinalAlbedo250 = lerpResult199;
			o.Albedo = FinalAlbedo250.rgb;
			float2 uv_EmissionMapAMask = i.uv_texcoord * _EmissionMapAMask_ST.xy + _EmissionMapAMask_ST.zw;
			float4 tex2DNode18 = tex2D( _EmissionMapAMask, uv_EmissionMapAMask );
			float4 Emission46 = ( _EmissionColor * tex2DNode18 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV123 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode123 = ( 0.0 + 3.0 * pow( 1.0 - fresnelNdotV123, 2.5 ) );
			float IceRange167 = ( 1.0 - SnowRange157 );
			float4 IceEmission126 = ( tex2D( _IceMap, uv_IceMap ) * fresnelNode123 * IceIntensity72 * _IceTint * IceRange167 );
			float4 lerpResult129 = lerp( Emission46 , IceEmission126 , IceIntensity72);
			float4 FinalEmission252 = lerpResult129;
			o.Emission = FinalEmission252.rgb;
			float2 uv_MSA = i.uv_texcoord * _MSA_ST.xy + _MSA_ST.zw;
			float4 tex2DNode21 = tex2D( _MSA, uv_MSA );
			float Metallic51 = ( tex2DNode21.r * _Metallic );
			float FinalMetallic257 = ( Metallic51 * ( 1.0 - IceIntensity72 ) * IceRange167 );
			o.Metallic = FinalMetallic257;
			float Smoothness53 = ( tex2DNode21.g * _Smoothness );
			float lerpResult101 = lerp( Smoothness53 , 0.0 , SnowRange157);
			float lerpResult238 = lerp( lerpResult101 , 1.0 , ( IceRange167 * IceIntensity72 ));
			float FinalSmoothness259 = lerpResult238;
			o.Smoothness = FinalSmoothness259;
			float AO55 = ( tex2DNode21.b * _AO );
			float lerpResult236 = lerp( AO55 , 1.0 , SnowRange157);
			float lerpResult245 = lerp( lerpResult236 , 1.0 , ( IceRange167 * IceIntensity72 ));
			float FinalAO260 = lerpResult245;
			o.Occlusion = FinalAO260;
			float Alpha40 = ( _MainColor.a * tex2DNode2.a );
			float FinalAlpha276 = saturate( max( Alpha40 , ( SnowRange157 + ( IceRange167 * IceIntensity72 * _IceAlpha ) ) ) );
			o.Alpha = FinalAlpha276;
			clip( Alpha40 - _Cutout );
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

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
				float4 screenPos : TEXCOORD2;
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
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
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
3021;399;1710;890;-1940.514;1351.955;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;133;-778.0345,-171.6135;Inherit;False;3165.108;1358.757;Ice;9;127;132;67;91;163;92;76;94;141;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;141;-759.2294,493.3794;Inherit;False;920.3812;321.7705;冰挂遮罩图UV;7;135;88;86;87;137;85;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;69;-741.584,541.5477;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;246;-766.3135,1322.614;Inherit;False;2028.817;1009.68;Snow;3;144;232;158;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-662.4857,-95.84309;Inherit;False;616.3414;174.8951;冰强度;2;72;65;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;158;-741.9044,1370.908;Inherit;False;1170.882;446.9315;雪范围;10;178;154;152;157;164;180;200;153;279;280;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-251.7003,708.5837;Inherit;False;WorldNormalY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-612.4857,-45.84337;Inherit;False;Property;_IceIntensity;IceIntensity;19;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;-680.95,1409.908;Inherit;False;137;WorldNormalY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;85;-540.917,538.1607;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-289.1442,-35.9481;Inherit;False;IceIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;-760.7376,104.6928;Inherit;False;826.2024;338.7207;世界空间法线Y轴向的遮罩;9;75;74;70;112;111;110;140;73;138;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-747.9503,704.6158;Inherit;False;Property;_IceMaskTile;IceMaskTile;26;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-713.6412,1707.614;Inherit;False;Property;_SnowRange;SnowRange;27;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;154;-410.9042,1414.793;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;62;-775.9733,-1411.429;Inherit;False;2925.239;1158.311;BPR;5;61;50;57;45;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;-733.6686,148.8868;Inherit;False;137;WorldNormalY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;-408.9714,1706.899;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-730.5357,253.414;Inherit;False;72;IceIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-388.1044,538.2172;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;180;-257.6155,1701.193;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;-264.1162,1415.437;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-509.7384,168.693;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;-0.3;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;88;-243.7946,579.5913;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;42;-722.9847,-1358.761;Inherit;False;1275.368;485.4322;主纹理贴图;8;29;2;3;32;31;40;4;38;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-748.426,875.2567;Inherit;False;914.4425;254.5102;冰挂遮罩图;3;89;293;136;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;2;-672.9847,-1113.561;Inherit;True;Property;_Albedo;Albedo;8;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;140;-732.6686,346.8872;Inherit;False;137;WorldNormalY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;164;-91.53977,1519.727;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-620.0847,-1306.661;Inherit;False;Property;_MainColor;MainColor;7;0;Create;True;0;0;False;1;Header(PBR);False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;74;-355.5362,173.4137;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;-46.2383,548.868;Inherit;False;IceOffsetUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;163;1113.572,933.6932;Inherit;False;709;185;冰范围;3;161;162;167;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;-741.0786,922.0687;Inherit;False;135;IceOffsetUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;157;212.7879,1443.872;Inherit;False;SnowRange;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;32;-323.7083,-1162.329;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;45;1190.994,-685.0231;Inherit;False;919.968;381.2365;法线;3;14;12;43;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;83.82024,-95.40289;Inherit;False;1088.348;439.6342;冰纹理贴图，并根据冰强度，混合主纹理贴图;11;66;187;64;186;59;63;96;95;93;289;288;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-486.8441,335.7885;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-188.536,181.4135;Inherit;False;YMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;285;1358.957,1349.47;Inherit;True;Property;_ASnowMaskGIceMaskBIceVertexOffset;A:SnowMask G:IceMask B:IceVertexOffset;18;0;Create;True;0;0;False;1;Header(Snow Ice);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;31;-322.7083,-1290.329;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;287;1736.074,1452.791;Inherit;False;IceMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;232;-744.2686,1838.233;Inherit;False;1056.979;328.0002;雪范围内的顶点偏移;5;214;209;211;213;215;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;14;1242.994,-572.5212;Inherit;False;Property;_NormalScale;NormalScale;10;0;Create;True;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;293;-547.3823,913.4108;Inherit;True;Property;_TextureSample1;Texture Sample 1;18;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;285;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;111;-332.8444,343.7886;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;1163.572,983.6932;Inherit;False;157;SnowRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;95.85249,242.4587;Inherit;False;75;YMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-17.18509,-1308.761;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;63;100.5158,-44.36942;Inherit;True;Property;_IceMap;IceMap;21;0;Create;True;0;0;False;0;False;-1;None;416fffdbe482dee48836e7d51518a082;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-147.8443,333.7885;Inherit;False;YMaskTop;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;91;1185.307,-109.9594;Inherit;False;1190.719;471.7025;依据冰强度计算冰范围内的顶点偏移;11;119;120;115;113;118;114;79;131;90;208;216;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-694.2684,1950.523;Inherit;False;Property;_SnowThickness;SnowThickness;28;0;Create;True;0;0;False;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;289;175.1423,150.2253;Inherit;False;287;IceMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;267.5948,253.4084;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;132;1108.266,410.0988;Inherit;False;1208.228;488.6582;冰法线混合主法线;6;104;44;109;103;105;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-44.89598,921.2365;Inherit;False;OffsetMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;57;-722.4414,-841.0036;Inherit;False;827.0729;558.1874;金属度、粗糙度、AO;10;21;23;51;24;26;53;55;22;25;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;162;1385.572,986.6932;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;309.3837,-1274.995;Inherit;False;Albedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;12;1565.994,-599.0222;Inherit;True;Property;_NormalMap;NormalMap;9;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;209;-612.9315,2051.233;Inherit;False;112;YMaskTop;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;50;168.3461,-794.2585;Inherit;False;979.6564;502.0392;自发光;5;48;46;20;18;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;96;413.5945,244.4084;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;286;1747.074,1363.791;Inherit;False;SnowMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;1207.313,23.69865;Inherit;False;75;YMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;406.4582,-48.40288;Inherit;False;38;Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;131;1200.552,114.5429;Inherit;False;Property;_IceLength;IceLength;25;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;1206.306,-53.53195;Inherit;False;89;OffsetMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;211;-383.932,1888.233;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-661.6058,-487.0518;Inherit;False;Property;_Smoothness;Smoothness;13;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;1872.37,-568.7381;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;1570.509,986.0862;Inherit;False;IceRange;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;-672.4414,-790.7643;Inherit;True;Property;_MSA;R:Metallic G:Smoothness B:AO;11;0;Create;False;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;144;447.5208,1374.549;Inherit;False;800.3744;543.8466;雪贴图与法线;6;169;290;143;291;168;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;104;1158.266,636.6042;Inherit;False;Property;_IceNormalScale;IceNormalScale;23;0;Create;True;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-655.6686,-397.8165;Inherit;False;Property;_AO;AO;14;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;278;3913.346,-155.1874;Inherit;False;1102.896;508.8989;最终透明度;10;276;281;272;275;268;270;274;273;283;284;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;127;178.1702,367.9864;Inherit;False;905.022;766.5598;冰范围内的菲涅尔效果;7;122;121;123;124;125;126;190;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;288;413.1423,63.22531;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;317.8797,775.7443;Inherit;False;72;IceIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;281;3922.712,247.8374;Inherit;False;Property;_IceAlpha;IceAlpha;20;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;134;494.5468,1421.549;Inherit;True;Property;_SnowMap;SnowMap;30;0;Create;True;0;0;False;0;False;-1;None;38d596dce2a4c0746b5d6afe5204aeb0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;213;-167.9325,2015.234;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;180.3461,-551.2287;Inherit;True;Property;_EmissionMapAMask;EmissionMap(A:Mask);15;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;64;628.3654,-16.17933;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;291;583.9231,1629.994;Inherit;False;286;SnowMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;1482.016,-52.79566;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;1545.103,489.0989;Inherit;False;43;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;3946.445,-2.189746;Inherit;False;167;IceRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-298.58,-600.3057;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;263;2712.103,-210.2232;Inherit;False;1137.662;622.4366;最终顶点偏移;9;262;217;218;225;220;221;219;222;224;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;583.5999,245.5767;Inherit;False;72;IceIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;103;1457.852,578.2462;Inherit;True;Property;_IceNormal;IceNormal;22;0;Create;True;0;0;False;0;False;-1;None;e2d698c0275f7ce40979df35e9583d93;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;121;228.1702,417.9865;Inherit;True;Property;_TextureSample0;Texture Sample 0;21;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;63;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-297.8,-460.9491;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;190.6645,-751.2585;Inherit;False;Property;_EmissionColor;EmissionColor;16;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;190;314.5789,1036.854;Inherit;False;167;IceRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;1541.494,783.7581;Inherit;False;72;IceIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-291.7081,-1006.328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;3976.745,121.0115;Inherit;False;72;IceIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-660.6128,-583.5665;Inherit;False;Property;_Metallic;Metallic;12;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;125;313.6493,853.5958;Inherit;False;Property;_IceTint;IceTint;24;1;[HDR];Create;True;0;0;False;0;False;0.2839088,0.3994353,0.4150943,0;0.2839088,0.3994353,0.4150943,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;123;291.1885,603.8593;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;3;False;3;FLOAT;2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;290;859.0172,1471.608;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;275;4198.949,77.71133;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;261;3908.953,-583.1834;Inherit;False;891.2258;395.2161;主AO与1在学范围内插值，再与1在冰范围与冰强度乘积的值插值;8;260;245;244;243;242;236;237;56;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;168;485.3657,1717.172;Inherit;True;Property;_SnowNormal;SnowNormal;31;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;253;3908.771,-1310.249;Inherit;False;897.1064;330.474;主金属度、（1 - 冰强度）、（1-雪范围）乘积;6;257;191;52;192;226;102;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-143.9687,-460.4292;Inherit;False;AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-138.3697,-595.6741;Inherit;False;Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-329.4045,-774.2609;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-113.6162,-1017.993;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;627.0653,-714.2586;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;2828.103,206.2137;Inherit;False;157;SnowRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;270;4139.649,-21.48821;Inherit;False;157;SnowRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;105;1860.251,567.7773;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;645.1923,644.5468;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;42.71043,2035.969;Inherit;False;SnowVertexOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;258;3909.038,-960.249;Inherit;False;889.1836;349.4469;主粗糙度与0在雪范围内插值，再与1在冰范围与冰强度乘积的值插值;8;259;238;240;241;239;229;54;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;2149.766,-66.78567;Inherit;False;IceVertexOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;225;2762.103,297.2136;Inherit;False;Property;_SnowThicknessEdge;SnowThicknessEdge;29;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;187;805.3679,123.6177;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;268;4159.55,-103.8874;Inherit;False;40;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;2919.402,102.2292;Inherit;False;215;SnowVertexOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;1041.847,1450.6;Inherit;False;SnowAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;219;2932.402,11.22906;Inherit;False;216;IceVertexOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;224;3064.46,250.0109;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;239;3958.31,-775.2557;Inherit;False;167;IceRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;283;4350.714,19.8374;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;2060.492,678.7578;Inherit;False;BlendIceNormal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;249;3105.623,-963.5497;Inherit;False;718.8975;331.5197;冰菲涅尔效果与原自发光效果，在冰范围内进行插值计算;5;129;47;130;128;252;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;968.3652,-21.17902;Inherit;False;IceAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;229;3956.592,-851.8179;Inherit;False;157;SnowRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;247;3098.24,-1311.178;Inherit;False;713.7957;326.6227;冰贴图混合主纹理贴图后，再与雪贴图进行雪范围内的插值计算，最终Albedo;5;250;199;145;184;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;248;3108.57,-586.5287;Inherit;False;717.1953;314.1285;冰法线混合主法线后，再与雪法线进行雪范围内的插值计算，最终法线;5;251;196;198;194;108;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-151.7986,-762.4337;Inherit;False;Metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;242;3965.46,-349.1226;Inherit;False;167;IceRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;3967.761,-517.7917;Inherit;False;55;AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;840.1919,691.5468;Inherit;False;IceEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;949.8092,1747.051;Inherit;False;SnowNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;901.9848,-652.3546;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;3957.875,-925.349;Inherit;False;53;Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;241;3961.603,-691.9326;Inherit;False;72;IceIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;3965.265,-266.9607;Inherit;False;72;IceIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;237;3958.953,-426.1837;Inherit;False;157;SnowRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;3919.77,-1176.005;Inherit;False;72;IceIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;3149.789,-1073.613;Inherit;False;157;SnowRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;3142.521,-744.0298;Inherit;False;72;IceIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;284;4496.714,-65.1626;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;3151.048,-368.7362;Inherit;False;157;SnowRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;101;4191.593,-889.0055;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;217;2947.698,-160.2233;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;4197.582,-749.2249;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;226;4150.716,-1088.775;Inherit;False;167;IceRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;244;4167.195,-330.0843;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;4148.217,-1265.249;Inherit;False;51;Metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;3147.922,-915.5498;Inherit;False;46;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;192;4151.878,-1169.067;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;3150.429,-453.5931;Inherit;False;169;SnowNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;3158.57,-536.5288;Inherit;False;107;BlendIceNormal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;236;4178.952,-533.1833;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;3143.623,-831.0299;Inherit;False;126;IceEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;3148.24,-1162.71;Inherit;False;143;SnowAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;3156.755,-1261.178;Inherit;False;66;IceAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;221;3234.402,84.22919;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;3408.109,-147.319;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;272;4643.147,-65.38893;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;191;4343.878,-1260.067;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;129;3393.521,-853.0301;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;199;3409.083,-1191.621;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;245;4390.438,-453.815;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;238;4368.451,-833.6405;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;196;3391.683,-471.0234;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;4549.521,-820.2045;Inherit;False;FinalSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;257;4519.842,-1228.489;Inherit;False;FinalMetallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;250;3591.729,-1183.588;Inherit;False;FinalAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;3582.766,-105.9965;Inherit;False;FinalVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;260;4573.442,-443.547;Inherit;False;FinalAO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;61;613.1716,-1357.969;Inherit;False;1466.301;513.9344;自发光透明通道混合主纹理贴图;8;35;33;49;39;36;34;37;58;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;60;2664.826,-1155.737;Inherit;False;352;784.0653;Rendering;7;1;5;9;10;6;8;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;276;4803.344,-73.13274;Inherit;False;FinalAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;251;3586.242,-457.4969;Inherit;False;FinalNormal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;3592.49,-841.8791;Inherit;False;FinalEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;8;2799.648,-608.6055;Inherit;False;Property;_DepthOffset;DepthOffset;5;0;Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;2714.826,-486.6733;Inherit;False;Property;_Cutout;Cutout;6;0;Fetch;True;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;635.391,-411.0954;Inherit;False;EmissionAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;970.4797,-1307.969;Inherit;False;38;Albedo;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;1004.656,-1068.422;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;266;3196.049,1330.604;Inherit;False;260;FinalAO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;267;3188.049,1675.604;Inherit;False;262;FinalVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;3200.049,1174.604;Inherit;False;257;FinalMetallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;279;-626.4406,1505.766;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;1854.016,102.2056;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;2800.948,-711.3056;Inherit;False;Property;_DepthWrite;DepthWrite;4;1;[Toggle];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;1455.38,-1224.662;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;120;1603.016,55.20484;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;663.1719,-1151.452;Inherit;False;48;EmissionAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;265;3171.049,1259.604;Inherit;False;259;FinalSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;294;3421.982,1316.725;Inherit;False;Property;_RefractionIntensity;RefractionIntensity;34;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;1995.016,32.20426;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;1427.016,263.2051;Inherit;False;112;YMaskTop;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;2810.049,-1005.103;Inherit;False;Property;_Src;Src;1;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;701.376,-1033.593;Inherit;False;Property;_MaskColor;MaskColor;17;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;280;-366.441,1543.766;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;254;3192.995,910.5297;Inherit;False;250;FinalAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;35;991.0797,-1174.562;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;1294.015,189.2047;Inherit;False;72;IceIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;277;3192.571,1425.762;Inherit;False;276;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;1630.865,272.0143;Inherit;False;167;IceRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;256;3193.995,1094.115;Inherit;False;252;FinalEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1;2806.689,-1105.737;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CullMode;True;1;Header(Rendering);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;3199.147,1561.057;Inherit;False;40;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;3195.995,1012.114;Inherit;False;251;FinalNormal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;1657.514,-1216.59;Inherit;False;EmissionAlphaBlendAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;2804.848,-810.1045;Inherit;False;Property;_DepthTest;DepthTest;3;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;1205.48,-1271.561;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;6;2745.049,-907.6035;Inherit;False;Property;_Dst;Dst;2;1;[Enum];Fetch;True;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3695.658,1119.701;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MT/Builtin/Standard_SnowIce;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;9;0;True;10;True;0;True;8;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;16;2;10;False;0.5;True;2;5;True;5;10;True;6;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;32;-1;0;False;0;0;True;1;-1;0;True;28;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;137;0;69;2
WireConnection;85;0;69;1
WireConnection;85;1;69;3
WireConnection;72;0;65;0
WireConnection;154;0;152;0
WireConnection;200;0;153;0
WireConnection;86;0;85;0
WireConnection;86;1;87;0
WireConnection;180;0;200;0
WireConnection;178;0;154;0
WireConnection;70;0;138;0
WireConnection;70;2;73;0
WireConnection;88;0;86;0
WireConnection;164;0;178;0
WireConnection;164;1;180;0
WireConnection;74;0;70;0
WireConnection;135;0;88;0
WireConnection;157;0;164;0
WireConnection;32;0;2;0
WireConnection;110;0;140;0
WireConnection;75;0;74;0
WireConnection;31;0;3;0
WireConnection;287;0;285;2
WireConnection;293;1;136;0
WireConnection;111;0;110;0
WireConnection;4;0;31;0
WireConnection;4;1;32;0
WireConnection;112;0;111;0
WireConnection;95;0;93;0
WireConnection;89;0;293;2
WireConnection;162;0;161;0
WireConnection;38;0;4;0
WireConnection;12;5;14;0
WireConnection;96;0;95;0
WireConnection;286;0;285;1
WireConnection;211;0;153;0
WireConnection;211;4;214;0
WireConnection;43;0;12;0
WireConnection;167;0;162;0
WireConnection;288;0;63;0
WireConnection;288;1;289;0
WireConnection;213;0;211;0
WireConnection;213;1;209;0
WireConnection;64;0;59;0
WireConnection;64;1;288;0
WireConnection;64;2;96;0
WireConnection;114;0;90;0
WireConnection;114;1;79;0
WireConnection;114;2;131;0
WireConnection;24;0;21;2
WireConnection;24;1;25;0
WireConnection;103;1;104;0
WireConnection;26;0;21;3
WireConnection;26;1;27;0
WireConnection;29;0;3;4
WireConnection;29;1;2;4
WireConnection;290;0;134;0
WireConnection;290;1;291;0
WireConnection;275;0;273;0
WireConnection;275;1;274;0
WireConnection;275;2;281;0
WireConnection;55;0;26;0
WireConnection;53;0;24;0
WireConnection;23;0;21;1
WireConnection;23;1;22;0
WireConnection;40;0;29;0
WireConnection;20;0;19;0
WireConnection;20;1;18;0
WireConnection;105;0;44;0
WireConnection;105;1;103;0
WireConnection;105;2;109;0
WireConnection;122;0;121;0
WireConnection;122;1;123;0
WireConnection;122;2;124;0
WireConnection;122;3;125;0
WireConnection;122;4;190;0
WireConnection;215;0;213;0
WireConnection;216;0;114;0
WireConnection;187;0;64;0
WireConnection;187;1;288;0
WireConnection;187;2;186;0
WireConnection;143;0;290;0
WireConnection;224;0;222;0
WireConnection;224;1;225;0
WireConnection;283;0;270;0
WireConnection;283;1;275;0
WireConnection;107;0;105;0
WireConnection;66;0;187;0
WireConnection;51;0;23;0
WireConnection;126;0;122;0
WireConnection;169;0;168;0
WireConnection;46;0;20;0
WireConnection;284;0;268;0
WireConnection;284;1;283;0
WireConnection;101;0;54;0
WireConnection;101;2;229;0
WireConnection;240;0;239;0
WireConnection;240;1;241;0
WireConnection;244;0;242;0
WireConnection;244;1;243;0
WireConnection;192;0;102;0
WireConnection;236;0;56;0
WireConnection;236;2;237;0
WireConnection;221;0;219;0
WireConnection;221;1;220;0
WireConnection;221;2;224;0
WireConnection;218;0;217;0
WireConnection;218;1;221;0
WireConnection;272;0;284;0
WireConnection;191;0;52;0
WireConnection;191;1;192;0
WireConnection;191;2;226;0
WireConnection;129;0;47;0
WireConnection;129;1;128;0
WireConnection;129;2;130;0
WireConnection;199;0;68;0
WireConnection;199;1;145;0
WireConnection;199;2;184;0
WireConnection;245;0;236;0
WireConnection;245;2;244;0
WireConnection;238;0;101;0
WireConnection;238;2;240;0
WireConnection;196;0;108;0
WireConnection;196;1;194;0
WireConnection;196;2;198;0
WireConnection;259;0;238;0
WireConnection;257;0;191;0
WireConnection;250;0;199;0
WireConnection;262;0;218;0
WireConnection;260;0;245;0
WireConnection;276;0;272;0
WireConnection;251;0;196;0
WireConnection;252;0;129;0
WireConnection;48;0;18;4
WireConnection;34;0;49;0
WireConnection;34;1;33;0
WireConnection;119;0;120;0
WireConnection;119;1;113;0
WireConnection;119;2;208;0
WireConnection;37;0;36;0
WireConnection;37;1;34;0
WireConnection;120;0;118;0
WireConnection;115;0;114;0
WireConnection;115;1;119;0
WireConnection;280;0;279;2
WireConnection;35;0;49;0
WireConnection;58;0;37;0
WireConnection;36;0;39;0
WireConnection;36;1;35;0
WireConnection;0;0;254;0
WireConnection;0;1;255;0
WireConnection;0;2;256;0
WireConnection;0;3;264;0
WireConnection;0;4;265;0
WireConnection;0;5;266;0
WireConnection;0;8;294;0
WireConnection;0;9;277;0
WireConnection;0;10;41;0
WireConnection;0;11;267;0
ASEEND*/
//CHKSM=F31B74EC50F0DEC99BE4D3B67A2E19D001BCA874