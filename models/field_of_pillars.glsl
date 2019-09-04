float square(vec2 pos, float side)
{
    return max(abs(pos.x), abs(pos.y)) - side /2.0;
}

float time_noise(vec2 grid_coord, float my_time)
{
    float time_step = 2.0;
    float time_now = floor(my_time / time_step);
    float intensity_now = noise(vec3(grid_coord, time_now));
    float intensity_soon = noise(vec3(grid_coord, time_now + 1.0));
    return mix(intensity_now, intensity_soon, mod(my_time/time_step, 1.0));
}

float dist_model(vec3 pos, float my_time)
{
   if(pos.y > 3.0)
    {
        return pos.y - 2.0;
    }

    if(pos.y < 0.0)
    {
        return 100.0;
    }


    float res = 1.0;
    vec2 coordInTile = fract( pos.xz * res) - 0.5;
    vec2 tileCoord = floor( pos.xz  * res ); 

    float dist = 100.0;
    for( int i = -1; i < 2 ; ++i)
    {
        for( int j = -1; j < 2 ; ++j)
        {  
            vec2 offset = vec2(i,j);
            float height = time_noise( tileCoord + offset, my_time );
            float localDist = max(square(coordInTile - offset, 1.0), abs(pos.y) - height); 
            dist = min(dist, localDist);
        }
    }
    return dist;
}
