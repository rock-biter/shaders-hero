#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../lights.glsl;

struct Blend {
  float scale;
  float start;
  float end;
};

uniform sampler2D uMap;
uniform float uTime;
uniform float uGlossiness;
uniform float uRadius;
uniform float uAlphaExp;
uniform HemiLight uHemi;
uniform PointLight uPointLight;
uniform DirectionalLight uDirLight;
uniform Blend uBlend;

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

  light += hemiLight(uHemi.skyColor,uHemi.groundColor, uHemi.intensity, n);
  vec3 lightDir = normalize(uDirLight.direction);
  vec3 lightColor = uDirLight.color;
  light += dirLight(lightColor,uDirLight.intensity,lightDir, n, -viewDir, 1. + vRandom * 2.);
  light += pointLight(uPointLight.color, uPointLight.intensity, uPointLight.position, vWorldPosition, n, uPointLight.maxDistance, -viewDir, uGlossiness);

  float blend = remap(length(light) * uBlend.scale,0.0,1.0, uBlend.start, uBlend.end);

  light = pow(light, vec3(3.0));

  vec3 color = vec3(1.0);
  color *= light;

  float a = pow(mapColor.a,uAlphaExp);
  color *= 1.0 - random(uv * 3. + 100. + uTime * 1.) * 0.5;
  a *= smoothstep(uRadius, uRadius + 0.1, length(vWorldPosition.xz));
  color *= a;

  a *= blend;
  
  gl_FragColor = vec4(color, a);
  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}