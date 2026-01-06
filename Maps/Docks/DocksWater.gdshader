shader_type spatial;
render_mode cull_back, depth_draw_opaque;

// ---- Base look ----
uniform vec4 water_color : source_color = vec4(0.10, 0.35, 0.55, 1.0);
uniform vec4 foam_color  : source_color = vec4(0.90, 0.95, 1.0, 1.0);

// ---- Waves ----
uniform float wave_height = 0.08;
uniform float wave_speed  = 0.8;
uniform float wave_scale  = 0.4;

// ---- Foam controls ----
uniform float foam_width      = 0.12;  // how far foam reaches inward
uniform float foam_noise_scale = 8.0;
uniform float foam_noise_speed = 0.4;
uniform float foam_strength    = 1.0;

// Cheap hash noise (no textures)
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void vertex() {
    float t = TIME * wave_speed;

    float wave =
        sin(VERTEX.x * wave_scale + t) +
        cos(VERTEX.z * wave_scale + t * 1.3);

    VERTEX.y += wave * wave_height;
}

void fragment() {
    // Base water
    vec3 col = water_color.rgb;

    // Distance to edge using UVs (0 at edge, 0.5 center)
    float edge_dist = min(
        min(UV.x, 1.0 - UV.x),
        min(UV.y, 1.0 - UV.y)
    );

    // Noise to break up foam edge
    float n = noise(UV * foam_noise_scale + TIME * foam_noise_speed);

    float foam_mask = smoothstep(
        foam_width,
        foam_width * 0.4,
        edge_dist + n * 0.05
    );

    foam_mask *= foam_strength;

    col = mix(col, foam_color.rgb, foam_mask);

    ALBEDO = col;
    ROUGHNESS = 0.05;
    SPECULAR = 0.8;
}
