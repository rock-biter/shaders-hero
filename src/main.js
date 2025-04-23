import './style.css'
import * as THREE from 'three'
// __controls_import__
// __gui_import__

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/base/vertex.glsl'
import fragmentShader from './shaders/base/fragment.glsl'
import { step } from 'three/tsl'

/**
 * Debug
 */
// __gui__
const config = {
	ambientLight: {
		color: new THREE.Color(0xffffff),
		intensity: 0.2,
	},
	hemiLight: {
		skyColor: new THREE.Color(0.55, 0.79, 1.0),
		groundColor: new THREE.Color(0.2, 0.35, 0.0),
		intensity: 0.3,
	},
	dirLight: {
		color: new THREE.Color(1.0, 0.3, 0.2),
		intensity: 0.9,
		direction: new THREE.Vector3(2, 2, 2),
	},
	glossiness: 24,
}
const pane = new Pane()

// Ambient Light
{
	const ambientLight = pane.addFolder({
		title: 'Ambient Light',
		expanded: false,
	})

	ambientLight.addBinding(config.ambientLight, 'color', {
		color: { type: 'float' },
	})

	ambientLight
		.addBinding(config.ambientLight, 'intensity', {
			min: 0.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uAmbientLight.value.intensity = ev.value
		})
}

// Hemi Light
{
	const hemiLight = pane.addFolder({
		title: 'Hemi Light',
		expanded: false,
	})

	hemiLight.addBinding(config.hemiLight, 'skyColor', {
		color: { type: 'float' },
	})

	hemiLight.addBinding(config.hemiLight, 'groundColor', {
		color: { type: 'float' },
	})

	hemiLight
		.addBinding(config.hemiLight, 'intensity', {
			min: 0.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uHemiLight.value.intensity = ev.value
		})
}

// Directional Light
{
	const directionalLight = pane.addFolder({
		title: 'Directional Light',
		expanded: true,
	})

	directionalLight.addBinding(config.dirLight, 'color', {
		color: { type: 'float' },
	})

	directionalLight
		.addBinding(config.dirLight, 'intensity', {
			min: 0.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uDirLight.value.intensity = ev.value
		})

	directionalLight
		.addBinding(config.dirLight, 'direction', {
			x: { min: -4, max: 4, step: 0.01 },
			y: { min: -4, max: 4, step: 0.01 },
			z: { min: -4, max: 4, step: 0.01 },
		})
		.on('change', (ev) => {
			material.uniforms.uDirLight.value.direction = ev.value
			dirLight.position.copy(ev.value)
		})
}

pane
	.addBinding(config, 'glossiness', {
		min: 1,
		max: 64,
		step: 0.1,
	})
	.on('change', (ev) => {
		material.uniforms.uGlossiness.value = ev.value
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
	uniforms: {
		uGlossiness: {
			value: config.glossiness,
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
				intensity: config.hemiLight.intensity,
			},
		},
		uDirLight: {
			value: {
				color: config.dirLight.color,
				intensity: config.dirLight.intensity,
				direction: config.dirLight.direction,
			},
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
box.position.x = -3

scene.add(box, ico, torus)

const dirLight = new THREE.Mesh(
	new THREE.SphereGeometry(0.1, 4, 4),
	new THREE.MeshBasicMaterial({ color: config.dirLight.color })
)
dirLight.position.copy(config.dirLight.direction)

scene.add(dirLight)

// background della scena
scene.background = new THREE.Color(0x555555)

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
camera.position.set(3, 2, 6)
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

	ico.rotation.x += 0.01

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
