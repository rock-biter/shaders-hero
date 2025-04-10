varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

uniform float uTime;

#include ../noise.glsl;

void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal,0.0)).xyz;
  vec3 pos = position;
  pos.z += random(position.xy ) * 0.2;
  vWorldPosition = (modelMatrix * vec4(pos,1.0)).xyz;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos,1.0);
}