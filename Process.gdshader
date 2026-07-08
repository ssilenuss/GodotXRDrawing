shader_type canvas_item;

// Color Adjustment Uniforms
uniform float brightness : hint_range(-1.0, 1.0) = 0.0;
uniform float saturation : hint_range(0.0, 3.0) = 1.0;
uniform float hue_shift : hint_range(-180.0, 180.0) = 0.0;
uniform float contrast : hint_range(0.0, 3.0) = 1.0;

// Gaussian Blur Uniforms
uniform float blur_amount : hint_range(0.0, 10.0) = 0.0;

// Sobel Edge Detection Uniforms
uniform bool enable_sobel = false;
uniform bool invert_sobel = false;
uniform float edge_threshold : hint_range(0.0, 0.5, 0.001) = 0.05;
// High values make a sharp cut, low values feather the line edge smoothly
uniform float edge_smoothing : hint_range(0.001, 0.2, 0.001) = 0.01; 

// --- New HSV Threshold Masking Uniforms ---
uniform bool enable_hsv_mask = false;
uniform bool invert_hsv_mask = false;
// Hue ranges from 0.0 to 1.0 (representing 0 to 360 degrees)
uniform vec2 hue_range = vec2(0.0, 1.0); 
uniform vec2 saturation_range = vec2(0.0, 1.0);
uniform vec2 value_range = vec2(0.0, 1.0);

// Helper to convert RGB to Hue-Saturation-Value (HSV)
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0 / 3.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Helper to convert HSV back to RGB
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Helper function to calculate accurate perceived grayscale intensity (Luminance)
float get_luma(vec3 rgb) {
	return dot(rgb, vec3(0.299, 0.587, 0.114));
}

// Helper function to sample and process a pixel at a given coordinate offset
vec3 get_processed_pixel(sampler2D tex, vec2 uv, vec2 offset) {
	vec4 raw_color = texture(tex, uv + offset);
	vec3 rgb = raw_color.rgb;
	
	// Apply basic color corrections for consistent Sobel reading
	rgb += brightness;
	rgb = (rgb - 0.5) * contrast + 0.5;
	
	vec3 hsv = rgb2hsv(rgb);
	hsv.x += hue_shift / 360.0;
	hsv.y *= saturation;
	
	return hsv2rgb(hsv);
}

void fragment() {
	vec4 final_color = vec4(0.0);
	
	// 1. Apply Gaussian Blur (Only runs if blur_amount is > 0 to optimize performance)
	if (blur_amount > 0.01) {
		vec2 ps = TEXTURE_PIXEL_SIZE * blur_amount;
		
		// 9-sample box-approximated Gaussian weights
		vec4 color = texture(TEXTURE, UV) * 0.227027;
		color += texture(TEXTURE, UV + vec2(ps.x, 0.0)) * 0.1945946;
		color += texture(TEXTURE, UV - vec2(ps.x, 0.0)) * 0.1945946;
		color += texture(TEXTURE, UV + vec2(0.0, ps.y)) * 0.1945946;
		color += texture(TEXTURE, UV - vec2(0.0, ps.y)) * 0.1945946;
		
		color += texture(TEXTURE, UV + vec2(ps.x, ps.y)) * 0.047581;
		color += texture(TEXTURE, UV + vec2(-ps.x, ps.y)) * 0.047581;
		color += texture(TEXTURE, UV + vec2(ps.x, -ps.y)) * 0.047581;
		color += texture(TEXTURE, UV - vec2(ps.x, ps.y)) * 0.047581;
		
		final_color = color;
	} else {
		final_color = texture(TEXTURE, UV);
	}
	
	// Cache the raw transparency value
	float target_alpha = final_color.a;
	vec3 rgb = final_color.rgb;

	// 2. Apply Core Color Properties to main pixel
	rgb += brightness;
	rgb = (rgb - 0.5) * contrast + 0.5;

	vec3 hsv = rgb2hsv(rgb);
	hsv.x += hue_shift / 360.0;
	// Wrap hue smoothly between 0.0 and 1.0 loop
	hsv.x = fract(hsv.x); 
	hsv.y *= saturation;
	rgb = hsv2rgb(hsv);

	// 3. Apply 2D Sobel Edge Detection as an Alpha Mask
	if (enable_sobel) {
		vec2 size = TEXTURE_PIXEL_SIZE;
		
		// Process 3x3 grid around current pixel to detect edges accurately 
		float n00 = get_luma(get_processed_pixel(TEXTURE, UV, vec2(-1.0, -1.0) * size));
		float n01 = get_luma(get_processed_pixel(TEXTURE, UV, vec2(0.0, -1.0) * size));
		float n02 = get_luma(get_processed_pixel(TEXTURE, UV, vec2(1.0, -1.0) * size));
		
		float n10 = get_luma(get_processed_pixel(TEXTURE, UV, vec2(-1.0, 0.0) * size));
		float n12 = get_luma(get_processed_pixel(TEXTURE, UV, vec2(1.0, 0.0) * size));
		
		float n20 = get_luma(get_processed_pixel(TEXTURE, UV, vec2(-1.0, 1.0) * size));
		float n21 = get_luma(get_processed_pixel(TEXTURE, UV, vec2(0.0, 1.0) * size));
		float n22 = get_luma(get_processed_pixel(TEXTURE, UV, vec2(1.0, 1.0) * size));

		// Sobel kernels
		float sobel_x = n02 + (2.0 * n12) + n22 - (n00 + (2.0 * n10) + n20);
		float sobel_y = n20 + (2.0 * n21) + n22 - (n00 + (2.0 * n01) + n02);
		
		// Find edge magnitude
		float edge = sqrt((sobel_x * sobel_x) + (sobel_y * sobel_y));

		// Anti-aliased interpolation replaces the rigid step logic
		float mask = smoothstep(edge_threshold, edge_threshold + edge_smoothing, edge);
		
		if (invert_sobel) {
			mask = 1.0 - mask;
		}
		
		target_alpha *= mask;
	}

	// 4. New Layer: Dynamic HSV Masking Logic
	if (enable_hsv_mask) {
		// Evaluate if the current pixel's color values exist within the requested threshold spans
		bool inside_hue = (hsv.x >= hue_range.x && hsv.x <= hue_range.y);
		bool inside_sat = (hsv.y >= saturation_range.x && hsv.y <= saturation_range.y);
		bool inside_val = (hsv.z >= value_range.x && hsv.z <= value_range.y);
		
		// Combine parameters: all conditions must pass
		float hsv_mask = (inside_hue && inside_sat && inside_val) ? 1.0 : 0.0;
		
		if (invert_hsv_mask) {
			hsv_mask = 1.0 - hsv_mask;
		}
		
		target_alpha *= hsv_mask;
	}

	// Output calculations back to the TextureRect
	COLOR = vec4(clamp(rgb, 0.0, 1.0), target_alpha);
}
