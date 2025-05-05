#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform sampler2D uMap;
uniform sampler2D uBacksideMap;
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
uniform float uBaseFrequency;
uniform float uBaseAmplitude;
uniform float uBaseStart;
uniform float uBaseEnd;
uniform float uTopFrequency;
uniform float uTopAmplitude;
uniform float uFireAmplitude;

varying vec2 vUv;
varying vec3 vWorldPosition;
varying float vHeight;

void main() {


  vec2 uv = vec2(vUv);

  float a = 1.0;

  a = 1.;
  a *= 1.0 - smoothstep(0.85, 1.,uv.x);
  a *= 1.0 - smoothstep(0.85, 1.0,uv.y);
  a *= smoothstep(0.0, 0.15,uv.x);
  a *= smoothstep(0.0, 0.15,uv.y);
  a *= smoothstep(0.001, 0.05, vHeight );

  // Fire color
  vec3 fire = uFireColor;

  // bottom falloff
  float baseNoise = noise(vec3(vWorldPosition.xy * uBaseFrequency , uTime * 2.)) * uBaseAmplitude;
  float baseFalloff = smoothstep(uBaseStart,uBaseEnd * uFireAmplitude,vHeight - baseNoise );

  fire *= baseFalloff;

  // top bloom
  float topNoise = noise(vec3(vWorldPosition.xy * uTopFrequency , uTime * 10.)) * uTopAmplitude;
  float topBloom = 1. + pow(vHeight + topNoise,2.) * uFireScale * 1.;
  fire *= topBloom;

  // granular effect
  fire *= (1.0 - random(fract(uv * 100.)) * 0.25);
  gl_FragColor = vec4(fire,a);

}