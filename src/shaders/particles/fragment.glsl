uniform sampler2D uMap;
uniform float uTime;

varying vec2 vUv;
varying vec3 vColor;
varying vec3 vWorldPosition;
varying float vRandom;

mat2 rotate(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, -s, s, c);
}

void main() {
  vec2 uv = gl_PointCoord;
  uv.y = 1. - uv.y;

  float angle = uTime * 3. * vRandom + vRandom * 10.;
  uv -= 0.5;
  uv = rotate(angle) * uv;
  uv += 0.5;

  vec4 colorMap = texture(uMap, uv);
  // vec3 color = vec3(uv,1.0);
  vec3 color = colorMap.xyz;
  color *= vColor;

  float toCamera = length(vWorldPosition - cameraPosition);
  float fog = 1. - smoothstep(20.,30., toCamera);

  float a = colorMap.a * fog;
  
  gl_FragColor = vec4(color, a);
}