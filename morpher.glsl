
float morpher( vec3 pos, float r, float shape)
{
	float norm = pow(dot(pow(abs(pos) / r, vec3(shape)), vec3(1.0)), 1.0 / shape);
    return (norm - 1.0) * r / 2.0;  
}

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

float dist_model( vec3 pos )
{
	float shape = triangle_wave(time/8.0) + 1.8;
	shape += smoothstep(2.1, 2.4, shape) * 3.0; 
	return morpher(rotate_y(pos, time), 5.0, shape);
}