@tool
extends Area3D
class_name Grabbable

var active_controller : XRController3D
var active_grab_area : Area3D
var rotation_offset : Basis = Basis.IDENTITY

var left_controller : XRController3D
var right_controller : XRController3D
var left_touch_ball : MeshInstance3D
var right_touch_ball : MeshInstance3D
var left_grab_area : Area3D
var right_grab_area: Area3D

func _ready() -> void:
	set_collision_mask_value(8, true)
	left_controller = get_tree().get_first_node_in_group("left_controller")
	right_controller = get_tree().get_first_node_in_group("right_controller")
	
	left_touch_ball = get_tree().get_first_node_in_group("left_touch_ball")
	right_touch_ball = get_tree().get_first_node_in_group("right_touch_ball")
	
	left_grab_area = get_tree().get_first_node_in_group("left_grab_area")
	right_grab_area = get_tree().get_first_node_in_group("right_grab_area")
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	left_controller.button_pressed.connect(_on_left_button_pressed)
	left_controller.button_released.connect(_on_left_button_released)
	right_controller.button_pressed.connect(_on_right_button_pressed)
	right_controller.button_released.connect(_on_right_button_released)
	
	
	
	

func _process(_delta: float) -> void:
	if active_controller and active_grab_area:
		match active_controller:
			left_controller:
				var target_basis : Basis = left_touch_ball.global_transform.basis.orthonormalized() * rotation_offset
				global_transform = Transform3D(target_basis, left_touch_ball.global_position)
				
			right_controller:
				var target_basis : Basis = right_touch_ball.global_transform.basis.orthonormalized() * rotation_offset
				global_transform = Transform3D(target_basis, right_touch_ball.global_position)
				
func grab(_c: XRController3D) -> void:
	active_controller = _c

func jump_to(_c: XRController3D)->void:
	match _c:
		left_controller:
			global_transform = left_touch_ball.global_transform 
			
		right_controller:
			global_transform = right_touch_ball.global_transform 
	

func _on_area_entered(_a:Area3D)->void:
	active_grab_area = _a
	#print("Area Entered!: ", _a)
	#print("Active_grabarea: ", active_grab_area)
	match active_grab_area:
		left_grab_area:
			var mat = left_touch_ball.get_surface_override_material(0)
			mat.albedo_color = Color.GREEN
		right_grab_area:
			var mat = right_touch_ball.get_surface_override_material(0)
			mat.albedo_color = Color.GREEN

func _on_area_exited(_a:Area3D)->void:
	match active_grab_area:
		left_grab_area:
			var mat = left_touch_ball.get_surface_override_material(0)
			mat.albedo_color = Color.WHITE
			if active_controller == left_controller:
				active_controller = null
			if active_grab_area == left_grab_area:
				active_grab_area == null
		right_grab_area:
			var mat = right_touch_ball.get_surface_override_material(0)
			mat.albedo_color = Color.WHITE
			if active_controller == right_controller:
				active_controller = null
			if active_grab_area == right_grab_area:
				active_grab_area == null
				
func _on_left_button_pressed(_name: String)->void:
	print("left button_pressed!: ", _name)
	#print("Active_grabarea: ", active_grab_area)
	if _name == "trigger_click" and active_grab_area ==left_grab_area:
		active_controller = left_controller
		rotation_offset = left_touch_ball.global_transform.basis.orthonormalized().inverse() * global_transform.basis.orthonormalized()
	#print("Active Controller: ", active_controller)
		

func _on_right_button_pressed(_name: String)->void:
	print("right button_pressed!: ", _name)
	#print("Active_grabarea: ", active_grab_area)
	if _name == "trigger_click" and active_grab_area ==right_grab_area:
		active_controller = right_controller
		rotation_offset = right_touch_ball.global_transform.basis.orthonormalized().inverse() * global_transform.basis.orthonormalized()
	#print("Active Controller: ", active_controller)

func _on_left_button_released(_name: String)->void:
	if active_controller == left_controller:
		active_controller = null


func _on_right_button_released(_name: String)->void:
	if active_controller == right_controller:
		active_controller = null
