#include ../noise.glsl;
#include ../random.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform float uTime;
uniform float uProgress;

varying vec3 vPos;
varying vec2 vUv;

float falloff(float d, float start, float end, float margin, float progress) {
    float m = margin*sign(end-start);
    float p = mix(start-m, end, progress);
    return 1. - smoothstep(p, p + m, d);
}

void main() {

  vec3 blue = vec3(0.3, 0.45, 1.0);

  float alpha = 1.0;
  vec3 color = vec3(0.7);

  color *= 1.0 - random(vPos.xz) * 0.2;

  alpha *= fbm(vec4(vPos * vec3(1.,1.0,0.5 ) + vec3(noise(vPos.z * 0.5) * 0.5, 0.0, noise(vPos.x + 20.) * 0.5) + vec3(0.0,0.0,uTime * 0.4), uTime * 0.4), 5 );
  alpha = pow(alpha, 2.0);
  alpha *= 2.0;
  alpha = clamp(alpha,0.0,1.0);

  alpha += cnoise(vec4(vPos, uTime * 0.5)) * 0.5;
  color += blue * alpha * 1.;

  alpha *= falloff(length(vPos),0.5, 7., 2., uProgress);
  alpha *= 1.0 - smoothstep(3.,4.,length(vPos));

  gl_FragColor = vec4(color, alpha);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}