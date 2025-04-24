#include ../random.glsl;
#include ../perlin.glsl;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  vec4 wPos = modelMatrix * vec4(position,1.0);

  // wPos.z += cnoise(wPos.xy * uFrequency + uTime) * uAmplitude;
  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}