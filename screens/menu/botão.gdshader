shader_type canvas_item;

uniform vec2 shadow_offset = vec2(20.0, 20.0);
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.8);

void fragment() {
    vec2 shadow_uv = UV - shadow_offset / vec2(textureSize(TEXTURE, 0));
    float shadow_alpha = texture(TEXTURE, shadow_uv).a;
    vec4 col = texture(TEXTURE, UV);
    
    if (col.a > 0.1) {
        COLOR = col;
    } else {
        COLOR = vec4(shadow_color.rgb, shadow_color.a * shadow_alpha);
    }
}