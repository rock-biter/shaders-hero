#include ../functions.glsl;
#include ../lights.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform vec3 uColor;
uniform vec3 uColorB;
uniform float uTime;
uniform float uExposure;
uniform HemiLight uHemi;
uniform DirectionalLight uDirLight;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying vec3 vPos;
varying vec3 vlPos;

void main() {

  vec2 uv = vUv;
  vec3 n = normalize(vNormal);
  vec3 pos = vWorldPosition;
  vec3 viewDir = normalize(cameraPosition - pos);

  vec3 light = vec3(0.);

  light += hemiLight(uHemi.skyColor,uHemi.groundColor, uHemi.intensity * 0.5, n);
  light += dirLight(uDirLight.color,uDirLight.intensity,uDirLight.direction, n, -viewDir, 20.);

  light *= uExposure;

  vec3 baseColor = uColor;

  // noise
  float t = fbm(vPos * 10., 3);
  float t2 = fbm(vPos * 100., 3);
  float t3 = fbm(vPos * 5., 2);
  baseColor *= 1.2 - t * 0.3 + t2 * 0.3;

  t3 = pow(t3,2.);

  baseColor = mix(baseColor,uColorB,t3);

  // glitter
  float dp = max(0.0,0.8 + dot(n,uDirLight.direction));
  float g = cnoise(vec4(vlPos * (50.) , pos.y * 2. + pos.x * 2. + pos.z * 2. + uTime * 4. - cameraPosition.x * 1. + cameraPosition.y * 2. + cameraPosition.z * 3.)) * 0.5 + 0.5;
  g = pow(g,28.);
  g *= dp;

  vec3 color = baseColor * light;
  color *= 1.0 + g * 10.;

  gl_FragColor = vec4(color,1.0);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}