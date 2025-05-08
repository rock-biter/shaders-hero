#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../lights.glsl;


uniform sampler2D uMap;
uniform float uTime;

varying vec2 vUv;
varying vec3 vColor;
varying vec3 vWorldPosition;
varying float vRandom;

mat2 rotate(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, -s, s, c);
}

void main() {
  vec3 viewDir = normalize(cameraPosition - vWorldPosition);
  vec2 uv = gl_PointCoord;
  
  uv.y = 1. - uv.y;
  
  vec2 uvMap = uv;
  if(vRandom > 0.5) {
    uvMap.y = 1.0 - uvMap.y;
  }
  uvMap -= 0.5;
  float dir = 1.;//sign((vRandom * 2. - 1.));
  uvMap = rotate(vRandom * dir * 200. + uTime * 0.2 * dir ) * uvMap;
  uvMap += 0.5;
  vec4 mapColor = texture(uMap,uvMap);

  uv -= 0.5;
  uv *= 2.;

  // uv = rotate(vRandom * 3.14159 * 0.5) * uv;

  vec3 n = vec3(uv, 0.0);
  float alpha = acos(length(uv));
  n.z = sin(alpha);

  // from view space to worlspace
  n = (transpose(viewMatrix) * vec4(n,0.0)).xyz;

  vec3 light = vec3(0.);

  // light += hemiLight(vec3(0.3,0.1,0.2)*0.5,vec3(0.8,0.5,0.3), 0.5, n);
  light += hemiLight(vec3(0.3,0.1,0.2)*0.5,vec3(0.8,0.5,0.3), 0.5, n);
  vec3 lightDir = normalize(vec3(1.,2.,0.5));
  vec3 lightColor = vec3(0.7,0.4,0.1);
  // vec3 lightColor = vec3(0.4,0.8,0.9) * 0.7;
  light += dirLight(lightColor,0.3,lightDir, n, -viewDir, 1. + vRandom * 2.);
  light += pointLight(vec3(1.), 0.255, vec3(0,0.5,0), vWorldPosition, n, 14., -viewDir, 10.);
  // light += pointLight(vec3(1.,0.2,0.01), 0.5, vec3(-3., -4., 5.), vWorldPosition, n, 10., -viewDir, 20.);

  // float dp = clamp(+ 0.8 + dot(lightDir, n),0.0,0.7);
  float dp = clamp(length(light) * 1., 0.75, 0.99);

  light = pow(light, vec3(3.0));

  vec3 color = vec3(1.0);
  color *= light;

  float d = length(uv);
  d = step(1.0,d);
  float t = 1. - d;

  // float a = t;
  float a = mapColor.a * 1.5;
  // if(a == 0.) {
  //   discard;
  // }
  color *= 1.0 - random(uv * 3. + 100. + uTime * 1.) * 0.4;
  a *= smoothstep(1.3, 1.4, length(vWorldPosition.xz));
  color *= a;

  // color = 1. - mapColor.rgb * 0.5 * (1. - dp);
  // color *= ;

  a *= 1.0 - dp;
  
  // a *= 0.5;
  
  gl_FragColor = vec4(color, a);
  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}