uniform float time;
varying highp vec2 qt_TexCoord0;
uniform float image_width;
uniform float image_height;

uniform sampler2D source;

float aspect_ratio = 1.0;
#define M_PI 3.1415926535897932384626433832795

float dist_model(vec3 pos, float my_time);
float castRay2( vec3 vStart, vec3 vDir, float dist_multiplier );