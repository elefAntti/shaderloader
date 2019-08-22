varying highp vec2 qt_TexCoord0;
uniform float image_width;
uniform float image_height;

uniform sampler2D source;


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

//Compute the gradient of the dist_model at pos
vec3 gradient_model( vec3 pos, float eps )
{
    return vec3(
        dist_model( vec3( eps, 0.0, 0.0 ) + pos ),
        dist_model( vec3( 0.0, eps, 0.0 ) + pos ),
        dist_model( vec3( 0.0, 0.0, eps ) + pos ) )
        - vec3( 1.0, 1.0, 1.0 ) * dist_model( pos );
}

//Does sort of environment map with 'source' texture
//The object appears shiny
vec4 reflectiveMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    vec3 hitPoint = cameraPos + rayDir * rayLen;
    vec3 lookup = -normalize(gradient_model(hitPoint, 0.01));
    return texture2D(source, lookup.xy + vec2(0.5, 0.5));
}

//This material renders the edges of object with black
//Otherwise everything is white
vec4 edgeMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    vec3 hitPoint = cameraPos + rayDir * rayLen;
    vec3 lookup = gradient_model(hitPoint, 0.01) / 0.01;
    float c = dot(rayDir, lookup);
    return vec4(vec3(step(0.2, abs(c))), 1.0);
}

vec4 switchMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    float control = sin(time / 2.0) + sin(time / 3.14);
    if(control > 0.2)
    {
        return reflectiveMaterial(cameraPos, rayDir, rayLen);
    }
    else
    {
        return edgeMaterial(cameraPos, rayDir, rayLen);
    }
}

vec4 rayTraceMain( vec2 fragCoord )
{
    vec2 position = fragCoord * -2.0 + 1.0;
    vec3 cameraPos = vec3( 0, 1.0, -20.0 );
    vec3 rayDir = normalize( vec3( position, 2.0 ) );
    float rayLen = castRay( cameraPos, rayDir );

    return switchMaterial(cameraPos, rayDir, rayLen);
}

void main()
{
    //Fix distortion due to screen ratio
    float ratio = image_width/image_height;
    vec2 fixedCoord = (qt_TexCoord0 - vec2(0.5, 0.5)) * vec2(ratio, 1.0) + vec2(0.5, 0.5);

    gl_FragColor = rayTraceMain( fixedCoord );
}