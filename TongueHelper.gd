extends Spatial

signal ready_to_register_collision

onready var tongue = $Tongue

var is_drawing_tongue := false
var is_extending_tongue := false

var hookpoint := Vector3.ZERO
var has_hookpoint := false


func init_tongue_extension(hookpoint: Vector3) -> void:
	self.hookpoint = hookpoint
	has_hookpoint = true
	is_extending_tongue = true


func draw_tongue() -> void:
	is_drawing_tongue = true
	look_at(hookpoint, Vector3.UP)
	tongue.visible = true
	
	var length: float = global_transform.origin.distance_to(hookpoint)
	
	if is_extending_tongue:
		tongue.height = lerp(tongue.height, length, 0.3) # TODO: No magic numbers
	else:
		tongue.height = lerp(tongue.height, 0, 0.3) # TODO: No magic numbers
	
	tongue.translation.z = tongue.height / -2

	if is_extending_tongue and Helpers.is_close_to(
		tongue.height,
		length,
		0.001
	):
		is_extending_tongue = false
		emit_signal("ready_to_register_collision")
		
	elif not is_extending_tongue and Helpers.is_close_to(
		tongue.height,
		0
	):
		tongue.height = 0
		is_drawing_tongue = false
		has_hookpoint = false


func end_tongue_launch() -> void:
	tongue.visible = false
