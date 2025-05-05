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

varying vec2 vUv;
varying vec3 vWorldPosition;
varying float vHeight;

void main() {
  float a = 1.0;
  vec3 color = uFireColor;

  // base
  float baseNoise = noise(vec3(vWorldPosition.xy * uBaseFrequency, uTime * 2.)) * uBaseAmplitude;
  float baseFalloff = smoothstep(uBaseStart, uBaseEnd * uFireAmplitude, vHeight + baseNoise);

  color *= baseFalloff;


  a *= smoothstep(0.0,0.15,vUv.x);
  a *= 1. - smoothstep(0.85,1.,vUv.x);
  a *= smoothstep(0.0,0.25,vUv.y);
  a *= 1. - smoothstep(0.75,1.,vUv.y);
  a *= smoothstep(0.001,0.03, vHeight);

  gl_FragColor = vec4(color, a);
}