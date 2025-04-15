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
  vec4 mvPosition = viewMatrix * worldPosition;
  gl_Position = projectionMatrix * mvPosition;

  gl_PointSize = uSize / - mvPosition.z;
  gl_PointSize *= 0.001 * uResolution.y;

}