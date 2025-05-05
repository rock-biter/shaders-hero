#include ../functions.glsl;
#include ../lights.glsl;
#include ../noise.glsl;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform sampler2D uMap;
uniform sampler2D uBacksideMap;
uniform float uProgress;

uniform float uAlphaOffset;
uniform float uAlphaMargin;
uniform float uBurnOffset;
uniform float uBurnMargin;
uniform float uFireOffset;
uniform float uFireMargin;
uniform vec3 uBurnColor;
uniform float uBurnMixExp;
uniform vec3 uFireColor;
uniform float uFireExp;
uniform float uFireScale;
uniform float uFireMixExp;

varying vec2 vUv;
varying vec3 vWorldPosition;

#include ../perlin.glsl;
#include ../curl.glsl;
#include ../fbm.glsl;

void main() {


  vec2 uv = vec2(vUv);

  vec4 map = texture2D(uMap, uv);
  vec4 backsideMap = texture2D(uBacksideMap, uv);
  float a = map.a;

  vec3 color = vec3(0.0);

  if (gl_FrontFacing == true) {
    color = map.rgb;
  } else {
    color = backsideMap.rgb;
  }

  // burn effect
	float edge = (1.0 - uProgress * 1.5) * (1.5 + uAmplitude);
  float d = length(vWorldPosition);
  d -= cnoise(vec4(vWorldPosition * uFrequency , uTime * 0.2)) * uAmplitude;
  d += fbm(vWorldPosition * uFrequency * 4. + uTime * 0.1,2) * uAmplitude;
  float c = domainWarpingFBM(vWorldPosition * uFrequency * 2. + vec3(0.0,-uTime,uTime * 0.6),2) * uAmplitude;
  c = pow(c,3.) * 0.15;

  float alphaFalloff = 1.0 - falloff(d + uAlphaOffset,2. + uAmplitude, -uAmplitude,uAlphaMargin,uProgress); 
  float burnFalloff = falloff(d + uBurnOffset,2. + uAmplitude, -uAmplitude,uBurnMargin,uProgress);
  float fireFalloff = falloff(d + uFireOffset - c,2. + uAmplitude, -uAmplitude,uFireMargin,uProgress);
  float sparkle = cnoise(vec4(vWorldPosition * uFrequency * vec3(4.,4.,1.) , uTime * 4.));
  sparkle = pow(sparkle,4.);

  fireFalloff += sparkle * fireFalloff;
  fireFalloff = max(0.0,fireFalloff);
  vec3 fire = uFireColor * pow(fireFalloff,uFireExp) * uFireScale;
  vec3 burn = mix(color, uBurnColor, pow(burnFalloff,uBurnMixExp));
  burn = mix(burn, fire,pow(fireFalloff,uFireMixExp));

  a *= alphaFalloff; 

  gl_FragColor = vec4(burn,a);
  // gl_FragColor.rgb = vec3(c);
}