#include ../functions.glsl;
#include ../lights.glsl;
#include ../noise.glsl;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform int uOctaves;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

// #include ../perlin.glsl;
// #include ../simplex.glsl;
#include ../fbm.glsl;


void main() {
	
  float n = fbm(vWorldPosition * uFrequency + uTime * 0.5,uOctaves); // fbm
  vec3 baseColor = vec3(n * 0.5 + 0.5);
	// final color
	vec3 color = baseColor;// * light;

  gl_FragColor = vec4(color,1.0);
}