Shader "Unlit/Raindrop_Multi_Layer"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_size("Size", float) = 5
		_T("Time" , float) = 1
		_Distortion("Distortion",range(-5,5)) = 1
		_Blur("Blur",range(0,1)) = 1
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
					p = frac(p*float2(123.34, 345.45));
					p += dot(p, p + 34.345);
					return frac(p.x*p.y);
				}

				float3 Layer(float2 UV, float t) {
					float2 aspect = float2(4, 1);       // 這是顯示一格的長寬比
					float2 aspect2 = float2(2, 1);
					float2 uv = UV *_size*aspect;       // 這是顯示 texture 有幾格
					uv.y += t * .25;                    // 每一格沿著 y 隨時間移動
					float2 gv = frac(uv) - .5;          // frac(): Returns the fractional portion of a scalar or each vector 
					float2 id = floor(uv);              // floor(): 对输入参数向下取整。例如 floor(float(1.3)) 返回的值为 1.0；但是 floor(float(-1.3))返回的值为-2.0。

					float n = N21(id);                  // n 就像是 random 的數
					t += n * 6.2831;                    // 每格的 t 不同

					float w = UV.y * 10;
					float x = (n - .5)*.8;//sin(3 * w)*pow(sin(w), 6)*.45;       // 雨滴 x 軸移動位置
					x += (.4 - abs(x))*sin(3 * w)*pow(sin(w), 6)*.45;

					float y = -sin(t + sin(t + sin(t)*.5))*.45;                  // 隨時間移動
					y -= (gv.x - x)*(gv.x - x);                                  // 雨滴會呈現雨滴形狀(減 x 是因為改變 x 值，會影響雨滴形狀)

					float2 droppos = (gv - float2(x, y)) / aspect2 * .7;         // 雨滴的位置
					float drop = S(.05, .03, length(droppos));                   // 雨滴的大小

					float2 trailpos = (gv - float2(x, t * .25)) / aspect2 * .8;
					trailpos.y = (frac(trailpos.y * 8) - .5) / 8;                // 有多少尾跡雨滴，顯示出來(frac function)
					float trail = S(.03, .01, length(trailpos));                 // 尾跡雨滴的大小

					float fogtrail = S(-.05, .05, droppos.y);
					fogtrail *= S(.5, y, gv.y);                                  // 讓後面的尾跡雨滴會漸漸消失
					trail *= fogtrail;                                           // 讓尾跡雨滴在雨滴的後面，不會在前面
					fogtrail *= S(.05, .03, abs(droppos.x));                     // 尾跡的形狀
					// col += fogtrail * .5;                                     // 把尾跡加入 texture 中
					// col += trail;                                             // 把尾跡雨滴加入 texture 中
					// col += drop;                                              // 把雨滴加進 texture 中
					// col.rg = gv;
					float2 offs = drop * droppos + trail * trailpos;
					//float2 offs = drop2 * droppos2 + trail2 * trailpos2;
					// if (gv.x > .48 || gv.y > .49) col = float4(1, 0, 0, 1);

					return float3(offs, fogtrail);
				}
				fixed4 frag(v2f i) : SV_Target
				{
					float t = fmod(_Time.y + _T, 7200);
					float4 col = 0;                                                              // 這是顯示 shader texture 的參數，0會全黑
					float3 drops = Layer(i.uv, t);
					drops += Layer(i.uv*1.23+7.54, t);
					drops += Layer(i.uv*1.35*3 + 1.54, t);
					drops += Layer(i.uv*1.57*2 - 7.54, t);
					float blur = _Blur * 7 * (1-drops.z);                                        // 加霧面感 (乘上 fogtrail，添增尾跡)
					col = tex2Dlod(_MainTex, float4(i.uv + drops.xy * _Distortion,0, blur));     // distortion 是雨滴折射圖片
					return col;
				}
				ENDCG
			}
		}
}
