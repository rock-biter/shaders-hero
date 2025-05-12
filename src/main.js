import './style.css'
import * as THREE from 'three'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import particlesFragmentShader from './shaders/particles/fragment.glsl'
import particlesVertexShader from './shaders/particles/vertex.glsl'

const mouse = new THREE.Vector2()

window.addEventListener('mousemove', (event) => {
	const x = (event.clientX / window.innerWidth) * 2 - 1
	const y = -(event.clientY / window.innerHeight) * 2 + 1

	pointsMaterial.uniforms.uSpeed.value +=
		Math.sqrt(Math.pow(x - mouse.x, 2) + Math.pow(y - mouse.y, 2)) * 1.5

	pointsMaterial.uniforms.uSpeed.value = Math.min(
		pointsMaterial.uniforms.uSpeed.value,
		1.5
	)

	mouse.x = x
	mouse.y = y
})

/**
 * Debug
 */
const config = {
	particles: {
		size: 16,
	},
	perlin: {
		frequency: 0.15,
		amplitude: 1.5,
	},
}
const pane = new Pane()

pane
	.addBinding(config.perlin, 'frequency', {
		min: 0.01,
		max: 5,
		step: 0.01,
	})
	.on('change', () => {
		pointsMaterial.uniforms.uFrequency.value = config.perlin.frequency
	})

pane
	.addBinding(config.perlin, 'amplitude', {
		min: 0.01,
		max: 10,
		step: 0.01,
	})
	.on('change', () => {
		pointsMaterial.uniforms.uAmplitude.value = config.perlin.amplitude
	})

pane
	.addBinding(config.particles, 'size', {
		min: 0,
		max: 800,
		step: 0.1,
	})
	.on('change', () => {
		pointsMaterial.uniforms.uSize.value =
			config.particles.size * renderer.getPixelRatio()
	})

/**
 * Scene
 */
const scene = new THREE.Scene()
// scene.background = new THREE.Color(0xdedede)

/**
 * render sizes
 */
const sizes = {
	width: window.innerWidth,
	height: window.innerHeight,
}

const particlesGeom = new THREE.BufferGeometry()
const count = 351
const position = new Float32Array(count * count * 3)
const random = new Float32Array(count * count)

let k = 0
let size = 0.05

for (let i = 0; i < count; i++) {
	for (let j = 0; j < count; j++) {
		const index = k * 3
		const x = i * size - count * size * 0.5
		const y = 0
		const z = j * size - count * size * 0.5

		position[index + 0] = x
		position[index + 1] = y
		position[index + 2] = z

		random[index] = Math.random()

		k++
	}
}
particlesGeom.setAttribute('position', new THREE.BufferAttribute(position, 3))
particlesGeom.setAttribute('aRandom', new THREE.BufferAttribute(random, 1))

const pointsMaterial = new THREE.ShaderMaterial({
	vertexShader: particlesVertexShader,
	fragmentShader: particlesFragmentShader,
	transparent: true,
	depthWrite: false,
	blending: THREE.AdditiveBlending,
	uniforms: {
		uSize: {
			value: config.particles.size,
		},
		uResolution: {
			value: new THREE.Vector2(sizes.width, sizes.height),
		},
		uTime: {
			value: 0,
		},
		uFrequency: {
			value: config.perlin.frequency,
		},
		uAmplitude: {
			value: config.perlin.amplitude,
		},
		uMouse: {
			value: new THREE.Vector2(0, 0),
		},
		uSpeed: {
			value: 0.0,
		},
	},
})
particlesGeom.getAttribute('position').setUsage(THREE.DynamicDrawUsage)
const particles = new THREE.Points(particlesGeom, pointsMaterial)

scene.add(particles)

/**
 * Camera
 */
const fov = 60
const camera = new THREE.PerspectiveCamera(fov, sizes.width / sizes.height, 0.1)
camera.position.set(2, 1.3, 3)
camera.lookAt(new THREE.Vector3(0, 2.5, 0))

/**
 * Show the axes of coordinates system
 */
// __helper_axes__
// const axesHelper = new THREE.AxesHelper(3)
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
let time = 0.0

/**
 * frame loop
 */
function tic() {
	/**
	 * tempo trascorso dal frame precedente
	 */
	const deltaTime = clock.getDelta()
	/**
	 * tempo totale trascorso dall'inizio
	 */
	time += deltaTime

	pointsMaterial.uniforms.uTime.value = time
	pointsMaterial.uniforms.uMouse.value.lerp(mouse, deltaTime * 4)
	pointsMaterial.uniforms.uSpeed.value *= 1 - deltaTime * 1.5

	// console.log(pointsMaterial.uniforms.uSpeed.value)

	// __controls_update__
	controls.update(deltaTime)

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

	pointsMaterial.uniforms.uResolution.value.x = sizes.width
	pointsMaterial.uniforms.uResolution.value.y = sizes.height

	const pixelRatio = Math.min(window.devicePixelRatio, 2)
	renderer.setPixelRatio(pixelRatio)
}
