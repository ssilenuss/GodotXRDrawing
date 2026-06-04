shader_type spatial;
render_mode world_vertex_coords, cull_disabled, unshaded; // Optional: Removes lighting

// Uniforms for the four corners
uniform vec3 top_left = vec3(-1.0, 1.0, 0.0);
uniform vec3 top_right = vec3(1.0, 1.0, 0.0);
uniform vec3 bottom_left = vec3(-1.0, -1.0, 0.0);
uniform vec3 bottom_right = vec3(1.0, -1.0, 0.0);

uniform sampler2D albedo_tex : source_color;

void vertex() {
	// UV.x goes 0->1 left to right, UV.y goes 0->1 top to bottom
	vec3 top = mix(top_left, top_right, UV.x);
	vec3 bottom = mix(bottom_left, bottom_right, UV.x);
	
	// Final position is interpolation between top and bottom
	VERTEX = mix(top, bottom, UV.y);
}

void fragment() {
	ALBEDO = texture(albedo_tex, UV).rgb;
}