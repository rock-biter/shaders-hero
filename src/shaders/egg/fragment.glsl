#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;
#include ../lights.glsl;

uniform float uTime;
uniform vec3 uColor;
uniform vec3 uColorB;
uniform float uExposure;
uniform DirectionalLight uDirLight;
uniform HemiLight uHemi;

varying vec2 vUv;
varying vec3 vWorldPosition;
varying vec3 vPosition;
varying vec3 vNormal;

void main() {

  vec3 viewDir = normalize(vWorldPosition - cameraPosition);
  vec3 n = normalize(vNormal);
  vec3 light = vec3(0.0);
  light += hemiLight(uHemi.skyColor, uHemi.groundColor, uHemi.intensity * 0.5,n);
  light += dirLight(uDirLight.color, uDirLight.intensity, normalize(uDirLight.direction), n,viewDir,20.);
  light *= uExposure;

  vec3 color = uColor;

  // texture
  float t = fbm(vPosition * 10., 3);
  float t2 = fbm(vPosition * 100., 3);
  float t3 = fbm(vPosition * 5., 2);
  t3 = pow(t3,2.);
  color = mix(color, uColorB, t3);
  color *= 1.2 - t * 0.3 + t2 * 0.3;

  color *= light;

  // glitter
  float g = cnoise(vec4(vPosition.xyz * 50., vWorldPosition.y * 2. + uTime * 2. + cameraPosition.x * 2. + cameraPosition.z * 2.5 + cameraPosition.y * 3.)) * 0.5 + 0.5;
  float dp = remap(dot(n, normalize(uDirLight.direction)),-1.,1.0, 0.,1.);
  g = pow(g, 28.);
  g *= dp;
  color *= 1. + g * 10.;

  gl_FragColor = vec4(color,1.0);
}