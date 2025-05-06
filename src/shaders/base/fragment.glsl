
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vWorldPosition;

void main() {

  vec2 uv = vUv;
  vec3 pos = vWorldPosition;

  vec3 baseColor = vec3(uv,1.0);

  vec3 color = baseColor;
  gl_FragColor = vec4(color,1.0);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}