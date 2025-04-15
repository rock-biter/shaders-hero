uniform sampler2D uMap;
uniform float uTime;

varying vec3 vColor;
varying float vRandom;

mat2 rotate(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, s, -s, c);
}

void main () {
  vec2 uvPoint = gl_PointCoord.xy;
  uvPoint = uvPoint - 0.5;
  uvPoint = rotate(uTime * 3. + vRandom * 10.) * uvPoint;
  uvPoint = uvPoint + 0.5;

  vec4 mapColor = texture2D(uMap, uvPoint);

  vec4 color = vec4(mapColor);
  color.rgb *= vColor;
  gl_FragColor = color;
}