attribute vec3 tangent;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform float uParallaxSize;


#include ../noise.glsl;
#include ../perlin.glsl;

varying vec3 vParallax;
varying vec3 vTangent;

void main() {
  vUv = uv;
  vNormal = normalize(modelMatrix * vec4(normal,0.0)).xyz;
  vec3 modelTangent = normalize(modelMatrix * vec4(tangent,0.0)).xyz;

  vec3 biTangent = normalize(cross(vNormal, modelTangent));
  mat3 tbn = transpose(mat3(modelTangent, biTangent, -vNormal));

  vTangent = biTangent;

  vec3 pos = position;
  vec4 wPos = (modelMatrix * vec4(pos,1.0));

  vec3 camDir = normalize(tbn * cameraPosition - tbn * wPos.xyz);
  camDir = camDir;
  vParallax.xy = camDir.xy;

  // scala il vettore di parallax
  float parallaxScale = uParallaxSize;
  parallaxScale * length(vParallax);
  parallaxScale /= length(dot(camDir,vec3(0.0,0.0,1.0)));  
  vParallax *= parallaxScale;

  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}