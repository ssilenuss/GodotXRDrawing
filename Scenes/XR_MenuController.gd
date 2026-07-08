extends Control

@export var panel_parent : Control
var panels : Array[Node]
var current_panel : int = 0 : set = set_panel
func set_panel(_v:int)->void:
	current_panel = _v
	for i in panels.size():
		if i == current_panel: panels[i].visible = true
		else: panels[i].visible = false

func _ready() -> void:
	panels = panel_parent.get_children()
	


func _on_left_pressed() -> void:
	var i : int = current_panel - 1
	if i < 0: i = panels.size()-1
	set_panel(i)


func _on_right_pressed() -> void:
	var i : int = current_panel + 1
	if i >= panels.size(): i = 0
	set_panel(i)
