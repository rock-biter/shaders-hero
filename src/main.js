import './style.css'
import * as THREE from 'three'

import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { Pane } from 'tweakpane'

import vertexShader from './shaders/base/vertex.glsl'
import fragmentShader from './shaders/base/fragment.glsl'
import particlesFragmentShader from './shaders/particles/fragment.glsl'
import particlesVertexShader from './shaders/particles/vertex.glsl'

/**
 * Debug
 */
const config = {
	frequency: 3,
}
const pane = new Pane()

pane
	.addBinding(config, 'frequency', {
		min: 0.1,
		max: 10,
		step: 0.1,
	})
	.on('change', (ev) => {
		material.uniforms.uFrequency.value = ev.value
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

/**
 * uv parallax examples
 * https://x.com/gnrmse/status/1876334608012468517
 * https://threejs.org/examples/?q=uv#webgpu_parallax_uv
 *
 * https://learnopengl.com/Advanced-Lighting/Parallax-Mapping
 */

/**
 * BOX
 */
// const material = new THREE.MeshNormalMaterial()
const material = new THREE.ShaderMaterial({
	vertexShader,
	fragmentShader,
	transparent: true,
	depthWrite: false,
	uniforms: {
		uTime: {
			value: 0,
		},
		uFrequency: {
			value: config.frequency,
		},
	},
})
const boxGeometry = new THREE.BoxGeometry(1, 1, 1, 5, 5, 5)
boxGeometry.computeTangents()
const box = new THREE.Mesh(boxGeometry, material)
scene.add(box)

/**
 * Camera
 */
const fov = 60
const camera = new THREE.PerspectiveCamera(fov, sizes.width / sizes.height, 0.1)
camera.position.set(2, 2, 3)
camera.lookAt(new THREE.Vector3(0, 2.5, 0))

/**
 * Show the axes of coordinates system
 */
// __helper_axes__
const axesHelper = new THREE.AxesHelper(3)
// scene.add(axesHelper)

scene.background = new THREE.Color(0x001820)

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

	const pixelRatio = Math.min(window.devicePixelRatio, 2)
	renderer.setPixelRatio(pixelRatio)
}
