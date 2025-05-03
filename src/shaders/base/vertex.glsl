#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform float uTime;
uniform float uTerrainFrequency;
uniform float uTerrainAmplitude;
uniform sampler2D uPerlin;
uniform sampler2D uFBM;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

float elevation(vec3 pos, float f, float a) {
  float el = texture(uFBM, pos.xz * f).r * a;
  float attenuation = 0.1 + linearstep(0.0,15.,length(pos)) * 0.9;
  attenuation = pow(attenuation, 2.);

  return el * attenuation;
}

void main() {
  vUv = uv;
  

  vec3 pos = position;
  vec3 posX = pos + vec3(0.2,0,0);
  vec3 posZ = pos + vec3(0,0,0.2);
  
  pos.y += elevation(pos.xyz,uTerrainFrequency, uTerrainAmplitude);
  posX.y += elevation(posX.xyz,uTerrainFrequency, uTerrainAmplitude);
  posZ.y += elevation(posZ.xyz,uTerrainFrequency, uTerrainAmplitude);

  vec3 n = normalize(cross(posZ - pos, posX - pos));
  vNormal = (modelMatrix * vec4(n, 0.0)).xyz;

  vec4 wPos = modelMatrix * vec4(pos,1.0);
  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}