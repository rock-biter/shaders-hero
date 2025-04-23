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


  float t = 1.0 - smoothstep(edge, edge + uSmooth1 * 0.2, d  + uOffset1 * 5.);
  float sparkle = cnoise(vec4(vWorldPosition * uFrequency * vec3(8.,8.,-1.) , uTime * 5.));

  // sparkle 
  sparkle = pow(sparkle,4.);
  vec3 fire = uFireColor;// * (1. + sparkle * 15.);

  a = 1.;
  a *= 1.0 - smoothstep(0.85, 1.,uv.x);
  a *= 1.0 - smoothstep(0.85, 1.0,uv.y);
  a *= smoothstep(0.0, 0.15,uv.x);
  a *= smoothstep(0.0, 0.15,uv.y);
  // c *= tSmoke;

  float fireEdge = noise(vec3(vWorldPosition.xy * 20. , uTime * 5.));
  float fireEdge2 = noise(vec3(vWorldPosition.xy * 10. , uTime * 10.)) * 0.5 + 0.5;
  fire *= smoothstep(-0.2,0.3,vHeight - fireEdge * 0.1 ) * 0.7 + 0.3;

  fire *= max(1., (pow(vHeight,3. ) + fireEdge2 * 0.2  ) * uFireScale * 3.);

  // granular effect
  fire *= (1.0 - random(fract(uv * 100.)) * 0.2);
  a *= smoothstep(0.001, 0.03, vHeight );

  gl_FragColor = vec4(fire,a);
  // gl_FragColor.rgb = vec3(c);
}