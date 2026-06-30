
shader_type canvas_item;
render_mode blend_mix;

uniform float left : hint_range(0.0, 1.0) = 0.0;
uniform float right : hint_range(0.0, 1.0) = 1.0;
uniform float top : hint_range(0.0, 1.0) = 0.0;
uniform float bottom : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	// mix() interpolates between the start and end values based on the UV coordinate
	float target_x = mix(left, right, UV.x);
	float target_y = mix(top, bottom, UV.y);
	
	vec2 stretched_uv = vec2(target_x, target_y);
	
	// Sample the texture using the new calculated coordinates
	COLOR = texture(TEXTURE, stretched_uv);
}
