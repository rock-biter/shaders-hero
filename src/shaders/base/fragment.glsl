#include ../functions.glsl;
#include ../lights.glsl;
#include ../noise.glsl;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform int uOctaves;
uniform sampler2D uMap;
uniform sampler2D uNoise;
uniform float uCurlIntensity;
uniform int uCurlSteps;
uniform float uParallaxSize;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying vec3 vTangent;

// #include ../perlin.glsl;
// #include ../curl.glsl;
// #include ../simplex.glsl;
#include ../fbm.glsl;
#include ../voronoi.glsl;

varying vec3 vParallax;

void main() {


  // vec2 curl = curlNoise(vUv * uFrequency);
  // float perlin = cnoise(vUv * uFrequency);

  // vec3 baseColor = vec3(0.0);
  // if(vUv.x < 0.5) {
  //   baseColor = vec3(perlin);
  // } else {
  //   baseColor = vec3(curl * 0.5 + 0.5,0.0);
  // }

  vec4 mapColor = vec4(0.0);

  int iterations = 4;

  for(int i = 0; i < iterations; i++) {
    vec2 uv = vec2(vUv - vParallax.xy * (float(i) * 1. * uParallaxSize + 0.3));

    vec2 t = 1.0 - smoothstep(0.99,2.8,uv);
    // vec2 t = 1.0 - smoothstep(1.,1.,uv);
    t *= smoothstep(-1.8,0.,uv);
    // t *= smoothstep(0.,0.,uv);

    // mapColor.rgb += texture2D(uMap, uv).rgb;
    float c = cellular(vec3(uv * uFrequency,float(i + 1) * 2. * uParallaxSize + uTime * 0.3)) * min(t.x,t.y) * (10. - float(i)) / 10.;
    c = pow(c,2.);
    mapColor.a += min(t.x,t.y) * c;
    mapColor.rgb += vec3(0.,c,c * float(iterations + 1 - i) / float(iterations + 1));
  }

  // mapColor.rgb /= 3.;
  // mapColor.a /= 2.;

  // vec2 uv = vec2(vUv - vParallax.xy);

  // vec2 t = 1.0 - step(1.01,uv);
  // t *= step(-0.01,uv);

  // vec3 mapColor = texture2D(uMap, uv).rgb;


	vec3 color = vec3(mapColor.rgb);
	// vec3 color = vec3(0.);
  // color = mix(color, vec3(1.0), 1.0 - min(t.x,t.y));
  // color.r = vTangent.r * 0.5 + 0.5;
  // color.g = vTangent.g * 0.5 + 0.5;
  // color.b = vTangent.b * 0.5 + 0.5;

  gl_FragColor = vec4(color,mapColor.a);
}