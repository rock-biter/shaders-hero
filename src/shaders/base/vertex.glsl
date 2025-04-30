#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

attribute vec3 tangent;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform int uOctaves;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {
  vUv = uv;
  vec3 wNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  vec3 wTangent = (modelMatrix * vec4(tangent, 0.0)).xyz;
  vec3 wBitangent = normalize(cross(wNormal, wTangent));

  vec3 dt = wTangent * 0.001;
  vec3 dbt = wBitangent * 0.001;

  vec4 wPos = modelMatrix * vec4(position,1.0);
  vec4 wPosT = wPos;
  wPosT.xyz += dt;

  vec4 wPosBT = wPos;
  wPosBT.xyz += dbt;

  vec3 offset = wNormal * cnoise(wPos.xyz * uFrequency + uTime * 0.5) * uAmplitude;
  vec3 offsetT = wNormal * cnoise(wPosT.xyz * uFrequency + uTime * 0.5) * uAmplitude;
  vec3 offsetBT = wNormal * cnoise(wPosBT.xyz * uFrequency + uTime * 0.5) * uAmplitude;
  
  wPos.xyz += offset;
  wPosT.xyz += offsetT;
  wPosBT.xyz += offsetBT;
  
  vWorldPosition = wPos.xyz;
  vNormal = normalize( cross( wPosT.xyz - wPos.xyz, wPosBT.xyz - wPos.xyz ));
  // vNormal = wNormal;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}