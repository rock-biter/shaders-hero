
struct AmbientLight {
	vec3 color;
	float intensity;
};

uniform AmbientLight uAmbientLight;

varying vec2 vUv;


#include ../lights.glsl;

void main() {

  // light color
	vec3 light = vec3(0.0);
	
	light += ambientLight(uAmbientLight.color,uAmbientLight.intensity);
	
	// geometry base color
	vec3 baseColor = vec3(1.0,0.,0.);
	
	// final color
	vec3 color = baseColor * light;
  gl_FragColor = vec4(color,1.0);
}