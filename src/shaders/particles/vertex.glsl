#include ../functions.glsl;
#include ../math.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;

attribute vec3 aRandom;

uniform float uSize;
uniform vec2 uResolution;
uniform float uTime;
uniform float uMinDistance;
uniform float uMaxDistance;

varying vec3 vWorldPosition;
varying vec3 vRandom;

void main() {

  vRandom = aRandom;

  vec4 wPos = modelMatrix * vec4(position,1.0);

  float speed = 1. - smoothstep(0.0,10.,length(wPos) );
  wPos.xz = rotate(uTime * speed * 0.3) * wPos.xz;
  wPos.y += cnoise(wPos.xyz * 0.5 + uTime * 0.5) * 0.1;

  vWorldPosition = wPos.xyz;
  vec4 mvPos = viewMatrix * wPos;

  gl_Position = projectionMatrix * mvPos;
  float size = uSize;
  float scale = 1. - smoothstep(uMinDistance,uMaxDistance,length(wPos));
  scale = pow(scale, 2.0);
  size *= (0.5 + aRandom.y * 0.5);
  size *= scale;
  gl_PointSize =  size / -mvPos.z;
  gl_PointSize *= 0.001 * uResolution.y;
  gl_PointSize *= 1. + noise(uTime * aRandom.z * .2 + aRandom.y * 100.) * 0.4;

}