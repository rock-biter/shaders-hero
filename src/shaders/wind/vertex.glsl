#include ../noise.glsl;
#include ../perlin.glsl;

uniform float uTime;

varying vec3 vPos;
varying vec2 vUv;

void main() {
  vUv = uv;
  float elevation = cnoise(position * vec3(1.0,1.0,.3) + uTime * 0.2) * 0.2;
  vPos = (modelMatrix * vec4(position + vec3(0.,elevation, 0.0), 1.0)).xyz;
  gl_Position = projectionMatrix * viewMatrix * vec4(vPos, 1.0);
}