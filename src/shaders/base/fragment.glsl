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
uniform sampler2D uPerlin;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec2 uv = vUv;
  vec3 pos = vWorldPosition;

  vec2 offest = vec2(
    texture(uPerlin, vec2(uv.y + uTime * 0.2, 0.5) * .3).r,
    texture(uPerlin, vec2(uv.x + uTime * 0.2, 0.5) * .3).r
  );
  offest *= 0.08;
  float v = 1. - texture(uMap, uv * uFrequency + offest + uTime * 0.1).b;

  // v +=  texture(uMap, uv * uFrequency * 2. + 10.).r * 0.5;
  // v +=  texture(uMap, uv * uFrequency * 4. + 20.).r * 0.25;
  v = pow(v, 4.);

  // v /= 1.75;

  vec3 baseColor = vec3(v);

  vec3 color = baseColor;
  gl_FragColor = vec4(color,1.0);

  // #include <tonemapping_fragment>
  // #include <colorspace_fragment>
}