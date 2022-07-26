extends Position3D

class_name FlySpawner

var fly = preload("res://Fly.tscn").instance()

func _ready():
	add_to_group(Strings.FLY_SPAWNERS_GROUP_ID)


mastersync func spawn() -> Fly:
	if not get_parent().get_children().has(fly):
		get_parent().add_child(fly)
	
	fly.global_transform.origin = global_transform.origin
	return fly
