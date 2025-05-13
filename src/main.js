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
	size: 600,
	hemiLight: {
		skyColor: new THREE.Color(0.17, 0.03, 0.1),
		groundColor: new THREE.Color(0.8, 0.5, 0.3),
		intensity: 0.4,
	},
	dirLight: {
		color: new THREE.Color(0.1, 0.37, 0.8),
		intensity: 0.3,
		direction: new THREE.Vector3(1, 2, 0.5),
	},
	pointLight: {
		color: new THREE.Color(1, 0.94, 0),
		intensity: 0.3,
		position: new THREE.Vector3(0, 0, 0),
		maxDistance: 10,
		glossiness: 700,
	},
	blend: {
		scale: 0.75,
		start: 0.25,
		end: 0.17,
	},
}
const pane = new Pane()
const particles = pane.addFolder({ title: 'particles', expanded: true })

particles
	.addBinding(config, 'size', {
		min: 500,
		max: 2800,
		step: 0.01,
	})
	.on('change', (ev) => {
		cloudMaterial.uniforms.uSize.value = ev.value * renderer.getPixelRatio()
	})

const hemi = pane.addFolder({ title: 'hemi light', expanded: false })
hemi.addBinding(config.hemiLight, 'skyColor', { color: { type: 'float' } })
hemi.addBinding(config.hemiLight, 'groundColor', { color: { type: 'float' } })
hemi
	.addBinding(config.hemiLight, 'intensity', { min: 0, max: 1, step: 0.01 })
	.on('change', (ev) => {
		cloudMaterial.uniforms.uHemi.value.intensity = ev.value
	})

const dir = pane.addFolder({ title: 'directional light', expanded: false })
dir.addBinding(config.dirLight, 'color', { color: { type: 'float' } })
dir
	.addBinding(config.dirLight, 'intensity', { min: 0, max: 1, step: 0.01 })
	.on('change', (ev) => {
		cloudMaterial.uniforms.uDirLight.value.intensity = ev.value
	})
dir.addBinding(config.dirLight, 'direction', {
	x: { min: -3, max: 3, step: 0.01 },
	y: { min: -3, max: 3, step: 0.01 },
	z: { min: -3, max: 3, step: 0.01 },
})

const point = pane.addFolder({ title: 'point light', expanded: false })
point.addBinding(config.pointLight, 'color', { color: { type: 'float' } })
point
	.addBinding(config.pointLight, 'intensity', { min: 0, max: 1, step: 0.01 })
	.on('change', (ev) => {
		cloudMaterial.uniforms.uPointLight.value.intensity = ev.value
	})
point.addBinding(config.pointLight, 'position', {
	x: { min: -3, max: 3, step: 0.01 },
	y: { min: -3, max: 3, step: 0.01 },
	z: { min: -3, max: 3, step: 0.01 },
})
point
	.addBinding(config.pointLight, 'maxDistance', { min: 0, max: 20, step: 0.01 })
	.on('change', (ev) => {
		cloudMaterial.uniforms.uPointLight.value.maxDistance = ev.value
	})

point
	.addBinding(config.pointLight, 'glossiness', {
		min: 0,
		max: 1000,
		step: 0.01,
	})
	.on('change', (ev) => {
		cloudMaterial.uniforms.uGlossiness.value = ev.value
	})

/**
 * Scene
 */
const scene = new THREE.Scene()

// __box__
/**
 * BOX
 */

// background della scena
// scene.background = new THREE.Color(1, 0.85, 0.59)
// scene.background = new THREE.Color(0.1, 0.1, 0.2)

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
camera.position.set(1, 2.2, 4)
camera.lookAt(new THREE.Vector3(2, 2.5, 0))

// const light = new THREE.DirectionalLight(0xffffff, 1.5)
// const light2 = new THREE.HemisphereLight(0x555555, 0x992233, 2)
// light.position.set(0.7, 2, 0.1)
// scene.add(light, light2)

/**
 * Show the axes of coordinates system
 */
// __helper_axes__
const axesHelper = new THREE.AxesHelper(3)
scene.add(axesHelper)

const bgGeom = new THREE.BufferGeometry()
bgGeom.setAttribute(
	'position',
	new THREE.BufferAttribute(
		new Float32Array([-1, -1, 0, 3, -1, 0, -1, 3, 0]),
		3
	)
)
bgGeom.setAttribute(
	'uv',
	new THREE.BufferAttribute(new Float32Array([0, 0, 2, 0, 0, 2]), 2)
)

const bgMat = new THREE.ShaderMaterial({
	vertexShader: /* glsl */ `
	varying vec2 vUv;
	void main() {
		vUv = uv;
		gl_Position = vec4(position.xy,0.0,1.0);
	}
	`,
	fragmentShader: /* glsl */ `
	varying vec2 vUv;
	void main() {
		
		// vec3 color = vec3(1, 0.85, 0.59);
		vec3 color = vec3(0.,0.03,0.05) * 0.4;
		vec3 colorB = vec3(0.,0.03,0.05);
		// color *= length(vUv);
		float t = smoothstep(0.3,1.,vUv.y);
		color = mix(colorB, color,t * t * t);

		gl_FragColor = vec4(color, 1.0);
  	#include <tonemapping_fragment>
  	#include <colorspace_fragment>
	}
	`,
	depthWrite: false,
})

const bg = new THREE.Mesh(bgGeom, bgMat)
bg.renderOrder = -2
bg.frustumCulled = false
scene.add(bg)

/**
 * renderer
 */
const renderer = new THREE.WebGLRenderer({
	antialias: window.devicePixelRatio < 2,
})
document.body.appendChild(renderer.domElement)

const cloudMaterial = new THREE.ShaderMaterial({
	vertexShader,
	fragmentShader,
	transparent: true,
	uniforms: {
		uSize: { value: config.size * renderer.getPixelRatio() },
		uResolution: { value: new THREE.Vector2(sizes.width, sizes.height) },
		uTime: { value: 0 },
	},
	depthWrite: false,
})

const cloudGeometry = new THREE.BufferGeometry()
const count = 10
const position = new Float32Array(count * 3)
const random = new Float32Array(count)

for (let i = 0; i < count; i++) {
	const index = i * 3
	const dir = new THREE.Vector3().randomDirection()
	const x = dir.x * Math.random() * 8
	const y = (Math.random() - 0.5) * 2
	const z = dir.z * Math.random() * 8

	position[index + 0] = x
	position[index + 1] = y
	position[index + 2] = z

	random[index] = Math.random()
}

const posAttribute = new THREE.BufferAttribute(position, 3)
cloudGeometry.setAttribute('position', posAttribute)

const randomAttribute = new THREE.BufferAttribute(random, 1)
cloudGeometry.setAttribute('aRandom', randomAttribute)

const cloud = new THREE.Points(cloudGeometry, cloudMaterial)

scene.add(cloud)

handleResize()

/**
 * OrbitControls
 */
// __controls__
const controls = new OrbitControls(camera, renderer.domElement)
controls.enableDamping = true
// controls.autoRotate = true
// controls.rotateSpeed = 0.5
// controls.target.set(0, 0.4, 0)

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

	cloudMaterial.uniforms.uTime.value = time

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
	cloudMaterial.uniforms.uResolution.value.set(sizes.width, sizes.height)

	renderer.setSize(sizes.width, sizes.height)

	const pixelRatio = Math.min(window.devicePixelRatio, 2)
	renderer.setPixelRatio(pixelRatio)
	cloudMaterial.uniforms.uSize.value = config.size * renderer.getPixelRatio()
}
