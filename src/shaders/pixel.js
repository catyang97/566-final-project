
const THREE = require('three');
import {textureLoaded} from '../rectangle'

var options = {
    lightColor: '#ffffff',
    lightIntensity: 2,
    albedo: '#dddddd',
    ambient: '#111111',
    useTexture: true,
    pixelSize: 18.0
}
var begin = Date.now();

export default function(renderer, scene, camera) {
    
    const Shader = {
        initGUI: function(gui) {
            gui.add(options, 'pixelSize').onChange(function(val) {
                Shader.material.uniforms.u_pixelSize.value = val;
            });
        },

        update: function() {
            Shader.material.uniforms.time.value = 0.0005 * (Date.now() - begin);
        },
        
        material: new THREE.ShaderMaterial({
            uniforms: {
                texture: {
                    type: "t", 
                    value: null
                },
                u_pixelSize: {
                    type: 'f',
                    value: options.pixelSize
                },
                time: {
                    type: "f", 
                    value: begin
                }
            },
            vertexShader: require('../glsl/lambert-vert.glsl'),
            fragmentShader: require('../glsl/pixel-frag.glsl')
        })
    }

    // once the texture loads, bind it to the material
    textureLoaded.then(function(texture) {
        Shader.material.uniforms.texture.value = texture;
    });

    return Shader;
}