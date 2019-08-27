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
