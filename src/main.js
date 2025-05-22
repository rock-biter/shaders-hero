import './style.css'
import * as THREE from 'three'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/base/vertex.glsl'
import fragmentShader from './shaders/base/fragment.glsl'
import { min, step } from 'three/tsl'

/**
 * Debug
 */
const config = {
	ambientLight: {
		color: new THREE.Color(0xffffff),
		intensity: 0.2,
	},
	hemiLight: {
		skyColor: new THREE.Color(0.55, 0.79, 1.0),
		groundColor: new THREE.Color(0.2, 0.35, 0.0),
	},
	dirLight: {
		color: new THREE.Color(0xff5500),
		intensity: 0.7,
		direction: new THREE.Vector3(1, 1.3, 1.2),
	},
	pointLight: {
		color: new THREE.Color(0x2211ff),
		intensity: 2.0,
		position: new THREE.Vector3(-1, 2, 0),
		maxDistance: 10,
	},
	spotLight: {
		color: new THREE.Color(0x22ff11),
		intensity: 2.0,
		position: new THREE.Vector3(-0, 4, 2),
		target: new THREE.Vector3(0, 1, 0),
		maxDistance: 10,
		angle: Math.PI / 2.5,
		penumbra: 0.1,
	},
	glossiness: 10,
	toon: 5,
}
const pane = new Pane()

// pane.addBinding(config.ambientLight, 'color', {
// 	color: { type: 'float' },
// })

const ambientFolder = pane.addFolder({
	title: 'Ambient Light',
	expanded: false,
})
const hemiFolder = pane.addFolder({ title: 'PointLight', expanded: false })
const dirFolder = pane.addFolder({
	title: 'Directional Light',
	expanded: false,
})
const pointFolder = pane.addFolder({ title: 'Point Light', expanded: false })
const spotFolder = pane.addFolder({ title: 'Spot Light', expanded: false })

// SPOT LIGHT
spotFolder.addBinding(config.spotLight, 'color', {
	color: { type: 'float' },
})

spotFolder
	.addBinding(config.spotLight, 'intensity', {
		min: 0,
		max: 4,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uSpotLight.value.intensity = ev.value
	})

spotFolder
	.addBinding(config.spotLight, 'angle', {
		min: 0,
		max: Math.PI,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uSpotLight.value.angle = ev.value
	})

spotFolder
	.addBinding(config.spotLight, 'penumbra', {
		min: 0,
		max: 1.0,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uSpotLight.value.penumbra = ev.value
	})

spotFolder
	.addBinding(config.spotLight, 'maxDistance', {
		min: 0,
		max: 20,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uSpotLight.value.maxDistance = ev.value
	})

spotFolder.addBinding(config.spotLight, 'position', {
	x: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
	y: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
	z: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
})

spotFolder
	.addBinding(config.spotLight, 'target', {
		min: -2,
		max: 2.0,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uSpotLight.value.target.x = ev.value
	})
spotFolder.addBinding(config.spotLight.target, 'y', {
	x: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
	y: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
	z: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
})

// POINT LIGHT
pointFolder.addBinding(config.pointLight, 'color', {
	color: { type: 'float' },
})

pointFolder
	.addBinding(config.pointLight, 'intensity', {
		min: 0,
		max: 4,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uPointLight.value.intensity = ev.value
	})

pointFolder
	.addBinding(config.pointLight, 'maxDistance', {
		min: 0,
		max: 20,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uPointLight.value.maxDistance = ev.value
	})

pointFolder.addBinding(config.pointLight, 'position', {
	x: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
	y: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
	z: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
})

// HEMI LIGHT
hemiFolder.addBinding(config.hemiLight, 'skyColor', {
	color: { type: 'float' },
})

hemiFolder.addBinding(config.hemiLight, 'groundColor', {
	color: { type: 'float' },
})

// DIR LIGHT
dirFolder.addBinding(config.dirLight, 'color', {
	color: { type: 'float' },
})

dirFolder
	.addBinding(config.dirLight, 'intensity', {
		min: 0,
		max: 1,
		steps: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uDirLight.value.intensity = ev.value
	})

dirFolder.addBinding(config.dirLight, 'direction', {
	x: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
	y: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
	z: {
		min: -2,
		max: 2.0,
		step: 0.01,
	},
})

// GLOSSINESS
pane
	.addBinding(config, 'glossiness', {
		min: 1,
		max: 100,
		step: 0.1,
	})
	.on('change', (ev) => {
		material.uniforms.uGlossiness.value = ev.value
	})

//TOON
pane
	.addBinding(config, 'toon', {
		min: 1,
		max: 10,
		step: 1,
	})
	.on('change', (ev) => {
		if (ev.value < 2) {
			delete material.defines.TOON
		} else {
			material.uniforms.uToon.value = ev.value
			material.defines.TOON = ev.value
		}
		material.needsUpdate = true
	})

/**
 * Scene
 */
const scene = new THREE.Scene()
// scene.background = new THREE.Color(0xdedede)

/**
 * BOX
 */
// const material = new THREE.MeshNormalMaterial()
const material = new THREE.ShaderMaterial({
	vertexShader,
	fragmentShader,
	defines: {
		TOON: config.toon,
	},
	uniforms: {
		uToon: {
			value: config.toon,
		},
		uAmbientLight: {
			value: {
				color: config.ambientLight.color,
				intensity: config.ambientLight.intensity,
			},
		},
		uHemiLight: {
			value: {
				skyColor: config.hemiLight.skyColor,
				groundColor: config.hemiLight.groundColor,
			},
		},
		uDirLight: {
			value: {
				color: config.dirLight.color,
				intensity: config.dirLight.intensity,
				direction: config.dirLight.direction,
			},
		},
		uPointLight: {
			value: {
				color: config.pointLight.color,
				intensity: config.pointLight.intensity,
				position: config.pointLight.position,
				maxDistance: config.pointLight.maxDistance,
			},
		},
		uSpotLight: {
			value: {
				color: config.spotLight.color,
				intensity: config.spotLight.intensity,
				position: config.spotLight.position,
				target: config.spotLight.target,
				maxDistance: config.spotLight.maxDistance,
				angle: config.spotLight.angle,
				penumbra: config.spotLight.penumbra,
			},
		},
		uGlossiness: {
			value: config.glossiness,
		},
	},
})
const boxGeometry = new THREE.BoxGeometry(1.3, 1.3, 1.3)
const icoGeometry = new THREE.IcosahedronGeometry(1)
const torusGeometry = new THREE.TorusGeometry(0.5, 0.3, 16, 100)
const box = new THREE.Mesh(boxGeometry, material)
const ico = new THREE.Mesh(icoGeometry, material)
const torus = new THREE.Mesh(torusGeometry, material)
// torus.position.x = 3
box.position.x = -3

scene.add(torus)

const planeGeom = new THREE.PlaneGeometry(10, 10)
planeGeom.rotateX(-Math.PI / 2)
const plane = new THREE.Mesh(planeGeom, material)
plane.position.y = -2
scene.add(plane)

/**
 * render sizes
 */
const sizes = {
	width: window.innerWidth,
	height: window.innerHeight,
}

/**
 * Camera
 */
const fov = 60
const camera = new THREE.PerspectiveCamera(fov, sizes.width / sizes.height, 0.1)
camera.position.set(4, 3, 6)
camera.lookAt(new THREE.Vector3(0, 2.5, 0))

/**
 * Show the axes of coordinates system
 */
// __helper_axes__
const axesHelper = new THREE.AxesHelper(3)
// scene.add(axesHelper)

scene.background = new THREE.Color(0x000022)

/**
 * renderer
 */
const renderer = new THREE.WebGLRenderer({
	antialias: window.devicePixelRatio < 2,
})
document.body.appendChild(renderer.domElement)
handleResize()

/**
 * OrbitControls
 */
// __controls__
const controls = new OrbitControls(camera, renderer.domElement)
controls.enableDamping = true

/**
 * Three js Clock
 */
// __clock__
// const clock = new THREE.Clock()

/**
 * frame loop
 */
function tic() {
	/**
	 * tempo trascorso dal frame precedente
	 */
	// const deltaTime = clock.getDelta()
	/**
	 * tempo totale trascorso dall'inizio
	 */
	// const time = clock.getElapsedTime()

	// __controls_update__
	controls.update()

	renderer.render(scene, camera)

	requestAnimationFrame(tic)
}

requestAnimationFrame(tic)

window.addEventListener('resize', handleResize)

function handleResize() {
	sizes.width = window.innerWidth
	sizes.height = window.innerHeight

	camera.aspect = sizes.width / sizes.height

	// camera.aspect = sizes.width / sizes.height;
	camera.updateProjectionMatrix()

	renderer.setSize(sizes.width, sizes.height)

	const pixelRatio = Math.min(window.devicePixelRatio, 2)
	renderer.setPixelRatio(pixelRatio)
}
