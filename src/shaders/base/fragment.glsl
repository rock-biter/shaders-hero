#include ../functions.glsl;
#include ../random.glsl;
#include ../noise.glsl;
#include ../perlin.glsl;
#include ../fbm.glsl;
#include ../cellular.glsl;
#include ../lights.glsl;
#include ../curl.glsl;

uniform float uTime;
uniform float uFrequency;
uniform float uAmplitude;
uniform float uProgress;
uniform sampler2D uTriangles;
uniform sampler2D uPerlin;
uniform sampler2D uFBM;
uniform sampler2D uTiles;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

float falloff(float d, float start, float end, float margin, float progress) {
    float m = margin*sign(end-start);
    float p = mix(start-m, end, progress);
    return 1. - smoothstep(p, p + m, d);
}

void main() {

  float start = 0.0;
  float end = 10.;
  vec3 normal = normalize(vNormal);
  vec3 viewDir = normalize(vWorldPosition - cameraPosition);
  float d = length(vWorldPosition);

  

  // LIGHT
  vec3 light = vec3(0.0);
  vec3 lightDir = normalize(vec3(2.));
  light += dirLight(vec3(1.0),0.8, lightDir,normal,viewDir,5.);
  light += ambientLight(vec3(1.0), 0.2);

  // COLOR
  vec3 baseColor = texture(uFBM,vWorldPosition.xz * 3.5 ).rgb * 0.6;
  baseColor += texture(uFBM,vWorldPosition.xz * 0.1 + 10. ).rgb * 0.6;
  baseColor *= texture(uFBM,vWorldPosition.xz * 0.02 ).rgb ;
  baseColor *= 3.;
  baseColor = pow(baseColor, vec3(2.5));
  baseColor *= vec3(0.7,0.8,1.0);

  vec2 baseUV = floor(vWorldPosition.xz * 10.);
  vec2 noiseUV = (texture(uTiles, baseUV * 0.1).rg * 2.0 - 1.0);
  vec2 baseOffset = vec2(0.0);//texture(uTiles, baseUV * 0.1).rg * 2.0 - 1.0;
  // baseOffset = floor(baseOffset * 2.0) / 2.0;
  baseOffset.x = sin(baseUV.y * 0.7);
  baseOffset.y = cos(baseUV.x * 0.7);

  float noiseOffset = texture(uPerlin, vWorldPosition.xz * uFrequency * 0.05 ).r * uAmplitude;

  d = length(vWorldPosition.xz + baseOffset * 0.15 ) + noiseOffset;
  float alpha = 0.0; 
  alpha += falloff(d, start - 0.0, end, 0.03, uProgress); 

  vec3 triangles = texture(uTriangles, vWorldPosition.xz * 1.2).xyz;
  triangles += texture(uTriangles, vWorldPosition.xz * 1.2 + 0.01).xyz * (1.0 - alpha);

  // d = length(vWorldPosition.xz + baseOffset * 0.03) + noiseOffset;
  float edge = 1.0 - falloff(d, start + 0.5, end, 2.0, uProgress);//smoothstep(d - 0.2, d + 2.5, uProgress * 30.);
  edge = pow(edge, 1.0);
  // float rand = random(vWorldPosition.xz * 0.1 + uTime * 0.1);

  float blueEdge = 1.0 - falloff(d, start, end, 6., uProgress); //smoothstep(d + 0.1, d + 1.5, uProgress * 30.);
  blueEdge = pow(blueEdge, 2.0);

  vec3 blue = vec3(0.3, 0.45, 1.0);
  vec3 color = baseColor;
  // color = mix(color, blue, blueEdge);
  color += blue * triangles * blueEdge * 2. + triangles * blueEdge * 2.;
  color += blue * edge * 2.;
  color += vec3(1.) * edge;
  // color = mix(color, vec3(1.3) + blue, edge);
  // color = mix(color, vec3(1.0 + rand * 0.25), edge);

  // triangles
  
  float trianglesAlphaEdge = falloff(d, start + 0.7, end, 0.2, uProgress); //smoothstep(d - 1.5, d - 0.5, uProgress * 30. );
  // float trianglesColorEdge = 1.0 - falloff(d, start, end, 0.5, uProgress); //smoothstep(d + 0., d + 1.5, uProgress * 30.);

  color *= light;
  // color += triangles * trianglesColorEdge;
  alpha += triangles.r * trianglesAlphaEdge;
  alpha *= 1.0 - smoothstep(0.85, 1.0, length(vWorldPosition.xz) * 0.0585);
  gl_FragColor = vec4(color,alpha);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}