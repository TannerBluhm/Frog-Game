extends Node

class_name StateMachine

onready var state: State = $State 

func get_desired_action(player: FrogPlayer):
	pass


func update_state(player: FrogPlayer):
	state.velocity = player.velocity
	state.position = player.translation
	state.rotation = player.rotation
	state.mesh_rotation = player.mesh.rotation
	state.mesh_translation_offset = player.mesh.translation
	state.tongue_translation = player.tongue_helper.tongue.translation
	state.tongue_rotation = player.tongue_helper.rotation
	state.tongue_height = player.tongue_helper.tongue.height
	state.tongue_is_visible = player.tongue_helper.tongue.visible
	
	state.is_on_floor = player.on_floor_detector.is_on_floor()
	_update_action_state(state)


func _update_action_state(new_state: State):
	if new_state.velocity.y < 0 and not new_state.is_on_floor:
		new_state.action = ActionState.Actions.FALLING
	elif new_state.velocity.length_squared() > 0 and new_state.velocity.y >= 0:
		new_state.action = ActionState.Actions.WALKING
	elif new_state.velocity.length_squared() == 0:
		new_state.action = ActionState.Actions.IDLE


func can_jump(player: FrogPlayer):
	return player.on_floor_detector.is_on_floor()


func get_state_from_dict(state_as_dict: Dictionary) -> State:
	var new_state = State.new()
	new_state.velocity = state_as_dict["velocity"]
	new_state.position = state_as_dict["position"]
	new_state.rotation = state_as_dict["rotation"]
	new_state.mesh_rotation = state_as_dict["mesh_rotation"]
	new_state.mesh_translation_offset = state_as_dict["mesh_translation_offset"]
	new_state.is_on_floor = state_as_dict["is_on_floor"]
	new_state.tongue_translation = state_as_dict["tongue_translation"]
	new_state.tongue_rotation = state_as_dict["tongue_rotation"]
	new_state.tongue_height = state_as_dict["tongue_height"]
	new_state.tongue_is_visible = state_as_dict["tongue_is_visible"]
	new_state.action = state_as_dict["action"]
	
	return new_state
