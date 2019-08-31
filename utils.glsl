vec3 rotate_y( vec3 pos, float angle )
{
    mat3 rotate = mat3(
                    cos(angle), 0.0, sin(angle),
                    0.0, 1.0                 , 0.0,
                    -sin(angle), 0.0, cos(angle));
    return rotate * pos;
}

float triangle_wave(float x)
{
    return abs(mod(x, 4.0) - 2.0) - 1.0;
}

float square_wave(float x)
{
    return sign(mod(x, 4.0) - 2.0);
}

float noise(float pos)
{
    //Picking the low bits, which are more random
    return mod(sin(pos) * 10000.0, 1.0);
}

float noise(vec2 pos)
{
    //Combine x and y so that there is no visible pattern in the noise
    //Just picking two numbers that are not multiples of each other
    float key = pos.x * 111.0 + pos.y * 788.0;
    return noise(key);
}

float noise(vec3 pos)
{
    float key = pos.x * 111.0 + pos.y * 788.0 + pos.z * 827.0;
    return noise(key);
}