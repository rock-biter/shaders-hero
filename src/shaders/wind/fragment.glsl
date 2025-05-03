#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform float uProgress;
uniform float uTime;

varying vec2 vUv;
varying vec3 vWorldPosition;

void  main() {
  vec3 color = vec3(0.7);
  vec3 blue = vec3(0.3, 0.45, 1.0);

  color *= 1.0 - random(vWorldPosition.xz) * 0.2;

  float d = length(vWorldPosition.xz);

  float alpha = 1.0;

  vec3 offset = vec3(0.);
  offset.x = noise(vWorldPosition.z * 1.) * 0.5;
  offset.z = noise(vWorldPosition.x * 1. + 20.) * 0.5 + uTime;
  alpha *= fbm( vWorldPosition * vec3(1.,1.,0.3) + offset + vec3(0.,uTime * 0.4, 0.0) , 3);
  alpha = pow(alpha, 4.);
  alpha *= 1.5;
  alpha = clamp(alpha, 0.0, 1.0);
  alpha += cnoise(vec4(vWorldPosition, uTime * 0.5)) * 0.2;
  color += blue * alpha;


  float alphaFalloff = falloff(d, 0.0, 10., 2., uProgress);
  alpha *= 1.0 - smoothstep(2., 4., d);
  alpha *= alphaFalloff;
  alpha *= 0.75;
  gl_FragColor = vec4(color,alpha);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}