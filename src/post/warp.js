const THREE = require('three');
const EffectComposer = require('three-effectcomposer')(THREE)

var options = {
    amount: 1.0
}

var begin = Date.now();

var WarpShader = new EffectComposer.ShaderPass({
    uniforms: {
        tDiffuse: {
            type: 't',
            value: null
        },
        u_amount: {
            type: 'f',
            value: options.amount
        },
        time: {
            type: "f", 
            value: begin
        }
    },
    vertexShader: require('../glsl/pass-vert.glsl'),
    fragmentShader: require('../glsl/warp-frag.glsl')
});

export default function Warp(renderer, scene, camera) {
    
    // this is the THREE.js object for doing post-process effects
    var composer = new EffectComposer(renderer);

    // first render the scene normally and add that as the first pass
    composer.addPass(new EffectComposer.RenderPass(scene, camera));

    // then take the rendered result and apply the WarpShader
    composer.addPass(WarpShader);  

    // set this to true on the shader for your last pass to write to the screen
    WarpShader.renderToScreen = true;  

    return {
        initGUI: function(gui) {
            gui.add(options, 'amount', 0, 1).onChange(function(val) {
                WarpShader.material.uniforms.u_amount.value = val;
            });
        },
        
        render: function() {
            WarpShader.uniforms['time'].value = 0.0005 * (Date.now() - begin);
            composer.render();
        }
    }
}