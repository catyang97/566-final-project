
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
// var clock = new THREE.Clock();
// var t = 0.0;

export default function(renderer, scene, camera) {
    
    const Shader = {
        initGUI: function(gui) {
            gui.add(options, 'pixelSize').onChange(function(val) {
                Shader.material.uniforms.u_pixelSize.value = val;
            });
            // gui.addColor(options, 'lightColor').onChange(function(val) {
            //     Shader.material.uniforms.u_lightCol.value = new THREE.Color(val);
            // });
            // gui.add(options, 'lightIntensity').onChange(function(val) {
            //     Shader.material.uniforms.u_lightIntensity.value = val;
            // });
            // gui.addColor(options, 'albedo').onChange(function(val) {
            //     Shader.material.uniforms.u_albedo.value = new THREE.Color(val);
            // });
            // gui.addColor(options, 'ambient').onChange(function(val) {
            //     Shader.material.uniforms.u_ambient.value = new THREE.Color(val);
            // });
            // gui.add(options, 'useTexture').onChange(function(val) {
            //     Shader.material.uniforms.u_useTexture.value = val;
            // });
        },

        update: function() {
            // var a = clock.getDelta();
            // t += a;
            // Shader.material.uniforms.time.value = t;
            
            Shader.material.uniforms.time.value = 0.0005 * (Date.now() - begin);
        },
        
        material: new THREE.ShaderMaterial({
            uniforms: {
                texture: {
                    type: "t", 
                    value: null
                },
                u_useTexture: {
                    type: 'i',
                    value: options.useTexture
                },
                u_albedo: {
                    type: 'v3',
                    value: new THREE.Color(options.albedo)
                },
                u_ambient: {
                    type: 'v3',
                    value: new THREE.Color(options.ambient)
                },
                u_lightPos: {
                    type: 'v3',
                    value: new THREE.Vector3(30, 50, 40)
                },
                u_lightCol: {
                    type: 'v3',
                    value: new THREE.Color(options.lightColor)
                },
                u_lightIntensity: {
                    type: 'f',
                    value: options.lightIntensity
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

    // once the Mario texture loads, bind it to the material
    textureLoaded.then(function(texture) {
        Shader.material.uniforms.texture.value = texture;
    });

    return Shader;
}