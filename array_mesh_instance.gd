@tool
extends MeshInstance3D
class_name ArrayMeshInstance

var surface_array : Array = []
var verts : PackedVector3Array = []
var uvs : PackedVector2Array = []
var normals : PackedVector3Array = []
var indices : PackedInt32Array = []

func _ready()->void:
	surface_array.resize(ArrayMesh.ARRAY_MAX)
	
	#define verts
	var width : float = 1
	var depth : float = 1
	verts.append( Vector3(-width/2.0,0,depth/2.0) ) #bottom_left
	verts.append( Vector3(width/2.0,0,depth/2.0) ) #bottom_right
	verts.append( Vector3(--width/2.0,0,-depth/2.0) ) #top_left
	verts.append( Vector3(width/2.0,0,-depth/2.0) ) #top_right
	
	#define normals (pointing upwards
	for i in range(4):
		normals.append(Vector3.UP)
		
	#define UVS
	uvs.append(Vector2(0, 1)) # Bottom-left
	uvs.append(Vector2(1, 1)) # Bottom-right
	uvs.append(Vector2(0, 0)) # Top-left
	uvs.append(Vector2(1, 0)) # Top-right
	
	# Define indices for two triangles (clockwise winding)
	indices.append(0) # Bottom-left
	indices.append(1) # Bottom-right
	indices.append(2) # Top-left
	
	indices.append(1) # Bottom-right
	indices.append(3) # Top-right
	indices.append(2) # Top-left
	
	#Assign arrays to surface_array
	surface_array[ArrayMesh.ARRAY_VERTEX] = verts
	surface_array[ArrayMesh.ARRAY_NORMAL] = normals
	surface_array[ArrayMesh.ARRAY_TEX_UV] = uvs
	surface_array[ArrayMesh.ARRAY_INDEX] = indices
	
	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	mesh = array_mesh
