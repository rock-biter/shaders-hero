uniform float uTime;
uniform float uProgress;

#include ../functions.glsl;
#include ../perlin.glsl;

varying vec3 vPos;

float falloffsmooth(float d, float start, float end, float margin, float progress) {
    float m = margin*sign(end-start);
    float p = mix(start-m, end, progress);
    return 1. - smoothstep(p, p + m, d);
}

void main() {
  vec3 color = vec3(1.0);
  float alpha = cnoise(vec4(vPos * 2.5 , uTime * 0.5 ));
  alpha = smoothstep(-0.2,0.2, alpha);

  alpha *= falloffsmooth(length(vPos),0.0 - 2.0, 20., 0.5, uProgress);
  alpha *= 1. - smoothstep(0.4, 0.8, uProgress);

  gl_FragColor = vec4(color, alpha);
  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}