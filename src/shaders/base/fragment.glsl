#include ../functions.glsl;
#include ../lights.glsl;
#include ../noise.glsl;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform int uOctaves;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

// #include ../perlin.glsl;
// #include ../simplex.glsl;
#include ../fbm.glsl;
#include ../voronoi.glsl;

void main() {

  vec3 light = vec3(0.0);

  vec3 normal = normalize(vNormal);
  vec3 viewDirection = normalize(vWorldPosition - cameraPosition);
  vec3 lightDir = vec3(0.5,1.0,0.3);

  light += dirLight(vec3(0.8,0.8,1.), 0.5, lightDir, normal, viewDirection, 4.);

  vec3 ambientLight = vec3(0.1,0.1,0.2);
  light += ambientLight;

  // float n = cellular(vec(vUv.xy * uFrequency, uTime * 0.5)); // voronoi 2D
  vec3 coords = vWorldPosition.xyz * uFrequency;
  coords += vec3(
    0.4 * noise(vWorldPosition.xyz * uFrequency * 2. + uTime),
    0.4 * noise(vWorldPosition.xyz * uFrequency * 2. + uTime + vec3(1.25,3.65,9.45)),
    0.4 * noise(vWorldPosition.xyz * uFrequency * 2. + uTime + vec3(6.45,0.24,2.78))
  );
  float delta = 0.03;
  float caustic = cellular(vec4(coords + vec3(delta,0.,delta), uTime * 0.5)); // voronoi 3D
  // float g = smoothVoronoi(vec4(coords + vec3(-delta,0.,-delta), uTime * 0.5)); // voronoi 3D
  // float b = cellular(vec4(coords + vec3(delta,0.,-delta), uTime * 0.5)); // voronoi 3D
  caustic = pow(caustic,2.);
  // light += caustic * 0.4;
  light += caustic * clamp(0.9 + dot(normal,lightDir),0.0,1.0) * 0.4;
  // vec3 baseColor = vec3(n);
  // baseColor /= 3.0;
	// final color
	vec3 color = vec3(1.0) * light;

  gl_FragColor = vec4(color,1.0);
}