extends StartXR
class_name DrawingMain

@export var texture_controller: XRCornerPinTextureController
@export var menu_passthrough: MenuPassthrough

@onready var left_controller_ray_cast: RayCast3D = $XROrigin3D/LeftController/LeftControllerRayCast
@onready var right_controller_ray_cast: RayCast3D = $XROrigin3D/RightController/RightControllerRayCast
@onready var right_controller : XRController3D = $XROrigin3D/RightController
@onready var left_controller : XRController3D = $XROrigin3D/LeftController

var countdown_to_recenter_hmd: int = 3



@export var button_pressed : Dictionary[String,XRTouchController] = {}


func _ready()->void:
	super._ready()
	menu_passthrough.enable_mode_full()
	menu_passthrough.init_passthrough()
	
	left_controller.button_pressed.connect(_on_left_controller_button_pressed)
	left_controller.input_vector2_changed.connect(_on_left_input_vector2_changed)
	left_controller.button_released.connect(_on_left_controller_button_released)
	
	right_controller.button_pressed.connect(_on_right_controller_button_pressed)
	right_controller.input_vector2_changed.connect(_on_right_input_vector2_changed)
	right_controller.button_released.connect(_on_right_controller_button_released)

func _process(_delta: float) -> void:
	if countdown_to_recenter_hmd > 0:
		countdown_to_recenter_hmd -= 1
		if countdown_to_recenter_hmd == 0:
			XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)
	
func _on_controller_button_pressed(_c:XRTouchController, _name:String)->void:
	if _name == "trigger_click":
		if _c.ray.is_colliding():
			var collider = _c.ray.get_collider()
			print(collider, collider.get_class())
			if collider is ValueSlider:
				collider.update_value(_c.ray.get_collision_point())
			elif collider is XRMenu:
				(collider as XRMenu). active_controller = _c
			#elif collider is CornerPin:
				#var _pin_num = (collider as CornerPin).num
				#texture_controller._on_controller_corner_grab(_c, _pin_num)
			elif collider is Grabbable:
				if (collider as Grabbable).active_grab_area == null:
					(collider as Grabbable).jump_to(_c)
			else:
				menu_passthrough.update(collider.name)
			
func _on_controller_button_released(_c: XRController3D, _name: String)->void:
	pass
	
func _on_controller_input_vector2_changed(_c:XRController3D, _name: String, _value: Vector2)->void:
	print("controller:", _c,  "input: ", _name, " value: ", _value)
	
func _on_left_controller_button_pressed(_name: String) -> void:
	button_pressed.get_or_add(_name, left_controller)
	_on_controller_button_pressed(left_controller, _name)
			
func _on_left_input_vector2_changed(_name:String, _value:Vector2)->void:
	_on_controller_input_vector2_changed(left_controller, _name, _value)
	
func _on_right_controller_button_pressed(_name: String) -> void:
	button_pressed.get_or_add(_name, right_controller)
	_on_controller_button_pressed(right_controller, _name)

func _on_right_input_vector2_changed(_name:String, _value:Vector2)->void:
	_on_controller_input_vector2_changed(right_controller, _name, _value)

func _on_right_controller_button_released(_name:String)->void:
	button_pressed.erase(_name)
	_on_controller_button_released(right_controller, _name)

func _on_left_controller_button_released(_name:String)->void:
	button_pressed.erase(_name)
	_on_controller_button_released(left_controller, _name)
