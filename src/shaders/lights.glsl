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

vec3 phongSpecular(vec3 viewDir, vec3 lightDir, vec3 lightColor, vec3 normal, float glossiness) {
	vec3 reflectDir = normalize(reflect(lightDir,normal));
	float phongValue = max(0.0,dot(viewDir, reflectDir));
	phongValue = pow(phongValue,glossiness);
	
	return lightColor * phongValue;

}

vec3 dirLight(vec3 lightColor, float intensity, vec3 lightDirection, vec3 normal, vec3 viewDirection, float glossiness) {
  lightDirection = normalize(lightDirection);
  float lightAngle = max(dot(normal,lightDirection),0.0);
  vec3 diffuse = lightColor * lightAngle;
  vec3 specular = phongSpecular(viewDirection, lightDirection, lightColor, normal, glossiness);

  vec3 light = (diffuse + specular) * intensity;

  return light;
}