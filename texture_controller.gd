@tool
extends Node
class_name TextureController


@export_category("TextureButtons")

@export var sbs : bool = true:
	set(value):
		sbs = value
		if !left_texture or !right_texture:
			return
		var l_mat : ShaderMaterial = left_texture.material
		var r_mat : ShaderMaterial = right_texture.material
		if sbs:
			l_mat.set_shader_parameter("left", 0.0)
			l_mat.set_shader_parameter("right", 0.5)
			r_mat.set_shader_parameter("left", 0.5)
			r_mat.set_shader_parameter("right", 1.0)
		else:
			l_mat.set_shader_parameter("left", 0.0)
			l_mat.set_shader_parameter("right", 1.0)
			r_mat.set_shader_parameter("left", 0.0)
			r_mat.set_shader_parameter("right", 1.0)
	

@export var texture : Texture2D :
	set(value):
		texture = value
		if !left_texture or !right_texture:
			return
		elif !camera_left or !camera_right:
			return
		elif !texture:
			camera_left.visible = true
			camera_right.visible = true
			left_texture.texture = texture
			right_texture.texture = texture
		else:
			camera_left.visible = false
			camera_right.visible = false
			left_texture.texture = texture
			right_texture.texture = texture
		

enum ExpandMode {KEEP, IGNORE, WIDTH, HEIGHT}
@export var expand: ExpandMode : 
	set(value):
		if !left_texture or !right_texture:
			return
		expand = value
		match expand:
			ExpandMode.KEEP:
				left_texture.set_expand_mode(TextureRect.EXPAND_KEEP_SIZE)
				right_texture.set_expand_mode(TextureRect.EXPAND_KEEP_SIZE)
				left_texture.set_stretch_mode(TextureRect.STRETCH_KEEP_CENTERED)
				right_texture.set_stretch_mode(TextureRect.STRETCH_KEEP_CENTERED)
			ExpandMode.IGNORE:
				left_texture.set_expand_mode(TextureRect.EXPAND_IGNORE_SIZE)
				right_texture.set_expand_mode(TextureRect.EXPAND_IGNORE_SIZE)
				left_texture.set_stretch_mode(TextureRect.STRETCH_SCALE)
				right_texture.set_stretch_mode(TextureRect.STRETCH_SCALE)
			ExpandMode.WIDTH:
				left_texture.set_expand_mode(TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL)
				right_texture.set_expand_mode(TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL)
				left_texture.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT)
				right_texture.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT)
			ExpandMode.HEIGHT:
				left_texture.set_expand_mode(TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL)
				right_texture.set_expand_mode(TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL)
				left_texture.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT)
				right_texture.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT)


@export_category("Dependants")
@export var camera_left: Camera3D 
@export var camera_right: Camera3D 
@export var left_texture: TextureRect
@export var right_texture : TextureRect


func _ready() -> void:
	texture = texture
	sbs = sbs
	expand = expand


func _on_pic_file_dialog_file_selected(_path: String) -> void:
	print("trying to get this file: ", _path)
	
	var file = FileAccess.open(_path, FileAccess.READ)
	var error = FileAccess.get_open_error()
	

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

	var image := Image.new()
	var load_error: Error
	var ext = _path.get_extension().to_lower()
	
	print("path: ", _path)
	print("ext: ", ext)

	# Try parsing by explicit extension first
	if ext == "png":
		load_error = image.load_png_from_buffer(file_buffer)
	elif ext == "jpg" or ext == "jpeg":
		load_error = image.load_jpg_from_buffer(file_buffer)
	else:
		# content:// paths fallback logic: Try PNG first, then JPEG
		print("No explicit extension found. Testing decoders...")
		load_error = image.load_png_from_buffer(file_buffer)
		if load_error != OK:
			load_error = image.load_jpg_from_buffer(file_buffer)

	# Handle image parsing confirmation
	if load_error != OK:
		printerr("Failure to parse buffer data into image! Error: ", load_error)
	else:
		print("Image successfully parsed into memory!")
		texture = ImageTexture.create_from_image(image)


func _on_button_toggled(toggled_on: bool) -> void:
	sbs = toggled_on
