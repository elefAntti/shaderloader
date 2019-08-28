//Different shapes formed by the idea of generalizing hexagon distance

float diamond_model( vec3 pos )
{
    float r = 2.0;
    return (abs(pos.x) + abs(pos.y) + abs(pos.z) + abs(pos.x + pos.y + pos.z)) / 4.0 - r;
}

float diamond2_model( vec3 pos )
{
    float r = 2.0;
    return (abs(pos.x) + abs(pos.y) + abs(pos.z) + abs(pos.x + pos.y) + abs(pos.z + pos.y) + abs(pos.x + pos.z) + abs(pos.x + pos.y + pos.z)) / 8.0 - r;
}

float diamond3_model( vec3 pos )
{
    float r = 2.0;
    return max(max(max(max(max(abs(pos.x), abs(pos.y)), abs(pos.z)), abs(pos.x + pos.y)), abs(pos.z + pos.y)), abs(pos.x + pos.z)) / 2.0 - r;
}

float diamond4_model( vec3 pos )
{
    float r = 2.0;
    return max(max(max(abs(pos.x), abs(pos.y)), abs(pos.z)), abs(pos.x + pos.y + pos.z)) / 2.0 - r;
}

float diamond5_model( vec3 pos )
{
    float r = 2.0;
    float e = 0.8;
    return pow(dot(pow(abs(pos),vec3(e)), vec3(1.0)) + pow(abs(dot(pos, vec3(1.0))), e), 1.0/e) / 4.0 - r;
}

float dist_model( vec3 pos, float my_time )
{
    return diamond3_model(rotate_y(pos, my_time));
}