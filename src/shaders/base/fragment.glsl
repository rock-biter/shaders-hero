#include ../functions.glsl;
#include ../lights.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../curl.glsl;
#include ../fbm.glsl;

uniform float uTime;
uniform float uProgress;

varying vec2 vUv;
varying vec3 vWorldPosition;

void main() {

  vec2 uv = vec2(vUv);
  vec3 color = vec3(1.0);

  gl_FragColor = vec4(color,1.0);
}