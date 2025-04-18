#include ../functions.glsl;
#include ../lights.glsl;
#include ../noise.glsl;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform sampler2D uMap;
uniform sampler2D uBacksideMap;
uniform float uProgress;

uniform float uOffset1;
uniform float uSmooth1;
uniform float uOffset2;
uniform float uSmooth2;
uniform float uOffset3;
uniform float uSmooth3;
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
// #include ../simplex.glsl;
#include ../fbm.glsl;
// #include ../voronoi.glsl;

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
  d -= fbm(vWorldPosition * uFrequency * 4. + uTime * 0.1,2) * uAmplitude;
  float c = domainWarpingFBM(vWorldPosition * uFrequency * 2. + vec3(0.0,-uTime,uTime * 0.6),1) * uAmplitude;
  c = pow(c,3.) * 0.15;

  float t = 1.0 - smoothstep(edge, edge + uSmooth1, d  + uOffset1);
  float t2 = smoothstep(edge,edge + uSmooth2, d  + uOffset2);
  float t3 = smoothstep(edge, edge + uSmooth3, d - c + uOffset3);
  // t3 = pow(t3,2.5);
  float sparkle = cnoise(vec4(vWorldPosition * uFrequency * 10. , uTime * 2.));
  // sparkle 
  sparkle = pow(sparkle,4.);

  t3 += sparkle * t3;
  t3 = max(0.0,t3);
  vec3 fire = uFireColor * pow(t3,uFireExp) * uFireScale;
  vec3 burn = mix(color, uBurnColor, pow(t2,uBurnMixExp));
  // fire = mix(fire, vec3(1.0),sparkle);
  burn = mix(burn, fire,pow(t3,uFireMixExp));

  float tSmoke = 1.0 - smoothstep(edge, edge + uSmooth1 * 10., d  - uOffset1 * 20. );

  c *= 1.0 - smoothstep(0.9, 1.0,uv.x);
  c *= 1.0 - smoothstep(0.9, 1.0,uv.y);
  c *= smoothstep(0.0, 0.1,uv.x);
  c *= smoothstep(0.0, 0.1,uv.y);
  c *= tSmoke;

  a *= t + c * c * c * 20.;


  gl_FragColor = vec4(burn,a);
  // gl_FragColor.rgb = vec3(c);
}