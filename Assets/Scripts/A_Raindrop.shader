Shader "Unlit/A_Raindrop"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_size("Size", float) = 5
		_T("Time" , float) = 1
		_Distortion("Distortion",range(-100,100)) = 1
		_Blur("Blur",range(0,1)) = 1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" "Queue"="Transparent"  }  // Transparent: 透明
			LOD 100

			GrabPass { "_GrabTexture" }
			Pass
			{
				Zwrite Off
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				// make fog work
				#pragma multi_compile_fog
				#define S(a,b,t) smoothstep(a,b,t)
				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 grabuv : TEXCOORD1;            // 讓透明層可以正常顯示，而不會縮小透明層中的東西
					UNITY_FOG_COORDS(1)
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex, _GrabTexture;
				float4 _MainTex_ST;
				float _size, _T, _Distortion, _Blur;
				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.grabuv = UNITY_PROJ_COORD(ComputeGrabScreenPos(o.vertex));   // 讓透明層可以正常顯示，而不會縮小透明層中的東西

					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}
				float N21(float2 p) {
					p = frac(p*float2(123.34, 345.45));
					p += dot(p, p + 34.345);
					return frac(p.x*p.y);
				}

				float3 Layer(float2 UV, float t) {
					float2 aspect = float2(4, 1);       // 這是顯示一格的長寬比
					float2 aspect2 = float2(1, 1);
					float2 uv = UV ;//*_size*aspect;    // 這是顯示 texture 有幾格

					float2 gv = frac(uv) - .5;          // frac(): Returns the fractional portion of a scalar or each vector 
	
					float x = 0;
					float y = 0;
					float2 droppos = (gv - float2(x, y)) / aspect2 * .5;         // 雨滴的位置
					float drop = S(0.25, .1, length(droppos));                    // 雨滴的大小

					float fogtrail = S(-.05, .05, droppos.y);
					fogtrail *= S(.5, y, gv.y);                                  // 讓後面的尾跡雨滴會漸漸消失
					fogtrail *= S(.05, .03, abs(droppos.x));                     // 尾跡的形狀
					
					float2 offs = drop * droppos;
					
					return float3(offs, fogtrail);
				}
				fixed4 frag(v2f i) : SV_Target
				{
					float t = fmod(_Time.y + _T, 7200);
					float4 col = 0;                                                              // 這是顯示 shader texture 的參數，0會全黑
					float3 drops = Layer(i.uv, t);
					// drops += Layer(i.uv*1.23 + 7.54, t);
					// drops += Layer(i.uv*1.35 * 3 + 1.54, t);
					// drops += Layer(i.uv*1.57 * 2 - 7.54, t);
					float fade = 1 - saturate(fwidth(i.uv) * 50);
					float blur = _Blur * 7 * (1 - drops.z+fade);                                 // 加霧面感 (乘上 fogtrail，添增尾跡)
					// col = tex2Dlod(_MainTex, float4(i.uv + drops.xy * _Distortion,0, blur));  // distortion 是雨滴折射圖片
					float2 projuv = i.grabuv.xy / i.grabuv.w;
					projuv += drops.xy*_Distortion*fade;                                         // 加雨滴顆粒感
					blur *= .01;                                                                 // 透明度   
					const float numSamples = 8;
					float a = N21(i.uv)*6.2831;                                                  // 值越大，霧面越粗糙
					for (float i = 0; i < numSamples; i++) {
						float2 offs = float2(sin(a), cos(a))*blur;
						float d = frac(sin((i + 1)*546.)*5424.);
						d = sqrt(d);
						offs *= d;
						col += tex2D(_GrabTexture, projuv+offs);
						a++;
					}	
					col /= numSamples;
				
					return col;
				}
				ENDCG
			}
		}
}
