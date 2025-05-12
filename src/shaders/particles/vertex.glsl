#include ../functions.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform vec2 uResolution;
uniform vec2 uPointer;
uniform float uSize;
uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform float uSpeed;
uniform float uDepth;
uniform float uVelocity;

varying float vAlpha;
varying float vS;
varying float vFog;
varying vec3 vWPos;
varying float vPointerDistance;
varying float vR;

void main() {
  vec4 wPos = modelMatrix * vec4(position,1.0);
  float e = cnoise(wPos.xz * uFrequency + uTime * uSpeed) * uAmplitude;
  wPos.y = e;

  vAlpha = fbm(wPos.xz * uFrequency * 5. + uTime * uSpeed, 3);

  vWPos = wPos.xyz;

  vec4 mvPos = viewMatrix * wPos;

  float d = mvPos.z;
  float s = remap(abs(d + uDepth),0.,3.,1.,4.);
  vS = remap(abs(d + uDepth),0.,3.,0.,0.4);
  vFog = 1. - smoothstep(4.5, 7.5, -d);

  gl_Position = projectionMatrix * mvPos;

  vec2 aspect = uResolution.xy / uResolution.xx;

  float pointerDistance = distance(uPointer * aspect, aspect * gl_Position.xy / gl_Position.w);
  float n = cnoise(wPos.xyz * 1.5 + uTime * 0.75) * 0.2;
  float r = max(0.0,1.0 + mvPos.z * 0.1); 
  float t = 1. - smoothstep(0.0, r, pointerDistance + n);
  // float t2 = 1.0 - step(0.3, pointerDistance );
  vR = r;

  vPointerDistance = pointerDistance;

  wPos.y += t * 0.25 * uVelocity;
  mvPos = viewMatrix * wPos;
  gl_Position = projectionMatrix * mvPos;

  gl_PointSize =  s * uSize / -mvPos.z;
  gl_PointSize *= 0.001 * uResolution.y;
}