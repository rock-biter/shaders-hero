import './style.css'
import * as THREE from 'three'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/base/vertex.glsl'
import fragmentShader from './shaders/base/fragment.glsl'
import {
	IcosahedronGeometry,
	MeshBasicMaterial,
	PointsMaterial,
} from 'three/webgpu'

const textureLoader = new THREE.TextureLoader()
const perlin = textureLoader.load('/textures/perlin-rgba.png')
perlin.wrapS = THREE.RepeatWrapping
perlin.wrapT = THREE.RepeatWrapping

/**
 * Debug
 */
const config = {
	noise: {
		amplitude: 0.2,
		frequency: 0.25,
		octaves: 5,
	},
	curl: {
		intensity: 1,
		steps: 0,
	},
}
const pane = new Pane()

pane
	.addBinding(config.noise, 'amplitude', {
		min: 0,
		max: 1,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uAmplitude.value = ev.value
	})

pane
	.addBinding(config.noise, 'frequency', {
		min: 0.005,
		max: 2,
		step: 0.005,
	})
	.on('change', (ev) => {
		material.uniforms.uFrequency.value = ev.value
	})

pane
	.addBinding(config.noise, 'octaves', {
		min: 1,
		max: 10,
		step: 1,
	})
	.on('change', (ev) => {
		material.uniforms.uOctaves.value = ev.value
	})

pane
	.addBinding(config.curl, 'intensity', {
		min: 0,
		max: 1,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uCurlIntensity.value = ev.value
	})

pane
	.addBinding(config.curl, 'steps', {
		min: 0,
		max: 30,
		step: 1,
	})
	.on('change', (ev) => {
		material.uniforms.uCurlSteps.value = ev.value
	})

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
	// wireframe: true,
	uniforms: {
		// uMap: {
		// 	value: map,
		// },
		uNoise: {
			value: perlin,
		},
		uCurlIntensity: {
			value: config.curl.intensity,
		},
		uCurlSteps: {
			value: config.curl.steps,
		},
		uTime: {
			value: 0,
		},
		uAmplitude: {
			value: config.noise.amplitude,
		},
		uFrequency: {
			value: config.noise.frequency,
		},
		uOctaves: {
			value: config.noise.octaves,
		},
	},
})
const boxGeometry = new THREE.BoxGeometry(1, 1, 1, 5, 5, 5)
const icoGeometry = new THREE.IcosahedronGeometry(1, 2)
const torusGeometry = new THREE.TorusGeometry(0.5, 0.3, 16, 100)
const box = new THREE.Mesh(boxGeometry, material)
const ico = new THREE.Mesh(icoGeometry, material)
const torus = new THREE.Mesh(torusGeometry, material)
torus.rotation.x = -Math.PI * 0.2
// torus.position.x = 3
// box.position.x = -3
// box.rotation.y = 0.2

// scene.add(box)
const particlesGeom = new THREE.BufferGeometry()
const count = 1000
const position = new Float32Array(count * 3)
const color = new Float32Array(count * 3)
for (let i = 0; i < count * 3; i++) {
	position[i] = (Math.random() - 0.5) * 2
	color[i] = Math.random()
}
particlesGeom.setAttribute('position', new THREE.BufferAttribute(position, 3))
particlesGeom.setAttribute('color', new THREE.BufferAttribute(color, 3))

const particleShape = textureLoader.load('/textures/particles/star.png')

const pointsMaterial = new PointsMaterial({
	size: 0.5,
	map: particleShape,
	// color: new THREE.Color('orange'),
	transparent: true,
	depthWrite: false,
	blending: THREE.AdditiveBlending,
	vertexColors: true,
})
const particles = new THREE.Points(particlesGeom, pointsMaterial)

const planeGeom = new THREE.PlaneGeometry(2, 2, 50, 50)
// planeGeom.rotateX(-Math.PI / 2)
const plane = new THREE.Mesh(planeGeom, material)
// plane.position.y = -2
scene.add(particles)

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
camera.position.set(2, 1, 2.4)
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
