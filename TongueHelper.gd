extends Spatial

signal ready_to_register_collision

export var tongue_height_lerp_weight = 0.01

onready var tongue = $Tongue

var is_drawing_tongue := false
var is_extending_tongue := false

var hookpoint := Vector3.ZERO
var has_hookpoint := false

var fly_being_eaten = null
var point_of_contact = null


func init_tongue_extension(hookpoint: Vector3) -> void:
	self.hookpoint = hookpoint
	has_hookpoint = true
	is_extending_tongue = true


func reset():
	hookpoint = Vector3.ZERO
	has_hookpoint = false
	is_drawing_tongue = false
	is_extending_tongue = false
	fly_being_eaten = false
	point_of_contact = false
	tongue.visible = false
	tongue.height = 0


func draw_tongue() -> void:
	is_drawing_tongue = true
	look_at(hookpoint, Vector3.UP)
	tongue.visible = true
	
	var length: float = global_transform.origin.distance_to(hookpoint)
	
	if is_extending_tongue:
		tongue.height = lerp(tongue.height, length, tongue_height_lerp_weight)
	else:
		tongue.height = lerp(tongue.height, 0, tongue_height_lerp_weight)
	
	tongue.translation.z = tongue.height / -2

	if is_extending_tongue and Helpers.is_close_to(
		tongue.height,
		length,
		0.05
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
	
	if fly_being_eaten and fly_being_eaten.is_inside_tree():
		attach_to_tongue(fly_being_eaten)
	else:
		fly_being_eaten = null
		point_of_contact = null


func end_tongue_launch() -> void:
	tongue.visible = false


func eat_fly(fly: Fly) -> void:
	fly_being_eaten = fly


func attach_to_tongue(obj: Spatial) -> void:
	var end_of_tongue_position = to_global(tongue.translation + Vector3(0, 0, tongue.height / -2))
	
	if not point_of_contact:
		point_of_contact = end_of_tongue_position
	else:
		var positional_difference = point_of_contact - end_of_tongue_position
		obj.global_transform.origin = obj.global_transform.origin - positional_difference
		
		point_of_contact = end_of_tongue_position
