
vec2  hash2( vec2  p ) { p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) ); return fract(sin(p)*43758.5453); }
vec3  hash3( vec3  p ) { p = vec3( dot(p,vec3(127.1,311.7,644.2)), dot(p,vec3(269.5,183.3,92.1)),dot(p,vec3(311.7,127.1,644.2)) ); return fract(sin(p)*43758.5453); }
vec4  hash4( vec4  p ) { p = vec4( dot(p,vec4(127.1,311.7,644.2,125.6)), dot(p,vec4(269.5,183.3,92.1,325.7)),dot(p,vec4(311.7,127.1,644.2,423.5)), dot(p,vec4(246.2,536.2,125.8,23.8)) ); return fract(sin(p)*43758.5453); }

float voronoi( in vec2 x )
{
    ivec2 p = ivec2(floor( x ));
    vec2  f = fract( x );

    float res = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        ivec2 b = ivec2( i, j );
        vec2  r = vec2( b ) - f + hash2( vec2(p + b) );
        float d = dot( r, r );
        res = min( res, d );
    }
    return sqrt( res );
}

float smoothVoronoi( in vec2 x )
{
    ivec2 p = ivec2(floor( x ));
    vec2  f = fract( x );

    float res = 0.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        ivec2 b = ivec2( i, j );
        vec2  r = vec2( b ) - f + hash2( vec2(p + b) );
        float d = dot( r, r );

        res += 1.0/pow( d, 8.0 );
    }
    return pow( 1.0/res, 1.0/32.0 );
}

// float smoothVoronoi( in vec2 x )
// {
//     ivec2 p = ivec2(floor( x ));
//     vec2  f = fract( x );

//     float res = 0.0;
//     for( int j=-1; j<=1; j++ )
//     for( int i=-1; i<=1; i++ )
//     {
//         ivec2 b = ivec2( i, j );
//         vec2  r = vec2( b ) - f + hash2( vec2(p + b) );
//         float d = length( r );

//         res += exp2( -16.0*d );
//     }
//     return -(1.0/16.0)*log2( res );
// }

float smoothVoronoi( in vec3 x )
{
    ivec3 p = ivec3(floor( x ));
    vec3  f = fract( x );

    float res = 0.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    for( int k=-1; k<=1; k++ )
    {
        ivec3 b = ivec3( i, j, k );
        vec3  r = vec3( b ) - f + hash3( vec3(p + b) );
        float d = dot( r, r );

        res += 1.0/pow( d, 8.0 );
    }
    return pow( 1.0/res, 1.0/4.0 );
}

float smoothVoronoi( in vec4 x )
{
    ivec4 p = ivec4(floor( x ));
    vec4  f = fract( x );

    float res = 0.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    for( int k=-1; k<=1; k++ )
    for( int w=-1; w<=1; w++ )
    {
        ivec4 b = ivec4( i, j, k,w );
        vec4  r = vec4( b ) - f + hash4( vec4(p + b) );
        float d = dot( r, r );

        res += 1.0/pow( d, 8.0 );
    }
    return pow( 1.0/res, 1.0/4.0 );
}