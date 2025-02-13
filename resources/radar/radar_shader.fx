texture gTexture;
sampler Sampler0 = sampler_state
{
    Texture = (gTexture);
};

float4 PixelShaderFunction(float2 tex : TEXCOORD0) : COLOR
{
    float2 center = float2(0.5, 0.5);
    float dist = distance(tex, center);
    if (dist > 0.5)
    {
        discard; // Ukrywa wszystko poza okręgiem
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
