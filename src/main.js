import './style.css'
import * as THREE from 'three'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/base/vertex.glsl'
import fragmentShader from './shaders/base/fragment.glsl'

import fireVertex from './shaders/fire/vertex.glsl'
import fireFragment from './shaders/fire/fragment.glsl'

import particlesFragmentShader from './shaders/particles/fragment.glsl'
import particlesVertexShader from './shaders/particles/vertex.glsl'
import { step } from 'three/tsl'

const textureLoader = new THREE.TextureLoader()
const perlin = textureLoader.load('/textures/perlin-rgba.png')
perlin.wrapS = THREE.RepeatWrapping
perlin.wrapT = THREE.RepeatWrapping

/**
 * Debug
 */
const config = {
	particles: {
		size: 500,
	},
	burn: {
		progress: 0.5,
		frequency: 1.09,
		amplitude: 1.3,
		offset1: 0.02,
		smooth1: 0.05,
		offset2: 0.59,
		smooth2: 0.46,
		offset3: 0.54,
		smooth3: 0.52,
		burnColor: new THREE.Color(0.23, 0.0, 0.0),
		burnMixExp: 32,
		fireColor: new THREE.Color(1.0, 0.44, 0.19),
		fireExp: 1.6,
		fireScale: 4.78,
		fireMixExp: 7.4,
	},
}
const pane = new Pane()

const burn = pane.addFolder({ title: 'Burn' })

burn
	.addBinding(config.burn, 'progress', {
		min: 0,
		max: 1,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uProgress.value = ev.value
	})

burn
	.addBinding(config.burn, 'frequency', {
		min: 0.01,
		max: 2,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uFrequency.value = ev.value
	})

burn
	.addBinding(config.burn, 'amplitude', {
		min: 0.1,
		max: 20,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uAmplitude.value = ev.value
	})

burn.addBinding(config.burn, 'fireColor', {
	color: { type: 'float' },
})

burn
	.addBinding(config.burn, 'fireScale', {
		min: 0,
		max: 20,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uFireScale.value = ev.value
	})

burn
	.addBinding(config.burn, 'fireExp', {
		min: 1,
		max: 10,
		step: 0.1,
	})
	.on('change', (ev) => {
		material.uniforms.uFireExp.value = ev.value
	})

burn
	.addBinding(config.burn, 'fireMixExp', {
		min: 1,
		max: 32,
		step: 0.1,
	})
	.on('change', (ev) => {
		material.uniforms.uFireMixExp.value = ev.value
	})

burn
	.addBinding(config.burn, 'offset3', {
		min: -1.0,
		max: 1.0,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uOffset3.value = ev.value
	})

burn
	.addBinding(config.burn, 'smooth3', {
		min: -1.0,
		max: 1.0,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uSmooth3.value = ev.value
	})

burn.addBinding(config.burn, 'burnColor', {
	color: { type: 'float' },
})

burn
	.addBinding(config.burn, 'offset2', {
		min: -1.0,
		max: 1.0,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uOffset2.value = ev.value
	})

burn
	.addBinding(config.burn, 'smooth2', {
		min: -1.0,
		max: 1.0,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uSmooth2.value = ev.value
	})

burn
	.addBinding(config.burn, 'burnMixExp', {
		min: 1,
		max: 32,
		step: 0.1,
	})
	.on('change', (ev) => {
		material.uniforms.uBurnMixExp.value = ev.value
	})

burn
	.addBinding(config.burn, 'offset1', {
		min: -1.0,
		max: 1.0,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uOffset1.value = ev.value
	})

// pane.addBinding(config.ambientLight, 'color', {
// 	color: { type: 'float' },
// })

/**
 * Scene
 */
const scene = new THREE.Scene()
scene.background = new THREE.Color(0x100202)

/**
 * render sizes
 */
const sizes = {
	width: window.innerWidth,
	height: window.innerHeight,
}

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
	transparent: true,
	side: THREE.DoubleSide,
	depthWrite: false,
	// wireframe: true,
	uniforms: {
		uTime: {
			value: 0,
		},
		uProgress: {
			value: config.burn.progress,
		},
		uAmplitude: {
			value: config.burn.amplitude,
		},
		uFrequency: {
			value: config.burn.frequency,
		},
		uOffset1: { value: config.burn.offset1 },
		uSmooth1: { value: config.burn.smooth1 },
		uOffset2: { value: config.burn.offset2 },
		uSmooth2: { value: config.burn.smooth2 },
		uOffset3: { value: config.burn.offset3 },
		uSmooth3: { value: config.burn.smooth3 },
		uBurnColor: { value: config.burn.burnColor },
		uBurnMixExp: { value: config.burn.burnMixExp },
		uFireColor: { value: config.burn.fireColor },
		uFireExp: { value: config.burn.fireExp },
		uFireScale: { value: config.burn.fireScale },
		uFireMixExp: { value: config.burn.fireMixExp },
	},
})

const backsideMap = textureLoader.load('/textures/backside.png')
const cardMap = textureLoader.load('/textures/charizard.png', () => {
	const aspect = cardMap.image.naturalWidth / cardMap.image.naturalHeight

	const planeGeom = new THREE.PlaneGeometry(2, 2 / aspect)
	// planeGeom.rotateX(-Math.PI / 2)
	material.uniforms.uMap = {
		value: cardMap,
	}
	material.uniforms.uBacksideMap = {
		value: backsideMap,
	}

	const plane = new THREE.Mesh(planeGeom, material)
	// plane.position.y = -2
	const fireMaterial = new THREE.ShaderMaterial({
		fragmentShader: fireFragment,
		vertexShader: fireVertex,
		transparent: true,
		side: THREE.DoubleSide,
		uniforms: material.uniforms,
		// wireframe: true,
		// depthTest: false,
		depthWrite: false,
		depthTest: true,
		blending: THREE.AdditiveBlending,
	})
	const fireGeom = new THREE.PlaneGeometry(2.3, 2.3 / aspect, 100, 200)
	const fire = new THREE.Mesh(fireGeom, fireMaterial)
	fire.position.z = 0.01

	// fire.renderOrder = 2

	scene.add(plane, fire)
})

// const boxGeometry = new THREE.BoxGeometry(1, 1, 1, 5, 5, 5)
// const icoGeometry = new THREE.IcosahedronGeometry(1, 2)
// const torusGeometry = new THREE.TorusGeometry(0.5, 0.3, 16, 100)
// const box = new THREE.Mesh(boxGeometry, material)
// const ico = new THREE.Mesh(icoGeometry, material)
// const torus = new THREE.Mesh(torusGeometry, material)
// torus.rotation.x = -Math.PI * 0.2
// torus.position.x = 3
// box.position.x = -3
// box.rotation.y = 0.2

// scene.add(box)
const particlesGeom = new THREE.BufferGeometry()
const count = 10000
const position = new Float32Array(count * 3)
const color = new Float32Array(count * 3)
const random = new Float32Array(count)

for (let i = 0; i < count; i++) {
	const index = i * 3
	const dir = new THREE.Vector3().randomDirection()
	const { x, y, z } = dir

	position[index + 0] = x * (Math.random() * 10 + 10)
	position[index + 1] = y * (Math.random() * 10 + 10)
	position[index + 2] = z * (Math.random() * 10 + 10)
	color[index + 0] = Math.random()
	color[index + 1] = Math.random()
	color[index + 2] = Math.random()

	random[index] = Math.random()
}
particlesGeom.setAttribute('position', new THREE.BufferAttribute(position, 3))
particlesGeom.setAttribute('color', new THREE.BufferAttribute(color, 3))
particlesGeom.setAttribute('aRandom', new THREE.BufferAttribute(random, 1))

const particleShape = textureLoader.load('/textures/particles/star.png')

// const pointsMaterial = new PointsMaterial({
// 	size: 0.5,
// 	map: particleShape,
// 	// color: new THREE.Color('orange'),
// 	transparent: true,
// 	depthWrite: false,
// 	blending: THREE.AdditiveBlending,
// 	vertexColors: true,
// })
const pointsMaterial = new THREE.ShaderMaterial({
	vertexShader: particlesVertexShader,
	fragmentShader: particlesFragmentShader,
	transparent: true,
	depthWrite: false,
	blending: THREE.AdditiveBlending,
	uniforms: {
		uMap: {
			value: particleShape,
		},
		uSize: {
			value: config.particles.size,
		},
		uResolution: {
			value: new THREE.Vector2(sizes.width, sizes.height),
		},
		uTime: {
			value: 0,
		},
	},
})
particlesGeom.getAttribute('position').setUsage(THREE.DynamicDrawUsage)
const particles = new THREE.Points(particlesGeom, pointsMaterial)

// scene.add(particles)

// const debugMesh = new THREE.Mesh(
// 	boxGeometry,
// 	new THREE.MeshBasicMaterial({ color: 0xffffff, envMap: envMap })
// )

// debugMesh.position.x = -5

// scene.add(debugMesh)

/**
 * Camera
 */
const fov = 60
const camera = new THREE.PerspectiveCamera(fov, sizes.width / sizes.height, 0.1)
camera.position.set(1, 2, 4)
camera.lookAt(new THREE.Vector3(0, 2.5, 0))

/**
 * Show the axes of coordinates system
 */
// __helper_axes__
const axesHelper = new THREE.AxesHelper(3)
// scene.add(axesHelper)

// scene.background = new THREE.Color(0x000022)

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

	// const posAttr = particlesGeom.getAttribute('position')

	// for (let i = 0; i < posAttr.count; i++) {
	// 	const x = posAttr.getX(i)
	// 	const z = posAttr.getZ(i)
	// 	const y = Math.sin(x + time) * 0.5 + Math.cos(z + time) * 0.5
	// 	posAttr.setY(i, y)
	// }

	// posAttr.needsUpdate = true

	pointsMaterial.uniforms.uTime.value = time
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

	pointsMaterial.uniforms.uResolution.value.x = sizes.width
	pointsMaterial.uniforms.uResolution.value.y = sizes.height

	const pixelRatio = Math.min(window.devicePixelRatio, 2)
	renderer.setPixelRatio(pixelRatio)
}
