@tool
extends Area3D
class_name XRMenu

@export var size : Vector2 = Vector2.ONE:
	set(value):
		size = value
		if mesh_instance:
			mesh_instance.mesh.size = size
			collision_shape.shape.size = Vector3(size.x, size.y, collision_shape.shape.size.z)

@export var resolution := Vector2(512, 512) :
	set(value):
		if value.x != resolution.x:
			var x = value.x
			var y = (x * size.y)/size.x
			resolution = Vector2(x,y)
		else:
			var y = value.y
			var x = (y * size.x)/size.y
			resolution = Vector2(x,y)
		if subviewport:
			subviewport.size = resolution
			

@export var mesh_instance: MeshInstance3D
@export var collision_shape : CollisionShape3D
@export var subviewport : SubViewport

@export var root : DrawingMain

@export var pic_dialog : FileDialog
@export var glb_dialog : FileDialog

var last_mouse_pos: Vector2

var active_controller: XRTouchController

var pressed : bool = false : 
	set(value):
		pressed = value
		if pressed == false and active_controller:
			interact_with_canvas(local_point, pressed)
		
	
var global_point : Vector3
var local_point : Vector3

func _ready() -> void:
	size = size
	resolution = resolution
	subviewport.physics_object_picking = true

func _process(_delta: float) -> void:
	if root == null:
		return
		
	if root.button_pressed.has("trigger_click") and active_controller:
		
		if active_controller.ray.is_colliding() and active_controller.ray.get_collider() == self:
			pressed = true
			global_point= active_controller.ray.get_collision_point()
			local_point = self.to_local(global_point)
			interact_with_canvas(local_point, pressed)
			
	else:
		pressed = false
		active_controller = null
	
		

func interact_with_canvas(local_position: Vector3, trigger_pressed: bool) -> void:
	
	# 1. Convert 3D local coordinates (-0.6 to +0.6) to a 0.0 -> 1.0 percentage
	var pct_x: float = (local_position.x + (size.x / 2.0)) / size.x
	# Invert Y because 3D up is positive, but 2D screen down is positive
	var pct_y: float = ((size.y / 2.0) - local_position.y) / size.y
	
	# 2. Map percentages to SubViewport pixel coordinates
	var pixel_pos := Vector2(
		pct_x * subviewport.size.x,
		pct_y * subviewport.size.y
	)
	
	# 3. Handle Mouse Movement (Hover states on buttons)
	if pixel_pos != last_mouse_pos:
		var motion_event = InputEventMouseMotion.new()
		motion_event.position = pixel_pos
		subviewport.push_input(motion_event)
		last_mouse_pos = pixel_pos
		
	# 4. Handle Controller Trigger Pull (Click Down)
	if trigger_pressed:
		var click_event = InputEventMouseButton.new()
		click_event.position = pixel_pos
		click_event.button_index = MOUSE_BUTTON_LEFT
		click_event.pressed = true
		subviewport.push_input(click_event)
		
	# 5. Handle Controller Trigger Release (Click Up)
	else:
		var release_event = InputEventMouseButton.new()
		release_event.position = pixel_pos
		release_event.button_index = MOUSE_BUTTON_LEFT
		release_event.pressed = false
		subviewport.push_input(release_event)


func _on_load_pic_pressed() -> void:
	pic_dialog.popup()



		


func _on_load_glb_pressed() -> void:
	glb_dialog.popup()
