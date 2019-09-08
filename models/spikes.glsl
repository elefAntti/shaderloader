float capsule(vec3 pos, vec3 end1, vec3 end2, float radius)
{
    vec3 dir = end2 - end1;
    float capsule_len = length(dir);
    dir /= capsule_len;
    float projection = dot(pos - end1, dir);
    vec3 nearest_point = end1 + clamp(projection, 0.0, capsule_len) * dir;
    return length(pos - nearest_point) - radius;
}

vec3 get_point_on_sphere(int idx, int pointsPerLayer, float layers, float radius)
{
    int layer = idx / pointsPerLayer + 1;
    int sector = idx - layer * pointsPerLayer;

    float sectorWidth = 2.0 * M_PI / float(pointsPerLayer);
    float layerWidth = M_PI / layers;

    float alpha = sectorWidth * float(sector);
    float y = -cos(layerWidth * float(layer)) * radius;
    float x = sin(layerWidth * float(layer)) * radius;
    vec3 raw_pos = vec3(cos(alpha) * x, y, sin(alpha)* x);
    return raw_pos;
}

float dist_model( vec3 pos, float my_time )
{
    my_time -= length(pos) * 0.5;
    float dist_accu = 100.0;
    for(int i = 0; i < 16; ++i)
    {
        vec3 pt = rotate_y(get_point_on_sphere(i, 4, 4.0, 4.0), my_time);
        dist_accu = min(capsule(pos, vec3(0.0), pt, 0.25), dist_accu);  
    }
    return dist_accu;
    //return capsule(pos, vec3(0.0), rotate_y(vec3(1.0, 0.0, 0.0), my_time), 0.25);
}