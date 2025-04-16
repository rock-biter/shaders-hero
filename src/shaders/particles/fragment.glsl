uniform sampler2D uMap;
uniform float uTime;
uniform float uSpeed;

varying float vRandom;
varying float vDistance;
varying float vSize;
varying vec3 vWPos;
varying float vS;
varying float vFog;
varying float vMouseDistance;

#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

void main () {
  vec2 uv = gl_PointCoord;
  uv -= 0.5;
  uv *= 2.0;
  float t = length(uv);
  t = 1. - min(1.0 , smoothstep(0.6 - vS, 0.6 + vS, t));

  float mDist = pow(vMouseDistance,3.);

  vec3 color = vec3(0.0,0.2,0.95);
  float n1 = fbm(vec3(vWPos.xz * (70.) + mDist * 30. * uSpeed, uTime * 0.5 * vWPos.y + cameraPosition.z * 2. + cameraPosition.x + cameraPosition.y * 4.),3) * 0.5 + 0.5;
  // float n2 = random(vWPos.zx + time);
  float glitter = pow(n1, 30.0 - mDist * 10. * uSpeed) * (20. + mDist * 20. * uSpeed); 
  glitter *= vSize;

  // float glitter = random(vWPos.xz + floor(uTime * 10.)) * 0.95;
  color = mix(color, vec3(0.2,0.1,0.9),vSize);
  color = mix(color, vec3(1.,0.3,0.2),clamp(pow(mDist,1.) * uSpeed * 1.5,0.0,1.0));
  color = mix(color, vec3(1.0), glitter);
  // color = mix(color, vec3(1.0), 5. * glitter * pow(vMouseDistance,2.));

  // color = pow(color,vec3(glitter));


  color = pow(color, vec3(1.0 / 2.2));
  gl_FragColor = vec4(color ,t * vFog * vSize );
  // gl_FragColor.a += glitter * 0.5;
}