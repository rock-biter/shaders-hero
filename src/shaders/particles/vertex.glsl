#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;

attribute vec3 color;
attribute float aRandom;

uniform float uSize;
uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUv;
varying vec3 vColor;
varying vec3 vWorldPosition;
varying float vRandom;

mat2 rotate(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, -s, s, c);
}

void main() {
  vUv = uv;
  vColor = color;
  vRandom = aRandom;

  vec4 wPos = modelMatrix * vec4(position,1.0);
  wPos.xz = rotate(uTime * (1.0 - smoothstep(0.,10.,length(wPos)) )* 0.3) * wPos.xz;
  wPos.y += cnoise(wPos.xyz * 0.5 + uTime * 0.1) * 0.1;
  wPos.x += cnoise(wPos.xyz * 0.5 + uTime * 0.2 + 100.) * 0.1;
  vWorldPosition = wPos.xyz;
  vec4 mvPosition = viewMatrix * wPos;

  gl_Position = projectionMatrix * mvPosition;
  float size = uSize;
  size *= ( 0.5 + vRandom * 0.5);
  float scale = 1. - smoothstep(10.,30.,length(wPos.xyz));
  scale *= scale;
  gl_PointSize =  scale * size / -mvPosition.z;
  gl_PointSize *= 0.001 * uResolution.y;
  gl_PointSize *= 1.2 + noise(uTime * aRandom * .10 + aRandom * 100.) * 0.4;

}