#include ../functions.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform vec3 uColorA;
uniform vec3 uColorB;
uniform float uTime;
uniform float uVelocity;

varying float vAlpha;
varying float vS;
varying float vFog;
varying vec3 vWPos;
varying float vPointerDistance;
varying float vR;


void main() {

  vec2 uv = gl_PointCoord;
  uv.y = 1.0 - uv.y;
  uv -= 0.5;
  uv *= 2.0;
  float t = length(uv);

  float pDist = max(0.0, 1. - vPointerDistance);
  pDist = pow(pDist, 3.);
  pDist * vR;

  float n = fbm( vec3(vWPos.xz * 70., vWPos.y * 2. + uTime * 2. + cameraPosition.x + cameraPosition.y * 4. + cameraPosition.z * 2. + pDist * 50. * uVelocity ) ,3) * 0.5 + 0.5;
  n = pow(n,30. - pDist * 10. * uVelocity) * (20. + pDist * 20. * uVelocity);
  n *= vAlpha;

  vec3 color = mix(uColorA, uColorB, vAlpha);
  float tPointer = 1. - smoothstep(0.0,1.,vPointerDistance);
  tPointer *= uVelocity;
  color = mix(color, vec3(1.,0.3,0.2), clamp(tPointer,0.0,1.0));
  color = mix(color, vec3(1.), n);


  float a = 1. - smoothstep(0.6 - vS, 0.6 + vS, t);
  a *= vAlpha * vFog;

  gl_FragColor = vec4(color,a);

}