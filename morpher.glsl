
float morpher( vec3 pos, float r, float shape)
{
	float norm = pow(dot(pow(abs(pos) / r, vec3(shape)), vec3(1.0)), 1.0 / shape);
    return (norm - 1.0) * r / 2.0;  
}

float dist_model( vec3 pos )
{
	float shape = triangle_wave(time/8.0) + 1.8;
	shape += smoothstep(2.1, 2.4, shape) * 3.0; 
	return morpher(rotate_y(pos, time), 5.0, shape);
}