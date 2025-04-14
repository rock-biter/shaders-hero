#include ../functions.glsl;
#include ../lights.glsl;
#include ../noise.glsl;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform int uOctaves;
uniform sampler2D uMap;
uniform sampler2D uNoise;
uniform float uCurlIntensity;
uniform int uCurlSteps;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

#include ../perlin.glsl;
#include ../curl.glsl;
// #include ../simplex.glsl;
// #include ../fbm.glsl;
// #include ../voronoi.glsl;

void main() {

  

  // vec2 curl = curlNoise(vUv * uFrequency);
  // float perlin = cnoise(vUv * uFrequency);

  // vec3 baseColor = vec3(0.0);
  // if(vUv.x < 0.5) {
  //   baseColor = vec3(perlin);
  // } else {
  //   baseColor = vec3(curl * 0.5 + 0.5,0.0);
  // }

  vec2 uv = vec2(vUv);
  // vec3 offset = vec2(0.);
  // vec3 t = vec3(0.0);

  // for(int i = 0; i < uCurlSteps; i++) {
  //   vec2 curl = curlNoise(uv * uFrequency) * 0.015;
  //   uv += curl;
  // }

  float t = texture(uNoise,uv * uFrequency).a; 
  // t += texture(uNoise,uv * uFrequency * 2.).r / 4.;
  // t += texture(uNoise,uv * uFrequency * 4.).r / 8.0;
  // t += texture(uNoise,uv * uFrequency * 8.).r / 16.;
  // t = smoothstep(0.15,0.85,t);

	vec3 color = vec3(t);

  gl_FragColor = vec4(color,1.0);
}