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
  vec3 specular = phongSpecular(viewDir, dir, lightColor, normal, glossiness);

  vec3 light = (diffuse + specular) * intensity;

  return light;
}

// Point Light
struct PointLight {
  vec3 color;
  float intensity;
  vec3 position;
  float maxDistance;
};

vec3 pointLight(vec3 lightColor, float intensity, vec3 lightPosition, vec3 position, vec3 normal, float maxDistance, vec3 viewDir, float glossiness) {

  vec3 lightDirection = lightPosition - position;
  float d = length(lightDirection);

  float decay = 1. - linearstep(0.0,maxDistance,d);

  vec3 dir = normalize(lightDirection);
  float angle = max(0.0,dot(dir, normal));
  vec3 diffuse = lightColor * angle;
  vec3 specular = phongSpecular(viewDir, dir, lightColor, normal, glossiness);

  vec3 light = (diffuse + specular) * intensity * decay;

  return light;

}

// Spot Light
struct SpotLight {
  vec3 color;
  float intensity;
  vec3 position;
  vec3 target;
  float angle;
  float maxDistance;
  float penumbra;
};

vec3 spotLight(vec3 lightColor, float intensity, vec3 lightPosition, vec3 targetPosition, float angle, float penumbra, vec3 position, vec3 normal, float maxDistance, vec3 viewDir, float glossiness) {

  vec3 fragDirection = lightPosition - position;
  float d = length(fragDirection);
  vec3 lightDirection = lightPosition - targetPosition;
  lightDirection = normalize(lightDirection);

  float decay = 1. - linearstep(0.0,maxDistance,d);

  fragDirection = normalize(fragDirection);
  float shading = max(0.0,dot(fragDirection, normal));
  vec3 diffuse = lightColor * shading;
  vec3 specular = phongSpecular(viewDir, fragDirection, lightColor, normal, glossiness);

  float maxAngle = cos(angle * 0.5);
  float lightAngle = max(0.0, dot(fragDirection, lightDirection));
  float edge = smoothstep(maxAngle - penumbra, maxAngle, lightAngle);

  vec3 light = (diffuse + specular) * intensity * decay * edge;

  return light;

}