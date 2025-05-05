#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../curl.glsl;
#include ../fbm.glsl;

uniform float uTime;
uniform float uProgress;
uniform float uFrequency;
uniform float uAmplitude;
uniform float uFireFrequency;
uniform float uFireAmplitude;
uniform float uFireExpAmplitude;
uniform float uFireFallinOffset;
uniform float uFireFallinMargin;
uniform float uFireFalloffOffset;
uniform float uFireFalloffMargin;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying float vHeight;

void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal,0.0)).xyz;
  vec3 pos = position;
  vec4 wPos = (modelMatrix * vec4(pos,1.0));

  // distance
  float d = length(wPos.xyz);
  d -= cnoise(vec4(wPos.xyz * uFrequency, uTime * 0.2)) * uAmplitude;
  d += fbm(wPos.xyz * uFrequency * 4. + uTime * 0.1, 2) * uAmplitude;

  // alpha
  float fireFallin = falloff(d + uFireFallinOffset,2. + uAmplitude,0. - uAmplitude,uFireFallinMargin,uProgress);
  float fireFalloff = 1. - falloff(d + uFireFalloffOffset,2. + uAmplitude,0. - uAmplitude,uFireFalloffMargin,uProgress);


  // fire shape
  float fireHeight = cnoise(wPos.xyz * uFireFrequency + vec3(uTime * 0.5));
  fireHeight = fireHeight * 0.5 + 0.5;
  fireHeight = pow(fireHeight, uFireExpAmplitude);
  fireHeight *= uFireAmplitude;

  wPos.z += fireFalloff * fireFallin * fireHeight;

  vHeight = wPos.z;

  wPos.x += cnoise(vec3(wPos.xy, wPos.z + uTime)) * wPos.z * 0.5;
  wPos.y += cnoise(vec3(wPos.xy + 50., wPos.z + uTime)) * wPos.z * 0.5;
  wPos.y += pow(wPos.z,2.);

  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}