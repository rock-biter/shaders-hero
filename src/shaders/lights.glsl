// AmbientLight

struct AmbientLight {
  vec3 color;
  float intensity;
};

vec3 ambientLight(vec3 color, float intensity) {
  return color * intensity;
}

// Hemi Light
struct HemiLight {
  vec3 skyColor;
  vec3 groundColor;
  float intensity;
};

vec3 hemiLight(vec3 skyColor, vec3 groundColor, float intensity, vec3 normal) {
  float hemiMix = remap(normal.y,-1.0,1.0,0.0,1.0);
  vec3 hemiColor = mix(groundColor, skyColor,hemiMix);

  return hemiColor * intensity;
}

vec3 phongSpecular(vec3 viewDir, vec3 lightDir, vec3 colorLight, vec3 normal, float glossiness ) {
  vec3 reflectDir = normalize(reflect(lightDir, normal));
  float phongValue = max(0.0, dot(viewDir, reflectDir));
  phongValue = pow(phongValue, glossiness);

  return colorLight * phongValue;
}

// Directional Light
struct DirectionalLight {
  vec3 color;
  float intensity;
  vec3 direction;
};

vec3 dirLight(vec3 lightColor, float intensity, vec3 lightDirection, vec3 normal, vec3 viewDir, float glossiness) {
  vec3 dir = normalize(lightDirection);
  float angle = max(0.0,dot(dir, normal));
  vec3 diffuse = lightColor * angle;
  vec3 specular = phongSpecular(viewDir, lightDirection, lightColor, normal, glossiness);

  vec3 light = (diffuse + specular) * intensity;

  return light;
}