// #define NUM_OCTAVES 5

float fbm(float x, int octaves) {
	float v = 0.0;
	float a = 1.;
  float normalization = 0.;
	float shift = float(100);
	for (int i = 0; i < octaves; ++i) {
    normalization += a;
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
  v /= normalization;
	return v;
}


float fbm(vec2 x, int octaves) {
	float v = 0.0;
	float a = 1.;
  float normalization = 0.;
	vec2 shift = vec2(100);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
	for (int i = 0; i < octaves; ++i) {
    normalization += a;
		v += a * noise(x);
		x = rot * x * 2.0 + shift;
		a *= 0.5;
	}
  v /= normalization;
	return v;
}


float fbm(vec3 x, int octaves) {
	float v = 0.0;
	float a = 1.;
  float normalization = 0.;
	vec3 shift = vec3(100);
	for (int i = 0; i < octaves; ++i) {
    normalization += a;
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
  v /= normalization;
	return v;
}