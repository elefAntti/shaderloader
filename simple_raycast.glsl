float castRay( vec3 vStart, vec3 vDir )
{
    float fCastLen = 0.0;
    vec3 vHit = vStart + vDir * 0.03;
    while( fCastLen < 100.0 )
    {
        float fDistance = dist_model( vHit );
        fCastLen += fDistance;
        vHit = vDir * fCastLen + vStart;

        if( fDistance < 0.001 )
        {
            return fCastLen;
        }
    }

    return fCastLen;
}

vec4 rayTraceMain( vec2 fragCoord )
{
    vec2 position = fragCoord * -2.0 + 1.0;
    vec3 cameraPos = vec3( 0, 1.0, -20.0 );
    vec3 rayDir = normalize( vec3( position, 2.0 ) );
    float rayLen = castRay( cameraPos, rayDir );

    return reflectiveMaterial(cameraPos, rayDir, rayLen);
}

void main()
{
    //Fix distortion due to screen ratio
    aspect_ratio = image_width/image_height;
    vec2 fixedCoord = (qt_TexCoord0 - vec2(0.5, 0.5)) * vec2(aspect_ratio, 1.0) + vec2(0.5, 0.5);

    gl_FragColor = rayTraceMain( fixedCoord );
}