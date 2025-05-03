import './style.css'
import * as THREE from 'three'
// __controls_import__
// __gui_import__

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/base/vertex.glsl'
import fragmentShader from './shaders/base/fragment.glsl'
import bgVertex from './shaders/background/vertex.glsl'
import bgFragment from './shaders/background/fragment.glsl'
import planesVertex from './shaders/planes/vertex.glsl'
import planesFragment from './shaders/planes/fragment.glsl'
import windVertex from './shaders/wind/vertex.glsl'
import windFrag from './shaders/wind/fragment.glsl'
import { BufferGeometryUtils } from 'three/examples/jsm/Addons.js'

const textureLoader = new THREE.TextureLoader()
const mapFBM = textureLoader.load('/textures/fbm.png')
const mapPerlin = textureLoader.load('/textures/perlin.png')
const mapTriangles = textureLoader.load('/textures/triangles.png')
mapFBM.wrapS = THREE.RepeatWrapping
mapFBM.wrapT = THREE.RepeatWrapping
mapPerlin.wrapS = THREE.RepeatWrapping
mapPerlin.wrapT = THREE.RepeatWrapping
mapTriangles.wrapS = THREE.RepeatWrapping
mapTriangles.wrapT = THREE.RepeatWrapping

/**
 * Debug
 */
// __gui__
const config = {
	terrain: {
		frequency: 0.015,
		amplitude: 6,
	},
	perlin: {
		frequency: 0.017,
		amplitude: 3,
	},
	color: {
		f1: 3.5,
		f2: 0.1,
		f3: 0.02,
	},
	progress: 0.3,
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

const terrain = pane.addFolder({ title: 'Terrain' })
terrain
	.addBinding(config.terrain, 'frequency', {
		min: 0.001,
		max: 0.1,
		step: 0.001,
	})
	.on('change', (ev) => {
		material.uniforms.uTerrainFrequency.value = ev.value
	})

terrain
	.addBinding(config.terrain, 'amplitude', {
		min: 0,
		max: 10,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uTerrainAmplitude.value = ev.value
	})

const perlin = pane.addFolder({ title: 'Perlin' })
perlin
	.addBinding(config.perlin, 'frequency', {
		min: 0.001,
		max: 0.1,
		step: 0.001,
	})
	.on('change', (ev) => {
		material.uniforms.uPerlinFrequency.value = ev.value
	})

perlin
	.addBinding(config.perlin, 'amplitude', {
		min: 0,
		max: 10,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uPerlinAmplitude.value = ev.value
	})

const terrainColor = pane.addFolder({ title: 'Terrain Color' })
terrainColor
	.addBinding(config.color, 'f1', {
		min: 0.1,
		max: 10,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uColorF1.value = ev.value
	})

terrainColor
	.addBinding(config.color, 'f2', {
		min: 0.01,
		max: 1.0,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uColorF2.value = ev.value
	})

terrainColor
	.addBinding(config.color, 'f3', {
		min: 0.001,
		max: 0.1,
		step: 0.001,
	})
	.on('change', (ev) => {
		material.uniforms.uColorF3.value = ev.value
	})

/**
 * Scene
 */
const scene = new THREE.Scene()
// scene.background = new THREE.Color(0xdedede)

const globalUniforms = {
	uProgress: {
		value: config.progress,
	},
	uTime: {
		value: 0.0,
	},
}

// __box__
/**
 * BOX
 */
// const material = new THREE.MeshNormalMaterial()
const material = new THREE.ShaderMaterial({
	vertexShader,
	fragmentShader,
	transparent: true,
	// wireframe: true,
	uniforms: {
		uTime: globalUniforms.uTime,
		uProgress: globalUniforms.uProgress,
		uTerrainFrequency: {
			value: config.terrain.frequency,
		},
		uTerrainAmplitude: {
			value: config.terrain.amplitude,
		},
		uPerlinFrequency: {
			value: config.perlin.frequency,
		},
		uPerlinAmplitude: {
			value: config.perlin.amplitude,
		},
		uPerlin: {
			value: mapPerlin,
		},
		uFBM: {
			value: mapFBM,
		},
		uTriangles: {
			value: mapTriangles,
		},
		uColorF1: { value: config.color.f1 },
		uColorF2: { value: config.color.f2 },
		uColorF3: { value: config.color.f3 },
	},
})

const planeGeometry = new THREE.PlaneGeometry(15, 15, 200, 200)
planeGeometry.rotateX(-Math.PI / 2)
const plane = new THREE.Mesh(planeGeometry, material)
// plane.position.y = -2

scene.add(plane)

/**
 * background
 */
const bgGeom = new THREE.BufferGeometry()
const position = new THREE.BufferAttribute(
	new Float32Array([-1, -1, 0, 3, -1, 0, -1, 3, 0]),
	3
)
const uv = new THREE.BufferAttribute(new Float32Array([0, 0, 2, 0, 0, 2]), 2)
bgGeom.setAttribute('position', position)
bgGeom.setAttribute('uv', uv)
const bgMaterial = new THREE.ShaderMaterial({
	vertexShader: bgVertex,
	fragmentShader: bgFragment,
	depthWrite: false,
	uniforms: {
		uProgress: globalUniforms.uProgress,
	},
})
const background = new THREE.Mesh(bgGeom, bgMaterial)
scene.add(background)
background.renderOrder = -1

// RANDOM PLANES
const geometries = []
const size = 0.5
const gridSize = 11
const halfGridSize = gridSize * 0.5

for (let y = 0; y < 2; y++) {
	for (let z = 0; z < gridSize; z++) {
		for (let x = 0; x < gridSize; x++) {
			if (Math.random() > 0.5) continue
			const g = new THREE.PlaneGeometry(size, size)
			const pos = new THREE.Vector3(x - halfGridSize, y, z - halfGridSize)
			pos.multiplyScalar(size)
			const step = Math.floor((Math.random() * Math.PI) / (Math.PI * 0.5))
			console.log(step)
			const angle = Math.PI * step * 0.5
			g.rotateY(angle)
			pos.x += size * 0.5 * step
			pos.z += size * 0.5 * step
			g.translate(...pos)

			geometries.push(g)
		}
	}
}

const planesGeom = BufferGeometryUtils.mergeGeometries(geometries)
const planesMaterial = new THREE.ShaderMaterial({
	vertexShader: planesVertex,
	fragmentShader: planesFragment,
	transparent: true,
	wireframe: true,
	uniforms: {
		...globalUniforms,
	},
})
const planes = new THREE.Mesh(planesGeom, planesMaterial)
planes.position.y = 0.5
planes.renderOrder = 2
scene.add(planes)

// WIND
const windGeom = new THREE.PlaneGeometry(8, 8)
windGeom.rotateX(-Math.PI * 0.5)
const windMat = new THREE.ShaderMaterial({
	vertexShader: windVertex,
	fragmentShader: windFrag,
	transparent: true,
	depthTest: false,
	depthWrite: false,
	uniforms: {
		...globalUniforms,
	},
})
const wind = new THREE.Mesh(windGeom, windMat)
wind.position.y = 0.4
scene.add(wind)

// background della scena
// scene.background = new THREE.Color(0x000033)

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
camera.position.set(1.5, 3, 1.5)
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

// renderer.toneMapping = THREE.ACESFilmicToneMapping
// renderer.toneMappingExposure = 2.5

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
	/**
	 * tempo totale trascorso dall'inizio
	 */
	// const time = clock.getElapsedTime()
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
