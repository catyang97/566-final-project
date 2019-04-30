uniform sampler2D tDiffuse;
uniform float u_amount;
varying vec2 f_uv;

void main() {
    vec4 col = texture2D(tDiffuse, f_uv);
    vec4 g = vec4(1.0);
    if (col[0] > 10.0/255.0 && col[1] > 10.0/255.0 && col[2] > 10.0/255.0) {
        g = col;
    }
    gl_FragColor = g;
}