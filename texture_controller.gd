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
@export var expand: ExpandMode = ExpandMode.IGNORE: 
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

@export_category("Post-Processing")
@export var reset : bool : set = reset_post
func reset_post(_v:bool)->void:
	reset = false
	set_brightness(0)
	set_saturation(1.0)
	set_hue_shift(0.0)
	set_contrast(1.0)
	set_blur_amount(0.0)
	set_sobel(false)
	set_invert_sobel(false)
	set_edge_threshold(0.05)
	set_edge_smoothing(0.01)
	set_hsv_mask(false)
	set_invert_hsv_mask(false)
	set_hue_range(Vector2(0,1))
	set_saturation_range(Vector2(0,1))
	set_value_range(Vector2(0,1))
	
@export_range(-1.0, 1.0, 0.0001) var brightness : float = 0.0: set = set_brightness
func set_brightness(_v: float)->void:
		brightness = _v
		if !left_post or !right_post:
			return
		var l_mat : ShaderMaterial = left_post.material
		var r_mat : ShaderMaterial = right_post.material
		l_mat.set_shader_parameter("brightness", brightness)
		r_mat.set_shader_parameter("brightness", brightness)

@export_range(0.0, 3.0, 0.0001) var saturation : float = 1.0: set = set_saturation
func set_saturation(_v: float)->void:
		saturation = _v
		if !left_post or !right_post:
			return
		var l_mat : ShaderMaterial = left_post.material
		var r_mat : ShaderMaterial = right_post.material
		l_mat.set_shader_parameter("saturation", saturation)
		r_mat.set_shader_parameter("saturation", saturation)

@export_range(-180.0, 180.0, 0.0001) var hue_shift : float = 0.0: set = set_hue_shift
func set_hue_shift(_v: float)->void:
	hue_shift = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("hue_shift", hue_shift)
	r_mat.set_shader_parameter("hue_shift", hue_shift)

@export_range(0.0, 3.0, 0.0001) var contrast : float = 1.0: set = set_contrast
func set_contrast(_v: float)->void:
	contrast = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("contrast", contrast)
	r_mat.set_shader_parameter("contrast", contrast)

@export_range(0.0, 10.0, 0.0001) var blur_amount : float = 0.0: set = set_blur_amount
func set_blur_amount(_v: float)->void:
	blur_amount = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("blur_amount", blur_amount)
	r_mat.set_shader_parameter("blur_amount", blur_amount)

#Sobel
@export var sobel : bool = false: set = set_sobel
func set_sobel(_v: bool)->void:
	sobel = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("enable_sobel", sobel)
	r_mat.set_shader_parameter("enable_sobel", sobel)

@export var invert_sobel : bool = false: set = set_invert_sobel
func set_invert_sobel(_v: bool)->void:
	invert_sobel = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("invert_sobel", invert_sobel)
	r_mat.set_shader_parameter("invert_sobel", invert_sobel)

@export_range(0.0, 0.5, 0.0001) var edge_threshold : float = 0.05: set = set_edge_threshold
func set_edge_threshold(_v: float)->void:
	edge_threshold = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("edge_threshold", edge_threshold)
	r_mat.set_shader_parameter("edge_threshold", edge_threshold)

@export_range(0.001, 0.2, 0.001) var edge_smoothing : float = 0.01: set = set_edge_smoothing
func set_edge_smoothing(_v: float)->void:
	edge_smoothing = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("edge_smoothing", edge_smoothing)
	r_mat.set_shader_parameter("edge_smoothing", edge_smoothing)

#HLS Mask
@export var invert_hsv_mask : bool = false: set = set_invert_hsv_mask
func set_invert_hsv_mask(_v: bool)->void:
	invert_hsv_mask = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("invert_hsv_mask", invert_hsv_mask)
	r_mat.set_shader_parameter("invert_hsv_mask", invert_hsv_mask)

@export var hsv_mask : bool = false: set = set_hsv_mask
func set_hsv_mask(_v: bool)->void:
	hsv_mask = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("enable_hsv_mask", hsv_mask)
	r_mat.set_shader_parameter("enable_hsv_mask", hsv_mask)

@export var hue_range : Vector2 = Vector2(0.0,1.0): set = set_hue_range
func set_hue_range(_v: Vector2)->void:
	hue_range = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("hue_range", hue_range)
	r_mat.set_shader_parameter("hue_range", hue_range)
	
@export var saturation_range : Vector2 = Vector2(0.0,1.0): set = set_saturation_range
func set_saturation_range(_v: Vector2)->void:
	saturation_range = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("saturation_range", saturation_range)
	r_mat.set_shader_parameter("saturation_range", saturation_range)

@export var value_range : Vector2 = Vector2(0.0,1.0): set = set_value_range
func set_value_range(_v: Vector2)->void:
	value_range = _v
	if !left_post or !right_post:
		return
	var l_mat : ShaderMaterial = left_post.material
	var r_mat : ShaderMaterial = right_post.material
	l_mat.set_shader_parameter("value_range", value_range)
	r_mat.set_shader_parameter("value_range", value_range)

@export_category("Dependants")
@export var camera_left: Camera3D 
@export var camera_right: Camera3D 
@export var left_texture: TextureRect
@export var right_texture : TextureRect
@export var left_post: TextureRect
@export var right_post : TextureRect


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



func _on_enable_sobel_toggled(toggled_on: bool) -> void:
	set_sobel(toggled_on)


func _on_invert_sobel_toggled(toggled_on: bool) -> void:
	set_invert_sobel(toggled_on)


func _on_sobel_threshold_slider_value_changed(value: float) -> void:
	set_edge_threshold(value)


func _on_sobel_smoothing_slider_value_changed(value: float) -> void:
	set_edge_smoothing(value)


func _on_brightness_slider_value_changed(value: float) -> void:
	set_brightness(value)


func _on_contrast_slider_value_changed(value: float) -> void:
	set_contrast(value)


func _on_saturation_slider_value_changed(value: float) -> void:
	set_saturation(value)


func _on_hue_shift_slider_value_changed(value: float) -> void:
	set_hue_shift(value)


func _on_blur_slider_value_changed(value: float) -> void:
	set_blur_amount(value)


func _on_enable_mask_toggled(toggled_on: bool) -> void:
	set_hsv_mask(toggled_on)


func _on_invert_mask_toggled(toggled_on: bool) -> void:
	set_invert_hsv_mask(toggled_on)


func _on_hue_mask_min_spin_box_value_changed(value: float) -> void:
	set_hue_range(Vector2(value, hue_range.y))


func _on_hue_mask_max_spin_box_value_changed(value: float) -> void:
	set_hue_range(Vector2(hue_range.x, value))


func _on_sat_mask_min_spin_box_value_changed(value: float) -> void:
	set_saturation_range(Vector2(value, saturation_range.y))


func _on_sat_mask_max_spin_box_value_changed(value: float) -> void:
	set_saturation_range(Vector2(saturation_range.x, value))


func _on_value_mask_min_spin_box_value_changed(value: float) -> void:
	set_value_range(Vector2(value, value_range.y))

func _on_value_mask_max_spin_box_value_changed(value: float) -> void:
	set_value_range(Vector2(value_range.x, value))


func _on_sbs_toggled(toggled_on: bool) -> void:
	sbs = toggled_on
