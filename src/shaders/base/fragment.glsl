varying vec2 vUv;
varying vec3 vNormal;

#include ../functions.glsl;
#include ../lights.glsl;

uniform AmbientLight uAmbientLight;
uniform HemiLight uHemiLight;
uniform DirectionalLight uDirLight;

void main() {

  vec3 light = vec3(0.0);
  vec3 normal = normalize(vNormal);

  // ambient light
  // light += ambientLight(uAmbientLight.color, uAmbientLight.intensity);

  // Hemi light

  light += hemiLight(uHemiLight.skyColor, uHemiLight.groundColor, uHemiLight.intensity, normal);

  // Dircetional light

  light += dirLight(uDirLight.color, uDirLight.intensity, uDirLight.direction, normal);

  vec3 baseColor = vec3(1.0,1.0,1.0);

  vec3 color = baseColor * light;
  gl_FragColor = vec4(color,1.0);
  // gl_FragColor.rgb = vec3(lightAngle);
}