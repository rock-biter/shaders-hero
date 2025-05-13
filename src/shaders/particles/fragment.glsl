#include ../functions.glsl;
#include ../math.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../lights.glsl;

uniform float uTime;
uniform sampler2D uMap;
uniform DirectionalLight uDirLight;
uniform HemiLight uHemi;
uniform PointLight uPointLight;

varying vec3 vWorldPosition;
varying vec3 vRandom;

void main() {
  vec3 viewDir = normalize(vWorldPosition - cameraPosition);
  vec2 uv = gl_PointCoord;
  
  uv.y = 1. - uv.y;
  vec2 uvMap = uv;
  uvMap -= 0.5;
  uvMap = rotate(uTime * (0.2  + 0.3 * vRandom.y) + vRandom.z * 200.) * uvMap;
  uvMap += 0.5;
  if(vRandom.y > 0.75) {
    uvMap.x = 1.0 - uvMap.x;
  }

  if(vRandom.z < 0.25) {
    uvMap.y = 1.0 - uvMap.y;
  }
  
  vec4 mapColor = texture(uMap, uvMap);
  // uv *= 2.0;

  vec3 light = vec3(0.0);

  

  vec3 color = vec3(1.0);
  float a = mapColor.a;
  // a = 1.0;

  uv -= 0.5;
  uv *= 2.0;
  vec3 n = vec3(uv,0.0);
  // a = 1.0 - step(1.0,length(uv));
  n.z = sqrt(1. - uv.x * uv.x - uv.y * uv.y);

  n = (transpose(viewMatrix) * vec4(n, 0.0)).xyz;

  light += hemiLight(uHemi.skyColor, uHemi.groundColor, uHemi.intensity, n);
  light += dirLight(uDirLight.color, uDirLight.intensity, normalize(uDirLight.direction), n, viewDir, 10.);
  // light += pointLight(uPointLight.color, uPointLight.intensity, uPointLight.position, vWorldPosition, n, uPointLight.maxDistance, viewDir, 20. );

  color = vec3(1.0);
  color *= light;
  
  gl_FragColor = vec4(color, a);
  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}