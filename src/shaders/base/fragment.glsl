#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;
#include ../cellular.glsl;
// #include ../lights.glsl;
#include ../curl.glsl;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform int uOctaves;
uniform int uCurlSteps;
uniform sampler2D uMap;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec2 uv = vUv;

  for(int i = 0; i < uCurlSteps; i++) {
    vec2 curl = curlNoise(uv * uFrequency * 10.);
    uv += curl * 0.015;
  }
  // float perlin = cnoise(uv * uFrequency * 10.) * 0.5 + 0.5;
  vec2 uvMap = uv;

  vec3 baseColor = texture(uMap, uvMap).rgb;

  // if(uv.x > 0.5) {
  //   baseColor = vec3(curl,0.0);
  // }

  vec3 color = baseColor;
  gl_FragColor = vec4(color,1.0);

  // #include <tonemapping_fragment>
  // #include <colorspace_fragment>
}