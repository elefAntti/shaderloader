
// potential at given point
float metaball( vec3 pos, float r )
{
    return r * r / dot( pos, pos );  
}

float metadiamond( vec3 pos, float r )
{
    vec3 a_pos = abs(pos);
    float l1_norm = a_pos.x + a_pos.y + a_pos.z;
    return r * r / (l1_norm * l1_norm);  
}

float metabox( vec3 pos, float r )
{
    vec3 a_pos = abs(pos);
    float inf_norm = max(max(a_pos.x, a_pos.y), a_pos.z);
    return r * r / (inf_norm * inf_norm);  
}

//Convert metaball 'potential' to approximate distance from surface
float dist_metab( float fPotential )
{
    return 1.0 / sqrt( fPotential ) - 1.0;
}

float dist_model( vec3 pos, float my_time )
{

    float fMeta = dist_metab(
        metaball( pos + vec3( sin(my_time) * 1.0, 1.0, cos(my_time) * 5.0 ), 1.1 )
        + metadiamond( 
            rotate_y(pos + vec3(
                            sin(my_time * 2.0) * 1.0,
                            cos(my_time * 2.0) * 4.0,
                            1.0 ),
                    my_time * 3.0 )
                , 1.0 )
        + metaball( my_time + vec3( sin(my_time * 1.2) * 3.0, sin(my_time * 1.2) * 1.0, cos(my_time * 1.2) * -1.0 ), 0.9 )
        + metaball( pos + vec3( sin(my_time * 1.5) * -1.0, cos(my_time * 1.5) * -1.5, sin(my_time * 1.5) * -0.5 ), 1.2 )
        ) / 1.0;

    return fMeta;
}