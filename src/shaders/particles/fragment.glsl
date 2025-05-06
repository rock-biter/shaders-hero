#include ../functions.glsl;
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
  uvMap -= 0.5;
  uvMap = rotate(vRandom * 3. + uTime * 0.1) * uvMap;
  uvMap += 0.5;
  vec4 mapColor = texture(uMap,uvMap);

  uv -= 0.5;
  uv *= 2.;



  vec3 n = vec3(uv, 0.0);
  float alpha = acos(length(uv));
  n.z = sin(alpha);

  // from view space to worlspace
  n = (transpose(viewMatrix) * vec4(n,0.0)).xyz;

  vec3 light = vec3(0.0);

  light += hemiLight(vec3(0.9,0.9,1.0),vec3(0.3,0.2,0.1), 0.3, n);
  vec3 lightDir = normalize(vec3(1.,2.,0.5));
  light += dirLight(vec3(1.0,0.5,0.1),0.4,lightDir, n, -viewDir, 20.);

  light = pow(light, vec3(2.0));

  vec3 color = vec3(1.0);
  color *= light;

  float d = length(uv);
  d = step(1.0,d);
  float t = 1. - d;

  // float a = t;
  float a = mapColor.a;
  // if(a == 0.) {
  //   discard;
  // }
  
  gl_FragColor = vec4(color, a);
}