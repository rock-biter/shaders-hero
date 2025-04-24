#include ../functions.glsl;
#include ../random.glsl;
#include ../simplex.glsl;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec2 uv = vUv;
  float r = snoise(vec4(vWorldPosition * uFrequency * 3., uTime)) * 0.5 + 0.5;
  vec3 baseColor = vec3(r);
  // baseColor *= 1. - r;

  vec3 color = baseColor;

  gl_FragColor = vec4(color,1.0);

  // #include <tonemapping_fragment>
  // #include <colorspace_fragment>
}