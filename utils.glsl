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

float noise_res(vec2 uv)
{
    vec2 id = floor(uv);
    vec2 rem = fract(uv);
    float a = mix(noise(id), noise(id + vec2(1.0, 0.0)), rem.x);
    float b = mix(noise(id+ vec2(0.0, 1.0)), noise(id + vec2(1.0, 1.0)), rem.x);
    return mix(a, b, rem.y);
}

float noise_frac(vec2 uv)
{
    float val = noise_res(uv)
      + noise_res(uv * 2.0 + vec2(1.11)) / 2.0
      + noise_res(uv * 4.0 + vec2(3.14)) / 4.0
      + noise_res(uv * 8.0 - vec2(2.7)) / 8.0
      + noise_res(uv * 16.0 + vec2(8)) / 16.0
      + noise_res(uv * 32.0 + vec2(3)) / 32.0;
    return val/2.0; 
}
