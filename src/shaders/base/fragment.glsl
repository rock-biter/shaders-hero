#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;
#include ../cellular.glsl;
#include ../lights.glsl;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform int uOctaves;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec3 light = vec3(0.0);
  vec3 viewDir = normalize(vWorldPosition - cameraPosition);
  vec3 normal = normalize(vNormal);
  vec3 lightDir = normalize( vec3(0.5,1.0,0.3));

  light += vec3(0.1,0.1,0.2);
  light += dirLight(vec3(0.8,0.8,1.0), 0.5, lightDir, normal, viewDir, 4.0);


  vec2 uv = vUv;
  uv *= 10.;
  vec3 p = vWorldPosition * uFrequency;
  
  vec3 offset = vec3(
    noise(vWorldPosition * uFrequency * 3. + uTime),
    noise(vWorldPosition * uFrequency * 3. + uTime + vec3(1.256,5.468,9.459)),
    noise(vWorldPosition * uFrequency * 3. + uTime + vec3(5.1236,2.758,7.568))
  );

  p += offset * 0.2;

  float caustic = cellular(vec4(p,uTime * 0.5));
  caustic = pow(caustic, 2.5);

  float causticAngle = clamp(0.7 + dot(normal,lightDir), 0.0, 1.0);

  light += caustic * 0.4 * causticAngle;

  vec3 baseColor = vec3(1.0);

  vec3 color = baseColor;
  color *= light;
  gl_FragColor = vec4(color,1.0);

  // #include <tonemapping_fragment>
  // #include <colorspace_fragment>
}