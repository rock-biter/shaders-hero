struct AmbientLight {
	vec3 color;
	float intensity;
};

vec3 ambientLight(vec3 color, float intensity) {
	return color * intensity;
}

struct HemiLight {
	vec3 skyColor;
	vec3 groundColor;
};

vec3 hemiLight(vec3 skyColor, vec3 groundColor, vec3 normal) {
  float hemiPct = remap(normal.y, -1.0, 1.0, 0.0, 1.0);
  return mix(groundColor, skyColor, hemiPct);
}

struct DirLight {
  vec3 color;
  float intensity;
  vec3 direction;
};

vec3 dirLight(vec3 lightColor, float intensity, vec3 lightDirection, vec3 normal) {
  lightDirection = normalize(lightDirection);
  float lightAngle = max(dot(normal,lightDirection),0.0);
  return lightColor * intensity * lightAngle;
}