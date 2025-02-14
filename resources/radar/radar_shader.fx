texture gTexture;
sampler Sampler0 = sampler_state
{
    Texture = (gTexture);
};

float rotation; // Dodajemy zmienną do przekazania rotacji z skryptu

float4 PixelShaderFunction(float2 tex : TEXCOORD0) : COLOR
{
    float2 center = float2(0.5, 0.5);
    float2 rotatedTex = tex - center;
    
    // Obracamy teksturę
    float cosTheta = cos(rotation);
    float sinTheta = sin(rotation);
    float2 newTex;
    newTex.x = rotatedTex.x * cosTheta - rotatedTex.y * sinTheta;
    newTex.y = rotatedTex.x * sinTheta + rotatedTex.y * cosTheta;
    newTex += center;

    // Sprawdzamy, czy piksel znajduje się w okręgu
    float dist = distance(newTex, center);
    if (dist > 0.5)
    {
        discard; // Ukrywa wszystko poza okręgiem
    }
    
    return tex2D(Sampler0, newTex);
}

technique Tec1
{
    pass P0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}