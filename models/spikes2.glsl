#define InnerRadius 7.95
#define OuterRadius 8.0

#define TimeStep 2.0

float model_radius_fcn(float time)
{
   return mix(InnerRadius, 0.0, clamp(time  / TimeStep - 5.0, 0.0, 1.0));
} 

float glow_radius_fcn(float time)
{
   return 0.05;
   //return mix(0.05, 0.25, clamp(time  / TimeStep - 6.0, 0.0, 1.0));
} 

vec3 to_polar(vec3 pos)
{
    float x = atan( pos.x, pos.z );
    float y = atan( pos.y, length(pos.xz));
    return vec3(x, y, length(pos));
}

vec4 quaternion_multiply(vec4 a, vec4 b)
{
    float real_p = a.x*b.x - dot(a.yzw, b.yzw);
    vec3 imag_p = a.x * b.yzw + b.x * a.yzw + cross(a.yzw, b.yzw);
    return vec4(real_p, imag_p);
}

vec4 quaternion_inverse(vec4 a)
{
    float len = length(a);
    return a * vec4(1.0, vec3(-1.0)) / (len * len);
}

vec4 rotation_quaternion(vec3 axis, float angle)
{
    return vec4(cos(angle/2.0), sin(angle/2.0) * axis);
}

vec3 rotate_around_axis(vec3 v, vec3 axis, float angle)
{
    vec4 Q = rotation_quaternion(axis, angle);
    vec4 Q_inv = quaternion_inverse(Q);
    return quaternion_multiply(quaternion_multiply(Q, vec4(0.0, v)), Q_inv).yzw;
}

float spoke_model(vec3 pos, float my_time)
{
    //float warp_factor = 0.5;//(1.0 - cos(my_time / 20.0)) * 0.5 + 0.5;
    vec3 polar = to_polar(pos);
    //my_time -= polar.z * 0.3;
    //polar.x += cos(my_time / 10.0) * 10.0;// * mix(0.0, 2.0, warp_factor);
    vec2 xy = polar.xy / (M_PI * 2.0) + 0.5;
    xy.y /= 0.75;
    float spoke_count = 5.0;// smoothstep(2.0, 10.0, my_time) * 7.0;
    vec2 xy2 = fract(xy * spoke_count) - 0.5;

    float dist_polar = length(xy2) * polar.z;
    float inner_radius = model_radius_fcn(time);
    return max(max(dist_polar - 0.25, polar.z - 8.0), inner_radius - polar.z ) * 0.4;  
}

float rotated_model(vec3 pos, float my_time)
{
    float t = floor(my_time / TimeStep);
    float angle = fract(my_time / TimeStep) * 2.0 * M_PI;
    vec3 axis =  t < 2.5  ?
         vec3( 0.0, 1.0, 0.0) :
         vec3(noise(t + 0.2) - 0.5,
              noise(t + 0.7) - 0.5,
              noise(t + 1.1) - 0.5);
    axis = normalize(axis);
    return spoke_model(rotate_around_axis(pos, axis, angle), my_time);
}

float dist_model(vec3 pos, float my_time)
{
    float len = length(pos);
    if( len > 8.5)
    {
        return len - 8.0;
    }
    return rotated_model(pos, (my_time - 0.3 * len) * 0.25);
}