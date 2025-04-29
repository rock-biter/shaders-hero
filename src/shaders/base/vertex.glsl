#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
// #include ../fbm.glsl;

attribute vec3 tangent;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform sampler2D uPerlin;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vNormalOut;
varying vec3 vWorldPosition;

void main() {
  vUv = uv;
  vec3 bitangent = cross(normal, normalize(tangent));

  vec3 dt = tangent * 0.001;
  vec3 dbt = bitangent * 0.001;
  vec4 wPos = modelMatrix * vec4(position,1.0);
  vec4 wPosT = modelMatrix * vec4(position + dt,1.0);
  vec4 wPosBT = modelMatrix * vec4(position + dbt,1.0);


  vec3 p = wPos.xyz * uFrequency + uTime * 0.5;
  vec3 pT = wPosT.xyz * uFrequency + uTime * 0.5;
  vec3 pBT = wPosBT.xyz * uFrequency + uTime * 0.5;

  float v = cnoise(p);
  float vt = cnoise(pT);
  float vbt = cnoise(pBT);
  wPos.xyz += normal * v * uAmplitude;
  wPosT.xyz += normal * vt * uAmplitude;
  wPosBT.xyz += normal * vbt * uAmplitude;

  vNormal = normalize(cross(normalize(wPosT.xyz - wPos.xyz), normalize(wPosBT.xyz - wPos.xyz)));

  // wPos.z += cnoise(wPos.xy * uFrequency + uTime) * uAmplitude;
  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}