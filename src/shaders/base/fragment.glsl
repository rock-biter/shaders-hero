#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;
#include ../cellular.glsl;
#include ../lights.glsl;
#include ../curl.glsl;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform sampler2D uPerlin;
uniform samplerCube uEnvMap;
uniform bool uInnerFace;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec3 light = vec3(0.0);
  vec2 uv = vUv;
  vec3 pos = vWorldPosition;
  vec3 normal = normalize(vNormal);
  vec3 viewDir = normalize(pos - cameraPosition);

  if(uInnerFace == true) {
    normal = -normal;
  }

  float inverseFresnel = max(dot(-viewDir, normal), 0.0);
  float fresnel = 1. - inverseFresnel;

  vec3 envCorrection = vec3(-1.0,1.0,1.0);
  vec3 reflecDir = normalize(reflect(viewDir, normal));

  vec3 refracDirR = normalize(refract(viewDir, normal, 1.0 / 1.07));
  // vec3 refracDir = normalize(refract(viewDir, normal, 1.0 / 1.05));
  // refracDir = normalize(refract(refracDir, normal, 1.0 / 1.05));
  vec3 refracDirG = normalize(refract(viewDir, normal, 1.0 / (1.07 + 0.025 * pow(fresnel,2.0))));
  vec3 refracDirB = normalize(refract(viewDir, normal, 1.0 / (1.07 + 0.035 * pow(fresnel,2.0))));
  
  float refracR = textureCube(uEnvMap, refracDirR * envCorrection).r;
  float refracG = textureCube(uEnvMap, refracDirG * envCorrection).g;
  float refracB = textureCube(uEnvMap, refracDirB * envCorrection).b;
  // vec3 refrac = textureCube(uEnvMap, refracDir * envCorrection).rgb;
  vec3 refracColor = vec3(refracR, refracG, refracB);
  vec3 reflecColor = textureCube(uEnvMap, reflecDir* envCorrection).rgb;

  fresnel = pow(fresnel, 1.0);
  inverseFresnel = pow(inverseFresnel, 1.);
  
  // v /= 1.75;

  // dirLight
  vec3 lightDir = normalize(vec3(-1, 3., 1));
  vec3 lightColor = vec3(1.0);
  light += hemiLight( vec3(0.),vec3(0.0,0.1,0.3), 0.3, normal);
  float phongLight = smoothstep(0.2,0.8,phongSpecular(viewDir, lightDir, normal, 5.));
  if(uInnerFace == true) {
    phongLight *= 0.15;
  } else {
    phongLight *= 0.8;
  }
  light += phongLight;
  // if(uInnerFace == false) {
    // light += phongSpecular(viewDir, lightDir, normal, 10.) * 0.7;
  // }
  // light += dirLight(lightColor, 1.0, lightDir, normal, viewDir, 20.0);
  light += reflecColor * fresnel * 0.7;
  if(uInnerFace == false) {
    light += refracColor * inverseFresnel * 2.;
  }

  vec3 baseColor = vec3( 0.85,0.89,1.0 ) * 0.8;
  // vec3 baseColor = vec3(1.0);
  baseColor *= light;

  vec3 color = baseColor;
  if(uInnerFace == true) {
    color *= 0.35;
    color *= pow(inverseFresnel,2.5);
  } else {
    color *= 0.9;
    color *= 1. + random(pos + 100.) * (0.15 + 0.25 * fresnel);
  }
  gl_FragColor = vec4(color,1.);
  // gl_FragColor *= 0.5;

  // grid bubble
  if(uInnerFace == false) {
    vec2 cellUv = vUv;
    cellUv = cellUv * 70. + vec2(0., -uTime * 10. );
    vec2 baseUV = floor(cellUv);
    cellUv = fract(cellUv) - 0.5;
    cellUv *= vec2(4.0,2.0);
    vec2 offset = vec2(0.);
    offset.x += sin(baseUV.y * 10. + uTime * 10.) * 0.4;
    offset.y += cos(baseUV.x * 10. + uTime) * 0.3;
    // offset *= remap(normal.y, -1., 1.0, 0.) 
    float shapeRadius = cnoise(vec3(baseUV * 10., 0.3));
    shapeRadius *= 0.6;
    float shape = 1.0 - smoothstep(shapeRadius - 0.2, shapeRadius, length(cellUv + offset) );
    // shape *= smoothstep(0.,shapeRadius, length(cellUv + offset) );
    float shapeAttenuation = 1. - abs(normal.y);
    shapeAttenuation = smoothstep(0.2, 0.3, shapeAttenuation);
    shapeAttenuation = pow(shapeAttenuation, 3.0);
    shape *= shapeAttenuation;

    // color = vec3(shape);
    // color *= 1. + shape * 0.2;
    gl_FragColor.rgb *= 1. + shape ;
    // gl_FragColor.rgb = vec3(shape);
  }

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}