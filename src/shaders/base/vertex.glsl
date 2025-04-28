#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform int uOctaves;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  vec4 wPos = modelMatrix * vec4(position,1.0);
  // vec3 p = wPos.xyz * uFrequency;

  // float v = ridgedFBM(p,uOctaves);
  // wPos.y += v * uAmplitude;

  // wPos.z += cnoise(wPos.xy * uFrequency + uTime) * uAmplitude;
  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}