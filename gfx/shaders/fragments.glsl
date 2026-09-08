#version 330 core

uniform vec4 uColor;
uniform vec2 uDimensions;
uniform float uRadius;
uniform sampler2D atlasText;
out vec4 fragColor;
in vec2 FragUV;

float rounded_rect_sdf(vec2 p, vec2 half_size, float radius) {
  vec2 q = abs(p) - half_size + radius;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}


void main() {
  vec2 half_size = uDimensions * 0.5;
  vec2 p = FragUV * uDimensions - half_size;

  float dist = rounded_rect_sdf(p, half_size, uRadius);
  float alpha = 1.0 - smoothstep(0.0, 1.0, dist);
  float sample = texture(atlasText, FragUV).r;
  fragColor = vec4(sample, sample, sample, 1.0);
}



