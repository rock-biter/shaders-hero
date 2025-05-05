attribute vec3 tangent;

uniform float uTime;
uniform float uFrequency;
uniform float uParallaxOffset;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying vec2 vParallax;

void main() {
  vUv = uv;
  vec3 wNormal = normalize(modelMatrix * vec4(normal,0.0)).xyz;
  vec3 wTangent = normalize(modelMatrix * vec4(tangent,0.0)).xyz;
  vec3 wBTangent = normalize(cross(wNormal, wTangent));
  vNormal = wNormal;

  mat3 tbn = transpose(mat3(wTangent, wBTangent,wNormal));

  vec3 pos = position;
  vec4 wPos = (modelMatrix * vec4(pos,1.0));

  vec3 viewDir = normalize(cameraPosition - wPos.xyz);
  viewDir = tbn * viewDir;
  vParallax = -viewDir.xy;

  float parallaxScale = uParallaxOffset / dot(viewDir, vec3(0,0,1));
  vParallax *= parallaxScale;

  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}