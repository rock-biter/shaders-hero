#include ../functions.glsl;
#include ../lights.glsl;
#include ../noise.glsl;
#include ../fbm.glsl;
#include ../voronoi.glsl;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform float uParallaxSize;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying vec3 vTangent;
varying vec3 vParallax;

void main() {

  vec4 mapColor = vec4(0.0);
  int iterations = 2;

  for(int i = 0; i < iterations; i++) {
    vec2 uv = vec2(vUv - vParallax.xy * (float(i) * 1. * uParallaxSize + 0.3));

    vec2 t = 1.0 - smoothstep(0.99,2.8,uv);
    // vec2 t = 1.0 - smoothstep(1.,1.,uv);
    t *= smoothstep(-1.8,0.,uv);
    // t *= smoothstep(0.,0.,uv);

    // mapColor.rgb += texture2D(uMap, uv).rgb;
    float c = cellular(vec3(uv * uFrequency,float(i + 1) * 2. * uParallaxSize + uTime * 0.3)) * min(t.x,t.y) * (10. - float(i)) / 10.;
    c = pow(c,2.);
    mapColor.a += min(t.x,t.y) * c;
    mapColor.rgb += vec3(0.,c,c * float(iterations + 1 - i) / float(iterations + 1));
  }


	vec3 color = vec3(mapColor.rgb);
  gl_FragColor = vec4(color,mapColor.a);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}