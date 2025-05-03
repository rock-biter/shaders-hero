#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;
#include ../cellular.glsl;
#include ../lights.glsl;
#include ../curl.glsl;

uniform float uTime;
uniform float uProgress;
uniform sampler2D uPerlin;
uniform sampler2D uFBM;
uniform sampler2D uTriangles;
uniform float uColorF1;
uniform float uColorF2;
uniform float uColorF3;
uniform float uPerlinFrequency;
uniform float uPerlinAmplitude;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;


void main() {

  vec3 normal = normalize(vNormal);
  vec2 uv = vUv;
  vec3 viewDir = normalize(vWorldPosition - cameraPosition);

  // light
  vec3 light = vec3(0.);
  vec3 lightDir = normalize(vec3(2.));
  light += dirLight(vec3(1.0),0.8,lightDir, normal,viewDir, 5. );
  light += ambientLight(vec3(1.0),0.2);

  // COLOR
  vec3 baseColor = texture(uFBM, vWorldPosition.xz * uColorF1).rgb * 0.6;
  baseColor += texture(uFBM, vWorldPosition.xz * uColorF2 + 10.).rgb * 0.6;
  baseColor *= texture(uFBM, vWorldPosition.xz * uColorF3).rgb;
  baseColor *= 3.0;
  baseColor = pow(baseColor, vec3(2.5));
  baseColor *= vec3(0.7,0.8,1.0);

  vec2 baseUV = floor(vWorldPosition.xz * 10.);
  vec2 cellOffset = vec2(0.0,0.0);
  cellOffset.x = sin(baseUV.y * 0.7);
  cellOffset.y = sin(baseUV.x * 0.7 + 10.);

  float d = length(vWorldPosition.xz + cellOffset * 0.15);
  float noiseOffset = texture(uPerlin,vWorldPosition.xz * uPerlinFrequency ).r;
  d += noiseOffset * uPerlinAmplitude;

  float alpha = 1.0;
  // r *= uProgress;
  

  vec3 blue = vec3(0.3,0.45,1.0);
  // tringles
  vec3 triangles = texture(uTriangles, vWorldPosition.xz ).rgb;
  float falloffTrianglesColor = 1. - falloff(d, 0.0, 10.0, 6., uProgress);
  falloffTrianglesColor = pow(falloffTrianglesColor, 2.0);
  baseColor += triangles * blue * 2. * falloffTrianglesColor;
  baseColor += triangles * 2. * falloffTrianglesColor;
  
  float falloffColor = 1.0 - falloff(d, 0.5, 10., 2., uProgress);
  baseColor += blue * falloffColor * 2.;
  baseColor += vec3(1.0) * falloffColor;

  float alphaFalloff = falloff(d, 0.0, 10., 0.03, uProgress);
  float falloffTrianglesAlpha = falloff(d, 0.8, 10., 0.2, uProgress);


  alpha *= alphaFalloff;
  alpha += triangles.r * falloffTrianglesAlpha;

  vec3 color = baseColor * light;
  gl_FragColor = vec4(color,alpha);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}