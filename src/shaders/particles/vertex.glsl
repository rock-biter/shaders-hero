attribute float aRandom;

uniform float uSize;
uniform vec2 uResolution;
uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;

varying float vRandom;
varying float vDistance;
varying float vSize;
varying vec3 vWPos;


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

  vDistance = mvPosition.z;
  float s = remap(abs(vDistance + 3.),0.0,3.0,1.0,3.);

  gl_PointSize = s * uSize / - mvPosition.z;
  gl_PointSize *= 0.001 * uResolution.y;

}