uniform float time;
varying highp vec2 qt_TexCoord0;
uniform float image_width;
uniform float image_height;

uniform sampler2D source;

float aspect_ratio = 1.0;

float castRay2( vec3 vStart, vec3 vDir, float dist_multiplier );