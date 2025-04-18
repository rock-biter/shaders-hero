varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying float vHeight;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform sampler2D uNoise;

uniform float uProgress;

uniform float uOffset1;
uniform float uSmooth1;
uniform float uOffset2;
uniform float uSmooth2;
uniform float uOffset3;
uniform float uSmooth3;
uniform vec3 uBurnColor;
uniform float uBurnMixExp;
uniform vec3 uFireColor;
uniform float uFireExp;
uniform float uFireScale;
uniform float uFireMixExp;

#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;


void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal,0.0)).xyz;
  vec3 pos = position;
  // pos.z += cnoise(position.xy * uFrequency) * uAmplitude;
  vec4 wPos = (modelMatrix * vec4(pos,1.0));

  float edge = (1.0 - uProgress * 1.5) * (1.5 + uAmplitude);
  float d = length(wPos.xyz);
  d -= cnoise(vec4(wPos.xyz * uFrequency , uTime * 0.2)) * uAmplitude * 0.8;
  d -= fbm(wPos.xyz * uFrequency * 4. + uTime * 0.1,2) * uAmplitude * 0.8;

  // float t = 1.0 - smoothstep(edge, edge + uSmooth1, d + uOffset1);
  float t = max(0.,d + uOffset1 - edge + 0.8);
  t = pow(t,4.) * 0.5 - 0.01;
  t *= 1. - uProgress * 0.5;
  vHeight = t;
  wPos.z += t;
  wPos.x += sin(t * 5. + wPos.y + uTime * 4.) * t * 0.1;
  wPos.y += cos(t * 4. + wPos.x + uTime * 6.) * t * 0.1 + 0.8 * t * t;
  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}