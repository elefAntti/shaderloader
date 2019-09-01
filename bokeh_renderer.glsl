float rayDistFromPoint(vec3 rayDir, vec3 rayOrigin, vec3 point)
{
    vec3 relativePos = point - rayOrigin;
    float projection = dot(rayDir, relativePos);
    return sqrt( dot(relativePos, relativePos) - projection * projection );
}

int bokkehCount = 42;
vec3 getBokehPosition(int idx, float my_time)
{
    int pointsPerLayer = 7;
    int layer = idx / pointsPerLayer + 1;
    int sector = idx - layer * pointsPerLayer;

    float sectorWidth = 2.0 * M_PI / float(pointsPerLayer);
    float layerWidth = M_PI / 7.0;

    float alpha = sectorWidth * float(sector);
    float radius = 10.0;
    float y = -cos(layerWidth * float(layer)) * radius;
    float x = sin(layerWidth * float(layer)) * radius;
    vec3 raw_pos = vec3(cos(alpha) * x, y, sin(alpha)* x);
    return rotate_y(raw_pos, my_time);
}

vec4 getBokehColor(int idx, float my_time)
{
    return vec4(0.0, 0.5, 1.0, 1.0);
}

vec4 renderBokeh(vec2 tex_coord, float my_time)
{
    vec2 position = tex_coord * -2.0 + 1.0;
    vec3 cameraPos = vec3( 0, 1.0, -20.0 );
    vec3 rayDir = normalize( vec3( position, 2.0 ) );

    vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
    for(int i = 0; i < bokkehCount; ++i)
    {
        vec3 pos = getBokehPosition(i, my_time);
        float dist = rayDistFromPoint(rayDir, cameraPos, pos);
        float smoothness = 0.1;

        float radius = 0.01 + length(pos - cameraPos) / 10.0;
        float intensity = (smoothstep(radius, radius * (1.0 - smoothness), dist) ) * 5.0 / length(pos - cameraPos);
        intensity *= mix(0.7, 1.0, smoothstep(0.8*radius, radius, dist));

        vec4 bokkehColor = getBokehColor(i, my_time);
        color += intensity * bokkehColor;
    }
    color.w = 1.0;
    return color;
}


void main()
{
    //Fix distortion due to screen ratio
    aspect_ratio = image_width/image_height;
    vec2 fixedCoord = (qt_TexCoord0 - vec2(0.5, 0.5)) * vec2(aspect_ratio, 1.0) + vec2(0.5, 0.5);

    gl_FragColor = renderBokeh( fixedCoord, time );
}