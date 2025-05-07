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

vec3 projectSphereToCube(vec3 p) {
    float absX = abs(p.x);
    float absY = abs(p.y);
    float absZ = abs(p.z);
    float maxComponent = max(max(absX, absY), absZ);

    return p / maxComponent;
}


void main() {
  vec3 viewDir = normalize(cameraPosition - vWorldPosition);
  vec2 uv = gl_PointCoord;
  uv.y = 1. - uv.y;
  vec2 vUv = uv;
  uv -= 0.5;
  uv *= 2.;

  vec3 n = vec3(uv, 0.0);
  float alpha = acos(length(uv));
  float z = sqrt(1. - n.x * n.x - n.y * n.y); // oppure sin(alpha);
  n.z = z;
  


  // from view space to worlspace
  n = (transpose(viewMatrix) * vec4(n,0.0)).xyz;
  vec3 pSphere = n;
  float is2 = inversesqrt(2.);


  vec3 oN = n;

  float aX = abs(pSphere.x);
  float aY = abs(pSphere.y);
  float aZ = abs(pSphere.z);
  if(aX > aY && aX > aZ) {
    n = vec3(1.0,0.0,0.0) * sign(pSphere.x);
  }

  if(aY > aX && aY > aZ) {
    n = vec3(0.0,1.0,0.0) * sign(pSphere.y);
  }

  if(aZ > aX && aZ > aY) {
    n = vec3(0.0,0.0,1.0) * sign(pSphere.z);
  }

  // n = clamp(n,-is2 * 2.,is2 * 2.0);
  // viewDir = normalize(cameraPosition - vWorldPosition + n * z);
  float dpfaceculling = step(0.0,dot(n,viewDir));
  

  vec3 light = vec3(0.0);

  light += hemiLight(vec3(0.9,0.9,1.0),vec3(0.2,0.3,0.1), 0.3, n);
  vec3 lightDir = normalize(vec3(1.,2.,0.5));
  light += dirLight(vec3(1.0,0.5,0.1),0.7,lightDir, n, -viewDir, 20.);

  vec3 color = vec3(1.0);
  color *= light;

  // sphere shape
  float d = length(uv);
  d = step(1.0,d);
  float t = 1. - d;

  // square shape
  // t = 0.0;
  // // float is2 = inversesqrt(2.);
  // if(abs(n.x) > is2) {
  //   t = 0.0;
  // }


  float a = t;
  a *= dpfaceculling;
  if(a == 0.) {
    discard;
  }
  
  gl_FragColor = vec4(color,1.0);
}