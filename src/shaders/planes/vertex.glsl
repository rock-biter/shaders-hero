varying vec3 vWorldPosition;

void main() {
  vec3 pos = position;
  vWorldPosition = (modelMatrix * vec4(pos,1.0)).xyz;
  gl_Position = projectionMatrix * viewMatrix * vec4(vWorldPosition,1.0);
}