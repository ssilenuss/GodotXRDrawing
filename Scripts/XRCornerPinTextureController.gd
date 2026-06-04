@tool
extends Node3D
class_name XRCornerPinTextureController

@export_tool_button("Set Corners") var set_corners_action = set_corners
@export var right_controller_touch_ball : MeshInstance3D
@export var left_controller_touch_ball : MeshInstance3D
@export var overlay_mesh: MeshInstance3D
@export var corner_pins: Array[Area3D]

var grabbed_pin : int = -1
var overlay_mat: ShaderMaterial
var active_controller: XRController3D

func _ready() -> void:
	overlay_mat = overlay_mesh.get_active_material(0)
	for i in corner_pins.size():
		update_overlay_cornerpin(i)

func _process(_delta: float) -> void:
	if active_controller:
		match active_controller.name:
			"LeftController":
				corner_pins[grabbed_pin].global_position = left_controller_touch_ball.global_position
				update_overlay_cornerpin(grabbed_pin)
			"RightController":
				corner_pins[grabbed_pin].global_position = right_controller_touch_ball.global_position
				update_overlay_cornerpin(grabbed_pin)

func update_overlay_cornerpin(_pin_num:int)->void:
	match _pin_num:
			0:
				overlay_mat.set_shader_parameter("top_left", corner_pins[0].global_position)
			1:
				overlay_mat.set_shader_parameter("top_right", corner_pins[1].global_position)
			2:
				overlay_mat.set_shader_parameter("bottom_right", corner_pins[2].global_position)
			3:
				overlay_mat.set_shader_parameter("bottom_left", corner_pins[3].global_position)

func set_corners()->void:
	for i in corner_pins.size():
		update_overlay_cornerpin(i)
	

func _on_controller_corner_grab(_controller: XRController3D, _pin_num: int) -> void:
	grabbed_pin = _pin_num
	active_controller = _controller
	

func _on_left_controller_button_released(name: String) -> void:
	active_controller = null

	
func _on_right_controller_button_released(name: String) -> void:
	active_controller = null
