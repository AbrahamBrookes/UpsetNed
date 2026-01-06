shader_type canvas_item;

uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float vignette_smoothness : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Distance from screen center
    float dist = distance(uv, vec2(0.5));

    // Smooth vignette falloff
    float vignette = smoothstep(
        vignette_intensity,
        vignette_intensity + vignette_smoothness,
        dist
    );

    vec4 screen_col = texture(SCREEN_TEXTURE, uv);

    COLOR = mix(screen_col, vignette_color, vignette);
}
