import './style.css'
import * as THREE from 'three'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/base/vertex.glsl'
import fragmentShader from './shaders/base/fragment.glsl'
import { color, min, step } from 'three/tsl'
import { IcosahedronGeometry, MeshBasicMaterial } from 'three/webgpu'

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
	glossiness: 22,
	toon: 3,
}
const pane = new Pane()

// pane.addBinding(config.ambientLight, 'color', {
// 	color: { type: 'float' },
// })

/**
 * Scene
 */
const scene = new THREE.Scene()
// scene.background = new THREE.Color(0xdedede)

const cubeTextureLoader = new THREE.CubeTextureLoader()
const envMap = cubeTextureLoader.load([
	'/env/01/px.png',
	'/env/01/nx.png',
	'/env/01/py.png',
	'/env/01/ny.png',
	'/env/01/pz.png',
	'/env/01/nz.png',
])

// scene.background = envMap

/**
 * BOX
 */
// const material = new THREE.MeshNormalMaterial()
const material = new THREE.ShaderMaterial({
	vertexShader,
	fragmentShader,
	wireframe: true,
	defines: {
		// TOON: config.toon,
	},
	uniforms: {
		uTime: {
			value: 0,
		},
	},
})
const boxGeometry = new THREE.BoxGeometry(1.3, 1.3, 1.3)
const icoGeometry = new THREE.IcosahedronGeometry(1)
const torusGeometry = new THREE.TorusGeometry(0.5, 0.3, 16, 100)
const box = new THREE.Mesh(boxGeometry, material)
const ico = new THREE.Mesh(icoGeometry, material)
const torus = new THREE.Mesh(torusGeometry, material)
torus.position.x = 3
// box.position.x = -3
// box.rotation.y = 0.2

// scene.add(box)

const planeGeom = new THREE.PlaneGeometry(1, 1, 10, 10)
// planeGeom.rotateX(-Math.PI / 2)
const plane = new THREE.Mesh(planeGeom, material)
// plane.position.y = -2
scene.add(plane)

const debugMesh = new THREE.Mesh(
	boxGeometry,
	new MeshBasicMaterial({ color: 0xffffff, envMap: envMap })
)

debugMesh.position.x = -5

// scene.add(debugMesh)

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
camera.position.set(0.5, 0.5, 1.5)
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
const clock = new THREE.Clock()

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
	const time = clock.getElapsedTime()

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
