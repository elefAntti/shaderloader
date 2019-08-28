
float max_xyz(vec3 v)
{
    return max(max(v.x, v.y), v.z);
}

float dist_box( float side, vec3 pos )
{
    return max_xyz(abs(pos)) - side;
}

float dist_model( vec3 pos, float my_time )
{
    //Incorporating x coordinate with time to rotation twists the torus in an interesting way 
    float model_rotation = sin(my_time / 6.0 + pos.y / 80.0) * 10.0;
    // but the result of the twist is not a true distance field, so it needs to be hacked to avoid artifacts
    // This makes us do more steps in the ray marching, so it also slows the computation down
    float dist_hack = 0.5; 
    
    return dist_box( 4.0, rotate_y(pos + vec3(0.0, 1.0, 0.0), model_rotation) ) * dist_hack;
}