
uniform sampler2D tDiffuse;
varying vec2 f_uv;

// Math functions 
vec3 cosh(vec3 val) { vec3 e = exp(val); return (e + vec3(1.0) / e) / vec3(2.0); }
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

float fbm(vec2 xy) { //from slides
    float total = 0.0;
    float persistence = 0.5;

    for (float i = 0.0; i < 3.0; i++) {
        float freq = pow(2.0, i);
        float amp = pow(persistence, i);
        total += interpNoise2D(xy.x * freq, xy.y * freq) * amp;
    }
    return total;
}

void main() {
    vec4 col = texture2D(tDiffuse, f_uv);

    vec3 r1,t1,r2,t2,rr,tt;

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