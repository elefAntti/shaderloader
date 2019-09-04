float dist_model(vec3 pos, float time)
{
    return (pos.y - noise_frac(pos.xz + time * vec2(0.2, 0.4)));
}