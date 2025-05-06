attribute vec3 color;
attribute float aRandom;

uniform float uSize;
uniform vec2 uResolution;
uniform float uTime;

varying vec2 vUv;
varying vec3 vColor;
varying vec3 vWorldPosition;
varying float vRandom;

void main() {
  vUv = uv;
  vColor = color;
  vRandom = aRandom;

  vec4 wPos = modelMatrix * vec4(position,1.0);
  wPos.y += sin(wPos.x + uTime) * 0.5 + cos(wPos.z + uTime) * 0.5;
  vWorldPosition = wPos.xyz;
  vec4 mvPosition = viewMatrix * wPos;

  float sizeScale = 1.0 + sin(uTime * 10. * (aRandom * 0.5 + 0.5) + aRandom * 50. );

  gl_Position = projectionMatrix * mvPosition;
  gl_PointSize = aRandom * uSize / -mvPosition.z;
  gl_PointSize *= 0.001 * uResolution.y;
  gl_PointSize *= sizeScale;
}