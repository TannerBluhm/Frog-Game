extends Node

class_name Wobbler

onready var player = get_parent()
onready var mesh = get_parent().get_node("Mesh")

var left_wobble := false
var MAX_WOBBLE = deg2rad(10)
var WOBBLE_THRESHOLD_BUFFER = deg2rad(2)
var WOBBLE_LERP_WEIGHT = 0.1
var x_wobble := 0.0

var WOBBLE_HEIGHT_OFFSET = 0.05

var is_wobbling := false

func wobble():
	if (player.on_floor()):
		mesh.translation.y = lerp(mesh.translation.y, WOBBLE_HEIGHT_OFFSET, WOBBLE_LERP_WEIGHT)
		_wobble_z()
		_wobble_x()
		is_wobbling = true
	else:
		dewobble()


func _wobble_z():
	if left_wobble:
		if (mesh.rotation.z <= -(MAX_WOBBLE - WOBBLE_THRESHOLD_BUFFER)):
			left_wobble = false
		else:
			mesh.rotation.z = lerp(mesh.rotation.z, -MAX_WOBBLE, WOBBLE_LERP_WEIGHT)
	else:
		if (mesh.rotation.z >= (MAX_WOBBLE - WOBBLE_THRESHOLD_BUFFER)):
			left_wobble = true
		else:
			mesh.rotation.z = lerp(mesh.rotation.z, MAX_WOBBLE, WOBBLE_LERP_WEIGHT)


func _wobble_x():
	if (x_wobble > 0):
		if (mesh.rotation.x >= x_wobble - WOBBLE_THRESHOLD_BUFFER):
			_get_new_x_wobble()
		else:
			mesh.rotation.x = lerp(mesh.rotation.x, x_wobble, WOBBLE_LERP_WEIGHT)
	else:
		if (mesh.rotation.x <= x_wobble + WOBBLE_THRESHOLD_BUFFER):
			_get_new_x_wobble()
		else:
			mesh.rotation.x = lerp(mesh.rotation.x, x_wobble, WOBBLE_LERP_WEIGHT)


func _get_new_x_wobble():
	var lower_limit = 2
	var higher_limit = 8
	var random_sign = rand_range(0, 1)
	if (random_sign < 0.5):
		x_wobble = -deg2rad(rand_range(lower_limit, higher_limit))
	else:
		x_wobble = deg2rad(rand_range(lower_limit, higher_limit))


func dewobble():
	mesh.translation.y = lerp(mesh.translation.y, 0, WOBBLE_LERP_WEIGHT)
	mesh.rotation.z = lerp(mesh.rotation.z, 0, WOBBLE_LERP_WEIGHT)
	mesh.rotation.x = lerp(mesh.rotation.x, 0, WOBBLE_LERP_WEIGHT)
	is_wobbling = false
