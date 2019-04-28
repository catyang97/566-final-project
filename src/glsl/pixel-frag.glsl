
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

void main() {
    vec2 square = 18.0/vec2(2000, 1500);
    vec2 coord = square * floor(f_uv/square);
    gl_FragColor = texture2D(texture,coord);
}