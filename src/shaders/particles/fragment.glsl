#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform float uTime;
uniform float uProgress;

varying vec3 vWorldPosition;

void main() {

  vec3 color = vec3(1.0);
  vec2 pointUV = gl_PointCoord;
  pointUV.y = 1.0 - pointUV.y;
  pointUV -= 0.5;
  pointUV *= 2.0;

  float a = 1. - smoothstep(0.2,1.0, length(pointUV));

  gl_FragColor = vec4(color,a);
}