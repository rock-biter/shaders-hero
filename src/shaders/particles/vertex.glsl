attribute vec3 color;
attribute float aRandom;

uniform float uSize;
uniform vec2 uResolution;
uniform float uTime;

varying vec3 vColor;
varying float vRandom;

void main() {
  vColor = color;
  vRandom = aRandom;

  vec4 worldPosition = modelMatrix * vec4(position, 1.0);

  worldPosition.y = sin(worldPosition.x + uTime * aRandom + aRandom * 10. );

  vec4 mvPosition = viewMatrix * worldPosition;
  gl_Position = projectionMatrix * mvPosition;

  float sizeScale = sin(uTime * 10. * aRandom + aRandom * 50.);

  gl_PointSize = aRandom * uSize / - mvPosition.z;
  gl_PointSize *= 0.001 * uResolution.y;
  gl_PointSize *= 1.0 + sizeScale;

}