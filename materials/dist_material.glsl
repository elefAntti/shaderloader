vec4 dist_material(vec3 camera_pos, vec3 ray_dir, float ray_len)
{
    return vec4(vec3(ray_len / MaxCastLen), 1.0);
}