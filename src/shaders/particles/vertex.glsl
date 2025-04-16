attribute float aRandom;

uniform float uSize;
uniform vec2 uResolution;
uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform vec3 uMouse;
uniform float uSpeed;

varying float vRandom;
varying float vDistance;
varying float vSize;
varying vec3 vWPos;
varying float vS;
varying float vFog;
varying float vMouseDistance;

#include ../perlin.glsl;
#include ../fbm.glsl;
#include ../functions.glsl;

void main() {
  vRandom = aRandom;

  vec4 worldPosition = modelMatrix * vec4(position, 1.0);

  float e = cnoise(worldPosition.xz * uFrequency + uTime * 0.1) * uAmplitude;
  worldPosition.y += e;

  vWPos = worldPosition.xyz;
  float sizeScale = fbm(worldPosition.xz * uFrequency * 5. + uTime * 0.1,3);
  // vSize = floor(sizeScale * 5.0) / 5.0 + 0.1;
  vSize = sizeScale;

  vec4 mvPosition = viewMatrix * worldPosition;
  gl_Position = projectionMatrix * mvPosition;

  float aspect = uResolution.x / uResolution.y;
  vec2 aspectRatio = vec2(1.0);
  float mouseDistance = 1. - distance(aspectRatio * gl_Position.xy / gl_Position.w  , aspectRatio * uMouse.xy);
  // mouseDistance = pow(mouseDistance, 2.);
  float t = smoothstep(0.6,1.0,mouseDistance + cnoise(mvPosition.xyz * 1.5 + uTime * 0.75) * 0.2);

  vMouseDistance = mouseDistance;

  worldPosition.y += uSpeed * t * 0.25 * max(1.0 - pow(mouseDistance, 3.0) * 0.2, 0.0);
  mvPosition = viewMatrix * worldPosition;
  gl_Position = projectionMatrix * mvPosition;

  vDistance = mvPosition.z;
  vS = remap(abs(vDistance + 3.),0.0,3.0,0.0,0.4);
  vFog = remap(-vDistance,4.5, 7.5,1.0,0.0);
  float s = remap(abs(vDistance + 3.),0.0,3.0,1.0,4.);
  // s += mouseDistance * 2.;

  gl_PointSize = s * uSize / - mvPosition.z;
  gl_PointSize *= 0.001 * uResolution.y;


}