uniform float uTime;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;
varying vec3 vPos;

mat2 rotate(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, -s, s, c);
}

void main() {
  vUv = uv;
  vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
  float angle = - uTime * 0.3;
  mat2 rot = rotate(angle);
  vNormal.xz = rot * vNormal.xz;
  vPos = position;
  vec4 wPos = modelMatrix * vec4(position,1.0);
  wPos.xz = rot * wPos.xz;
  wPos.y += sin(uTime) * 0.3;

  vWorldPosition = wPos.xyz;

  gl_Position = projectionMatrix * viewMatrix * wPos;
}