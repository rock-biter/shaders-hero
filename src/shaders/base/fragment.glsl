#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
// #include ../fbm.glsl;
// #include ../cellular.glsl;
#include ../lights.glsl;
// #include ../curl.glsl;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform samplerCube uEnvMap;
uniform bool uInnerFace;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

vec3 reflectRefractDir(vec3 refractDir, vec3 rightDir, vec3 upDir) {
  refractDir = reflect(refractDir, rightDir); // riflessione orizzontale
  refractDir = reflect(refractDir, upDir); // riflessione verticale
  refractDir = normalize(refractDir);
  return refractDir;
}

void main() {

  vec3 cameraX = vec3(viewMatrix[0][0], viewMatrix[1][0], viewMatrix[2][0]);
  vec3 cameraY = vec3(viewMatrix[0][1], viewMatrix[1][1], viewMatrix[2][1]);

  vec3 pos = vWorldPosition;
  vec3 viewDir = normalize(pos - cameraPosition);
  vec3 normal = normalize(vNormal); 

  if(uInnerFace == true) {
    normal = -normal;
  }


  vec3 baseColor = vec3(0.85,0.89,1.0) * 0.8;

  vec3 lightDir = normalize(vec3(-1,3,1));

  vec3 light = vec3(0.);

  // specular light
  float specular = smoothstep(0.2, 0.8 ,phongSpecular(viewDir, lightDir, normal, 5.));
  if(uInnerFace == true) {
    light += specular * 0.15;
  } else {
    light += specular * 0.8;
  }


  // hemi light
  light += hemiLight(vec3(0.0), vec3(0.,0.1, 0.3), 0.3, normal);

  vec3 envCorrection = vec3(-1.,1.0,1.0);

  // reflection
  vec3 reflectDir = normalize(reflect(viewDir, normal));
  float inverseFresnel = max(0.0, dot(-viewDir, normal));
  float fresnel = 1.0 - inverseFresnel;
  vec3 reflectColor =  texture(uEnvMap, reflectDir * envCorrection).rgb;
  light += reflectColor * fresnel * 0.7;

  // refraction
  float refFresnel = pow(fresnel, 2.0);
  vec3 refractDirR = reflectRefractDir(normalize(refract(viewDir, normal, 1.0 / 1.07)), cameraX, cameraY);
  vec3 refractDirG = reflectRefractDir(normalize(refract(viewDir, normal, 1.0 / (1.07 + 0.025 * refFresnel))), cameraX, cameraY);
  vec3 refractDirB = reflectRefractDir(normalize(refract(viewDir, normal, 1.0 / (1.07 + 0.035 * refFresnel))), cameraX, cameraY);
  float refractColorR = texture(uEnvMap, refractDirR * envCorrection).r;
  float refractColorG = texture(uEnvMap, refractDirG * envCorrection).g;
  float refractColorB = texture(uEnvMap, refractDirB * envCorrection).b;
  vec3 refractColor = vec3(refractColorR, refractColorG, refractColorB);
  
  if(uInnerFace == false) {
    light += refractColor * inverseFresnel * 2.;
  }
  

  vec3 color = baseColor * light;

  // random noise
  if(uInnerFace == true) {
    color *= 0.35;
    color *= pow(inverseFresnel, 2.52);

  } else {
    color *= 0.9;
    float rNoise = 1. + random(pos + 100.) * ( 0.15  + 0.25 * fresnel);
    color *= rNoise;  

  }


  // sparkling
  if(uInnerFace == false) {
    vec2 cellUV = vUv;
    cellUV *= 60.;
    cellUV += vec2(0.0, -uTime * 10.);
    vec2 baseUV = floor(cellUV);
    cellUV = fract(cellUV) - 0.5;
    cellUV *= vec2(4.,2.);
    cellUV.x += sin(baseUV.y * 10. + uTime * 10.) * 0.4;
    cellUV.y += cos(baseUV.x * 10. + uTime) * 0.3;

    float shapeRadius = cnoise(vec3(baseUV * 10., 0.3));
    shapeRadius *= 0.6;

    float shapeAttenuation = 1. - abs(normal.y);
    shapeAttenuation = pow(shapeAttenuation, 3.0);

    float shape = 1. - smoothstep(shapeRadius - 0.2, shapeRadius,length(cellUV));
    shape *= shapeAttenuation;
    // color = vec3(shape);
    // color.rg *= cellUV;

    color *= 1.0 + shape;
  }


  
  // color.xy += cellUV;
  gl_FragColor = vec4(color,1.0);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}