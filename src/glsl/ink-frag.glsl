uniform sampler2D tDiffuse;
uniform float u_amount;
varying vec2 f_uv;

void main() {
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
    
    // Combine edge color with original colors
    vec4 color = texture2D(tDiffuse, f_uv);
    // gl_FragColor = vec4(g.rgb, 1) * (u_amount) + color * (1.0 - u_amount);

    // If pixel is at an edge, use the original color, else paint white
    // Edge = key characteristic, thick ink. Otherwise, thin ink and more water for ink effect
    if (g[0] > 20.0/255.0 && g[1] > 20.0/255.0 && g[2] > 10.0/255.0) {
        g = color;
    } else {
        g = vec4(1.0);
    }
    gl_FragColor = g;
}