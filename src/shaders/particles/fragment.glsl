uniform sampler2D uMap;
uniform float uTime;

varying float vRandom;
varying float vDistance;
varying float vSize;
varying vec3 vWPos;

#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

void main () {
  vec2 uv = gl_PointCoord;
  uv -= 0.5;
  uv *= 2.0;
  float t = length(uv);
  float s = remap(abs(vDistance + 3.),0.0,3.0,0.0,0.4);
  float fog = remap(-vDistance,5., 7.,1.0,0.0);
  t = 1. - min(1.0 , smoothstep(0.6 - s, 0.6 + s, t));

  vec3 color = vec3(0.0,0.2,0.95);
  float time = floor(uTime * 1.); // Controlla la velocità del flash
  float n1 = fbm(vec3(vWPos.xz * 70., uTime * 0.5),3) * 0.5 + 0.5;
  // float n2 = random(vWPos.zx + time);
  float glitter = pow(n1, 30.0) * 20.; 
  glitter *= vSize;

  // float glitter = random(vWPos.xz + floor(uTime * 10.)) * 0.95;
  color = mix(color, vec3(0.2,0.1,0.9),vSize);
  color = mix(color, vec3(1.0), glitter);
  // color = pow(color,vec3(glitter));



  color = pow(color, vec3(1.0 / 2.2));
  gl_FragColor = vec4(color,t * fog * vSize);
  // gl_FragColor.a += glitter * 0.5;
}