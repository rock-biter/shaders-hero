#include ../functions.glsl;
#include ../lights.glsl;

uniform AmbientLight uAmbientLight;
uniform HemiLight uHemiLight;
uniform DirLight uDirLight;
uniform float uGlossiness;
uniform PointLight uPointLight;
uniform SpotLight uSpotLight;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec3 normal = normalize(vNormal);
  vec3 viewDirection = normalize(vWorldPosition - cameraPosition );

  // light color
	vec3 light = vec3(0.0);
	
  // ambient
	// light += ambientLight(uAmbientLight.color,uAmbientLight.intensity);

  // hemi light
  // light += hemiLight(uHemiLight.skyColor,uHemiLight.groundColor,normal);

  // directional light
  // light += dirLight(uDirLight.color,uDirLight.intensity,uDirLight.direction,normal,viewDirection, uGlossiness);

  // point light
  // light += pointLight(uPointLight.color, uPointLight.intensity, uPointLight.position, vWorldPosition, normal, viewDirection, uGlossiness, uPointLight.maxDistance);
  
  light += spotLight(uSpotLight.color, uSpotLight.intensity, uSpotLight.position, uSpotLight.target, vWorldPosition, normal, viewDirection, uGlossiness, uSpotLight.maxDistance, uSpotLight.angle, uSpotLight.penumbra);
	
	// geometry base color
	vec3 baseColor = vec3(1.0);
	
	// final color
	vec3 color = baseColor * light;

  gl_FragColor = vec4(color,1.0);
}