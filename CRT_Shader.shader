Shader "Hidden/CRT_Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType" = "Transparent" }
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

		Pass
		{
			CGPROGRAM
			#pragma exclude_renderers d3d11 gles	
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			uniform float u_zoom;

			uniform float u_time;

			uniform float u_bend;
			uniform float u_middle_bend;

			uniform float u_hue;
			uniform float u_saturation;
			uniform float u_colors_intensity;

			struct u_screen_line{
				float size;
				float speed;
			};

			u_screen_line _lines[4];

			uniform float u_scanline_size_1;
			uniform float u_scanline_speed_1;
			uniform float u_scanline_size_2;
			uniform float u_scanline_speed_2;
			uniform float u_scanline_amount;

			uniform float u_vignette_size;
			uniform float u_vignette_smoothness;
			uniform float u_vignette_edge_round;

			uniform float u_noise_size;
			uniform float u_noise_amount;

			uniform float u_chromo_intensity;
			uniform half2 u_red_offset;
			uniform half2 u_green_offset;
			uniform half2 u_blue_offset;

			// COlor Shift (Hue)
			float3 shift_col(float3 RGB, float3 shift)
            {
                float3 RESULT = float3(RGB);
                float VSU = shift.z*shift.y*cos(shift.x*3.14159265/180);
				float VSW = shift.z*shift.y*sin(shift.x*3.14159265/180);
			
				RESULT.x = (.299*shift.z+.701*VSU+.168*VSW)*RGB.x
						+ (.587*shift.z-.587*VSU+.330*VSW)*RGB.y
						+ (.114*shift.z-.114*VSU-.497*VSW)*RGB.z;
			
				RESULT.y = (.299*shift.z-.299*VSU-.328*VSW)*RGB.x
						+ (.587*shift.z+.413*VSU+.035*VSW)*RGB.y
						+ (.114*shift.z-.114*VSU+.292*VSW)*RGB.z;
			
				RESULT.z = (.299*shift.z-.3*VSU+1.25*VSW)*RGB.x
						+ (.587*shift.z-.588*VSU-1.05*VSW)*RGB.y
						+ (.114*shift.z+.886*VSU-.203*VSW)*RGB.z;
                
                return (RESULT);
            }
 

			// Image position + Lens Bend
			half2 crt_coords(half2 uv, float bend, float m_bend, float c_zoom)
			{
				uv -= 0.5;
				uv *= 2;
				uv.x *= 1. + pow(abs(uv.y) / bend, m_bend);
				uv.y *= 1. + pow(abs(uv.x) / bend, m_bend);

				uv /= c_zoom;
				return uv + 0.5;
			}

			// Well, the vignette 
			float vignette(half2 uv, float size, float smoothness, float edgeRounding)
			{
				uv -= .5;
				uv *= size;
				float amount = sqrt(pow(abs(uv.x), edgeRounding) + pow(abs(uv.y), edgeRounding));
				amount = 1. - amount;
				return smoothstep(0, smoothness, amount);
			}

			// Distors image creating screen line effect
			float scanline(half2 uv, float lines, float speed)
			{
				return sin(uv.y * lines + u_time * speed);
			}

			// Getting fake random
			float random(half2 uv)
			{
				return frac(sin(dot(uv, half2(15.1511, 42.5225))) * 12341.51611 * sin(u_time * 0.03));
			}

			// Image noise
			float noise(half2 uv)
			{
				half2 i = floor(uv);
				half2 f = frac(uv);

				float a = random(i);
				float b = random(i + half2(1., 0.));
				float c = random(i + half2(0, 1.));
				float d = random(i + half2(1., 1.));

				half2 u = smoothstep(0., 1., f);

				return lerp(a, b, u.x) + (c - a) * u.y * (1. - u.x) + (d - b) * u.x * u.y;
			}

			// Output
			fixed4 frag (v2f i) : SV_Target
			{
				half2 crt_uv = crt_coords(i.uv, u_bend, u_middle_bend, u_zoom);

				// Chromatic Abberation
				fixed4 col;

				col.r = tex2D(_MainTex, crt_uv + (u_red_offset * -u_chromo_intensity / 10000.)).r;
				col.g = tex2D(_MainTex, crt_uv + (u_green_offset * -u_chromo_intensity / 10000.)).g;
				col.b = tex2D(_MainTex, crt_uv + (u_blue_offset * -u_chromo_intensity / 10000.)).b;
				col.a = tex2D(_MainTex, crt_uv).a;

				// Adding Screen lines effect
				float s1 = scanline(i.uv, u_scanline_size_1*100, u_scanline_speed_1);
				float s2 = scanline(i.uv, u_scanline_size_2*100, u_scanline_speed_2);

				// Combining into one color
				col = lerp(col, fixed(s1 + s2), u_scanline_amount/100);

				float3 shift = float3(u_hue, u_saturation, u_colors_intensity);
				col = float4(shift_col(col, shift), 1.);

				// Output the color
				return lerp(col, fixed(noise(i.uv * u_noise_size/10.)), u_noise_amount/1000.) * vignette(i.uv, u_vignette_size, u_vignette_smoothness, u_vignette_edge_round);
			}
			ENDCG
		}
	}
}