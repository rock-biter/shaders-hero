varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;

#include ../noise.glsl;
#include ../perlin.glsl;

void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal,0.0)).xyz;
  vec3 pos = position;
  // pos.z += cnoise(position.xy * uFrequency) * uAmplitude;
  vWorldPosition = (modelMatrix * vec4(pos,1.0)).xyz;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos,1.0);
}