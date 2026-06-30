@tool
extends MeshInstance3D
class_name OverlayMesh

@export_enum("Texture", "XRCam") var shader_type : int = 0 :
	set(value):
		shader_type = value
		#material_override = shaders[shader_type]
		
@export var shaders : Array[ShaderMaterial]

var texture : ImageTexture :
	set(value):
		texture = value
		var mat : ShaderMaterial = get_active_material(0)
		mat.set_shader_parameter("tex_left", texture)
		mat.set_shader_parameter("tex_right", texture)
		print("new image fully loaded")

func _on_alpha_slider_value_changed(value: float) -> void:
	var mat : ShaderMaterial = get_active_material(0)
	mat.set_shader_parameter("alpha", value)
