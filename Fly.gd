extends Spatial

class_name Fly

onready var exists_on_server = get_tree().is_network_server()

func _ready():
	add_to_group(Strings.FLIES_GROUP_ID)


remotesync func get_eaten():
	get_parent().remove_child(self)


remotesync func _get_global_position_updated_by_server(new_pos: Vector3):
	translation = new_pos
