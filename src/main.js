import './style.css'
import * as THREE from 'three'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/card/vertex.glsl'
import fragmentShader from './shaders/card/fragment.glsl'

import fireVertexShader from './shaders/fire/vertex.glsl'
import fireFragmentShader from './shaders/fire/fragment.glsl'

import particlesVert from './shaders/particles/vertex.glsl'
import particlesFrag from './shaders/particles/fragment.glsl'

const loadingManager = new THREE.LoadingManager()
const textureLoader = new THREE.TextureLoader(loadingManager)

/**
 * Debug
 */
const config = {
	progress: 0.3,
	burn: {
		frequency: 1.09,
		amplitude: 1.3,
		alphaOffset: 0.02,
		alphaMargin: 0.05,
		burnColor: new THREE.Color(0.23, 0.0, 0.0),
		burnOffset: 0.5,
		burnMargin: 0.46,
		burnExp: 32,
		fireColor: new THREE.Color(1.0, 0.44, 0.19),
		fireOffset: 0.39,
		fireMargin: 0.52,
		fireScale: 4.78,
		fireExp: 1.6,
		fireMixExp: 7.4,
	},
	fire: {
		wireframe: false,
		frequency: 4.3,
		amplitude: 1.1,
		expAmplitude: 3,
		fallinOffset: 0.3,
		fallinMargin: 0.5,
		falloffOffset: -0.1,
		falloffMargin: 0.2,
		baseFrequency: 16,
		baseAmplitude: 0.25,
		baseStart: -0.1,
		baseEnd: 0.35,
		topFrequency: 30,
		topAmplitude: 0.1,
	},
}

const globalUniforms = {
	uProgress: { value: config.progress },
	uTime: { value: 0.0 },
}
const pane = new Pane()

pane
	.addBinding(config, 'progress', {
		min: 0,
		max: 1,
		step: 0.001,
	})
	.on('change', (ev) => {
		globalUniforms.uProgress.value = ev.value
	})

{
	const burn = pane.addFolder({
		title: 'Burn',
		expanded: false,
	})

	burn
		.addBinding(config.burn, 'frequency', {
			min: 0.01,
			max: 3,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uFrequency.value = ev.value
		})

	burn
		.addBinding(config.burn, 'amplitude', {
			min: 0,
			max: 2,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uAmplitude.value = ev.value
		})

	burn
		.addBinding(config.burn, 'alphaOffset', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uAlphaOffset.value = ev.value
		})
	burn
		.addBinding(config.burn, 'alphaMargin', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uAlphaMargin.value = ev.value
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
			cardMaterial.uniforms.uBurnOffset.value = ev.value
		})
	burn
		.addBinding(config.burn, 'burnMargin', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uBurnMargin.value = ev.value
		})

	burn
		.addBinding(config.burn, 'burnExp', {
			min: 0.0,
			max: 64,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uBurnExp.value = ev.value
		})

	burn.addBinding(config.burn, 'fireColor', {
		color: { type: 'float' },
	})

	burn
		.addBinding(config.burn, 'fireOffset', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uFireOffset.value = ev.value
		})

	burn
		.addBinding(config.burn, 'fireMargin', {
			min: -1.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uFireMargin.value = ev.value
		})

	burn
		.addBinding(config.burn, 'fireScale', {
			min: 0,
			max: 20,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uFireScale.value = ev.value
		})

	burn
		.addBinding(config.burn, 'fireExp', {
			min: 0,
			max: 10,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uFireExp.value = ev.value
		})

	burn
		.addBinding(config.burn, 'fireMixExp', {
			min: 0,
			max: 32,
			step: 0.01,
		})
		.on('change', (ev) => {
			cardMaterial.uniforms.uFireMixExp.value = ev.value
		})
}

{
	const fire = pane.addFolder({ title: 'Fire', expanded: false })

	fire.addBinding(config.fire, 'wireframe').on('change', (ev) => {
		fireMaterial.wireframe = ev.value
	})

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
		.addBinding(config.fire, 'expAmplitude', {
			min: 0,
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
			min: 0,
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
			min: 0,
			max: 1,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uFireFalloffMargin.value = ev.value
		})

	fire
		.addBinding(config.fire, 'baseFrequency', {
			min: 0,
			max: 50,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uBaseFrequency.value = ev.value
		})

	fire
		.addBinding(config.fire, 'baseAmplitude', {
			min: 0,
			max: 50,
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
			min: -1,
			max: 3,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uBaseEnd.value = ev.value
		})

	fire
		.addBinding(config.fire, 'topFrequency', {
			min: 0,
			max: 50,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uTopFrequency.value = ev.value
		})

	fire
		.addBinding(config.fire, 'topAmplitude', {
			min: 0,
			max: 50,
			step: 0.01,
		})
		.on('change', (ev) => {
			fireMaterial.uniforms.uTopAmplitude.value = ev.value
		})
}

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
const cardMaterial = new THREE.ShaderMaterial({
	vertexShader,
	fragmentShader,
	side: THREE.DoubleSide,
	transparent: true,
	uniforms: {
		...globalUniforms,
		uFrequency: { value: config.burn.frequency },
		uAmplitude: { value: config.burn.amplitude },
		uAlphaOffset: { value: config.burn.alphaOffset },
		uAlphaMargin: { value: config.burn.alphaMargin },
		uBurnColor: { value: config.burn.burnColor },
		uBurnOffset: { value: config.burn.burnOffset },
		uBurnMargin: { value: config.burn.burnMargin },
		uBurnExp: { value: config.burn.burnExp },
		uFireColor: { value: config.burn.fireColor },
		uFireOffset: { value: config.burn.fireOffset },
		uFireMargin: { value: config.burn.fireMargin },
		uFireScale: { value: config.burn.fireScale },
		uFireExp: { value: config.burn.fireExp },
		uFireMixExp: { value: config.burn.fireMixExp },
	},
})

const fireMaterial = new THREE.ShaderMaterial({
	fragmentShader: fireFragmentShader,
	vertexShader: fireVertexShader,
	side: THREE.DoubleSide,
	transparent: true,
	depthWrite: false,
	blending: THREE.AdditiveBlending,
	wireframe: config.fire.wireframe,
	uniforms: {
		...globalUniforms,
		uFireColor: cardMaterial.uniforms.uFireColor,
		uFireScale: cardMaterial.uniforms.uFireScale,
		uAmplitude: cardMaterial.uniforms.uBurnColor,
		uFrequency: cardMaterial.uniforms.uFrequency,
		uAmplitude: cardMaterial.uniforms.uAmplitude,
		uFireFrequency: {
			value: config.fire.frequency,
		},
		uFireAmplitude: {
			value: config.fire.amplitude,
		},
		uFireExpAmplitude: {
			value: config.fire.expAmplitude,
		},
		uFireFallinOffset: { value: config.fire.fallinOffset },
		uFireFallinMargin: { value: config.fire.fallinMargin },
		uFireFalloffOffset: { value: config.fire.falloffOffset },
		uFireFalloffMargin: { value: config.fire.falloffMargin },
		uBaseFrequency: {
			value: config.fire.baseFrequency,
		},
		uBaseAmplitude: {
			value: config.fire.baseAmplitude,
		},
		uBaseStart: { value: config.fire.baseStart },
		uBaseEnd: { value: config.fire.baseEnd },
		uTopFrequency: {
			value: config.fire.topFrequency,
		},
		uTopAmplitude: {
			value: config.fire.topAmplitude,
		},
		uVelocity: {
			value: new THREE.Vector2(0),
		},
	},
})

// plane
const frontMap = textureLoader.load('/textures/charizard.png')
const backMap = textureLoader.load('/textures/backside.png')

loadingManager.onLoad = () => {
	cardMaterial.uniforms.uMap = {
		value: frontMap,
	}

	cardMaterial.uniforms.uBacksideMap = {
		value: backMap,
	}

	const aspect = frontMap.image.naturalWidth / frontMap.image.naturalHeight

	const cardGeometry = new THREE.PlaneGeometry(2, 2 / aspect)
	const card = new THREE.Mesh(cardGeometry, cardMaterial)

	const fireGeometry = new THREE.PlaneGeometry(2, 2 / aspect, 250, 400)
	const fire = new THREE.Mesh(fireGeometry, fireMaterial)
	fire.position.z = 0.001
	scene.add(card, fire)
}

/**
 * Camera
 */
const fov = 60
const camera = new THREE.PerspectiveCamera(fov, sizes.width / sizes.height, 0.1)
camera.position.set(1.7, -1.1, 2.8)
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

window.addEventListener('mousemove', (e) => {
	if (!isMoving) return
	pointer.x = 2 * (e.clientX / window.innerWidth) - 1
	pointer.y = -2 * (e.clientY / window.innerHeight) + 1
})

window.addEventListener('mousedown', (e) => {
	isMoving = true
	pointer.x = 2 * (e.clientX / window.innerWidth) - 1
	pointer.y = -2 * (e.clientY / window.innerHeight) + 1
	prevPointer.copy(pointer)
})

window.addEventListener('mouseup', () => {
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

	prevPointer.lerp(pointer, deltaTime * 5)
	const v = pointer.clone().sub(prevPointer)
	velocity.lerp(v, deltaTime * 2)

	// console.log(velocity.x)

	fireMaterial.uniforms.uVelocity.value = velocity
	globalUniforms.uTime.value = time

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
