Shader "Unlit/rain"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_size("Size", float) = 5
		_T("Time" , float) = 1
		_Distortion("Distortion",range(-5,5)) = 3
		_Blur("Blur", range(0,1)) = 0.88
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
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
					UNITY_FOG_COORDS(1)
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _size, _T, _Distortion, _Blur;
				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}
				float N21(float2 p) {
					p = frac(p * float2(123.34, 345.45));
					p += dot(p, p + 34.345);
					return frac(p.x * p.y);
				}

				float3 Layer(float2 newUV, float t){
					float2 aspect = float2(1.2, 1);//4, 1);
					float2 aspect2 = float2(1, 1);//2, 1);
					float2 uv = newUV * _size * aspect;
					uv.y += t * .25;
					float2 gv = frac(uv) - .5;
					float2 id = floor(uv);

					float n = N21(id);
					t += n * 6.2831;

					float w = newUV.y * 10;
					float x = (n - .5) * .8;//sin(3 * w)*pow(sin(w), 6)*.45;
					x += (.4 - abs(x)) * sin(3 * w) * pow(sin(w), 6) * .45;

					float y = -sin(t + sin(t + sin(t) * .5)) * .45;
					y -= (gv.x - x) * (gv.x - x);
					float2 droppos = (gv - float2(x,y)) / aspect2 * .7;
					float drop = S(.05, .03, length(droppos));
					float2 trailpos = (gv - float2(x, t * .25)) / aspect2 * .8;
					trailpos.y = (frac(trailpos.y * 8) - .5) / 8;
					float trail = S(.03, .01, length(trailpos));
					float fogtrail = S(-.05, .05, droppos.y);
					fogtrail *= S(.5, y, gv.y);
					trail *= fogtrail;
					fogtrail *= S(.05, .04, abs(droppos.x));

					// col += fogtrail * .5;
					// col += trail;
					// col += drop;
					// //col.rg = gv;

					float2 offs = drop * droppos + trail * trailpos;
					// //float2 offs = drop2 * droppos2 + trail2 * trailpos2;
					// if (gv.x > .48 || gv.y > .49) col = float4(1, 0, 0, 1);
					// //col *= 0;
					// //col += N21(id);
					// //col.rg = id * .1;
					
					return float3(offs, fogtrail);
				}
				
				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture
					//fixed4 col = tex2D(_MainTex, i.uv);
					// apply fog
					//UNITY_APPLY_FOG(i.fogCoord, col);
					float t = fmod(_Time.y + _T,7200);
					float4 col = 0;

					float3 drops = Layer(i.uv, t);
					drops += Layer(i.uv * 1.23 + 7.54, t);
					drops += Layer(i.uv * 1.23 * 2 + 7.54, t);

					float blur = _Blur * 7 * (1 - drops.z);
					// col = tex2D(_MainTex, i.uv + offs * _Distortion);
					col = tex2Dlod(_MainTex, float4(i.uv + drops.xy * _Distortion, 0, blur));
					return col;
				}
				ENDCG
			}
		}
}