@tool
extends Camera3D

@export var target_mesh : OverlayMesh :
	set(value):
		target_mesh = value
		target_shader = target_mesh.get_active_material(0)
		
var target_shader : ShaderMaterial
