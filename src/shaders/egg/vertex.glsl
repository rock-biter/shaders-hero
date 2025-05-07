uniform float uTime;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying vec3 vPos;

void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  vPos = position;
  vec4 wPos = modelMatrix * vec4(position,1.0);
  wPos.y += sin(uTime) * 0.5;

  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}