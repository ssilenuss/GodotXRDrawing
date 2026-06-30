extends Label
class_name ValueDisplay

@export var to_display: Range

func _ready() -> void:
	to_display.value_changed.connect(_on_value_changed)
	
func _on_value_changed(_v: float)->void:
	text = String.num(_v, 2) #two decimal places
