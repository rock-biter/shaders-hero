varying vec3 vPos;

void main() {

  vPos = (modelMatrix * vec4(position, 1.0)).xyz;

  gl_Position = projectionMatrix * viewMatrix * vec4(vPos, 1.0);
}