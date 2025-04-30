import './style.css'
import * as THREE from 'three'
// __controls_import__
// __gui_import__

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/base/vertex.glsl'
import fragmentShader from './shaders/base/fragment.glsl'

const cubeTextureLoader = new THREE.CubeTextureLoader()
const envMap = cubeTextureLoader.load(
	[
		'/env/02/px.png',
		'/env/02/nx.png',
		'/env/02/py.png',
		'/env/02/ny.png',
		'/env/02/pz.png',
		'/env/02/nz.png',
	],
	() => {
		scene.background = envMap
		scene.add(drop, innerDrop)
	}
)

/**
 * Debug
 */
// __gui__
const config = {
	perlin: {
		frequency: 0.3,
		amplitude: 0.8,
	},
}
const pane = new Pane()

const perlin = pane.addFolder({ title: 'Perlin' })
perlin
	.addBinding(config.perlin, 'frequency', {
		min: 0.01,
		max: 4,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uFrequency.value = ev.value
	})

perlin
	.addBinding(config.perlin, 'amplitude', {
		min: 0.1,
		max: 2,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uAmplitude.value = ev.value
	})

/**
 * Scene
 */
const scene = new THREE.Scene()
// scene.background = new THREE.Color(0xdedede)

// __box__
/**
 * BOX
 */
// const material = new THREE.MeshNormalMaterial()
const material = new THREE.ShaderMaterial({
	vertexShader,
	fragmentShader,
	// wireframe: true,
	uniforms: {
		uTime: {
			value: 0,
		},
		uFrequency: {
			value: config.perlin.frequency,
		},
		uAmplitude: {
			value: config.perlin.amplitude,
		},
		uEnvMap: {
			value: envMap,
		},
		uInnerFace: {
			value: false,
		},
	},
})
// const boxGeometry = new THREE.BoxGeometry(3.3, 3.3, 3.3)
// const icoGeometry = new THREE.IcosahedronGeometry(3)
// const torusGeometry = new THREE.TorusGeometry(0.5, 0.3, 16, 100)
// const box = new THREE.Mesh(boxGeometry, material)
// const ico = new THREE.Mesh(icoGeometry, material)
// const torus = new THREE.Mesh(torusGeometry, material)
// // torus.position.x = 3
// // box.position.x = -3
// torus.rotation.x = -Math.PI * 0.2
// torus.scale.setScalar(3)
// const planeGeometry = new THREE.PlaneGeometry(5, 5, 50, 50)
// // planeGeometry.rotateX(-Math.PI / 2)
// const plane = new THREE.Mesh(planeGeometry, material)
// plane.position.y = -2
const sphereGeometry = new THREE.SphereGeometry(2.5, 100, 100)
sphereGeometry.computeTangents()
console.log(sphereGeometry)
const drop = new THREE.Mesh(sphereGeometry, material)
const innerDrop = drop.clone()
innerDrop.material = drop.material.clone()
innerDrop.material.uniforms.uTime = material.uniforms.uTime
innerDrop.material.side = THREE.BackSide
innerDrop.material.blending = THREE.AdditiveBlending
innerDrop.material.depthTest = false
innerDrop.material.uniforms.uInnerFace.value = true

// background della scena
// scene.background = new THREE.Color(0x000033)

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
camera.position.set(5, -3.5, -7.5)
camera.lookAt(new THREE.Vector3(2, 2.5, 0))

/**
 * Show the axes of coordinates system
 */
// __helper_axes__
// const axesHelper = new THREE.AxesHelper(3)
// scene.add(axesHelper)

/**
 * renderer
 */
const renderer = new THREE.WebGLRenderer({
	antialias: window.devicePixelRatio < 2,
})
document.body.appendChild(renderer.domElement)
handleResize()

// renderer.toneMapping = THREE.ACESFilmicToneMapping
// renderer.toneMappingExposure = 2.5

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
const clock = new THREE.Clock()
let time = 0

/**
 * frame loop
 */
function tic() {
	/**
	 * tempo trascorso dal frame precedente
	 */
	const deltaTime = clock.getDelta()
	time += deltaTime
	/**
	 * tempo totale trascorso dall'inizio
	 */
	// const time = clock.getElapsedTime()
	material.uniforms.uTime.value = time

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
