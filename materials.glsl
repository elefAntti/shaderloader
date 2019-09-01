//Select the desired material here
#define mainMaterial redshiftMaterial
#define backgroundMaterial constantMaterial

//This was the color used for the redshift material
#define backgroundColor vec4(vec3(0.6), 1.0)

#define materialColor vec4(1.0, 0.0, 0.0, 1.0)
//#define backgroundColor vec4(1.0, 1.0, 1.0, 1.0)

//Compute the gradient of the dist_model at pos
vec3 gradient_model( vec3 pos, float eps, float my_time )
{
    return vec3(
        dist_model( vec3( eps, 0.0, 0.0 ) + pos, my_time ),
        dist_model( vec3( 0.0, eps, 0.0 ) + pos, my_time ),
        dist_model( vec3( 0.0, 0.0, eps ) + pos, my_time ) )
        - vec3( 1.0, 1.0, 1.0 ) * dist_model( pos, my_time );
}

float curvature_model( vec3 pos, float eps, float my_time )
{
    vec3 curv = abs(vec3(dist_model( pos, my_time ))
        - vec3(
        dist_model( vec3( eps, 0.0, 0.0 ) + pos, my_time),
        dist_model( vec3( 0.0, eps, 0.0 ) + pos, my_time),
        dist_model( vec3( 0.0, 0.0, eps ) + pos, my_time) )
        - vec3(
        dist_model( vec3( -eps, 0.0, 0.0 ) + pos, my_time),
        dist_model( vec3( 0.0, -eps, 0.0 ) + pos, my_time),
        dist_model( vec3( 0.0, 0.0, -eps ) + pos, my_time)));
    return max(max(curv.x, curv.y), curv.z) / (2.0 * eps);
}

float time_derivative( vec3 pos, float eps, float my_time )
{
    return (dist_model(pos, my_time + eps) - dist_model(pos, my_time)) / eps;
}

//Does sort of environment map with 'source' texture
//The object appears shiny
vec4 reflectiveMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    vec3 hitPoint = cameraPos + rayDir * rayLen;
    vec3 norm = normalize(gradient_model(hitPoint, 0.01, time));

    vec3 lookup = reflect(rayDir, norm);
    float x = lookup.x * 0.5 + 0.5;
    float y = -lookup.y * 0.5 + 0.5;
    return texture2D(source, vec2(x,y));
}


//Does sort of environment map with 'source' texture
//The object appears shiny
vec4 glossyMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    vec3 hitPoint = cameraPos + rayDir * rayLen;
    vec4 color = vec4(0.0);
    vec3 gradient = gradient_model(hitPoint, 0.01, time);
    for(int i = 0; i < 10; ++i)
    {
        vec3 norm = normalize( gradient + noise(hitPoint + vec3(float(i)) ) * 0.001);
        vec3 lookup = reflect(rayDir, norm);
        float x = lookup.x * 0.5 + 0.5;
        float y = -lookup.y * 0.5 + 0.5;
        color += texture2D(source, vec2(x,y));
    }
    return color / 10.0;
}

//Just projecting the source image on the surface
//Useful for backround images
vec4 projectiveMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    vec3 hitPoint = rayDir / rayDir.z;
    return texture2D(source, vec2(hitPoint.x / aspect_ratio + 0.5, 0.5 - hitPoint.y));
}

//Called by refractive material, because glsl doesn't support recursion
vec4 refractiveMaterial_b(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    if(rayLen > 50.0)
    {
        return projectiveMaterial(cameraPos, rayDir, rayLen);
    }
    else
    {
        vec3 hitPoint = cameraPos + rayDir * rayLen;
        vec3 norm = normalize(gradient_model(hitPoint, 0.01, time));

        vec3 lookup = refract(rayDir, norm, 1.005);

        float x = lookup.x * 0.5 + 0.5;
        float y = -lookup.y * 0.5 + 0.5;
        return texture2D(source, vec2(x,y));
    }
}

//Main refractive, reflective and a bit red material
vec4 refractiveMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    if(rayLen > 50.0)
    {
        return projectiveMaterial(cameraPos, rayDir, rayLen);
    }
    else
    {
        vec3 hitPoint = cameraPos + rayDir * (rayLen + 0.03);
        vec3 norm = -normalize(gradient_model(hitPoint, 0.01, time));

        vec3 lookup = refract(rayDir, norm, 1.0/1.005);

        float dist = castRay2(hitPoint, lookup, -1.0);
        vec4 refract = refractiveMaterial_b(hitPoint, lookup, dist);

        return refract * 0.6 + 0.4 * reflectiveMaterial(cameraPos, rayDir, rayLen) + vec4(0.1, 0.0, 0.0, 1.0);
    }
}

//This material renders the edges of object with black
//Otherwise everything is white
vec4 edgeMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    vec3 hitPoint = cameraPos + rayDir * rayLen;
    vec3 lookup = normalize(gradient_model(hitPoint, 0.01, time));
    float c = dot(rayDir, lookup);
    return vec4(vec3(step(0.2, abs(c))), 1.0);
}

//This material is sensitive to curvature, so it colors the edges white
vec4 edgeMaterial2(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    vec3 hitPoint = cameraPos + rayDir * rayLen;
    float c = curvature_model(hitPoint, 0.1, time);
    return vec4(vec3(min(c * 5.0, 1.0)), 1.0);
}

vec4 redshiftMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    float scale = 0.1;
    vec3 hitPoint = cameraPos + rayDir * rayLen;
    float lookup = time_derivative(hitPoint, 0.01, time) * scale + 0.5;
    return mix(vec4(1.0, 0.0, 0.0, 1.0), vec4(0.0, 0.0, 1.0, 1.0), lookup);
}

//Switching the material that is used as a function of time
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

//Refelective material for the front, projection for the background
vec4 envMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
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

vec4 constantMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    return backgroundColor;
}

vec4 distLineMaterial(vec3 cameraPos, vec3 rayDir, float rayLen)
{
    float frequency = 3.0;
    float thickness = 0.2;
    float intensity = step((1.0 - thickness), mod(rayLen * frequency, 1.0));
    return mix(backgroundColor, materialColor, intensity);
}