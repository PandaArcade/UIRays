// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PicoTanks/UI/Rays"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		[NoScaleOffset]_Texture("Texture", 2D) = "white" {}
		_RadialTiling("Radial Tiling", Range( 0 , 10)) = 1
		_RotationSpeed("Rotation Speed", Range( -1 , 1)) = 0
		_HorizontalScale("Horizontal Scale", Range( 0 , 2)) = 1
		_VerticalScale("Vertical Scale", Range( 0 , 2)) = 1
		_HorizontalOffset("Horizontal Offset", Range( -1 , 1)) = 0
		_VerticalOffset("Vertical Offset", Range( -1 , 1)) = 0
		_Intensity("Intensity", Range( 0 , 5)) = 1
		_Falloff("Falloff", Range( 0 , 5)) = 3
		_InsideColor("Inside Color", Color) = (0,0,0,0)
		_OutsideColor("Outside Color", Color) = (0,0,0,0)
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			CompFront [_StencilComp]
			PassFront [_StencilOp]
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}


		Cull Off
		Lighting Off
		ZWrite Off
		ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		
		Pass
		{
			Name "Default"
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			#include "UnityShaderVariables.cginc"

			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			uniform float4 _InsideColor;
			uniform float4 _OutsideColor;
			uniform float _HorizontalOffset;
			uniform float _HorizontalScale;
			uniform float _VerticalOffset;
			uniform float _VerticalScale;
			uniform float _Intensity;
			uniform float _Falloff;
			uniform sampler2D _Texture;
			uniform float _RadialTiling;
			uniform float _RotationSpeed;
			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.worldPosition = IN.vertex;
				
				
				OUT.worldPosition.xyz +=  float3( 0, 0, 0 ) ;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN  ) : SV_Target
			{
				float2 uv04 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult17 = (float2(( ( ( uv04.x - _HorizontalOffset ) + ( ( _HorizontalScale - 1.0 ) * 0.5 ) ) / _HorizontalScale ) , ( ( ( uv04.y - _VerticalOffset ) + ( ( _VerticalScale - 1.0 ) * 0.5 ) ) / _VerticalScale )));
				float temp_output_9_0 = ( distance( float2( 0.5,0.5 ) , appendResult17 ) / 0.5 );
				float4 lerpResult115 = lerp( _InsideColor , _OutsideColor , temp_output_9_0);
				float2 break93 = -(float2( -1,-1 ) + (appendResult17 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
				float mulTime109 = _Time.y * _RotationSpeed;
				float2 appendResult68 = (float2(( ( _RadialTiling * ( ( degrees( atan2( break93.y , break93.x ) ) + 180.0 ) / 360.0 ) ) + mulTime109 ) , 1.0));
				float4 appendResult5 = (float4((( lerpResult115 * IN.color )).rgb , ( IN.color.a * ( _Intensity * pow( saturate( ( 1.0 - temp_output_9_0 ) ) , _Falloff ) ) * tex2D( _Texture, appendResult68 ) ).r));
				
				half4 color = appendResult5;
				
				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16700
2561;1;2558;1387;609.8469;917.123;1;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-2372.719,-313.3295;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-1429.971,-237.6156;Float;False;Property;_HorizontalScale;Horizontal Scale;3;0;Create;True;0;0;False;0;1;0.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1424,-38;Float;False;Property;_VerticalScale;Vertical Scale;4;0;Create;True;0;0;False;0;1;0.87;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1994.882,-225.1732;Float;False;Property;_HorizontalOffset;Horizontal Offset;5;0;Create;True;0;0;False;0;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1993.108,-44.55717;Float;False;Property;_VerticalOffset;Vertical Offset;6;0;Create;True;0;0;False;0;0;0.04;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-1100.25,-173.1409;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;122;-2027.052,-147.5917;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-1115.279,26.4747;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-954.2793,26.4747;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;-1683.26,-100.8394;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-925.1271,-173.2384;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1683.83,-292.8551;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-758.2509,-295.1412;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-757.2793,-98.52533;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-604.203,-55.23883;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;24;-607.2509,-255.1409;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;17;-392.4507,-255.2239;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;65;-142.8522,-23.20052;Float;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;-1,-1;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;92;55.47385,-23.78635;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;93;212.1826,-24.59184;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ATan2OpNode;94;533.2476,-24.77995;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;7;-435,-391;Float;False;Constant;_Center;Center;2;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DegreesOpNode;95;685.5218,-24.84489;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;62;-159.9168,-277.8095;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;864.2454,-25.28331;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;808.2523,-214.9369;Float;False;Constant;_Distance;Distance;1;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;91;1021.217,-24.8978;Float;False;2;0;FLOAT;0;False;1;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;876.2673,87.10135;Float;False;Property;_RotationSpeed;Rotation Speed;2;0;Create;True;0;0;False;0;0;0.2;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;875.7849,-106.8152;Float;False;Property;_RadialTiling;Radial Tiling;1;0;Create;True;0;0;False;0;1;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;9;1008.403,-274.9108;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;118;1771.55,-428.3914;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;109;1171.028,92.07698;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;1200.769,-47.63281;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;102;1527.718,-275.2802;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;1624.881,-193.234;Float;False;Property;_Falloff;Falloff;8;0;Create;True;0;0;False;0;3;3.7;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;1370.456,-47.94187;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;113;1844.553,-801.0927;Float;False;Property;_InsideColor;Inside Color;9;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;111;1747.328,-275.5841;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;117;2060.153,-443.9929;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;114;1844.752,-624.2927;Float;False;Property;_OutsideColor;Outside Color;10;0;Create;True;0;0;False;0;0,0,0,0;0.9921569,0.8713218,0.1597373,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;119;1814.851,-374.6919;Float;False;Property;_Intensity;Intensity;7;0;Create;True;0;0;False;0;1;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;68;1530.932,-47.16639;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;115;2165.855,-642.4927;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;106;1935.836,-275.7686;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;99;2149.804,-477.0692;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;2398.552,-499.4928;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;2191.85,-297.9921;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;54;1741.829,-75.04516;Float;True;Property;_Texture;Texture;0;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;11;2618.804,-505.2314;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;2418.537,-320.4922;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;2909.557,-500.9863;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;125;3131.988,-501.1112;Float;False;True;2;Float;ASEMaterialInspector;0;4;PicoTanks/UI/Rays;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;True;True;True;True;True;0;True;-9;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;False;-1;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;29;0;15;0
WireConnection;122;0;4;2
WireConnection;41;0;13;0
WireConnection;42;0;41;0
WireConnection;23;0;122;0
WireConnection;23;1;20;0
WireConnection;40;0;29;0
WireConnection;22;0;4;1
WireConnection;22;1;19;0
WireConnection;39;0;22;0
WireConnection;39;1;40;0
WireConnection;43;0;23;0
WireConnection;43;1;42;0
WireConnection;25;0;43;0
WireConnection;25;1;13;0
WireConnection;24;0;39;0
WireConnection;24;1;15;0
WireConnection;17;0;24;0
WireConnection;17;1;25;0
WireConnection;65;0;17;0
WireConnection;92;0;65;0
WireConnection;93;0;92;0
WireConnection;94;0;93;1
WireConnection;94;1;93;0
WireConnection;95;0;94;0
WireConnection;62;0;7;0
WireConnection;62;1;17;0
WireConnection;98;0;95;0
WireConnection;91;0;98;0
WireConnection;9;0;62;0
WireConnection;9;1;2;0
WireConnection;118;0;9;0
WireConnection;109;0;107;0
WireConnection;88;0;89;0
WireConnection;88;1;91;0
WireConnection;102;0;9;0
WireConnection;108;0;88;0
WireConnection;108;1;109;0
WireConnection;111;0;102;0
WireConnection;117;0;118;0
WireConnection;68;0;108;0
WireConnection;115;0;113;0
WireConnection;115;1;114;0
WireConnection;115;2;117;0
WireConnection;106;0;111;0
WireConnection;106;1;105;0
WireConnection;116;0;115;0
WireConnection;116;1;99;0
WireConnection;120;0;119;0
WireConnection;120;1;106;0
WireConnection;54;1;68;0
WireConnection;11;0;116;0
WireConnection;103;0;99;4
WireConnection;103;1;120;0
WireConnection;103;2;54;0
WireConnection;5;0;11;0
WireConnection;5;3;103;0
WireConnection;125;0;5;0
ASEEND*/
//CHKSM=CA742B4CB1D9886312C7ADCE82031EB4931759EA