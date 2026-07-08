extends Node3D

@export var materials_array : Array[Material]

var last_grabbed : Grabbable

	
func _on_glb_file_dialog_file_selected(_path: String) -> void:
	print("trying to get this file: ", _path)
	
	var file := FileAccess.open(_path, FileAccess.READ)
	var error := FileAccess.get_open_error()
	

	if error != OK:
		if error == ERR_FILE_NOT_FOUND:
			printerr("Error: File does not exist at this path.")
		elif error == ERR_FILE_CANT_OPEN or error == ERR_UNAUTHORIZED:
			printerr("Error: Android permissions blocking access.")
		else:
			printerr("Failed to open file. Error code: ", error)
		return # Exit early if we can't read the file

	print("Success: File is fully readable!")
	
	# Read the buffer while the file is still safely open
	var file_buffer: PackedByteArray = file.get_buffer(file.get_length())
	file.close() # Close immediately after reading
	
	##Load Mesh From Boffer
	# 1. Ensure the buffer actually contains data
	if file_buffer.is_empty():
		print("Error: The provided file buffer is empty.")
		return

	# 2. Initialize GLTF helper classes
	var gltf_state := GLTFState.new()
	var gltf_doc := GLTFDocument.new()
	
	# 3. Append and parse the raw data buffer
	# The third argument is the base path used for finding external texture dependencies.
	# For self-contained .glb files, an empty string "" works perfectly.
	error = gltf_doc.append_from_buffer(file_buffer, "", gltf_state)
	
	if error == OK:
		# 4. Generate the temporary scene hierarchy from the GLTF state
		var generated_scene_root : Node = gltf_doc.generate_scene(gltf_state)
		
		#create target grabbable
		var grab := Grabbable.new()
		var meshInstance := MeshInstance3D.new()
		meshInstance.material_override = materials_array[1]
		var collider := CollisionShape3D.new()
		
		
		#add them to a Node3D
		self.add_child(grab)
		grab.add_child(meshInstance)
		grab.add_child(collider)
		collider.shape = BoxShape3D.new()
		
		
		
		var import_mesh: Mesh = find_first_mesh(generated_scene_root)
		
		if import_mesh:
			# 6. Swap the current mesh with the newly extracted runtime mesh
			meshInstance.mesh = import_mesh
			collider.shape.size = import_mesh.get_aabb().size
			print("Mesh replaced from buffer successfully!")
		else:
			print("Error: No mesh found inside the GLB buffer structure.")
			
		# 7. Clean up the temporary node hierarchy to free memory
		generated_scene_root.queue_free()
	else:
		print("Failed to parse GLB buffer. Error code: ", error)
	
func find_first_mesh(node: Node) -> Mesh:
	if node is MeshInstance3D and node.mesh:
		return node.mesh
		
	for child in node.get_children():
		var found_mesh = find_first_mesh(child)
		if found_mesh:
			return found_mesh
			
	return null
