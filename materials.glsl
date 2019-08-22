
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
    vec3 norm = normalize(gradient_model(hitPoint, 0.01));

    vec3 lookup = reflect(rayDir, norm);
    float x = lookup.x * 0.5 + 0.5;
    float y = -lookup.y * 0.5 + 0.5;
    return texture2D(source, vec2(x,y));
}

vec4 projectiveMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    vec3 hitPoint = rayDir / rayDir.z;
    return texture2D(source, vec2(hitPoint.x / aspect_ratio + 0.5, 0.5-hitPoint.y));
}

//This material renders the edges of object with black
//Otherwise everything is white
vec4 edgeMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    vec3 hitPoint = cameraPos + rayDir * rayLen;
    vec3 lookup = normalize(gradient_model(hitPoint, 0.01));
    float c = dot(rayDir, lookup);
    return vec4(vec3(step(0.2, abs(c))), 1.0);
}

vec4 switchMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    float control = sin(time / 2.0) + sin(time / 3.14);
    if(control > 0.2)
    {
        if(rayLen > 50.0)
        {
            return projectiveMaterial(cameraPos, rayDir, rayLen);
        }
        else
        {
            return reflectiveMaterial(cameraPos, rayDir, rayLen);
        }
    }
    else
    {
        if(rayLen > 50.0)
        {
            return vec4(vec3(0.5), 1.0);
        }
        else
        {
            return edgeMaterial(cameraPos, rayDir, rayLen);
        }
    }
}