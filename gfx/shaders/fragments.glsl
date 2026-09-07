#version 330 core

uniform vec4 uColor;
uniform vec2 uDimensions;
out vec4 fragColor;
in vec2 FragUV;

void main() {
  fragColor = vec4(FragUV.x, FragUV.y, 0.0, 1.0);
}
