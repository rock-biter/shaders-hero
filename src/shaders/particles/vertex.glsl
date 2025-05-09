#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

attribute float aRandom;
attribute float aLife;

uniform vec2 uResolution;
uniform float uTime;
uniform float uProgress;
uniform float uSize;
uniform float uSpeed;
uniform vec2 uDivergenceFreq;
uniform float uDivergenceAmp;
uniform vec2 uVelocity;

varying vec2 vUv;
varying vec3 vWorldPosition;
varying vec3 vWorldOriginalPosition;
varying float vRandom;
varying float vLife;

void main() {

  vUv = uv;
  vRandom = aRandom;
  vLife = aLife;

  vec4 wPos = modelMatrix * vec4(position,1.0);
  vWorldOriginalPosition = wPos.xyz;

  float zOffset = mod(2. + uTime * uSpeed * (0.2 + aRandom) + aRandom * aLife, aLife);
  zOffset = pow(zOffset * aLife * 3., 0.3) + zOffset;
  zOffset /= 2.;
  wPos.z += zOffset;

  float divScale = remap(wPos.z,0.,1.,0.,0.5);

  float xDiv = (fbm(wPos.xyz * uDivergenceFreq.x + aRandom * 1.,3) * 2. - 1.);
  float yDiv = (fbm(wPos.xyz * uDivergenceFreq.y + 200. + aRandom * 2.,3) * 2. - 1.);

  wPos.xy += vec2(xDiv,yDiv) * uDivergenceAmp * divScale;

  wPos.y += pow(wPos.z, 2.) * 0.5 * (aRandom * 2. - 1.);

  wPos.x -= clamp(uVelocity.x, -0.1, 0.1) * pow(wPos.z,2.) * 4.5;

  vWorldPosition = wPos.xyz;

  vec4 mvPos = viewMatrix * wPos;
  gl_Position = projectionMatrix * mvPos;
  gl_PointSize = uSize / -mvPos.z;
  gl_PointSize *= 1. + aRandom * 4.;
  gl_PointSize *= aLife - zOffset * 0.7;
  gl_PointSize *= 0.001 * uResolution.y;

}