#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;
#include ../cellular.glsl;
// #include ../lights.glsl;
#include ../curl.glsl;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform int uOctaves;
uniform int uCurlSteps;
uniform sampler2D uMap;
uniform sampler2D uPerlin;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec3 baseColor = vec3(vUv,1.0);

  vec3 color = baseColor;
  gl_FragColor = vec4(color,1.0);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}