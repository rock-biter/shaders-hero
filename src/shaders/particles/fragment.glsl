#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform float uTime;
uniform float uProgress;
uniform vec3 uFireColor;
uniform vec3 uBurnColor;
uniform float uFireScale;
uniform float uFrequency;
uniform float uAmplitude;
uniform sampler2D uMap;

varying vec3 vWorldPosition;
varying vec3 vWorldOriginalPosition;
varying vec3 vRandom;
varying float vLife;
varying vec2 vUv;

void main() {

  vec2 pointUV = gl_PointCoord;
  pointUV.y = 1.0 - pointUV.y;
  pointUV -= 0.5;
  pointUV *= 2.0;

  vec4 mapColor = texture(uMap,vUv);
  vec3 color = mix(uFireColor,mapColor.rgb,0.6);

  float a = mapColor.a;
  a *= 1. - smoothstep(0.2,1.0, length(pointUV));

  // distance
  float d = length(vWorldOriginalPosition.xyz);
  d -= cnoise(vec4(vWorldOriginalPosition.xyz * uFrequency, uTime * 0.2)) * uAmplitude;
  d += fbm(vWorldOriginalPosition.xyz * uFrequency * 4. + uTime * 0.1, 2) * uAmplitude;

  // alpha
  float fallin = falloff(d + 0.15,2. + uAmplitude,0. - uAmplitude,0.05,uProgress);
  float falloff = 1. - falloff(d,2. + uAmplitude,0. - uAmplitude,0.05,uProgress);

  a *= fallin * falloff;

  float colorBloom = 1. - smoothstep(0., vLife * 0.3 + vRandom.x * 0.2, vWorldPosition.z);
  color += colorBloom * uFireColor * uFireScale;

  float colorDark = smoothstep(vLife * 0.75, vLife, vWorldPosition.z);
  // color *= colorDark;

  color = mix(color, uBurnColor, colorDark);
  a -= colorDark;
  a = max(0.0,a);

  gl_FragColor = vec4(color,a);
}