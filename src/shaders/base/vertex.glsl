#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform float uTime;
uniform float uTerrainFrequency;
uniform float uTerrainAmplitude;
uniform float uProgress;
uniform sampler2D uTriangles;
uniform sampler2D uPerlin;
uniform sampler2D uFBM;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

float elevation(vec3 pos, float f, float a) {
  float elevation = texture(uFBM, pos.xz * f).r * a;
  float elAttenuation = 0.1 + linearstep(0.0, 30., length(pos.xz)) * 0.9;
  return elevation * elAttenuation;
}

void main() {
  vUv = uv;
  
  vec3 pos = position;
  vec3 posX = position + vec3(0.5, 0.0, 0.0);
  vec3 posZ = position + vec3(0.0, 0.0, 0.5);

  pos.y += elevation(pos, uTerrainFrequency, uTerrainAmplitude);
  posX.y += elevation(posX, uTerrainFrequency, uTerrainAmplitude);
  posZ.y += elevation(posZ, uTerrainFrequency, uTerrainAmplitude);

  vec4 wPos = modelMatrix * vec4(pos,1.0);
  vWorldPosition = wPos.xyz;

  vec3 n = normalize(cross(posZ - pos, posX - pos));
  vNormal = (modelMatrix * vec4(n,0.0)).xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}