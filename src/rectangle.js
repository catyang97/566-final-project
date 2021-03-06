
// this file is just for convenience. it sets up loading the rectangle obj and texture

const THREE = require('three');
require('three-obj-loader')(THREE)

export var textureLoaded = new Promise((resolve, reject) => {
    (new THREE.TextureLoader()).load(require('./assets/mountain.bmp'), function(texture) {
        resolve(texture);
    })
})

export var objLoaded = new Promise((resolve, reject) => {
    (new THREE.OBJLoader()).load(require('./assets/rect2.obj'), function(obj) {
        var geo = obj.children[0].geometry;
        geo.computeBoundingSphere();
        resolve(geo);
    });
})