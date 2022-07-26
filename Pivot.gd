extends Spatial

export var MOUSE_SENSITIVITY: float = 0.03

onready var grapple_ray: RayCast = $Pivot/Camera/GrappleRayCast

onready var pivot = $Pivot
onready var default_camera_rotation = $Pivot/Camera.rotation
onready var default_camera_zoom = $Pivot/Camera.fov
onready var camera: Camera = $Pivot/Camera
onready var hud  = $Pivot/Camera/HUD
onready var gameplay_hud = $Pivot/Camera/HUD/GameplayHud
onready var win_hud = $Pivot/Camera/HUD/WinHud
onready var lose_hud = $Pivot/Camera/HUD/LostHud
onready var jump_power_ui = $Pivot/Camera/HUD/GameplayHud/Label
var CAMERA_ZOOM_FOV = 45

const DEAIM_LERP_WEIGHT = 0.1

var is_aiming := false


func aim():
	DebugDraw.set_text("Aiming", true)
	is_aiming = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = lerp(camera.fov, CAMERA_ZOOM_FOV, DEAIM_LERP_WEIGHT) # TODO: Control the weight elsewhere


func deaim():
	is_aiming = false
	DebugDraw.set_text("Aiming", false)
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	rotation = lerp(rotation, Vector3.ZERO, DEAIM_LERP_WEIGHT) # TODO: Control the weight elsewhere
	pivot.rotation = lerp(camera.rotation, default_camera_rotation, DEAIM_LERP_WEIGHT) # TODO: Control the weight elsewhere
	camera.fov = lerp(camera.fov, default_camera_zoom, DEAIM_LERP_WEIGHT) # TODO: Control the weight elsewhere


func mesh_should_fade() -> bool:
	DebugDraw.set_text("Camera y", camera.global_transform.origin.y < global_transform.origin.y)
	return camera.global_transform.origin.y < global_transform.origin.y


func init_connections_for_player(player: FrogPlayer):
	win_hud.get_node("ReplayButton").connect("pressed", player, "_on_ReplayButton_pressed")


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-(MOUSE_SENSITIVITY * event.relative.x/10)) # TODO: No magic numbers
		rotation.y = clamp(rotation.y, -1.2, 1.2) # TODO: No magic numbers
		pivot.rotate_x(-(MOUSE_SENSITIVITY * event.relative.y/10)) # TODO: No magic numbers
		pivot.rotation.x = clamp(pivot.rotation.x, -0.35, 1.2) # TODO: No magic numbers
