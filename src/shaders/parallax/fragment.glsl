#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;
#include ../voronoi.glsl;

uniform float uTime;
uniform float uFrequency;
uniform int uParallaxStep;
uniform sampler2D uMap;
uniform float uParallaxOffset;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying vec2 vParallax;

void main() {

  vec2 uv = vUv;
  vec3 mapColor = vec3(0.0);
  float alpha = 0.;

  for(int i = 0; i < uParallaxStep; i++) {
    uv += vParallax * float(i + 1);

    vec2 t = smoothstep(-1.8,0.0,uv);
    t *= 1.0 - smoothstep(1.0,2.8,uv);

    float c = cellular(vec4(uv * uFrequency, uParallaxOffset * float(i) * uFrequency , uTime * 0.5
    ) );
    c = pow(c, 2.0);
    float pStep = float(uParallaxStep);
    c *= (pStep - float(i)) / pStep;
    alpha += c * min(t.x,t.y);

    mapColor += vec3(0.,c,c * (pStep - float(i)) / pStep );

    // mapColor += texture(uMap,uv).rgb * min(t.x,t.y);
  }

  // alpha /= float(uParallaxStep);

  
  // mapColor.a = c;

  gl_FragColor = vec4(mapColor,alpha);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}