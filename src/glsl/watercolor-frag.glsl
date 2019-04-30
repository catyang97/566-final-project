uniform sampler2D tDiffuse;
uniform float u_amount;
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

void main() {
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
    
    vec4 color = texture2D(tDiffuse, f_uv);
    vec4 col = texture2D(tDiffuse, f_uv);
    float luminance = dot(col.rgb, vec3(0.2126*255.0, 0.7152*255.0, 0.0722*255.0));
    vec4 newCol = col;

    newCol = newCol * (u_amount) + col * (1.0 - u_amount);
    // Edge = key characteristic, thick ink. Otherwise, thin ink and more water for ink effect
    if (g[0] > 30.0/255.0 && g[1] > 30.0/255.0 && g[2] > 10.0/255.0) {
        // "Color bleeding"
        vec4 left1 = texture2D(tDiffuse, vec2(f_uv.x - epsilon, f_uv.y));
        vec4 right1 = texture2D(tDiffuse, vec2(f_uv.x + epsilon, f_uv.y));
        vec4 rDown1 = texture2D(tDiffuse, vec2(f_uv.x + epsilon + 0.003, f_uv.y - epsilon));
        vec4 lUp1 = texture2D(tDiffuse, vec2(f_uv.x - epsilon-0.005, f_uv.y + epsilon));
        vec4 up1 = texture2D(tDiffuse, vec2(f_uv.x, f_uv.y + epsilon+0.015));

        g = mix(left1, right1, 0.5);
        g = mix(g, lUp1, 0.6);
        g = mix(g, rDown1, 0.6);
        g = mix(up1, g, 0.6);
    } else {
        g = newCol;
    }
    gl_FragColor = g;
}