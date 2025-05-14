#include ../functions.glsl;

uniform float uTime;

varying vec2 vUv;
varying vec3 vWorldPosition;
varying vec3 vPosition;
varying vec3 vNormal;

void main() {
  vUv = uv;

  vPosition = position;
  vec4 wPos = modelMatrix * vec4(position,1.0);

  vNormal = (modelMatrix * vec4(normal,0.0)).xyz;
  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}