#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../curl.glsl;
#include ../fbm.glsl;

uniform vec3 uFireColor;

varying vec2 vUv;
varying vec3 vWorldPosition;
varying float vHeight;

void main() {
  float alpha = 1.0;
  vec3 color = uFireColor;

  alpha *= smoothstep(0.001,0.03, vHeight);

  gl_FragColor = vec4(color, alpha);
}