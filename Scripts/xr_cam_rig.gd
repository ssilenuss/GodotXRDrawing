@tool
extends Node3D
class_name XR_Cam_Rig

@export var interpupillary_distance: float = 0.065 # Average human IPD in meters
@export var camera_left: Camera3D 
@export var camera_right: Camera3D 
@export var left_node: Node3D
@export var right_node: Node3D

func _ready() -> void:
		get_hardware_ipd()
		print("ipd: ", interpupillary_distance)
		left_node.global_transform = self.global_transform.translated_local(Vector3(-interpupillary_distance / 2.0, 0, 0))
		right_node.global_transform = self.global_transform.translated_local(Vector3(interpupillary_distance / 2.0, 0, 0))
	
func _process(_delta: float) -> void:
	if visible:
		camera_left.global_transform = left_node.global_transform
		camera_right.global_transform = right_node.global_transform
	
func get_hardware_ipd() -> float:
	var xr_interface : XRInterface = XRServer.primary_interface
	
	# Verify that XR is active and rendering views
	if xr_interface and xr_interface.is_initialized() and xr_interface.get_view_count() >= 2:
		# Retrieve local Transform3D offsets relative to the HMD tracking root
		var left_eye_transform : Transform3D = xr_interface.get_transform_for_view(0, global_transform)
		var right_eye_transform : Transform3D = xr_interface.get_transform_for_view(1, global_transform)
		
		# Compute the physical distance between both tracking points (returns meters)
		var ipd : float = left_eye_transform.origin.distance_to(right_eye_transform.origin)
		print("new ipd!")
		return ipd
		
		
	# Fallback to standard human average (64mm) if no headset is connected
	return 0.064
