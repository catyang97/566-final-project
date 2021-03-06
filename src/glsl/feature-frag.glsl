uniform sampler2D tDiffuse;
uniform float u_amount;
varying vec2 f_uv;

void main() {
    vec4 col = texture2D(tDiffuse, f_uv);
    float luminance = dot(col.rgb, vec3(0.2126*255.0, 0.7152*255.0, 0.0722*255.0));
    vec4 newCol = col;

    // Luminance Division step: equations 10 and 11 in section 4.1 of paper
    newCol = vec4((30.0*ceil(col.r*255.0 / 30.0))/255.0, (30.0*ceil(col.g*255.0 / 30.0))/255.0, (30.0*ceil(col.b*255.0 / 30.0))/255.0, newCol.a);
    // newCol.rgb = (ceil(luminance/floor(255.0/23.0)) / luminance) * newCol.rbg;
    newCol = newCol * (u_amount) + col * (1.0 - u_amount);

    // Color Segmentation step?
    gl_FragColor = newCol;
}