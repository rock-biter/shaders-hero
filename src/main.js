import './style.css'
import * as THREE from 'three'
// __controls_import__
// __gui_import__

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/particles/vertex.glsl'
import fragmentShader from './shaders/particles/fragment.glsl'

const textureLoader = new THREE.TextureLoader()

/**
 * Debug
 */
// __gui__
const config = {
	size: 200,
}
const pane = new Pane()

pane
	.addBinding(config, 'size', {
		min: 0,
		max: 1000,
		step: 0.01,
	})
	.on('change', (ev) => {
		particlesMaterial.uniforms.uSize.value = ev.value * renderer.getPixelRatio()
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

// background della scena
scene.background = new THREE.Color(0x222222)

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
camera.position.set(8, 8, 8)
camera.lookAt(new THREE.Vector3(2, 2.5, 0))

/**
 * Show the axes of coordinates system
 */
// __helper_axes__
const axesHelper = new THREE.AxesHelper(3)
scene.add(axesHelper)

/**
 * renderer
 */
const renderer = new THREE.WebGLRenderer({
	antialias: window.devicePixelRatio < 2,
})
document.body.appendChild(renderer.domElement)

// renderer.toneMapping = THREE.ACESFilmicToneMapping
// renderer.toneMappingExposure = 2.5

// const material = new THREE.MeshNormalMaterial()
const map = textureLoader.load('/particles/star.png')
// map.flipY = true
// map.wrapS = THREE.RepeatWrapping
// map.wrapT = THREE.RepeatWrapping
const material = new THREE.PointsMaterial({
	size: 2,
	// color: new THREE.Color('orange'),
	map: map,
	transparent: true,
	depthWrite: false,
	blending: THREE.AdditiveBlending,
	vertexColors: true,
	// sizeAttenuation: false,
})

const particlesMaterial = new THREE.ShaderMaterial({
	vertexShader,
	fragmentShader,
	transparent: true,
	uniforms: {
		uMap: { value: map },
		uSize: { value: config.size * renderer.getPixelRatio() },
		uResolution: { value: new THREE.Vector2(sizes.width, sizes.height) },
		uTime: { value: 0 },
	},
	depthWrite: false,
	blending: THREE.AdditiveBlending,
})
const boxGeometry = new THREE.BoxGeometry(10, 10, 10, 5, 5, 5)
const sphereGeometry = new THREE.SphereGeometry(5, 12, 24)
const particlesGeometry = new THREE.BufferGeometry()
const count = 100000
const position = new Float32Array(count * 3)
const color = new Float32Array(count * 3)
const random = new Float32Array(count)
for (let i = 0; i < count; i++) {
	const index = i * 3

	position[index + 0] = (Math.random() * 2 - 1) * 10
	position[index + 1] = 0
	position[index + 2] = (Math.random() * 2 - 1) * 10
	color[index + 0] = Math.random()
	color[index + 1] = Math.random()
	color[index + 2] = Math.random()

	random[index] = Math.random()
}

const posAttribute = new THREE.BufferAttribute(position, 3)
particlesGeometry.setAttribute('position', posAttribute)
// posAttribute.setUsage(THREE.DynamicDrawUsage)

const colorAttribute = new THREE.BufferAttribute(color, 3)
particlesGeometry.setAttribute('color', colorAttribute)

const randomAttribute = new THREE.BufferAttribute(random, 1)
particlesGeometry.setAttribute('aRandom', randomAttribute)

const box = new THREE.Points(particlesGeometry, particlesMaterial)

scene.add(box)

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

	particlesMaterial.uniforms.uTime.value = time
	/**
	 * tempo totale trascorso dall'inizio
	 */
	// const time = clock.getElapsedTime()
	// for (let i = 0; i < posAttribute.count; i++) {
	// 	const x = posAttribute.getX(i)
	// 	const z = posAttribute.getZ(i)
	// 	const y = Math.sin(z + time) * 0.5 + Math.cos(x + time) * 0.5
	// 	posAttribute.setY(i, y)
	// }

	// posAttribute.needsUpdate = true

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
	particlesMaterial.uniforms.uResolution.value.set(sizes.width, sizes.height)

	renderer.setSize(sizes.width, sizes.height)

	const pixelRatio = Math.min(window.devicePixelRatio, 2)
	renderer.setPixelRatio(pixelRatio)
}
