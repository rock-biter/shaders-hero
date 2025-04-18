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

// Directional Light
struct DirectionalLight {
  vec3 color;
  float intensity;
  vec3 direction;
};

vec3 dirLight(vec3 lightColor, float intensity, vec3 lightDirection, vec3 normal) {
  vec3 dir = normalize(lightDirection);
  float angle = max(0.0,dot(dir, normal));
  return lightColor * intensity * angle;
}