shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, diffuse_lambert, specular_schlick_ggx;

// Uniforms expose properties to the inspector for easy tuning
uniform vec4 glow_color : source_color = vec4(0.0, 0.6, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float fresnel_power : hint_range(0.1, 10.0) = 3.0;
uniform float fill_opacity : hint_range(0.0, 1.0) = 0.15;
uniform bool see_through_walls = true;

void vertex() {
	// If you want a cool scanline or pulsing effect, you can manipulate vertices here
}

void fragment() {
	// 1. Calculate the view direction vector in world space
	vec3 view_dir = normalize(VIEW);
	
	// 2. Calculate the basic Fresnel math (dot product of view direction and surface normals)
	// Truncating/clamping prevents issues where the vector points completely away
	float fresnel = 1.0 - max(dot(NORMAL, view_dir), 0.0);
	
	// 3. Shape the curve of the glow using the power variable
	float fresnel_glow = pow(fresnel, fresnel_power);
	
	// 4. Mix the core transparency with the bright neon edge glow
	vec3 final_color = glow_color.rgb * glow_intensity;
	float final_alpha = clamp(fresnel_glow + fill_opacity, 0.0, 1.0) * glow_color.a;
	
	// 5. Output to Godot's standard rendering pipelines
	ALBEDO = final_color;
	ALPHA = final_alpha;
	EMISSION = final_color * fresnel_glow; // Makes the edges physically emit light/glow
}