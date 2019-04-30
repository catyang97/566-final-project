const THREE = require('three');
const EffectComposer = require('three-effectcomposer')(THREE)

var options = {
    amount: 1
}

var FirstPass = new EffectComposer.ShaderPass({
    uniforms: {
        tDiffuse: {
            type: 't',
            value: null
        },
        tOne: {
            type: 't',
            value: THREE.ImageUtils.loadTexture(require('../assets/1.bmp'))
        },
        u_amount: {
            type: 'f',
            value: options.amount
        },
        screenHeight: {
            type: 'f', 
            value: screen.height
        }, 
        screenWidth: {
            type: 'f', 
            value: screen.width
        }
    },
    vertexShader: require('../glsl/pass-vert.glsl'),
    fragmentShader: require('../glsl/layer1.glsl')
});

// var SecondPass = new EffectComposer.ShaderPass({
//     uniforms: {
//         tDiffuse: {
//             type: 't',
//             value: null
//         }

//     },
//     vertexShader: require('../glsl/pass-vert.glsl'),
//     fragmentShader: require('../glsl/layer2.glsl')
// });

export default function Layer1(renderer, scene, camera) {
    
    // this is the THREE.js object for doing post-process effects
    var composer = new EffectComposer(renderer);

    // first render the scene normally and add that as the first pass
    composer.addPass(new EffectComposer.RenderPass(scene, camera));

    // then take the rendered result and apply the FeatureShader
    composer.addPass(FirstPass);  
    FirstPass.renderToScreen = true;
    // composer.addPass(SecondPass);
    // SecondPass.renderToScreen = true;  

    // set this to true on the shader for your last pass to write to the screen
    // FirstPass.renderToScreen = false;  

    return {
        // uniforms: SecondPass.uniforms,
        initGUI: function(gui) {
            gui.add(options, 'amount', 0, 1).onChange(function(val) {
                FirstPass.material.uniforms.u_amount.value = val;
                // SecondPass.material.uniforms.u_amount.value = val;

            });
        },
        
        render: function() {;
            composer.render();
        }
    }
}