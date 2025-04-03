@vs vs
in vec2 position;

in vec2 instancePosition;
in vec2 instanceSize;
in vec4 instanceColor;
in vec4 instanceTexCoords;
in float instanceGlyphIndex;

out vec4 color;
out vec2 texCoord;
out float glyphIndex;

void main() {
    // Calculate final position
    vec2 worldPos = position * instanceSize + instancePosition;

    // Convert to normalized device coordinates (-1 to 1)
    vec2 ndcPos = worldPos * 2.0 - 1.0;
    // Y coordinate in OpenGL goes from bottom to top, so flip it
    ndcPos.y = -ndcPos.y;

    gl_Position = vec4(ndcPos, 0.0, 1.0);

    // Calculate texture coordinates
    texCoord = mix(
        vec2(instanceTexCoords.x, instanceTexCoords.y),
        vec2(instanceTexCoords.z, instanceTexCoords.w),
        position
    );

    color = instanceColor;
    glyphIndex = instanceGlyphIndex;
}
@end

@fs fs
in vec4 color;
in vec2 texCoord;
in float glyphIndex;

layout(binding=0) uniform texture2D fontTexture;
layout(binding=0) uniform sampler fontSampler;

out vec4 frag_color;

void main() {
    // Check if this is a background or a glyph
    if (glyphIndex <= 0.0) {
        // Just use the color for backgrounds
        frag_color = color;
    } else {
        // Sample the texture for glyphs
        float alpha = texture(sampler2D(fontTexture, fontSampler), texCoord).r;
        frag_color = vec4(color.rgb, color.a * alpha);
    }
    frag_color = color;
}
@end

@program triangle vs fs
