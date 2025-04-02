float toonify(vec3 normal, vec3 lightDir, float steps) {
  float d = max(0.0, dot(normalize(normal), normalize(lightDir)));
  float t = floor(d * steps );
  t += smoothstep( floor(d * steps) / steps,floor(d * steps) / steps + 0.08, d);
  t /= steps;
  return t;
}

float toonify(float l, float colors) {
  float t = l;
  t = floor(t * colors ) + smoothstep( floor(t * colors) / colors,floor(t * colors) / colors + 0.05, t) ;
  t /= colors;
  return t;
}

vec3 toonity(vec3 specular,float t) {
  return smoothstep(0.5, 0.5 + t,specular);
}

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
  vec3 hemi = mix(groundColor, skyColor, hemiPct);

  #ifdef TOON
    hemi *= toonify(length(hemi),float(TOON));
  #endif
  return hemi;
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

  #ifdef TOON
    specular = toonity(specular,0.05);
    diffuse = diffuse * toonify(normal, lightDirection, float(TOON));
  #endif

  vec3 light = (diffuse + specular) * intensity;

  return light;
}

struct PointLight {
  vec3 color;
  float intensity;
  vec3 position;
  float maxDistance;
};

vec3 pointLight(vec3 lightColor, float intensity, vec3 lightPosition, vec3 position, vec3 normal, vec3 viewDirection, float glossiness, float maxDistance) {
  vec3 lightDirection = lightPosition - position;
  float d = length(lightDirection);

  float decay = 1.0 - linearstep(0.0, maxDistance, d);
  lightDirection = normalize(lightDirection);
  float lightAngle = max(dot(normal,lightDirection),0.0);
  vec3 diffuse = lightColor * lightAngle;
  vec3 specular = phongSpecular(viewDirection, lightDirection, lightColor, normal, glossiness);

  #ifdef TOON
    specular = toonity(specular,0.05);
    diffuse = diffuse * toonify(normal, lightDirection, float(TOON));
  #endif

  vec3 light = (diffuse + specular) * intensity * decay;

  return light;
}

struct SpotLight {
  vec3 color;
  float intensity;
  vec3 position;
  vec3 target;
  float maxDistance;
  float angle;
  float penumbra;
};

vec3 spotLight(vec3 lightColor, float intensity, vec3 lightPosition, vec3 lightTarget, vec3 position, vec3 normal, vec3 viewDirection, float glossiness, float maxDistance, float angle, float penumbra) {
  vec3 lightDirection = lightPosition - lightTarget;
  vec3 fragDirection = lightPosition - position;
  float d = length(fragDirection);

  float decay = 1.0 - linearstep(0.0, maxDistance, d);
  lightDirection = normalize(lightDirection);
  fragDirection = normalize(fragDirection);
  float shading = max(dot(normal,fragDirection),0.0);
  vec3 diffuse = lightColor * shading;
  vec3 specular = phongSpecular(viewDirection, fragDirection, lightColor, normal, glossiness);

  float maxLightAngle = cos(angle * 0.5);
  float lightAngle = max(dot(fragDirection,lightDirection),0.0);
  float edge = smoothstep(maxLightAngle - penumbra, maxLightAngle, lightAngle);

  #ifdef TOON
    specular = toonity(specular,0.05);
    diffuse = diffuse * toonify(normal, lightDirection, float(TOON));
  #endif

  vec3 light = (diffuse + specular) * intensity * decay * edge;

  return light;
  // vec3 lightDirection = lightPosition - lightTarget;
  // vec3 fragmentDirection = lightPosition - position;
  // float d = length(fragmentDirection);

  // float decay = 1.0 - linearstep(0.0, maxDistance, d);
  // lightDirection = normalize(lightDirection);
  // fragmentDirection = normalize(fragmentDirection);
  // float lightAngle = max(dot(fragmentDirection,lightDirection),0.0);
  // float shading = max(dot(normal,fragmentDirection),0.0);
  // float maxLightAngle = cos(angle * 0.5);
  // float edge = smoothstep(maxLightAngle - penumbra, maxLightAngle, lightAngle);
  // vec3 diffuse = lightColor * shading;
  // vec3 specular = phongSpecular(viewDirection, fragmentDirection, lightColor, normal, glossiness);

  // vec3 light = (diffuse + specular) * intensity * decay * edge;

  // return light;
}