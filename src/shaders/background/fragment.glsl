uniform float uProgress;
varying vec2 vUv;

void main() {

  vec3 color = vec3(0.36, 0.38, 0.44);
  color -= (1. - length(vUv)) * 0.5 * uProgress;

  gl_FragColor = vec4(color, 1.0);

  #include <tonemapping_fragment>
  #include <colorspace_fragment>
}