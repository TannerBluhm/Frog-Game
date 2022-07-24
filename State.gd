extends Node

class_name State

var velocity := Vector3.ZERO
var position := Vector3.ZERO
var rotation := Vector3.ZERO
var mesh_rotation := Vector3.ZERO
var mesh_translation_offset := Vector3.ZERO
var is_on_floor := true
var tongue_translation := Vector3.ZERO
var tongue_rotation := Vector3.ZERO
var tongue_height := 0.0
var tongue_is_visible := false
onready var action: int = ActionState.Actions.IDLE


func to_dict() -> Dictionary:
	return {
		"velocity": velocity,
		"position": position,
		"rotation": rotation,
		"mesh_rotation": mesh_rotation,
		"mesh_translation_offset": mesh_translation_offset,
		"is_on_floor": is_on_floor,
		"tongue_translation": tongue_translation,
		"tongue_rotation": tongue_rotation,
		"tongue_height": tongue_height,
		"tongue_is_visible": tongue_is_visible,
		"action": action
	}
