#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../curl.glsl;
#include ../fbm.glsl;

uniform vec3 uFireColor;
uniform float uTime;
uniform float uBaseFrequency;
uniform float uBaseAmplitude;
uniform float uFireAmplitude;
uniform float uBaseStart;
uniform float uBaseEnd;
uniform float uTopFrequency;
uniform float uTopAmplitude;
uniform float uFireScale;

varying vec2 vUv;
varying vec3 vWorldPosition;
varying float vHeight;
varying vec3 vNormal;

void main() {
  float a = 1.0;
  vec3 color = uFireColor;
  vec3 normal = normalize(vNormal);
  if(gl_FrontFacing == false) {
    normal = -normal;
  }
  vec3 viewDir = normalize(cameraPosition - vWorldPosition);

  float inverseFresnel = max(0.0, dot(viewDir, normal));
  inverseFresnel = pow(inverseFresnel, 2.0);

  // base
  float baseNoise = noise(vec3(vWorldPosition.xy * uBaseFrequency, uTime * 2.)) * uBaseAmplitude;
  float baseFalloff = smoothstep(uBaseStart, uBaseEnd * uFireAmplitude, vHeight + baseNoise);

  color *= baseFalloff;

  // top bloom
  float topNoise = noise(vec3(vWorldPosition.xy * uTopFrequency, uTime * 10.)) * uTopAmplitude;
  float topFalloff = 1. + pow(vHeight + topNoise,2.) * uFireScale * 3.;

  color *= topFalloff * inverseFresnel * 2.;

  color *= 1. - random(vWorldPosition.xy + uTime + 10.) * 0.3;

  a *= smoothstep(0.0,0.15,vUv.x);
  a *= 1. - smoothstep(0.85,1.,vUv.x);
  a *= smoothstep(0.0,0.25,vUv.y);
  a *= 1. - smoothstep(0.75,1.,vUv.y);
  a *= smoothstep(0.001,0.03, vHeight);

  a *=  inverseFresnel * 2.;

  gl_FragColor = vec4(color, a);
}