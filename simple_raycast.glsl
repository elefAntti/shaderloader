#define AccuracyDropoff 10.0
#define MaxCastLen 50.0
#define NoiseAmount 0.01
#define VignetteStrength 0.6
#define GammaValue 0.8
#define HitDistance 0.001
#define FocalLength 2.0

float castRay2( vec3 vStart, vec3 vDir, float dist_multiplier, float my_time  )
{
    float fCastLen = 0.0;
    vec3 vHit = vStart;
    while(fCastLen < MaxCastLen)
    {
        float fDistance = dist_model( vHit, my_time ) * dist_multiplier;

        if(fDistance < HitDistance)
        {
            return fCastLen;
        }

        fDistance *= max(1.0, fCastLen / AccuracyDropoff);

        fCastLen += fDistance;
        vHit = vDir * fCastLen + vStart;
    }

    return fCastLen;
}

float castRay2( vec3 vStart, vec3 vDir, float dist_multiplier)
{
    return castRay2( vStart, vDir, 1.0, time );
}

float castRay( vec3 vStart, vec3 vDir, float my_time )
{
    return castRay2( vStart, vDir, 1.0, my_time );
}

vec4 rayTraceMain( vec2 fragCoord, float my_time )
{
    vec2 position = fragCoord * -2.0 + 1.0;
    vec3 cameraPos = vec3( 0, 1.0, -20.0 );
    vec3 rayDir = normalize( vec3( position, FocalLength ) );
    float rayLen = castRay( cameraPos, rayDir, my_time );

    return vec4(vec3(rayLen / MaxCastLen), 1.0);
/*
    return rayLen > 50.0 ? backgroundMaterial(cameraPos, rayDir, rayLen)
                         : mainMaterial(cameraPos, rayDir, rayLen);*/
}

void main()
{
    //Fix distortion due to screen ratio
    aspect_ratio = image_width/image_height;
    vec2 fixedCoord = (qt_TexCoord0 - vec2(0.5, 0.5)) * vec2(aspect_ratio, 1.0) + vec2(0.5, 0.5);

    vec4 color = rayTraceMain( fixedCoord, time );

    //Gamma
    color.rgb = pow(color.rgb, vec3(GammaValue));

    //Saturate channels
    color.rgb = min(color.rgb, vec3(1.0));

    //Add noise to improve image quality
    color.rgb += vec3(noise(fixedCoord) - 0.5) * NoiseAmount;

    //Vignette
    color.rgb *= pow(1.0 - length(fixedCoord - vec2(0.5, 0.5)) * VignetteStrength, 0.5); 

    gl_FragColor = color;
}