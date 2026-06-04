extends StartXR

@export var texture_controller: XRCornerPinTextureController
@export var menu_passthrough: MenuPassthrough

@onready var left_controller_ray_cast: RayCast3D = $XROrigin3D/LeftController/LeftControllerRayCast
@onready var right_controller_ray_cast: RayCast3D = $XROrigin3D/RightController/RightControllerRayCast
@onready var right_controller : XRController3D = $XROrigin3D/RightController
@onready var left_controller : XRController3D = $XROrigin3D/LeftController

var countdown_to_recenter_hmd: int = 3


func _ready()->void:
	super._ready()
	menu_passthrough.enable_mode_full()
	menu_passthrough.init_passthrough()
	
	left_controller.button_pressed.connect(_on_left_controller_button_pressed)
	left_controller.input_vector2_changed.connect(_on_left_input_vector2_changed)
	
	right_controller.button_pressed.connect(_on_right_controller_button_pressed)
	right_controller.input_vector2_changed.connect(_on_right_input_vector2_changed)

func _process(_delta: float) -> void:
	if countdown_to_recenter_hmd > 0:
		countdown_to_recenter_hmd -= 1
		if countdown_to_recenter_hmd == 0:
			XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)
			

func _on_left_controller_button_pressed(name: String) -> void:
	if name == "trigger_click" and left_controller_ray_cast.is_colliding():
		var collider = left_controller_ray_cast.get_collider()
		if collider is ValueSlider:
			collider.update_value(left_controller_ray_cast.get_collision_point())
		elif collider is CornerPin:
			var _pin_num = (collider as CornerPin).num
			texture_controller._on_controller_corner_grab(left_controller, _pin_num)
		elif collider is Grabbable:
			if (collider as Grabbable).active_grab_area == null:
				(collider as Grabbable).jump_to(left_controller)
		else:
			menu_passthrough.update(collider.name)
			
func _on_left_input_vector2_changed(_name:String, _value:Vector2)->void:
	print("left input: ", name, " value: ", _value)
	
func _on_right_controller_button_pressed(name: String) -> void:
	if name == "trigger_click" and right_controller_ray_cast.is_colliding():
		var collider = right_controller_ray_cast.get_collider()

		if collider is ValueSlider:
			collider.update_value(right_controller_ray_cast.get_collision_point())
		elif collider is CornerPin:
			var _pin_num = (collider as CornerPin).num
			texture_controller._on_controller_corner_grab(right_controller, _pin_num)
		elif collider is Grabbable:
			if (collider as Grabbable).active_grab_area == null:
				(collider as Grabbable).jump_to(right_controller)
			
		else:
			menu_passthrough.update(collider.name)

func _on_right_input_vector2_changed(_name:String, _value:Vector2)->void:
	print("right input: ", name, " value: ", _value)
