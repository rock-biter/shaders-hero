#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;

uniform float uProgress;
uniform float uTime;

varying vec3 vWorldPosition;

void main() {
  vec3 color = vec3(1.0);
  float alpha = cnoise(vec4(vWorldPosition * 2.5, uTime * 0.5));
  alpha = smoothstep(-0.2, 0.2, alpha);
  float d = length(vWorldPosition);

  float alphaFalloff = falloff(d, 0.0, 20., 0.5, uProgress);
  alpha *= alphaFalloff;
  alpha *= 1.0 - smoothstep(0.4, 0.8, uProgress);

  gl_FragColor = vec4(color, alpha);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}