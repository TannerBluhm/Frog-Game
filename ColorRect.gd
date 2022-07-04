extends ColorRect

export var fade_speed: float = 2

var active := false


func _process(delta):
	DebugDraw.set_text("Is b&w", active)
	if active:
		_apply_black_and_white_over_time(delta)
	else:
		_deapply_black_and_white_over_time(delta)


func fade_in_black_and_white() -> void:
	active = true


func fade_out_black_and_white() -> void:
	active = false


func _apply_black_and_white_over_time(delta) -> void:
	var current_shader_level = material.get_shader_param("filter_amount")
	var new_shader_level = current_shader_level + fade_speed * delta
	
	_update_shader_level(new_shader_level)


func _deapply_black_and_white_over_time(delta) -> void:
	var current_shader_level = material.get_shader_param("filter_amount")
	var new_shader_level = current_shader_level - fade_speed * delta
	
	_update_shader_level(new_shader_level)


func _update_shader_level(new_amount: float) -> void:
	var amount = clamp(new_amount, 0, 1)
	material.set_shader_param("filter_amount", amount)
