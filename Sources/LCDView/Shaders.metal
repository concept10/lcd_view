#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              constant float4 *vertices [[buffer(0)]]) {
    VertexOut out;
    out.position = float4(vertices[vertexID].xy, 0.0, 1.0);
    out.texCoord = vertices[vertexID].zw;
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                             texture2d<float> fontTexture [[texture(0)]],
                             texture2d<float> waveTexture [[texture(1)]],
                             constant float *waveformData [[buffer(0)]],
                             constant uchar *textData [[buffer(1)]],
                             constant uchar *midiStatus [[buffer(2)]]) {
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    
    float2 uv = in.texCoord;
    float4 color = float4(0.0, 0.0, 0.0, 1.0);
    
    // LCD background color (dark blue-green)
    float4 bgColor = float4(0.0, 0.12, 0.08, 1.0);
    
    // Calculate character grid
    float charWidth = 1.0 / 16.0;  // 16 characters per row in our LCD display
    float charHeight = 1.0 / 4.0;  // 4 rows of text
    
    // Render LCD background
    color = bgColor;
    
    // Scanline effect
    float scanlineIntensity = 0.15 * sin(in.position.y * 40.0) + 0.85;
    color.rgb *= scanlineIntensity;
    
    // Display the waveform in the middle section if MIDI is active
    if (uv.y > 0.4 && uv.y < 0.6 && midiStatus[0] > 0) {
        float waveX = uv.x;
        int waveIndex = int(waveX * 128);
        if (waveIndex >= 0 && waveIndex < 128) {
            float waveHeight = waveformData[waveIndex];
            float waveY = 0.5; // Center position
            float dist = abs(uv.y - (waveY - waveHeight * 0.15 + 0.15));
            
            if (dist < 0.01) {
                color = float4(0.0, 0.8, 0.2, 1.0); // Bright green for waveform
            }
        }
    }
    
    // Text color (bright green)
    float4 textColor = float4(0.0, 0.8, 0.2, 1.0);
    
    // Simple glow effect on text
    float4 glow = fontTexture.sample(s, uv);
    color += glow * textColor * 0.5;
    
    // Apply vignette effect
    float2 center = float2(0.5, 0.5);
    float dist = distance(uv, center);
    color.rgb *= 1.0 - dist * 0.5;
    
    return color;
}

// LCD effects fragment shader (carried over from original)
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
