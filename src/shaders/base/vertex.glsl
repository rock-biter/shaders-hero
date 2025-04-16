attribute vec3 tangent;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

uniform float uTime;
uniform float uAmplitude;
uniform float uFrequency;
uniform sampler2D uNoise;
uniform float uParallaxSize;


#include ../noise.glsl;
#include ../perlin.glsl;

varying vec3 vParallax;

vec3 projectOnPlane(vec3 v, vec3 n) {
    // Formula: v - (v·n)n
    // dove · è il prodotto scalare
    return v - dot(v, n) * n;
}

mat3 alignVector(vec3 v, vec3 target) {
    // Normalizza i vettori
    vec3 v_n = normalize(v);
    vec3 target_n = normalize(target);
    // v_n *= vec3(-1.0,-1.0 ,-1.0);
    
    // Calcola l'asse di rotazione tramite prodotto vettoriale
    vec3 axis = -cross(v_n, target_n);
    
    // Calcola l'angolo tra i vettori usando il prodotto scalare
    float cosAngle = dot(v_n, target_n);
    float angle = acos(cosAngle);
    
    // Costruisci la matrice di rotazione (formula di Rodrigues)
    float s = sin(angle);
    float c = cosAngle;
    float t = 1.0 - c;
    
    // Costruisci la matrice di rotazione
    mat3 rotMatrix = mat3(
        t * axis.x * axis.x + c,        t * axis.x * axis.y - s * axis.z, t * axis.x * axis.z + s * axis.y,
        t * axis.x * axis.y + s * axis.z, t * axis.y * axis.y + c,        t * axis.y * axis.z - s * axis.x,
        t * axis.x * axis.z - s * axis.y, t * axis.y * axis.z + s * axis.x, t * axis.z * axis.z + c
    );
    
    // Applica la rotazione al vettore originale
    return rotMatrix;
}

varying vec3 vTangent;

void main() {
  vUv = uv;
  vNormal = normalize(modelMatrix * vec4(normal,0.0)).xyz;
  vec3 modelTangent = normalize(modelMatrix * vec4(tangent,0.0)).xyz;

  vec3 biTangent = normalize(cross(vNormal, modelTangent));
  mat3 tbn = transpose(mat3(modelTangent, biTangent, -vNormal));

  vTangent = biTangent;

  vec3 pos = position;
  // pos.z += cnoise(position.xy * uFrequency) * uAmplitude;
  vec4 wPos = (modelMatrix * vec4(pos,1.0));

  vec3 camDir = normalize(tbn * cameraPosition - tbn * wPos.xyz);
  camDir = camDir;
  // vParallax = projectOnPlane(camDir, vec3(0.0,0.0,1.0));
  vParallax.xy = camDir.xy;

  // scala il vettore di parallax
  float parallaxScale = uParallaxSize;
  parallaxScale * length(vParallax);
  parallaxScale /= length(dot(camDir,vec3(0.0,0.0,1.0)));  
  vParallax *= parallaxScale;

  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}