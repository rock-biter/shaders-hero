varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying float vHeight;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform sampler2D uNoise;

uniform float uProgress;
uniform float uAlphaOffset;
uniform float uFireFallinOffset;
uniform float uFireFallinMargin;
uniform float uFireFalloffOffset;
uniform float uFireFalloffMargin;

uniform float uFireFrequency;
uniform float uFireAmplitude;
uniform float uFireExpAmplitude;

uniform vec2 uPointerVelocity;

#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;


void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal,0.0)).xyz;
  vec3 pos = position;
  vec4 wPos = (modelMatrix * vec4(pos,1.0));

  float edge = (1.0 - uProgress * 1.5) * (1.5 + uAmplitude);
  float d = length(wPos.xyz);
  d -= cnoise(vec4(wPos.xyz * uFrequency , uTime * 0.2)) * uAmplitude * 1.;
  d += fbm(wPos.xyz * uFrequency * 4. + uTime * 0.1,2) * uAmplitude * 1.;

  // Fire
  float fireFallin = falloff(d + uFireFallinOffset,2. + uAmplitude, -uAmplitude,uFireFallinMargin,uProgress);
  float t = smoothstep(edge - 0.3, edge + 0.1, d + uAlphaOffset);
  float fireFalloff = 1.0 - falloff(d + uFireFalloffOffset,2. + uAmplitude, -uAmplitude,uFireFalloffMargin,uProgress);

  // fire height
  float fireHeight = cnoise(wPos.xyz * uFireFrequency + vec3(uTime * 0.5));
  fireHeight = fireHeight * 0.5 + 0.5;
  fireHeight = pow(fireHeight, uFireExpAmplitude);
  fireHeight *= uFireAmplitude;
  fireHeight *= 1. - uProgress * 0.3;

  vHeight = fireFallin * fireFalloff;
  vHeight *= fireHeight;
  wPos.z += vHeight;
  // oscillazione orizzontale
  wPos.x += cnoise(vec3(wPos.xy, wPos.z + uTime)) * wPos.z * 0.5 - clamp(uPointerVelocity.x,-0.1,0.1) * wPos.z * wPos.z * 8.;
  // oscillazione verticale
  wPos.y += cnoise(vec3(wPos.xy + 50., wPos.z + uTime)) * wPos.z * 0.5;
  wPos.y += 1. * wPos.z * wPos.z;
  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}