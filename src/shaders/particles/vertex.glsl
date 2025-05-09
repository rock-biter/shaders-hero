#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform vec2 uResolution;
uniform float uTime;
uniform float uProgress;
uniform float uSize;

varying vec2 vUv;
varying vec3 vWorldPosition;

void main() {

  vec4 wPos = modelMatrix * vec4(position,1.0);
  vWorldPosition = wPos.xyz;

  vec4 mvPos = viewMatrix * wPos;
  gl_Position = projectionMatrix * mvPos;
  gl_PointSize = uSize / -mvPos.z;
  gl_PointSize *= 0.001 * uResolution.y;

}