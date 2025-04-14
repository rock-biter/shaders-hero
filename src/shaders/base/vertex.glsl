varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform sampler2D uNoise;

#include ../noise.glsl;
#include ../perlin.glsl;

void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal,0.0)).xyz;
  vec3 pos = position;
  // pos.z += cnoise(position.xy * uFrequency) * uAmplitude;
  vec4 wPos = (modelMatrix * vec4(pos,1.0));
  float e = texture(uNoise,wPos.xz * uFrequency ).r;
  e = e * 2.0 - 1.0;
  e *= uAmplitude;


  // wPos.y += e;

  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}