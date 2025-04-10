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
#include ../voronoi.glsl;


void main() {
	
  // float n = domainWarpingFBM(vWorldPosition * uFrequency + uTime * 0.2 ,uOctaves); // fbm
  // float n = smoothVoronoi(vWorldPosition * uFrequency + vec3(0.0,0.0,uTime * 0.5) + noise(vWorldPosition * uFrequency + uTime ) * 0.2);
  float v = noise(vWorldPosition * uFrequency * 2. + uTime ) * 0.1;
  float n = smoothVoronoi(vec4(vWorldPosition * uFrequency + v, uTime * 0.5)  );
  vec3 baseColor = vec3(1. - n);
	// final color
	vec3 color = baseColor;// * light;

  gl_FragColor = vec4(color,1.0);
}