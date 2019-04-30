
uniform sampler2D tDiffuse;
varying vec2 f_uv;

// Table of pigments 
// from Computer-Generated Watercolor. Cassidy et al.
// K is absorption. S is scattering
vec3 K_QuinacridoneRose = vec3(0.22, 1.47, 0.57);
vec3 S_QuinacridoneRose = vec3(0.05, 0.003, 0.03);
vec3 K_FrenchUltramarine = vec3(0.86, 0.86, 0.06);
vec3 S_FrenchUltramarine = vec3(0.005, 0.005, 0.09);
vec3 K_CeruleanBlue = vec3(1.52, 0.32, 0.25);
vec3 S_CeruleanBlue = vec3(0.06, 0.26, 0.40);
vec3 K_HookersGreen = vec3(1.62, 0.61, 1.64);
vec3 S_HookersGreen = vec3(0.01, 0.012, 0.003);
vec3 K_HansaYellow = vec3(0.06, 0.21, 1.78);
vec3 S_HansaYellow = vec3(0.50, 0.88, 0.009);

// Math functions not available in webgl
vec3 cosh(vec3 val) { vec3 e = exp(val); return (e + vec3(1.0) / e) / vec3(2.0); }
vec3 tanh(vec3 val) { vec3 e = exp(val); return (e - vec3(1.0) / e) / (e + vec3(1.0) / e); }
vec3 sinh(vec3 val) { vec3 e = exp(val); return (e - vec3(1.0) / e) / vec3(2.0); }

// Kubelka-Munk reflectance and transmittance model
void KMCol(vec3 color, float x, out vec3 refl, out vec3 trans) {
    // Absorption coefficient
    vec3 Ab = vec3(0.9999998);
    // Scattering coefficient
    vec3 S = (2.0*color)/((Ab-color)*(Ab-color));
    vec3 a = (S+Ab)/S;
    vec3 b = sqrt(a*a - vec3(1.0));
    vec3 c = a*(sinh(b*S*x)) + b*(cosh(b*S*x));
    refl = (sinh(b*S*x))/c;
    trans = b/c;
}

// The watercolours tends to dry first in the center
// and accumulate more pigment in the corners
float brush_effect(float dist, float h_avg, float h_var)
{
    float h = max(0.0,1.0-10.0*abs(dist));
    h *= h;
    h *= h;
    return (h_avg+h_var*h) * smoothstep(-0.01, 0.002, dist);
}

// Kubelka-Munk model for layering
// void layering(vec3 r0, vec3 t0, vec3 r1, vec3 t1, out vec3 r, out vec3 t)
// {
//     r = r0 + t0*t0*r1 / (vec3(1.0)-r0*r1);
//     t = t0*t1 / (vec3(1.0)-r0*r1);
// }

void layer(vec3 r1, vec3 t1, vec3 r2, vec3 t2, out vec3 refl, out vec3 trans) {
    refl = r1 + t1*t1*r2/(vec3(1.0)-r1*r2);
    trans = t1*t2 / (vec3(1.0)-r1*r2);
}

// For FBM
float random1( vec2 p , vec2 seed) {
    return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float random1( vec3 p , vec3 seed) {
    return fract(sin(dot(p + seed, vec3(987.654, 123.456, 531.975))) * 85734.3545);
}

vec2 random2( vec2 p , vec2 seed) {
    return fract(sin(vec2(dot(p + seed, vec2(311.7, 127.1)), dot(p + seed, vec2(269.5, 183.3)))) * 85734.3545);
}

float interpNoise2D(float x, float y) { //from slides
    float intX = floor(x);
    float fractX = fract(x);
    float intY = floor(y);
    float fractY = fract(y);

    float v1 = random1(vec2(intX, intY), vec2(1.0, 1.0));
    float v2 = random1(vec2(intX + 1.0, intY), vec2(1.0, 1.0));
    float v3 = random1(vec2(intX, intY + 1.0), vec2(1.0, 1.0));
    float v4 = random1(vec2(intX + 1.0, intY + 1.0), vec2(1.0, 1.0));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);

    return mix(i1, i2, fractY);
}

const float OCTAVES = 3.0;
float fbm(vec2 xy) { //from slides
    float total = 0.0;
    float persistence = 0.5;
    float octaves = 3.0;

    for (float i = 0.0; i < OCTAVES; i++) {
        float freq = pow(2.0, i);
        float amp = pow(persistence, i);
        total += interpNoise2D(xy.x * freq, xy.y * freq) * amp;
    }
    return total;
}

void main() {
    vec4 col = texture2D(tDiffuse, f_uv);

    vec3 r1,t1,r2,t2,rr,tt;

    // float sky = 0.1 + 0.1 * fbm(uv * vec2(0.1));
    // KM(K_CeruleanBlue, S_CeruleanBlue, sky, r0, t0);
    
    // float mountain_line = 0.5+0.04*(sin(uv.x*18.0+2.0)+sin(sin(uv.x*2.0)*7.0))-uv.y;
    // float s = clamp(2.0-10.0*abs(mountain_line),0.0,1.0);
    // vec2 uv2 = uv + vec2(0.04*s*fbm(uv * vec2(0.1)));
    // float mountains = brush_effect(0.5+0.04*(sin(uv2.x*18.0+2.0)+sin(sin(uv2.x*2.0)*7.0))-uv2.y, 0.2, 0.1);
    // mountains *= 0.85+0.15*fbm(uv*vec2(0.2));
    // KM(K_HookersGreen, S_HookersGreen, mountains, r1, t1);
    // layering(r0,t0,r1,t1,r0,t0);
    
    // vec2 uv3 = uv*vec2(1.0,0.7) + vec2(0.02*fbm(uv * vec2(0.2)));
    // float sun = brush_effect(1.0 - distance(uv3, vec2(0.2,0.45)) / 0.08, 0.2, 0.1);
    // KM(K_HansaYellow, S_HansaYellow, sun, r1, t1);
    // layering(r0,t0,r1,t1,r0,t0);



    // Sobel: https://en.wikipedia.org/wiki/Sobel_operator
    float epsilon = 0.001;

    // Left of pixel
    vec4 lUp = texture2D(tDiffuse, vec2(f_uv.x - epsilon, f_uv.y + epsilon));
    vec4 left = texture2D(tDiffuse, vec2(f_uv.x - epsilon, f_uv.y));
    vec4 lDown = texture2D(tDiffuse, vec2(f_uv.x - epsilon, f_uv.y - epsilon));

    // Right of pixel
    vec4 rUp = texture2D(tDiffuse, vec2(f_uv.x + epsilon, f_uv.y + epsilon));
    vec4 right = texture2D(tDiffuse, vec2(f_uv.x + epsilon, f_uv.y));
    vec4 rDown = texture2D(tDiffuse, vec2(f_uv.x + epsilon, f_uv.y - epsilon));

    // Over and under pixel
    vec4 up = texture2D(tDiffuse, vec2(f_uv.x, f_uv.y + epsilon));
    vec4 down = texture2D(tDiffuse, vec2(f_uv.x, f_uv.y - epsilon));

    // Apply kernel numbers to get gx and gy
    vec4 gx = -1.0*lUp - 2.0*left - lDown + rUp + 2.0*right + rDown;
    vec4 gy = -1.0*lUp - 2.0*up - rUp + lDown + 2.0*down + rDown;
    vec4 g = sqrt(gx*gx + gy*gy);

    // Layer 1
    // if (col[0] > 200.0/255.0 && col[1] > 200.0/255.0 && col[2] > 200.0/255.0) {
    //     KMCol(col.xyz, 1.0, r1, t1);
    // } else if (col[0] > 150.0/255.0 && col[1] > 150.0/255.0 && col[2] > 150.0/255.0) {
        
    // } else if (col[0] > 100.0/255.0 && col[1] > 100.0/255.0 && col[2] > 100.0/255.0) {
        
    // } else if (col[0] > 50.0/255.0 && col[1] > 50.0/255.0 && col[2] > 50.0/255.0) {
        
    // } else {

    // }
    vec4 outCol = vec4(1.0);
    // if (g[0] > 20.0/255.0 && g[1] > 20.0/255.0 && g[2] > 10.0/255.0) { // edge
        KMCol(col.xyz, 1.0, r1,t1);
        KMCol(left.xyz, 1.0, r2, t2);
        layer(r1, t1, r2, t2, rr, tt);
        // g = col;
        vec3 total = rr + tt;
        outCol = vec4(total,1.0);

    // } else {
    //     g = vec4(1.0);
    //     outCol = g;

    // }
	gl_FragColor = outCol;
}