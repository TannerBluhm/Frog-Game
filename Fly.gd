extends Spatial

class_name Fly

func _ready():
	add_to_group("Flys")


func _on_Player_register_tongue_collision(collider):
	print($Area)
	if collider == $Area:
		queue_free()
