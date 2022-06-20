extends Spatial

class_name OnFloorDetector

export var enabled: bool = true

func _ready():
	for child in get_children():
		child.enabled = enabled


func is_colliding():
	for child in get_children():
		if child.is_colliding():
			return true
	
	return false
