#include ../functions.glsl;
#include ../lights.glsl;
#include ../noise.glsl;
#include ../fbm.glsl;
#include ../voronoi.glsl;

uniform float uTime;
uniform float uFrequency;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec4 mapColor = vec4(vUv,1.0,1.0);

	vec3 color = vec3(mapColor.rgb);
  gl_FragColor = vec4(color,mapColor.a);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}