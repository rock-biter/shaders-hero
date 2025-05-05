import './style.css'
import * as THREE from 'three'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/base/vertex.glsl'
import fragmentShader from './shaders/base/fragment.glsl'

import fireVertex from './shaders/fire/vertex.glsl'
import fireFragment from './shaders/fire/fragment.glsl'

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
		progress: 0.3,
		frequency: 1.09,
		amplitude: 1.3,
		alphaOffset: 0.02,
		alphaMargin: 0.05,
		burnOffset: 0.5,
		burnMargin: 0.46,
		fireOffset: 0.39,
		fireMargin: 0.52,
		burnColor: new THREE.Color(0.23, 0.0, 0.0),
		burnMixExp: 32,
		fireColor: new THREE.Color(1.0, 0.44, 0.19),
		fireExp: 1.6,
		fireScale: 4.78,
		fireMixExp: 7.4,
	},
	fire: {
		frequency: 4.3,
		amplitude: 1.1,
		exp: 3,
		fallinOffset: 0.3,
		fallinMargin: 0.5,
		falloffOffset: -0.1,
		falloffMargin: 0.2,
		baseFrequency: 16,
		baseAmplitude: 0.22,
		baseStart: -0.1,
		baseEnd: 0.15,
		topFrequency: 30,
		topAmplitude: 0.1,
	},
	wireframe: false,
}
const pane = new Pane()

pane.addBinding(config, 'wireframe').on('change', (ev) => {
	fireMaterial.wireframe = ev.value
})

// Burn
{
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
			max: 3,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uFrequency.value = ev.value
		})

	burn
		.addBinding(config.burn, 'amplitude', {
			min: 0.1,
			max: 2,
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
		.addBinding(config.burn, 'fireOffset', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uFireOffset.value = ev.value
		})

	burn
		.addBinding(config.burn, 'fireMargin', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uFireMargin.value = ev.value
		})

	burn.addBinding(config.burn, 'burnColor', {
		color: { type: 'float' },
	})

	burn
		.addBinding(config.burn, 'burnOffset', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uBurnOffset.value = ev.value
		})

	burn
		.addBinding(config.burn, 'burnMargin', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uBurnMargin.value = ev.value
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
		.addBinding(config.burn, 'alphaOffset', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uAlphaOffset.value = ev.value
		})
	burn
		.addBinding(config.burn, 'alphaMargin', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uAlphaMargin.value = ev.value
		})
}

// Fire
{
	const fire = pane.addFolder({ title: 'Fire' })

	fire
		.addBinding(config.fire, 'frequency', {
			min: 0.01,
			max: 10,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uFireFrequency.value = ev.value
		})

	fire
		.addBinding(config.fire, 'amplitude', {
			min: 0,
			max: 3,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uFireAmplitude.value = ev.value
		})

	fire
		.addBinding(config.fire, 'exp', {
			min: 0.01,
			max: 10,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uFireExpAmplitude.value = ev.value
		})

	fire
		.addBinding(config.fire, 'fallinOffset', {
			min: -1,
			max: 1,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uFireFallinOffset.value = ev.value
		})

	fire
		.addBinding(config.fire, 'fallinMargin', {
			min: -1,
			max: 1,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uFireFallinMargin.value = ev.value
		})

	fire
		.addBinding(config.fire, 'falloffOffset', {
			min: -1,
			max: 1,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uFireFalloffOffset.value = ev.value
		})

	fire
		.addBinding(config.fire, 'falloffMargin', {
			min: -1,
			max: 1,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uFireFalloffMargin.value = ev.value
		})

	fire
		.addBinding(config.fire, 'baseFrequency', {
			min: 0.01,
			max: 50,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uBaseFrequency.value = ev.value
		})

	fire
		.addBinding(config.fire, 'baseAmplitude', {
			min: 0,
			max: 2,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uBaseAmplitude.value = ev.value
		})

	fire
		.addBinding(config.fire, 'baseStart', {
			min: -1,
			max: 1,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uBaseStart.value = ev.value
		})

	fire
		.addBinding(config.fire, 'baseEnd', {
			min: -1.0,
			max: 1,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uBaseEnd.value = ev.value
		})

	fire
		.addBinding(config.fire, 'topFrequency', {
			min: 0.01,
			max: 50,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uTopFrequency.value = ev.value
		})

	fire
		.addBinding(config.fire, 'topAmplitude', {
			min: 0,
			max: 10,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uTopAmplitude.value = ev.value
		})
}

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
		uAlphaOffset: { value: config.burn.alphaOffset },
		uAlphaMargin: { value: config.burn.alphaMargin },
		uBurnOffset: { value: config.burn.burnOffset },
		uBurnMargin: { value: config.burn.burnMargin },
		uFireOffset: { value: config.burn.fireOffset },
		uFireMargin: { value: config.burn.fireMargin },
		uBurnColor: { value: config.burn.burnColor },
		uBurnMixExp: { value: config.burn.burnMixExp },
		uFireColor: { value: config.burn.fireColor },
		uFireExp: { value: config.burn.fireExp },
		uFireScale: { value: config.burn.fireScale },
		uFireMixExp: { value: config.burn.fireMixExp },
		uFireFrequency: { value: config.fire.frequency },
		uFireExpAmplitude: { value: config.fire.exp },
		uPointerVelocity: { value: new THREE.Vector2(0, 0) },
	},
})

const fireMaterial = new THREE.ShaderMaterial({
	fragmentShader: fireFragment,
	vertexShader: fireVertex,
	transparent: true,
	side: THREE.DoubleSide,
	uniforms: {
		...material.uniforms,
		uFireAmplitude: { value: config.fire.amplitude },
		uFireFallinOffset: {
			value: config.fire.fallinOffset,
		},
		uFireFallinMargin: {
			value: config.fire.fallinMargin,
		},
		uFireFalloffOffset: {
			value: config.fire.falloffOffset,
		},
		uFireFalloffMargin: {
			value: config.fire.falloffMargin,
		},
		uBaseFrequency: {
			value: config.fire.baseFrequency,
		},
		uBaseAmplitude: {
			value: config.fire.baseAmplitude,
		},
		uBaseStart: {
			value: config.fire.baseStart,
		},
		uBaseEnd: {
			value: config.fire.baseEnd,
		},
		uTopFrequency: {
			value: config.fire.topFrequency,
		},
		uTopAmplitude: {
			value: config.fire.topAmplitude,
		},
	},
	wireframe: config.wireframe,
	// depthTest: false,
	depthWrite: false,
	depthTest: true,
	blending: THREE.AdditiveBlending,
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

	const fireGeom = new THREE.PlaneGeometry(2, 2 / aspect, 150, 300)
	const fire = new THREE.Mesh(fireGeom, fireMaterial)
	fire.position.z = 0.01

	// fire.renderOrder = 2

	/**
	 * add particles
	 * https://tympanus.net/codrops/2025/02/17/implementing-a-dissolve-effect-with-shaders-and-particles-in-three-js/
	 */

	// scene.add(plane, fire)
	scene.add(plane, fire)
})

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
let time = 0

const pointer = new THREE.Vector2()
const prevPointer = new THREE.Vector2()
const velocity = new THREE.Vector2()
let isMoving = false

window.addEventListener('mousemove', (ev) => {
	if (!isMoving) return
	pointer.x = (ev.clientX / sizes.width) * 2 - 1
	pointer.y = -(ev.clientY / sizes.height) * 2 + 1
})

window.addEventListener('mousedown', (ev) => {
	isMoving = true
	pointer.x = (ev.clientX / sizes.width) * 2 - 1
	pointer.y = -(ev.clientY / sizes.height) * 2 + 1
	prevPointer.copy(pointer)
})

window.addEventListener('mouseup', (ev) => {
	isMoving = false
})

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

	// const posAttr = particlesGeom.getAttribute('position')

	// for (let i = 0; i < posAttr.count; i++) {
	// 	const x = posAttr.getX(i)
	// 	const z = posAttr.getZ(i)
	// 	const y = Math.sin(x + time) * 0.5 + Math.cos(z + time) * 0.5
	// 	posAttr.setY(i, y)
	// }
	prevPointer.lerp(pointer, deltaTime * 3)
	velocity.copy(pointer).sub(prevPointer)

	// posAttr.needsUpdate = true

	material.uniforms.uTime.value = time
	fireMaterial.uniforms.uPointerVelocity.value = velocity

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
