#include ../noise.glsl;
#include ../perlin.glsl;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;



varying vec3 vParallax;
varying vec3 vTangent;

void main() {
  vUv = uv;
  vNormal = normalize(modelMatrix * vec4(normal,0.0)).xyz;

  vec3 pos = position;
  vec4 wPos = (modelMatrix * vec4(pos,1.0));

  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}