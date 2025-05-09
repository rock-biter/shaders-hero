#include ../functions.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;

uniform vec2 uResolution;
uniform sampler2D uMap;
uniform float uTime;
uniform float uProgress;
uniform vec3 uFireColor;
uniform vec3 uBurnColor;
uniform float uFireScale;
uniform float uFrequency;
uniform float uAmplitude;

varying vec3 vWorldPosition;
varying vec3 vWorldOriginalPosition;
varying vec2 vUv;
varying float vRandom;
varying float vLife;

void main() {

  vec2 uv = vec2(vUv);
  vec4 mapColor = texture(uMap, uv);
  vec3 color = uFireColor * 0.4 + mapColor.rgb * 0.6;
  float a = mapColor.a;
  vec2 pointUV = gl_PointCoord;
  pointUV.y = 1.0 - pointUV.y;
  pointUV -= 0.5;
  pointUV *= 2.0;

  a *= 1. - smoothstep(0.2,1.0, length(pointUV));

    // distance
  float d = length(vWorldOriginalPosition.xy);
  d -= cnoise(vec4(vWorldOriginalPosition.xyz * uFrequency, uTime * 0.2)) * uAmplitude;
  d += fbm(vWorldOriginalPosition.xyz * uFrequency * 4. + uTime * 0.1, 2) * uAmplitude;

  // alpha
  float fallin = falloff(d + 0.15,2. + uAmplitude,0. - uAmplitude,0.05,uProgress);
  float falloff = 1. - falloff(d,2. + uAmplitude,0. - uAmplitude,0.05,uProgress);

  a *= fallin * falloff;

  // color scale
  float colorBloom = 1. - smoothstep(0.,vLife * 0.3 + vRandom * 0.2,vWorldPosition.z);
  color += colorBloom * uFireScale * uFireColor;

  float colorDark = smoothstep(vLife,vLife * 1.5,vWorldPosition.z);
  // color = mix(color, uBurnColor, pow(colorDark,2.));

  gl_FragColor = vec4(color,a);
}