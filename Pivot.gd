extends Spatial

export var MOUSE_SENSITIVITY: float = 0.03

onready var grapple_ray: RayCast = $Camera/GrappleRayCast

onready var default_camera_rotation = $Camera.rotation
onready var default_camera_zoom = $Camera.fov
var CAMERA_ZOOM_FOV = 45

const DEAIM_LERP_WEIGHT = 0.1

var is_aiming := false


func aim():
	DebugDraw.set_text("Aiming", true)
	is_aiming = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera.fov = lerp($Camera.fov, CAMERA_ZOOM_FOV, DEAIM_LERP_WEIGHT) # TODO: Control the weight elsewhere
	$Camera/HUD/GameplayHud/Crosshair.visible = true


func deaim():
	is_aiming = false
	DebugDraw.set_text("Aiming", false)
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	rotation = lerp(rotation, Vector3.ZERO, DEAIM_LERP_WEIGHT) # TODO: Control the weight elsewhere
	$Camera.rotation = lerp($Camera.rotation, default_camera_rotation, DEAIM_LERP_WEIGHT) # TODO: Control the weight elsewhere
	$Camera.fov = lerp($Camera.fov, default_camera_zoom, DEAIM_LERP_WEIGHT) # TODO: Control the weight elsewhere
	$Camera/HUD/GameplayHud/Crosshair.visible = false


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-(MOUSE_SENSITIVITY * event.relative.x/10)) # TODO: No magic numbers
		rotation.y = clamp(rotation.y, -1.2, 1.2) # TODO: No magic numbers
		$Camera.rotate_x(-(MOUSE_SENSITIVITY * event.relative.y/10)) # TODO: No magic numbers
		$Camera.rotation.x = clamp($Camera.rotation.x, -0.35, 1.2) # TODO: No magic numbers
