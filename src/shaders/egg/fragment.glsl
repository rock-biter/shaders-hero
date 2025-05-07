#include ../functions.glsl;
#include ../lights.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform vec3 uColor;
uniform float uTime;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec2 uv = vUv;
  vec3 n = normalize(vNormal);
  vec3 pos = vWorldPosition;
  vec3 viewDir = normalize(cameraPosition - pos);

  vec3 light = vec3(0.);

  light += hemiLight(vec3(0.0,0.5,0.9),vec3(0.9,0.2,0.1), 0.3, n);
  vec3 lightDir = normalize(vec3(1.,2.,0.5));
  vec3 lightColor = vec3(0.7,0.4,0.1);
  // vec3 lightColor = vec3(0.4,0.8,0.9) * 0.7;
  light += dirLight(lightColor,1.,lightDir, n, -viewDir, 20.);

  

  vec3 baseColor = vec3(1.);

  // noise
  float t = fbm(pos * 10., 3);
  float t2 = fbm(pos * 100., 3);
  float t3 = fbm(pos * 5., 2);
  // float t4 = fbm(pos * 5., 2);
  baseColor *= 1.2 - t * 0.3 + t2 * 0.3;

  t3 = pow(t3,2.);
  vec3 gold = vec3(1.,0.6,0.4);

  // baseColor = mix(baseColor,vec3(0.9,0.1,0.0),pow(t4,5.));
  baseColor = mix(baseColor,gold,t3);

  // glitter
  float dp = max(0.0,0.8 + dot(n,lightDir));
  float g = cnoise(vec4(pos * 40. , uTime * 10.)) * 0.5 + 0.5;
  g = pow(g,19.);
  g *= dp;

  vec3 color = baseColor * light;
  color *= 1.0 + g * 5.;

  // color *= 1. - random(pos + 100.) * 0.25;
  gl_FragColor = vec4(color,1.0);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}