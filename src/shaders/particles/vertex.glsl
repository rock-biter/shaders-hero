#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;


uniform float uSize;
uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUv;
varying vec3 vWorldPosition;

void main() {
  vUv = uv;

  vec4 wPos = modelMatrix * vec4(position,1.0);
  vWorldPosition = wPos.xyz;
  vec4 mvPos = viewMatrix * wPos;

  gl_Position = projectionMatrix * mvPos;
  float size = uSize;
  gl_PointSize =  size / -mvPos.z;
  gl_PointSize *= 0.001 * uResolution.y;

}