
uniform sampler2D texture;
uniform int u_useTexture;
uniform vec3 u_albedo;
uniform vec3 u_ambient;
uniform vec3 u_lightPos;
uniform vec3 u_lightCol;
uniform float u_lightIntensity;

varying vec3 f_position;
varying vec3 f_normal;
varying vec2 f_uv;

// Noise reference: https://www.shadertoy.com/view/XtsXRn
float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.-2.*f);
	
    float n = p.x + p.y*157. + 113.*p.z;
    
    vec4 v1 = fract(753.5453123*sin(n + vec4(0., 1., 157., 158.)));
    vec4 v2 = fract(753.5453123*sin(n + vec4(113., 114., 270., 271.)));
    vec4 v3 = mix(v1, v2, f.z);
    vec2 v4 = mix(v3.xy, v3.zw, f.y);
    return mix(v4.x, v4.y, f.x);
}

float fbm(vec3 p) {
  p = mat3(0.28862355854826727, 0.6997227302779844, 0.6535170557707412,
           0.06997493955670424, 0.6653237235314099, -0.7432683571499161,
           -0.9548821651308448, 0.26025457467376617, 0.14306504491456504)*p;
  return dot(vec4(noise(p), noise(p*2.), noise(p*4.), noise(p*8.)),
             vec4(0.5, 0.25, 0.125, 0.06));
}

void main() {
    vec4 color = texture2D(texture, f_uv);
    
    // float d = clamp(dot(f_normal, normalize(u_lightPos - f_position)), 0.0, 1.0);
    // float height = getHeight(vec2(f_uv.x, f_uv.y))* 2.0;

    // gl_FragColor = vec4(d * color.rgb * u_lightCol * u_lightIntensity + u_ambient, 1.0);
    vec2 uv = vec2(f_uv.x, f_uv.y);
    vec3 col = 1.0 - 0.025 * vec3(smoothstep(0.6, 0.2, fbm(vec3(uv * 70.0,1.0))));
    vec3 diff = vec3(color.x - (1.0-col.x)*2.0, color.y - (1.0-col.y)*2.0, color.z - (1.0-col.z)*2.0);

    gl_FragColor = vec4(diff, 1.0);
}