#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../fbm.glsl;
#include ../simplex.glsl;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform int uOctaves;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec2 uv = vUv;
  uv *= 10.;
  // float r = snoise(vec4(vWorldPosition * uFrequency * 3., uTime)) * 0.5 + 0.5;
  vec3 p = vWorldPosition * uFrequency;
  // float v = noise(p);
  // v += noise(p * 2.) * 0.5;
  // v += noise(p * 4.) * 0.25;
  // v += noise(p * 8.) * 0.125;
  // v += noise(p * 16.) * 0.125 * 0.5;

  // v /= 1.0 + 0.5 +0.25 +0.125 + 0.125 * 0.5;
  float v = fbm(p,uOctaves);

  vec3 baseColor = vec3(v);
  // baseColor *= 1. - r;

  

  vec3 color = baseColor;

  gl_FragColor = vec4(color,1.0);

  // #include <tonemapping_fragment>
  // #include <colorspace_fragment>
}