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
varying float vHeight;

#include ../perlin.glsl;
// #include ../curl.glsl;
// #include ../simplex.glsl;
#include ../fbm.glsl;
// #include ../voronoi.glsl;

void main() {


  vec2 uv = vec2(vUv);

  vec4 map = texture2D(uMap, uv);
  vec4 backsideMap = texture2D(uBacksideMap, uv);

  float a = 1.0;

  vec3 color = vec3(0.0);

  if (gl_FrontFacing == true) {
    color = map.rgb;
  } else {
    color = backsideMap.rgb;
  }

  // burn effect
	float edge = (1.0 - uProgress * 1.5) * (1.5 + uAmplitude);
  float d = length(vWorldPosition);
  d -= cnoise(vec4(vWorldPosition * uFrequency , uTime * 0.2)) * uAmplitude * 0.9;
  d -= fbm(vWorldPosition * uFrequency * 4. + uTime * 0.1,2) * uAmplitude * 0.9;
  float c = cnoise(vWorldPosition * uFrequency * vec3(2.,2.,0.3) + vec3(uTime,uTime,uTime * 1.)) * 2.;
  // c = pow(c,3.) * 0.15;

  float t = 1.0 - smoothstep(edge, edge + uSmooth1 * 0.2, d  + uOffset1 * 5.);
  // float t2 = smoothstep(edge,edge + uSmooth2, d  + uOffset2);
  // float t3 = smoothstep(edge, edge + uSmooth3, d - c + uOffset3);
  // t3 = pow(t3,2.5);
  float sparkle = cnoise(vec4(vWorldPosition * uFrequency * vec3(8.,8.,-1.) , uTime * 5.));
  // sparkle 
  sparkle = pow(sparkle,4.);

  // t3 += sparkle * t3;
  // t3 = max(0.0,t3);
  vec3 fire = uFireColor * (1. + sparkle * 10.);

  a = 1.;
  a *= 1.0 - smoothstep(0.85, 1.,uv.x);
  a *= 1.0 - smoothstep(0.85, 1.0,uv.y);
  a *= smoothstep(0.0, 0.1,uv.x);
  a *= smoothstep(0.0, 0.1,uv.y);
  // c *= tSmoke;

  // a *= t + c * c * 15.;
  float fireEdge = noise(vec3(vWorldPosition.xy * 15. , uTime * 5.));
  float fireEdge2 = noise(vec3(vWorldPosition.xy * 5. , uTime * 5.)) * 0.5 + 0.5;
  fire *= smoothstep(-0.1,0.2,vHeight - fireEdge * 0.3) * 0.5 + 0.5;
  fire *= smoothstep(0.00, 0.1, vHeight );
  fire.r *= 1.3;
  // fire.b *= 1.1;
  // fire.g *= 0.9;

  fire *= max(1., (vHeight * vHeight * vHeight + fireEdge2 * 0.2 - c * c * 0.25 ) * uFireScale * 3.);

  a *= max(0.0,1.0 - vHeight * c * 6.);
  float inverseProgress = 1. - uProgress;
  a *= 1.0 - smoothstep(0.5 * inverseProgress,2.5 * inverseProgress + uProgress * (c * c * 0.3 ),vHeight * 1.8);

  fire *= (1.0 - random(fract(uv * 100.)) * 0.2);

  gl_FragColor = vec4(fire,a);
  // gl_FragColor.rgb = vec3(c);
}