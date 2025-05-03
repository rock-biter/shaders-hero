varying vec2 vUv;
varying vec3 vWorldPosition;

void main() {
  vec3 pos = position;
  vec4 wPos = modelMatrix * vec4(pos,1.0);
  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}