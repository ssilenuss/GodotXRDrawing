@tool
extends MeshInstance3D
class_name OverlayMesh

@export_enum("Texture", "XRCam") var shader_type : int = 0 :
	set(value):
		shader_type = value
		#material_override = shaders[shader_type]
		
@export var shaders : Array[ShaderMaterial]
