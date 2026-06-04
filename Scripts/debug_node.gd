extends Label3D

@export var node : Node

func _process(_delta: float) -> void:
	if node:
		pass
	else:
		text = "no node attached"
