shader_type spatial;
render_mode unshaded;

uniform sampler2D noise_tex;

// offset scrolling the texture
uniform float waver_amplitude;
uniform float waver_speed;
uniform float scroll_speed;

// colourizing for deep water
uniform vec3 deep_color: source_color;
uniform vec3 mid_color: source_color;
uniform vec3 shallow_color: source_color;
vec3 water_ramp(float v) {
	vec3 col;

	col = mix(deep_color, mid_color, smoothstep(0.1, 0.85, v));
	col = mix(col, shallow_color, smoothstep(0.45, 0.75, v));

	return col;
}

// applying whitecaps
uniform float whitecap_frequency = 3.0;
uniform float whitecap_mask_frequency = 2.5;


uniform float wave_amplitude = 0.3;
uniform float wave_wavelength = 8.0; // bigger = wider waves
uniform float wave_speed = 1.2;
uniform float wave_steepness = 0.6;  // 0–1 (keep < 1)

uniform vec2 wave_direction = vec2(1.0, 0.3); // XZ direction

void vertex() {
	vec3 world_pos =  (NODE_POSITION_WORLD + VERTEX).xyz;

	vec2 dir = normalize(wave_direction);

	float k = TAU / wave_wavelength;     // wave number
	float phase = k * dot(dir, world_pos.xz) + TIME * wave_speed;

	float cos_p = cos(phase);
	float sin_p = sin(phase);

	// horizontal displacement (this is the key difference)
	VERTEX.x += dir.x * wave_steepness * wave_amplitude * cos_p;
	VERTEX.z += dir.y * wave_steepness * wave_amplitude * cos_p;

	// vertical displacement
	VERTEX.y += wave_amplitude * sin_p;
}

void fragment() {
	// move the uv colour around wavily
	vec2 uv_space = UV;
	uv_space.y += sin(TIME * waver_speed) * waver_amplitude + (TIME * scroll_speed);
	uv_space.x += sin(TIME * waver_speed) * -sin(waver_amplitude) + (TIME * scroll_speed);
	
	// start processing the fragment by grabbing the pixel in the uvmap
	float final_pixel_colour = texture(noise_tex, uv_space).r;
	
	// bring up the blacks
	final_pixel_colour = 0.4 - abs(final_pixel_colour + (-0.5 + (sin(TIME / 5.0) * 0.5)));
	
	// apply the colour ramp - this is now an rgb pixel
	vec3 final_albedo = water_ramp(final_pixel_colour);
	
	// overlay a smaller, all white version of the noise texture for whitecaps
	float whitecap_pixel_colour = texture(noise_tex, vec2(uv_space.x * whitecap_frequency, uv_space.y * whitecap_frequency)).r;
	// bring up the blacks
	whitecap_pixel_colour = whitecap_pixel_colour - 0.3;
	// animate a mask over the whitecaps
	vec2 whitecap_uv = UV;
	whitecap_uv.y += cos(TIME * (waver_speed * 1.8)) * waver_amplitude + (TIME * scroll_speed);
	whitecap_uv.x += sin(TIME * (waver_speed * 1.8)) * -sin(waver_amplitude) + (TIME * scroll_speed);
	float whitecap_mask = texture(noise_tex, vec2(whitecap_uv.x * whitecap_mask_frequency, whitecap_uv.y * whitecap_mask_frequency)).r;
	// bring up the blacks
	whitecap_mask = 0.1 - whitecap_mask + (-0.25 + (sin(TIME / 5.0) * 0.5));
	//whitecap_pixel_colour = step(0.8, whitecap_pixel_colour);
	float phase = texture(noise_tex, uv_space * 0.25).r * TAU;
	float t = 0.5 + 0.5 * sin(TIME + phase);
	whitecap_pixel_colour = mix(whitecap_mask, whitecap_pixel_colour, t);
	whitecap_pixel_colour = step(0.3, whitecap_pixel_colour);
	float foam_alpha = whitecap_pixel_colour * 0.8;
	final_albedo = mix(final_albedo, vec3(1.0), foam_alpha);
	
	ALBEDO = final_albedo;

}