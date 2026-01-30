@tool
extends Node3D

var mouse_pos := Vector2()
var grab_pos := Vector3()
const RAY_DIST = 1000
var grabbed_object : Area3D = null

@export var overlay_mesh: MeshInstance3D
var overlay_mat: ShaderMaterial

func _ready() -> void:
	overlay_mat = overlay_mesh.get_active_material(0)
	update_overlay_cornerpin($Corners/Corner0)
	update_overlay_cornerpin($Corners/Corner1)
	update_overlay_cornerpin($Corners/Corner2)
	update_overlay_cornerpin($Corners/Corner3)

func _process(delta: float) -> void:
	if grabbed_object:
		grabbed_object.position = get_3D_position_from_2D(mouse_pos, 10)
	update_overlay_cornerpin($Corners/Corner0)
	update_overlay_cornerpin($Corners/Corner1)
	update_overlay_cornerpin($Corners/Corner2)
	update_overlay_cornerpin($Corners/Corner3)
		
				
			
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = event.position
	if event is InputEventMouseButton:
		if event.pressed == false and event.button_index == MOUSE_BUTTON_LEFT:
			grab_object_at(mouse_pos)
		if event.pressed == false and event.button_index == MOUSE_BUTTON_RIGHT:
			grabbed_object = null
	
			
func grab_object_at(_pos: Vector2)->void:
	var space : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var start :Vector3 = get_viewport().get_camera_3d().project_ray_origin(_pos)
	var end : Vector3 = get_viewport().get_camera_3d().project_position(_pos, RAY_DIST)
	var params := PhysicsRayQueryParameters3D.new()
	params.collide_with_areas = true
	
	params.from = start
	params.to = end
	
	var result :Dictionary= space.intersect_ray(params)
	if result.is_empty() == false:
		grabbed_object = result.collider
	#print(result)

func get_3D_position_from_2D(_pos2D: Vector2, z_pos: float)->Vector3:
	return get_viewport().get_camera_3d().project_position(_pos2D, z_pos)

func update_overlay_cornerpin(_node3D:Node3D)->void:
	match _node3D.name:
			"Corner0":
				overlay_mat.set_shader_parameter("top_left", _node3D.global_position)
			"Corner1":
				overlay_mat.set_shader_parameter("top_right", _node3D.global_position)
			"Corner2":
				overlay_mat.set_shader_parameter("bottom_right", _node3D.global_position)
			"Corner3":
				overlay_mat.set_shader_parameter("bottom_left", _node3D.global_position)
	
