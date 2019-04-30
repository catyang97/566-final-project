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
    vec4 col = texture2D(tDiffuse, f_uv);
    float luminance = dot(col.rgb, vec3(0.2126*255.0, 0.7152*255.0, 0.0722*255.0));
    vec4 newCol = col;

    // Luminance Division step: equations 10 and 11 in section 4.1 of paper
    // newCol = vec4((30.0*ceil(col.r*255.0 / 30.0))/255.0, (30.0*ceil(col.g*255.0 / 30.0))/255.0, (30.0*ceil(col.b*255.0 / 30.0))/255.0, newCol.a);
    // newCol.rgb = (ceil(luminance/floor(255.0/23.0)) / luminance) * newCol.rbg;
    newCol = newCol * (u_amount) + col * (1.0 - u_amount);
    // If pixel is at an edge, use the original color, else paint white
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