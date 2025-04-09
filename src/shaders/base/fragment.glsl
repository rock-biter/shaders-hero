#include ../functions.glsl;
#include ../lights.glsl;

uniform AmbientLight uAmbientLight;
uniform HemiLight uHemiLight;
uniform DirLight uDirLight;
uniform float uGlossiness;
uniform PointLight uPointLight;
uniform SpotLight uSpotLight;
uniform float uToon;
uniform samplerCube uEnvMap;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec3 normal = normalize(vNormal);
  vec3 viewDirection = normalize(vWorldPosition - cameraPosition );

  // light color
	vec3 light = vec3(0.0);

  vec3 reflectDir = normalize(reflect(viewDirection,normal));
  reflectDir.x *= -1.; // why is flipped horizontally????

  // float fresnel = 1. - max(0.0, dot(normal,-viewDirection));
  // fresnel = pow(fresnel, 2.);
  // // env map
  light += texture(uEnvMap,reflectDir).xyz ;
	
  // ambient
	// light += ambientLight(uAmbientLight.color,uAmbientLight.intensity);

  // hemi light
  // light += hemiLight(uHemiLight.skyColor,uHemiLight.groundColor,normal) * 0.5;

  float colors = uToon;

  // directional light
  // light += dirLight(uDirLight.color,uDirLight.intensity,uDirLight.direction,normal,viewDirection, uGlossiness);

  // point light
  // light += pointLight(uPointLight.color, uPointLight.intensity, uPointLight.position, vWorldPosition, normal, viewDirection, uGlossiness, uPointLight.maxDistance);
  

  // light += spotLight(uSpotLight.color, uSpotLight.intensity, uSpotLight.position, uSpotLight.target, vWorldPosition, normal, viewDirection, uGlossiness, uSpotLight.maxDistance, uSpotLight.angle, uSpotLight.penumbra);

  

  // float colors = 2.;
  // light = light * colors;
  // light = floor(light) / colors;
	
	// geometry base color
	vec3 baseColor = vec3(1.0, 1.0 , 0.0);
	
	// final color
	vec3 color = baseColor * light;

  color = pow(color,vec3(1.0 / 2.2));

  gl_FragColor = vec4(color,1.0);
}