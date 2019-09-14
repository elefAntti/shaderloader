#define InnerRadius 7.95
#define OuterRadius 8.0

#define TimeStep 2.0
#define SpokeCount 5.0

float model_radius_fcn(float time)
{
   return mix(InnerRadius, 0.0, clamp(time  / TimeStep - 5.0, 0.0, 1.0));
} 

float spoke_model(vec3 pos, float my_time)
{
    vec3 polar = to_polar(pos);
    vec2 xy = polar.xy / (M_PI * 2.0);
    //Adjust spoke position away from the poles
    xy.y /= 0.75;
    xy += 0.5;
    
    vec2 xy2 = fract(xy * SpokeCount) - 0.5;

    float dist_polar = length(xy2) * polar.z;
    float inner_radius = model_radius_fcn(time);
    return max(max(dist_polar - 0.25, polar.z - 8.0), inner_radius - polar.z ) * 0.4;  
}

float rotated_model(vec3 pos, float my_time)
{
    float t = floor(my_time / TimeStep);
    float angle = fract(my_time / TimeStep) * 2.0 * M_PI;
    vec3 axis =  t < 1.0  ?
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
    //Early out
    if( len > (OuterRadius + 0.5))
    {
        return len - OuterRadius;
    }
    return rotated_model(pos, (my_time - 0.3 * len) * 0.25);
}