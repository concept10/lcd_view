#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 lcd_effects_fragment(VertexOut in [[stage_in]], 
                                     texture2d<float> textTex [[texture(0)]],
                                     texture2d<float> waveTex [[texture(1)]]) {
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    
    float4 textColor = textTex.sample(s, in.texCoord);
    float4 waveColor = waveTex.sample(s, in.texCoord * float2(1.0, 0.5)); 

    // Scanline effect
    float scanlineIntensity = 0.3 * sin(in.position.y * 30.0) + 0.8;
    textColor.rgb *= scanlineIntensity;

    // Glow effect
    float4 glow = textTex.sample(s, in.texCoord + float2(0.002, 0.002)) * 0.5;
    textColor.rgb += glow.rgb;

    // Combine waveform preview with text
    float alpha = waveColor.a * 0.7;  // Mix transparency
    float4 finalColor = mix(textColor, waveColor, alpha);

    return finalColor;
}