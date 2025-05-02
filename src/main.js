import './style.css'
import * as THREE from 'three'
// __controls_import__
// __gui_import__

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'
import { KTX2Loader } from 'three/addons/loaders/KTX2Loader.js'

import vertexShader from './shaders/base/vertex.glsl'
import fragmentShader from './shaders/base/fragment.glsl'
import vertexSquare from './shaders/square/vertex.glsl'
import fragmentSquare from './shaders/square/fragment.glsl'
import vertexBG from './shaders/background/vertex.glsl'
import fragmentBG from './shaders/background/fragment.glsl'
import gsap from 'gsap'
import { BufferGeometryUtils } from 'three/examples/jsm/Addons.js'

const textureLoader = new THREE.TextureLoader()
const triangles = textureLoader.load('/textures/triangles.png')
const tiles = textureLoader.load('/textures/tiles.png')
const mapPerlin = textureLoader.load('/textures/perlin.png')
const mapFBM = textureLoader.load('/textures/fbm.png')
triangles.wrapS = THREE.RepeatWrapping
triangles.wrapT = THREE.RepeatWrapping
mapPerlin.wrapS = THREE.RepeatWrapping
mapPerlin.wrapT = THREE.RepeatWrapping
mapFBM.wrapS = THREE.RepeatWrapping
mapFBM.wrapT = THREE.RepeatWrapping
tiles.wrapS = THREE.RepeatWrapping
tiles.wrapT = THREE.RepeatWrapping

/**
 * Debug
 */
// __gui__
const config = {
	perlin: {
		frequency: 0.35,
		amplitude: 3,
	},
	terrain: {
		frequency: 0.015,
		amplitude: 6.0,
	},
	progress: 0.3,
	alphaFalloff: {
		start: 0.0,
		end: 30,
		margin: 0.05,
	},
	terrainFalloff: {
		start: 0.0,
		end: 30,
		margin: 0.05,
	},
}
const pane = new Pane()

pane
	.addBinding(config, 'progress', {
		min: 0,
		max: 1,
		step: 0.001,
	})
	.on('change', (ev) => {
		material.uniforms.uProgress.value = ev.value
		mat.uniforms.uProgress.value = ev.value
	})

const perlin = pane.addFolder({ title: 'Perlin' })

perlin
	.addBinding(config.perlin, 'frequency', {
		min: 0.01,
		max: 2,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uFrequency.value = ev.value
	})

perlin
	.addBinding(config.perlin, 'amplitude', {
		min: 0.01,
		max: 10,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uAmplitude.value = ev.value
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
		min: 0.1,
		max: 10,
		step: 0.01,
	})
	.on('change', (ev) => {
		material.uniforms.uTerrainAmplitude.value = ev.value
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
	transparent: true,
	// wireframe: true,
	uniforms: {
		uTime: {
			value: 0,
		},
		uFrequency: {
			value: config.perlin.frequency,
		},
		uAmplitude: {
			value: config.perlin.amplitude,
		},
		uTerrainFrequency: {
			value: config.terrain.frequency,
		},
		uTerrainAmplitude: {
			value: config.terrain.amplitude,
		},
		uOctaves: {
			value: config.octaves,
		},
		uProgress: {
			value: config.progress,
		},
		uTriangles: new THREE.Uniform(triangles),
		uFBM: new THREE.Uniform(mapFBM),
		uPerlin: new THREE.Uniform(mapPerlin),
		uTiles: new THREE.Uniform(tiles),
	},
})
const boxGeometry = new THREE.BoxGeometry(3.3, 3.3, 3.3)
const icoGeometry = new THREE.IcosahedronGeometry(3)
const torusGeometry = new THREE.TorusGeometry(0.5, 0.3, 16, 100)
const box = new THREE.Mesh(boxGeometry, material)
const ico = new THREE.Mesh(icoGeometry, material)
const torus = new THREE.Mesh(torusGeometry, material)
// torus.position.x = 3
// box.position.x = -3
torus.rotation.x = -Math.PI * 0.2
torus.scale.setScalar(3)
const planeGeometry = new THREE.PlaneGeometry(15, 15, 200, 200)
planeGeometry.rotateX(-Math.PI / 2)
const plane = new THREE.Mesh(planeGeometry, material)
// plane.position.y = -2

scene.add(plane)

// background della scena
// scene.background = new THREE.Color(0.36, 0.38, 0.44)

// pane.addBinding(scene, 'background', {
// 	color: { type: 'float' },
// })

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
camera.position.set(2, 3, 2)
camera.lookAt(new THREE.Vector3(2, 2.5, 0))

// backgorund
const geom = new THREE.BufferGeometry()
const position = new THREE.BufferAttribute(
	new Float32Array([-1.0, -1.0, 0, 3.0, -1.0, 0.0, -1.0, 3.0, 0.0]),
	3
)
const uv = new THREE.BufferAttribute(
	new Float32Array([0.0, 0.0, 2.0, 0.0, 0.0, 2.0]),
	2
)
const normal = new THREE.BufferAttribute(
	new Float32Array([0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0]),
	3
)

geom.setAttribute('position', position)
geom.setAttribute('uv', uv)
geom.setAttribute('normal', normal)
const materialBg = new THREE.ShaderMaterial({
	vertexShader: vertexBG,
	fragmentShader: fragmentBG,
	depthWrite: false,
})

const bg = new THREE.Mesh(geom, materialBg)
bg.renderOrder = -1
scene.add(bg)

const geometries = []
const size = 0.5
const gridSize = 11
const halGridSize = gridSize / 2

for (let y = 0; y < 2; y++) {
	for (let z = 0; z < gridSize; z++) {
		for (let x = 0; x < gridSize; x++) {
			if (Math.random() > 0.5) continue
			const g = new THREE.PlaneGeometry(size, size)
			const pos = new THREE.Vector3(x - halGridSize, y - 0.5, z - halGridSize)
			pos.multiplyScalar(size)
			g.translate(...pos)
			const step = Math.floor((Math.random() * Math.PI) / (Math.PI * 0.5))
			console.log('step', step)
			g.rotateY(step * Math.PI * 0.5)
			g.translate(size * step * 0.5, 0, size * step * 0.5)

			geometries.push(g)
		}
	}
}

const mat = new THREE.ShaderMaterial({
	vertexShader: vertexSquare,
	fragmentShader: fragmentSquare,
	transparent: true,
	wireframe: true,
	depthTest: false,
	uniforms: {
		uTime: {
			value: 0,
		},
		uProgress: {
			value: config.progress,
		},
	},
})
const panleGeometry = BufferGeometryUtils.mergeGeometries(geometries)

const panel = new THREE.Mesh(panleGeometry, mat)
scene.add(panel)

panel.position.set(0, 1, 0)
scene.add(panel)

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

// const ktx2loader = new KTX2Loader()
// ktx2loader.setTranscoderPath('/ktx2/')
// ktx2loader.detectSupport(renderer)
// ktx2loader.load('/textures/triangles.ktx2', (texture) => {
// 	texture.wrapS = THREE.RepeatWrapping
// 	texture.wrapT = THREE.RepeatWrapping
// 	material.uniforms.uTriangles.value = texture
// })
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

// gsap.to(material.uniforms.uProgress, {
// 	value: 1,
// 	duration: 4,
// 	delay: 0,
// 	ease: 'power2.in',
// })
// gsap.to(mat.uniforms.uProgress, {
// 	value: 1,
// 	duration: 4,
// 	delay: 0,
// 	ease: 'power2.in',
// })

// gsap.to(camera.position, {
// 	y: 1.5,
// 	x: 2,
// 	z: 2,
// 	duration: 4,
// 	delay: 0.5,
// 	ease: 'power3.inOut',
// })

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
	material.uniforms.uTime.value = time
	mat.uniforms.uTime.value = time

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
