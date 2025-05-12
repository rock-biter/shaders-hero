import './style.css'
import * as THREE from 'three'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/particles/vertex.glsl'
import fragmentShader from './shaders/particles/fragment.glsl'

/**
 * Debug
 */
const config = {
	size: 16,
	frequency: 0.15,
	amplitude: 1.5,
	speed: 0.1,
	colorA: new THREE.Color(0.0, 0.2, 0.95),
	colorB: new THREE.Color(0.2, 0.1, 0.9),
	depth: 3,
}
const pane = new Pane()

pane
	.addBinding(config, 'size', {
		min: 0,
		max: 50,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uSize.value = ev.value
	})

pane
	.addBinding(config, 'frequency', {
		min: 0.01,
		max: 5,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uFrequency.value = ev.value
	})

pane
	.addBinding(config, 'amplitude', {
		min: 0,
		max: 10,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uAmplitude.value = ev.value
	})

pane
	.addBinding(config, 'speed', {
		min: 0,
		max: 10,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uSpeed.value = ev.value
	})

pane.addBinding(config, 'colorA', {
	color: { type: 'float' },
})

pane.addBinding(config, 'colorB', {
	color: { type: 'float' },
})

pane
	.addBinding(config, 'depth', {
		min: 0,
		max: 10,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uDepth.value = ev.value
	})

/**
 * Scene
 */
const scene = new THREE.Scene()

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
camera.position.set(2, 1.3, 3)
// camera.lookAt(new THREE.Vector3(0, 2.5, 0))

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

const pointer = new THREE.Vector2(0, 0)

window.addEventListener('mousemove', (e) => {
	const x = (2 * e.clientX) / window.innerWidth - 1
	const y = -(2 * e.clientY) / window.innerHeight + 1

	const v = new THREE.Vector2(x, y)
	v.sub(pointer)

	material.uniforms.uVelocity.value += v.length()
	material.uniforms.uVelocity.value = Math.min(
		material.uniforms.uVelocity.value,
		1.5
	)

	pointer.set(x, y)
})

const material = new THREE.ShaderMaterial({
	vertexShader,
	fragmentShader,
	transparent: true,
	depthWrite: false,
	blending: THREE.AdditiveBlending,
	uniforms: {
		uResolution: { value: new THREE.Vector2(sizes.width, sizes.height) },
		uSize: { value: config.size },
		uFrequency: { value: config.frequency },
		uAmplitude: { value: config.amplitude },
		uTime: { value: 0 },
		uSpeed: { value: config.speed },
		uColorA: { value: config.colorA },
		uColorB: { value: config.colorB },
		uDepth: { value: config.depth },
		uPointer: { value: new THREE.Vector2(0, 0) },
		uVelocity: { value: 0 },
	},
})

const geometry = new THREE.BufferGeometry()
const side = 101
const position = new Float32Array(side * side * 3)

let k = 0

for (let i = 0; i < side; i++) {
	for (let j = 0; j < side; j++) {
		const x = i * 0.1 - side * 0.1 * 0.5
		const y = 0
		const z = j * 0.1 - side * 0.1 * 0.5

		const index = k * 3
		position[index + 0] = x
		position[index + 1] = y
		position[index + 2] = z

		k++
	}
}

geometry.setAttribute('position', new THREE.BufferAttribute(position, 3))
const particles = new THREE.Points(geometry, material)

scene.add(particles)

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
	material.uniforms.uTime.value = time
	material.uniforms.uPointer.value.lerp(pointer, deltaTime * 4)
	material.uniforms.uVelocity.value *= 1 - deltaTime * 1.5
	// console.log(material.uniforms.uVelocity.value)

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

	const pixelRatio = Math.min(window.devicePixelRatio, 2)
	renderer.setPixelRatio(pixelRatio)

	material.uniforms.uResolution.value.set(sizes.width, sizes.height)
}
