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
		intensity: 0.2,
	},
	dirLight: {
		color: new THREE.Color(1.0, 0.3, 0.2),
		intensity: 0.8,
		direction: new THREE.Vector3(2, 2, 2),
	},
	pointLight: {
		color: new THREE.Color(0.25, 0.25, 1.0),
		intensity: 1,
		position: new THREE.Vector3(-2, 1.5, 1.5),
		maxDistance: 20,
	},
	spotLight: {
		color: new THREE.Color(0x22ff11),
		intensity: 0.3,
		position: new THREE.Vector3(-1, 2, -2),
		target: new THREE.Vector3(1, 0, 1),
		maxDistance: 20,
		angle: Math.PI / 2,
		penumbra: 0.08,
	},
	glossiness: 24,
	toon: 3,
}
const pane = new Pane()

pane
	.addBinding(config, 'toon', {
		min: 1,
		max: 10,
		step: 1,
	})
	.on('change', (ev) => {
		if (ev.value < 2) {
			delete material.defines.TOON
		} else {
			material.defines.TOON = ev.value
		}
		material.needsUpdate = true
	})

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
		expanded: false,
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

// Point Light
{
	const pointLight = pane.addFolder({
		title: 'Point Light',
		expanded: false,
	})

	pointLight
		.addBinding(config.pointLight, 'color', {
			color: { type: 'float' },
		})
		.on('change', (ev) => {
			pointLightMesh.material.color = ev.value
		})

	pointLight
		.addBinding(config.pointLight, 'intensity', {
			min: 0.0,
			max: 2.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uPointLight.value.intensity = ev.value
		})

	pointLight
		.addBinding(config.pointLight, 'position', {
			x: { min: -4, max: 4, step: 0.01 },
			y: { min: -4, max: 4, step: 0.01 },
			z: { min: -4, max: 4, step: 0.01 },
		})
		.on('change', (ev) => {
			material.uniforms.uPointLight.value.position = ev.value
			pointLightMesh.position.copy(ev.value)
		})

	pointLight
		.addBinding(config.pointLight, 'maxDistance', {
			min: 0.0,
			max: 10.0,
			step: 0.1,
		})
		.on('change', (ev) => {
			material.uniforms.uPointLight.value.maxDistance = ev.value
		})
}

// Spot Light
{
	const spotLight = pane.addFolder({
		title: 'Spot Light',
		expanded: false,
	})

	spotLight
		.addBinding(config.spotLight, 'color', {
			color: { type: 'float' },
		})
		.on('change', (ev) => {
			spotLightMesh.material.color = ev.value
		})

	spotLight
		.addBinding(config.spotLight, 'intensity', {
			min: 0.0,
			max: 2.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uSpotLight.value.intensity = ev.value
		})

	spotLight
		.addBinding(config.spotLight, 'position', {
			x: { min: -4, max: 4, step: 0.01 },
			y: { min: -4, max: 4, step: 0.01 },
			z: { min: -4, max: 4, step: 0.01 },
		})
		.on('change', (ev) => {
			material.uniforms.uSpotLight.value.position = ev.value
			spotLightMesh.position.copy(ev.value)
		})

	spotLight
		.addBinding(config.spotLight, 'target', {
			x: { min: -4, max: 4, step: 0.01 },
			y: { min: -4, max: 4, step: 0.01 },
			z: { min: -4, max: 4, step: 0.01 },
		})
		.on('change', (ev) => {
			material.uniforms.uSpotLight.value.target = ev.value
		})

	spotLight
		.addBinding(config.spotLight, 'maxDistance', {
			min: 0.0,
			max: 10.0,
			step: 0.1,
		})
		.on('change', (ev) => {
			material.uniforms.uSpotLight.value.maxDistance = ev.value
		})

	spotLight
		.addBinding(config.spotLight, 'angle', {
			min: 0.0,
			max: Math.PI,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uSpotLight.value.angle = ev.value
		})

	spotLight
		.addBinding(config.spotLight, 'penumbra', {
			min: 0.0,
			max: 1.0,
			step: 0.01,
		})
		.on('change', (ev) => {
			material.uniforms.uSpotLight.value.penumbra = ev.value
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

const cubeTextureLoader = new THREE.CubeTextureLoader()
const envMap = cubeTextureLoader.load([
	'/env/01/px.png',
	'/env/01/nx.png',
	'/env/01/py.png',
	'/env/01/ny.png',
	'/env/01/pz.png',
	'/env/01/nz.png',
])

scene.background = envMap

// __box__
/**
 * BOX
 */
// const material = new THREE.MeshNormalMaterial()
const material = new THREE.ShaderMaterial({
	vertexShader,
	fragmentShader,
	defines: {
		// TOON: config.toon,
	},
	uniforms: {
		uEnvMap: {
			value: envMap,
		},
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
		uPointLight: {
			value: {
				color: config.pointLight.color,
				intensity: config.pointLight.intensity,
				position: config.pointLight.position,
				maxDistance: config.pointLight.maxDistance,
			},
		},
		uSpotLight: {
			value: {
				color: config.spotLight.color,
				intensity: config.spotLight.intensity,
				position: config.spotLight.position,
				maxDistance: config.spotLight.maxDistance,
				angle: config.spotLight.angle,
				penumbra: config.spotLight.penumbra,
				target: config.spotLight.target,
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
const planeGeometry = new THREE.PlaneGeometry(10, 10)
planeGeometry.rotateX(-Math.PI / 2)
const plane = new THREE.Mesh(planeGeometry, material)
plane.position.y = -2

scene.add(box, ico, torus)

const dirLight = new THREE.Mesh(
	new THREE.SphereGeometry(0.1, 4, 4),
	new THREE.MeshBasicMaterial({ color: config.dirLight.color })
)
dirLight.position.copy(config.dirLight.direction)

// scene.add(dirLight)

const pointLightMesh = new THREE.Mesh(
	new THREE.SphereGeometry(0.1, 4, 4),
	new THREE.MeshBasicMaterial({ color: config.pointLight.color })
)
pointLightMesh.position.copy(config.pointLight.position)

// scene.add(pointLightMesh)

const spotLightMesh = new THREE.Mesh(
	new THREE.SphereGeometry(0.1, 4, 4),
	new THREE.MeshBasicMaterial({ color: config.spotLight.color })
)
spotLightMesh.position.copy(config.spotLight.position)

// scene.add(spotLightMesh)

// background della scena
// scene.background = new THREE.Color(0x555555)

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

renderer.toneMapping = THREE.ACESFilmicToneMapping
renderer.toneMappingExposure = 2.5

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
