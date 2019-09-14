#define GridDist 0.1

float player( vec2 uv_pos, vec2 player_pos )
{
    return smoothstep( 0.044, 0.04, length(uv_pos - player_pos));
}

float maze(vec2 fixedCoord)
{
    fixedCoord *= mat2(1.0, 1.0, 1.0, -1.0);

    vec2 coordInTile = fract( fixedCoord * 0.5 / GridDist ) - 0.5;
    vec2 tileCoord = floor( fixedCoord * 0.5 / GridDist ); 

    if(noise(tileCoord) > 0.5)
    {
        coordInTile.x *= -1.0; 
    }

    float intensity = step(0.9,  1.0 - abs(abs(coordInTile.x + coordInTile.y) - 0.5));
    return intensity;
}

bool isCollision(vec2 from, vec2 dir)
{
    vec2 centerCoord = floor(from / GridDist + 0.5) * GridDist;
    vec2 testPos = centerCoord + 0.5 * GridDist * dir;
    return maze(testPos) > 0.5;  
}

vec2 ccw(vec2 v)
{
    return v.yx * vec2(1.0, -1.0);
}

vec2 cw(vec2 v)
{
    return v.yx * vec2(-1.0, 1.0);
}

vec2 playerCoords( float time )
{
    vec2 currentPos = vec2(0.59);
    vec2 prevPos = vec2(0.59);
    vec2 currentDir = vec2(0.0, -1.0);

    float my_time = time;
    while(my_time > 0.0)
    {
        prevPos = currentPos;
        if(!isCollision(currentPos, ccw(currentDir)))
        {
            currentDir = ccw(currentDir);
        }
        else if(!isCollision(currentPos, currentDir))
        {
            //Do nothing
        }
        else if(!isCollision(currentPos, cw(currentDir)))
        {
            currentDir = cw(currentDir);
        }
        else
        {
            currentDir *= -1.0;
        }
        my_time -= GridDist * 10.0;
        currentPos += currentDir * GridDist;
    }
    float frac_time = my_time / (10.0 * GridDist) + 1.0; 
    return mix(prevPos, currentPos, frac_time);
}

vec4 effectMain( vec2 fixedCoord, float time )
{
    vec4 color = vec4(0.0, 0.0, 0.0, 1.0);

    vec2 playerPos = playerCoords(time);

    fixedCoord += playerPos - 0.5;
    vec2 tileCoord2 = floor(fixedCoord / GridDist + 0.5) * GridDist;


    color.b = maze( fixedCoord );
    color.g = player(fixedCoord, playerPos);

    return color;
}

void main()
{
    //Fix distortion due to screen ratio
    aspect_ratio = image_width/image_height;
    vec2 fixedCoord = (qt_TexCoord0 - vec2(0.5, 0.5)) * vec2(aspect_ratio, 1.0) + vec2(0.5, 0.5);
    gl_FragColor = effectMain( fixedCoord, time );
}