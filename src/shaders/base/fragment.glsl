varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

#include ../functions.glsl;
#include ../lights.glsl;

uniform AmbientLight uAmbientLight;
uniform HemiLight uHemiLight;
uniform DirectionalLight uDirLight;
uniform PointLight uPointLight;
uniform SpotLight uSpotLight;
uniform float uGlossiness;
uniform samplerCube uEnvMap;

void main() {

  vec3 light = vec3(0.0);
  vec3 normal = normalize(vNormal);
  vec3 viewDir = normalize(vWorldPosition - cameraPosition);

  // ambient light
  // light += ambientLight(uAmbientLight.color, uAmbientLight.intensity);

  // Hemi light
  light += hemiLight(uHemiLight.skyColor, uHemiLight.groundColor, uHemiLight.intensity, normal);

  // Dircetional light

  light += dirLight(uDirLight.color, uDirLight.intensity, uDirLight.direction, normal, viewDir, uGlossiness);
  
  // Point light
  light += pointLight(uPointLight.color, uPointLight.intensity, uPointLight.position, vWorldPosition, normal, uPointLight.maxDistance, viewDir, uGlossiness );

  // SPot light
  light += spotLight(uSpotLight.color, uSpotLight.intensity, uSpotLight.position, uSpotLight.target, uSpotLight.angle,  uSpotLight.penumbra, vWorldPosition, normal, uSpotLight.maxDistance, viewDir, uGlossiness );

  //envmap
  vec3 reflectDir = normalize(reflect(viewDir, normal));
  reflectDir.x *= -1.0;
  vec3 envColor = texture(uEnvMap, reflectDir).rgb;

  float fresnel = 1.0 - max(0.0, dot(-viewDir, normal));
  fresnel = pow(fresnel, 2.0);

  light += envColor * fresnel;

  vec3 baseColor = vec3(1.0,1.0,1.0);

  vec3 color = baseColor * light;
  gl_FragColor = vec4(color,1.0);
  // gl_FragColor.rgb = vec3(lightAngle);
}