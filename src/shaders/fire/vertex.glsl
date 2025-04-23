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

uniform float uFireFrequency;
uniform float uFireAmplitude;
uniform float uFireExpAmplitude;

uniform vec2 uPointerVelocity;

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
  d -= cnoise(vec4(wPos.xyz * uFrequency , uTime * 0.2)) * uAmplitude * 1.;
  d -= fbm(wPos.xyz * uFrequency * 4. + uTime * 0.1,2) * uAmplitude * 1.;

// Fire
  float t = smoothstep(edge - 0.3, edge + 0.1, d + uOffset1);
  t *= 1. - smoothstep(edge + 0.2, edge + 0.3, d + uOffset1);
  float fireHeight = cnoise(wPos.xyz * uFireFrequency + vec3(uTime * 0.5));
  float h = fireHeight;
  float posH = max(0.0,h);
  fireHeight = fireHeight * 0.5 + 0.5;
  fireHeight = pow(fireHeight, uFireExpAmplitude);
  fireHeight *= uFireAmplitude;
  fireHeight *= 1. - uProgress * 0.3;

  vHeight = fireHeight * t;
  wPos.z += vHeight;
  wPos.x += cnoise(vec3(wPos.xy, wPos.z + uTime)) * wPos.z * 0.5 - uPointerVelocity.x * wPos.z * wPos.z * 10.;
  wPos.y += cnoise(vec3(wPos.xy + 50., wPos.z + uTime)) * wPos.z * 0.5;
  wPos.y += 1.5 * wPos.z * wPos.z;
  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}