texture gTexture;
sampler Sampler0 = sampler_state
{
    Texture = (gTexture);
};

float4 PixelShaderFunction(float2 tex : TEXCOORD0) : COLOR
{
    float2 center = float2(0.5, 0.5);
    
    // Calculate the distance from the center
    float dist = distance(tex, center);
    
    // Discard pixels outside the circle
    if (dist > 0.5)
    {
        discard;
    }
    
    return tex2D(Sampler0, tex);
}

technique Tec1
{
    pass P0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
