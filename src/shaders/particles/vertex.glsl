#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

attribute vec3 aRandom;
attribute float aLife;

uniform vec2 uResolution;
uniform float uTime;
uniform float uProgress;
uniform float uSize;
uniform float uSpeed;
uniform vec2 uVelocity;
uniform float uDivergenceAmp;
uniform vec2 uDivergenceFreq;

varying vec2 vUv;
varying vec3 vWorldPosition;
varying vec3 vWorldOriginalPosition;
varying vec3 vRandom;
varying float vLife;

void main() {

  vUv = uv;
  vRandom = aRandom;
  vLife = aLife;

  vec4 wPos = modelMatrix * vec4(position,1.0);
  vWorldOriginalPosition = wPos.xyz;

  float zOffset = mod(uTime * uSpeed * (0.2 + aRandom.z) + aRandom.y * aLife, aLife);
  zOffset = pow(zOffset * aLife * 3., 0.3) + zOffset;
  zOffset /= 2.;
  wPos.z = zOffset;

  float divScale = remap(zOffset,0.,1., 0.,0.5);

  float xDiv = fbm(wPos.xyz * uDivergenceFreq.x + aRandom.z, 3 ) * 2. - 1.;
  float yDiv = fbm(wPos.xyz * uDivergenceFreq.y + aRandom.y * 5. + 200., 3 ) * 2. - 1.;

  wPos.xy += vec2(xDiv,yDiv) * uDivergenceAmp * divScale;
  wPos.x -= clamp(uVelocity.x, -0.1, 0.1) * pow(wPos.z,2.) * 4.5;
  wPos.y += pow(wPos.z, 2.) * 0.5 * -(aRandom.x * 2. - 1.);

  vWorldPosition = wPos.xyz;
  
  vec4 mvPos = viewMatrix * wPos;
  gl_Position = projectionMatrix * mvPos;
  gl_PointSize = uSize / -mvPos.z;
  gl_PointSize *= 1. + aRandom.x * 4.;
  gl_PointSize *= aLife - zOffset * 0.7;
  gl_PointSize *= 0.001 * uResolution.y;

}