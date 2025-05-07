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
	size: 2000,
}
const pane = new Pane()

pane
	.addBinding(config, 'size', {
		min: 1200,
		max: 2800,
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
scene.background = new THREE.Color(1, 0.85, 0.59)
// scene.background = new THREE.Color(0.1, 0.1, 0.2)

pane.addBinding(scene, 'background', {
	color: { type: 'float' },
})

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
camera.position.set(3.5, 2.5, 3.5)
camera.lookAt(new THREE.Vector3(2, 2.5, 0))

const sphere = new THREE.Mesh(
	new THREE.SphereGeometry(0.7, 32, 32),
	new THREE.MeshStandardMaterial({
		color: new THREE.Color(1, 0.85, 0.59).multiplyScalar(1.5),
	})
)
sphere.scale.y = 1.3
sphere.position.y = 0.5
scene.add(sphere)
const light = new THREE.DirectionalLight(0xffffff, 1.5)
const light2 = new THREE.HemisphereLight(0x555555, 0x992233, 2)
light.position.set(0.7, 2, 0.1)
scene.add(light, light2)

/**
 * Show the axes of coordinates system
 */
// __helper_axes__
const axesHelper = new THREE.AxesHelper(3)
// scene.add(axesHelper)

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
		float s = smoothstep(1.,0.5,vUv.x);
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

// renderer.toneMapping = THREE.ACESFilmicToneMapping
// renderer.toneMappingExposure = 2.5

// const material = new THREE.MeshNormalMaterial()
const map = textureLoader.load('/particles/smoke.png')
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
	// blending: THREE.MultiplyBlending,
	// blending: THREE.SubtractiveBlending,
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
	// blending: THREE.AdditiveBlending,
	// blending: THREE.MultiplyBlending,
	// blending: THREE.SubtractiveBlending,
	blending: THREE.CustomBlending,
	blendEquation: THREE.AddEquation,
	blendSrc: THREE.OneFactor,
	blendDst: THREE.OneMinusSrcAlphaFactor,
})
const boxGeometry = new THREE.BoxGeometry(10, 10, 10, 5, 5, 5)
const sphereGeometry = new THREE.SphereGeometry(5, 12, 24)
const particlesGeometry = new THREE.BufferGeometry()
const count = 1000
const position = new Float32Array(count * 3)
const color = new Float32Array(count * 3)
const random = new Float32Array(count)

for (let i = 0; i < count; i++) {
	const index = i * 3
	const dir = new THREE.Vector3().randomDirection()
	const x = dir.x * Math.random() * 10
	const y = (Math.random() - 0.5) * 2
	const z = dir.z * Math.random() * 10

	position[index + 0] = x
	position[index + 1] = y
	position[index + 2] = z
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
controls.autoRotate = true
controls.rotateSpeed = 0.5
controls.target.set(0, 0.5, 0)

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
	particlesMaterial.uniforms.uResolution.value.set(sizes.width, sizes.height)

	renderer.setSize(sizes.width, sizes.height)

	const pixelRatio = Math.min(window.devicePixelRatio, 2)
	renderer.setPixelRatio(pixelRatio)
}
