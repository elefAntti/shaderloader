
float dist_torus( float r1, float r2, vec3 pos )
{
    float f = length( pos.xz ) - r1;
    return length( vec2( f, pos.y ) ) - r2;
}

float dist_model( vec3 pos, float my_time )
{
    //Incorporating x coordinate with time to rotation twists the torus in an interesting way 
    float model_rotation = sin(my_time / 6.0 + pos.x / 8.0) * 10.0;
    // but the result of the twist is not a true distance field, so it needs to be hacked to avoid artifacts
    // This makes us do more steps in the ray marching, so it also slows the computation down
    float dist_hack = 0.5; 

    mat3 rotate = mat3( 1.0, 0.0                 , 0.0,
                        0.0, cos(model_rotation) , sin(model_rotation),
                        0.0, -sin(model_rotation), cos(model_rotation));
    
    return dist_torus( 6.0, 2.0, rotate*pos ) * dist_hack;
}