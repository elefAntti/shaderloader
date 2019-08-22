uniform float time;

float dist_torus( float r1, float r2, vec3 pos )
{
    float f = length( pos.xz ) - r1;
    return length( vec2( f, pos.y ) ) - r2;
}

float dist_model( vec3 pos )
{
    float model_rotation = sin(time / 6.0) * 10.0;
    mat3 rotate = mat3( 1.0, 0.0                 , 0.0,
                        0.0, cos(model_rotation) , sin(model_rotation),
                        0.0, -sin(model_rotation), cos(model_rotation));
    return dist_torus( 6.0, 2.0, rotate*pos );
}