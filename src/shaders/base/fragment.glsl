#include ../functions.glsl;
#include ../lights.glsl;

uniform AmbientLight uAmbientLight;
uniform HemiLight uHemiLight;

varying vec2 vUv;
varying vec3 vNormal;

void main() {

  vec3 normal = normalize(vNormal);

  // light color
	vec3 light = vec3(0.0);
	
  // ambient
	// light += ambientLight(uAmbientLight.color,uAmbientLight.intensity);

  // hemi light
  light += hemiLight(uHemiLight.skyColor,uHemiLight.groundColor,normal);
	
	// geometry base color
	vec3 baseColor = vec3(1.0);
	
	// final color
	vec3 color = baseColor * light;
  gl_FragColor = vec4(color,1.0);
}