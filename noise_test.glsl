//Field-of-pillars model based on special voxel renderer
//Produces faster results then the generic field of pillars model

float moving_pixel_noise(vec2 texCoord, float my_time, float time_step, float resolution)
{
    float time_now = floor(my_time / time_step);
    vec2 grid_coord = floor(texCoord * resolution);
    float intensity_now = noise(vec3(grid_coord, time_now));
    float intensity_soon = noise(vec3(grid_coord, time_now + 1.0));
    return mix(intensity_now, intensity_soon, mod(my_time/time_step, 1.0));
}

float grid_space = 1.0;


float height_model(vec2 coord, float my_time)
{
    vec2 grid_coord = floor(coord * grid_space);
    float time_step = noise(grid_coord) * 2.0 + 0.5;
    return moving_pixel_noise(coord, time, time_step, grid_space);
}

float min_comp(vec2 vector)
{
    return min(vector.x, vector.y);
}

float max_comp(vec3 vector)
{
    return max(max(vector.x, vector.y), vector.z);
}

float castRay( vec3 vStart, vec3 vDir, float resolution, float my_time )
{
    float fCastLen = 0.0;
    vec3 vHit = vStart + vDir * 0.03;
    while( fCastLen < 100.0 )
    {
        float height = vHit.y - moving_pixel_noise( vHit.xz, my_time, 3.0, resolution );

        float fDistance = abs(height);

        fCastLen += fDistance;
        vHit = vDir * fCastLen + vStart;
        if( height < 0.003 )
        {
            return fCastLen - 0.5 * fDistance;
        }
    }

    return 100.0;
}

float castRayX( vec3 vStart, vec3 vDir, float fMult )
{
    vec3 vGridStart = ( floor( vStart / grid_space ) + vec3(0.5) ) * grid_space;
    vec3 vStepX = vec3( grid_space, 0.0, 0.0 ) * sign( vDir.x );
    vec3 vStepY = vec3( 0.0, grid_space, 0.0 ) * sign( vDir.y );
    vec3 vStepZ = vec3(  0.0, 0.0, grid_space ) * sign( vDir.z );

    int iLastDir = 0;

    vec3 vHit = vStart;

    //The values for t where the ray crosses to next voxel
    vec3 tMax = abs( ( vGridStart + ( vStepX + vStepY + vStepZ ) * 0.5 ) - vStart) / vDir; 

    //How far we have to move in units of t to move the width of a voxel
    vec3 tDelta = (vec3(1.0, 1.0, 1.0) * grid_space) / abs(vDir); 

    int max_steps = 100;


    for( int i = 0; i < max_steps; ++i) {
        float height = height_model(vHit.xz, grid_space) - vHit.y;
        float tMaxY = abs(height / vDir.y);
        if(tMax.x < tMaxY)
        {
            if(tMax.x < tMax.z)
            {
                vHit += vStepX;
                tMax.x += tDelta.x;
            }
            else 
            {
                vHit += vStepZ;
                tMax.z += tDelta.z;
            }
        }
        else 
        {
            if(tMaxY < tMax.z)
            {
                vHit.y += height;
                tMax.y += tDelta.y; 
            }
            else 
            {
                vHit += vStepZ;
                tMax.z += tDelta.z;
            } 
        }


        if( height > -0.03 )
        {         
            return length( vHit - vStart );
        }
    }

    return 1000.0;
}


float castRay2( vec3 vStart, vec3 vDir, float dist_multiplier)
{
    return 1.0;
}

vec4 rayTraceMain( vec2 fragCoord, float my_time )
{
    vec2 position = fragCoord * -2.0 + 1.0;
    vec3 cameraPos = vec3( 0, 2.0, -20.0 );
    vec3 rayDir = normalize( vec3( position, 2.0 ) );
    float rayLen = castRayX( cameraPos, rayDir, 1.0 );//castRay( cameraPos, rayDir, 1.0, my_time );

    return vec4(vec3(pow(rayLen / 100.0, 1.0)), 0.8);
}

void main()
{
    //Fix distortion due to screen ratio
    aspect_ratio = image_width/image_height;
    vec2 fixedCoord = (qt_TexCoord0 - vec2(0.5, 0.5)) * vec2(aspect_ratio, 1.0) + vec2(0.5, 0.5);
    //float intensity = moving_pixel_noise(fixedCoord, time, 1.0, 10.0);
    gl_FragColor = rayTraceMain( fixedCoord, time );//vec4(vec3(intensity), 1.0);
}