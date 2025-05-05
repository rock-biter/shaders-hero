#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../curl.glsl;
#include ../fbm.glsl;

uniform float uTime;
uniform float uProgress;
uniform float uFrequency;
uniform float uAmplitude;
uniform float uFireFrequency;
uniform float uFireAmplitude;
uniform float uFireExpAmplitude;
uniform float uFireFallinOffset;
uniform float uFireFallinMargin;
uniform float uFireFalloffOffset;
uniform float uFireFalloffMargin;
uniform vec2 uVelocity;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying float vHeight;

float getFireHeight(vec3 pos, float f, float a, float e) {
  float h = cnoise(pos.xyz * f + vec3(uTime * 0.5));
  h = h * 0.5 + 0.5;
  h = pow(h, e);
  h *= a;
  return h;
}

vec3 translate(vec3 pos, float fallin, float falloff) {
  float fireHeight = getFireHeight(pos,uFireFrequency,uFireAmplitude,uFireExpAmplitude);

  pos.z += falloff * fallin * fireHeight;
  pos.z *= 1.0 - uProgress * 0.4;

  vHeight = pos.z;

  pos.x += cnoise(vec3(pos.xy, pos.z + uTime)) * pos.z * 0.5;
  pos.x -= clamp(uVelocity.x, -0.1, 0.1) * pow(pos.z,2.) * 10.;
  pos.y += cnoise(vec3(pos.xy + 50., pos.z + uTime)) * pos.z * 0.5;
  pos.y += pow(pos.z,2.);

  return pos;
}

void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal,0.0)).xyz;
  vec3 pos = position;
  vec4 wPos = (modelMatrix * vec4(pos,1.0));

  // distance
  float d = length(wPos.xyz);
  d -= cnoise(vec4(wPos.xyz * uFrequency, uTime * 0.2)) * uAmplitude;
  d += fbm(wPos.xyz * uFrequency * 4. + uTime * 0.1, 2) * uAmplitude;

  // alpha
  float fireFallin = falloff(d + uFireFallinOffset,2. + uAmplitude,0. - uAmplitude,uFireFallinMargin,uProgress);
  float fireFalloff = 1. - falloff(d + uFireFalloffOffset,2. + uAmplitude,0. - uAmplitude,uFireFalloffMargin,uProgress);


  // fire shape
  // float fireHeight = cnoise(wPos.xyz * uFireFrequency + vec3(uTime * 0.5));
  // fireHeight = fireHeight * 0.5 + 0.5;
  // fireHeight = pow(fireHeight, uFireExpAmplitude);
  // fireHeight *= uFireAmplitude;

  // wPos.z += fireFalloff * fireFallin * fireHeight;
  // wPos.z *= 1.0 - uProgress * 0.4;


  // wPos.x += cnoise(vec3(wPos.xy, wPos.z + uTime)) * wPos.z * 0.5;
  // wPos.x -= clamp(uVelocity.x, -0.1, 0.1) * pow(wPos.z,2.) * 10.;
  // wPos.y += cnoise(vec3(wPos.xy + 50., wPos.z + uTime)) * wPos.z * 0.5;
  // wPos.y += pow(wPos.z,2.);
  float e = 0.002;
  vec3 wPosX = wPos.xyz + vec3(0. + e,0.,0.);
  vec3 wPosY = wPos.xyz + vec3(0.,0. + e,0.);
  wPos.xyz = translate(wPos.xyz,fireFallin, fireFalloff);
  wPosX = translate(wPosX,fireFallin, fireFalloff);
  wPosY = translate(wPosY,fireFallin, fireFalloff);

  vNormal = normalize(cross(wPosX - wPos.xyz, wPosY - wPos.xyz));

  vHeight = wPos.z;
  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}