
float castRay( vec3 vStart, vec3 vDir, float my_time )
{
    float fCastLen = 0.0;
    float fMinDist = 100.0;
    vec3 vHit = vStart + vDir * 0.03;
    while( fCastLen < MaxCastLen )
    {
        float fDistance = dist_model( vHit, my_time );
        fMinDist = min(fMinDist, fDistance);

        if( fDistance < HitDistance)
        {
            return fMinDist;
        }

        fDistance *= max(1.0, fCastLen / AccuracyDropoff);
#ifdef DistanceNoise
        fDistance *= ( 1.0 - noise(vHit) * DistanceNoise);
#endif
        fCastLen += fDistance;
        vHit = vDir * fCastLen + vStart;
    }

    return fMinDist;
}

vec3 glow( vec3 dist )
{
    return /*smoothstep(0.0, 0.04, dist) * */ pow(abs(dist - 0.1) / GlowRadius, vec3(-2.0));
}

vec4 rayTraceMain( vec2 fragCoord )
{
    float dt = 0.1;
    vec2 position = fragCoord * -2.0 + 1.0;
    vec3 cameraPos = vec3( 0, 1.0, -20.0 );
    vec3 rayDir = normalize( vec3( position, 2.0 ) );
    float dist_r = castRay( cameraPos, rayDir, time );
    float dist_g = castRay( cameraPos, rayDir, time + dt);
    float dist_b = castRay( cameraPos, rayDir, time + dt * 2.0);

    return vec4(glow(vec3(dist_r, dist_g, dist_b)), 1.0);
}

void main()
{
    //Fix distortion due to screen ratio
    aspect_ratio = image_width/image_height;
    vec2 fixedCoord = (qt_TexCoord0 - vec2(0.5, 0.5)) * vec2(aspect_ratio, 1.0) + vec2(0.5, 0.5);

    gl_FragColor = rayTraceMain( fixedCoord );
}