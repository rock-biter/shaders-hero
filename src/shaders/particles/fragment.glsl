uniform sampler2D uMap;
uniform float uTime;

varying vec3 vColor;
varying float vRandom;

mat2 rotate(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, -s, s, c);
}

void main () {
  vec2 uv = gl_PointCoord;
  uv -= 0.5;
  vec2 uv2 = uv;
  uv2 = rotate(3.14159 * 0.25) * uv2;
  
  uv *= 2.0;
  uv = abs(uv);

  uv2 *= 2.0;
  uv2 = abs(uv2);

  float e = 0.2 + sin(uTime * 5. + vRandom * 10.) * 0.02;
  float e2 = 0.3 + sin(uTime * 10. + vRandom * 20.) * 0.05;
  uv = pow(uv,vec2(e));
  uv2 = pow(uv2,vec2(0.2));

  float d = smoothstep(0.4, 1.0, length(uv));
  float d2 = smoothstep(0.1, 1.0, length(uv2));

  float t = 1.0 - d;
  t = mix(1.0, t,d2);

  vec3 color = mix(vec3(1.0),vColor,0.5);
  gl_FragColor = vec4(color,t);
}