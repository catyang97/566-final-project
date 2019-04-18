
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

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

// Worley-Perlin Noise from https://www.shadertoy.com/view/MdGSzt
vec3 hash(vec3 p3) {
	p3 = fract(p3 * vec3(0.1031, 0.11369, 0.13787));
  p3 += dot(p3, p3.yxz + 20.0);
  return -1.0 + 2.0 * fract(vec3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}

float perlinNoise(vec3 point) {
  vec3 pi = floor(point);
  vec3 pf = point - pi;
  vec3 w = pf * pf * (3.0 - 2.0 * pf);
  
  return 	mix(mix(mix(dot(pf - vec3(0, 0, 0), hash(pi + vec3(0, 0, 0))), 
                      dot(pf - vec3(1, 0, 0), hash(pi + vec3(1, 0, 0))),
                      w.x),
                  mix(dot(pf - vec3(0, 0, 1), hash(pi + vec3(0, 0, 1))), 
                      dot(pf - vec3(1, 0, 1), hash(pi + vec3(1, 0, 1))),
                      w.x),
                  w.z),
              mix(mix(dot(pf - vec3(0, 1, 0), hash(pi + vec3(0, 1, 0))), 
                      dot(pf - vec3(1, 1, 0), hash(pi + vec3(1, 1, 0))),
                      w.x),
                  mix(dot(pf - vec3(0, 1, 1), hash(pi + vec3(0, 1, 1))), 
                      dot(pf - vec3(1, 1, 1), hash(pi + vec3(1, 1, 1))),
                      w.x),
                w.z),
              w.y);
}

float getHeight(vec2 pos) {
  float height = pow(1.0 - perlinNoise(vec3(pos.x, pos.y, 1000.0)), 0.3);
  return height;
}
void main() {
    vec4 color = vec4(u_albedo, 1.0);
    
    if (u_useTexture == 1) {
        color = texture2D(texture, f_uv);
    }

    float d = clamp(dot(f_normal, normalize(u_lightPos - f_position)), 0.0, 1.0);
    float height = getHeight(vec2(f_uv.x, f_uv.y))* 2.0;

    float ran = random1(f_uv, vec2(0.2, 0.8));
  
    if (ran < 0.05) {
        color = color * height; 
    }
    gl_FragColor = vec4(d * color.rgb * u_lightCol * u_lightIntensity + u_ambient, 1.0);
}