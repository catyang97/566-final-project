uniform sampler2D tDiffuse;
uniform sampler2D tOne;
uniform float u_amount;
varying vec2 f_uv;

void main() {
    vec4 col = texture2D(tOne, f_uv);
    // vec4 g = vec4(1.0);
    // if (col[0] > 200.0/255.0 && col[1] > 200.0/255.0 && col[2] > 200.0/255.0) {
    //     g = col;
    // }
    gl_FragColor = col;
}