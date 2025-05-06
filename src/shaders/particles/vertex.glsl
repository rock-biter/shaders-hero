#include ../noise.glsl;

attribute vec3 color;
attribute float aRandom;

uniform float uSize;
uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUv;
varying vec3 vColor;
varying vec3 vWorldPosition;
varying float vRandom;

void main() {
  vUv = uv;
  vColor = color;
  vRandom = aRandom;

  vec4 wPos = modelMatrix * vec4(position,1.0);
  vWorldPosition = wPos.xyz;
  vec4 mvPosition = viewMatrix * wPos;

  gl_Position = projectionMatrix * mvPosition;
  float size = uSize;
  size *= ( 0.5 + vRandom * 0.5);
  gl_PointSize =  size / -mvPosition.z;
  gl_PointSize *= 0.001 * uResolution.y;
  gl_PointSize *= 1.2 + noise(uTime * aRandom * .10 + aRandom * 100.) * 0.4;

}