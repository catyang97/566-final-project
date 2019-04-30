
uniform sampler2D texture;
uniform int u_useTexture;
uniform vec3 u_albedo;
uniform vec3 u_ambient;
uniform vec3 u_lightPos;
uniform vec3 u_lightCol;
uniform float u_lightIntensity;
uniform float u_pixelSize;
uniform float time;

varying vec3 f_position;
varying vec3 f_normal;
varying vec2 f_uv;

float random (vec2 st) {
    return fract(sin(dot(st.xy*time*0.1,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

void main() {
    vec2 square = u_pixelSize/vec2(2000, 1500);
    vec2 coord = square * floor(f_uv/square);
    float epsilon = 0.01;
    vec2 coord2 = square * floor(vec2(f_uv.x - epsilon+0.01, f_uv.y)/square);
    vec2 coord3 = square * floor(vec2(f_uv.x + epsilon, f_uv.y - epsilon-0.02)/square);
    vec2 coord4 = square * floor(vec2(f_uv.x, f_uv.y + epsilon)/square);

    // Randomize the block that is colored
    float rand = random(coord);
    if (rand > 0.6) {
        coord = coord2;
    } else if (rand > 0.3){
        coord = coord3;
    } else {
        coord = coord4;
    }

    gl_FragColor = texture2D(texture,coord);
}