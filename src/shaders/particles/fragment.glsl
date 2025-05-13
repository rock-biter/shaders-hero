#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../lights.glsl;

uniform sampler2D uMap;
uniform float uTime;

varying vec2 vUv;
varying vec3 vWorldPosition;


void main() {
  vec3 viewDir = normalize(cameraPosition - vWorldPosition);
  vec2 uv = gl_PointCoord;
  
  uv.y = 1. - uv.y;
  uv *= 2.0;

  vec3 color = vec3(uv, 1.0);
  float a = 1.0;
  
  gl_FragColor = vec4(color, a);
  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}