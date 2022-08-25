extends KinematicBody

class_name FrogPlayer

var JUMP_VECTOR := Vector3(0, 3, -1.5).normalized()
var GRAVITY := Vector3.DOWN * 1

var velocity := Vector3.ZERO
var jump_force: float = 0.0
var STARTING_JUMP_FORCE = 15
var MAX_JUMP_FORCE = 45
var jump_force_increment: float = 20
var MAX_LEAN = deg2rad(50)
var MAX_LEAN_HEIGHT_OFFSET = 0.019

var BACKWARDS_SPEED = 175
var FORWARDS_SPEED = 175

export var TURNING_SENSITIVITY: float = 0.02
export var mouse_sensitivity: float = 0.03

onready var state_machine = $StateMachine

onready var wobbler: Wobbler = $Wobbler
var should_wobble := false

onready var on_floor_detector: OnFloorDetector = $OnFloorDetector
onready var on_floor_cooldown: Timer = $OnFloorDetectionCooldown

onready var mesh := $Mesh

onready var camera_controller = $PlayerCameraAndHud
onready var camera = camera_controller.camera
onready var jump_power_ui = camera_controller.jump_power_ui
var tongue_collider = null

onready var hud = camera_controller.hud

onready var spawn = get_parent().get_node("Spawn")

onready var tongue_helper = $TongueHelper

var game_over := false


func _ready():
	_init_connections()
	if not is_network_master():
		camera_controller.queue_free()


func _process(delta):
	if is_network_master():
		debug_draw()
		_handle_movement(delta)
		
#		if camera_controller.mesh_should_fade():
#			mesh.fade_mesh_out()
		
		_update_state()


func _handle_movement(delta) -> void:
	should_wobble = false
	
	if game_over:
		return
	
	should_wobble = false
	_register_input(delta)
	_handle_gravity()
	wobbler.handle_wobble(should_wobble)
	velocity = move_and_slide(velocity, Vector3.UP, true)


func _register_input(delta):
	if (Input.is_action_pressed("jump")):
		if (on_floor()):
			power_up_jump(delta)
			velocity = Vector3.ZERO
	elif (Input.is_action_just_released("jump")):
		if (on_floor()):
			_jump()
	elif (on_floor()):
		velocity = Vector3.ZERO
	
	if (not on_floor() and velocity == Vector3.ZERO):
		velocity = (Vector3.FORWARD).rotated(Vector3.UP, rotation.y)
	
	if (Input.is_action_pressed("left")):
		_turn_left()
	if (Input.is_action_pressed("right")):
		_turn_right()
	
	if (Input.is_action_pressed("backward") and on_floor() and not Input.is_action_pressed("jump")):
		_go_back(delta)
		hud.get_node("CanvasLayer/ColorRect").fade_in_black_and_white()
	
	if (Input.is_action_pressed("forward") and on_floor() and not Input.is_action_pressed("jump")):
		_go_forward(delta)
		hud.get_node("CanvasLayer/ColorRect").fade_out_black_and_white()
	
	if Input.is_action_pressed("aim"):
		camera_controller.aim()
		hud.show_aiming_hud()
	else:
		camera_controller.deaim()
		hud.hide_aiming_hud()
	
	if (Input.is_action_just_pressed("fire") and camera_controller.is_aiming) or tongue_helper.is_drawing_tongue:
		_launch_tongue()
	else:
		tongue_helper.end_tongue_launch()


func _update_state():
	state_machine.update_state(self)
	rpc_unreliable("remotely_update_state", state_machine.state.to_dict())


puppet func remotely_update_state(state_as_dict: Dictionary):
	var state = state_machine.get_state_from_dict(state_as_dict)
	translation = state.position
	rotation = state.rotation
	mesh.rotation = state.mesh_rotation
	mesh.translation = state.mesh_translation_offset
	tongue_helper.set_to_state(state)


func _launch_tongue():
	if not tongue_helper.has_hookpoint:
		DebugDraw.set_text("setting is extending tongue to true", true)
		
		var hookpoint = camera_controller.grapple_ray.default_end.global_transform.origin
		if camera_controller.grapple_ray.is_colliding():
			tongue_collider = camera_controller.grapple_ray.get_collider()
			hookpoint = camera_controller.grapple_ray.get_collision_point()
		else:
			tongue_collider = null
			
		tongue_helper.init_tongue_extension(hookpoint)
	
	tongue_helper.draw_tongue()


func _handle_gravity() -> void:
	if (not on_floor_detector.is_on_floor()):
			velocity = _apply_gravity(velocity)


func _apply_gravity(vec: Vector3) -> Vector3:
	return vec + GRAVITY


func power_up_jump(delta):
	if jump_force < STARTING_JUMP_FORCE:
		jump_force = STARTING_JUMP_FORCE
	
	jump_force = jump_force + (jump_force_increment * delta)
	if (jump_force > MAX_JUMP_FORCE):
		jump_force = MAX_JUMP_FORCE
	
	_power_lean()
	
	jump_power_ui.text = str(jump_force)


func _power_lean():
	var power_percentage = jump_force / (MAX_JUMP_FORCE - STARTING_JUMP_FORCE)
	var lean = power_percentage * MAX_LEAN
	var height_offset = power_percentage * MAX_LEAN_HEIGHT_OFFSET * Vector3.UP
	mesh.rotation.x = lerp(mesh.rotation.x, -lean, wobbler.WOBBLE_LERP_WEIGHT)
	mesh.translation = mesh.translation + height_offset
	
	if jump_force == 0:
		mesh.tranlsation = lerp(mesh.translation, Vector3.ZERO, wobbler.WOBBLE_LERP_WEIGHT)


func _jump():
	on_floor_cooldown.start()
	velocity = (JUMP_VECTOR * jump_force).rotated(Vector3.UP, rotation.y)
	jump_force = 0
	jump_power_ui.text = str(jump_force)


func _turn_left():
	rotate(Vector3.UP, TURNING_SENSITIVITY)
	should_wobble = true


func _turn_right():
	rotate(Vector3.UP, -TURNING_SENSITIVITY)
	should_wobble = true


func _go_back(delta):
	var backward_vector = (Vector3.BACK * BACKWARDS_SPEED).rotated(Vector3.UP, rotation.y)
	velocity = velocity + (backward_vector * delta)
	should_wobble = true

func _go_forward(delta):
	var forward_vector = (Vector3.FORWARD * FORWARDS_SPEED).rotated(Vector3.UP, rotation.y)
	velocity = velocity + (forward_vector * delta)
	should_wobble = true


func on_floor():
	if on_floor_cooldown.is_stopped():
		return on_floor_detector.is_on_floor()
	
	return false


func debug_draw():
	DebugDraw.set_text("Velocity", velocity)
	DebugDraw.set_text("Translation", translation)
#	DebugDraw.set_text("Network ID", get_tree().get_network_unique_id())
#	DebugDraw.set_text("Master ID", get_network_master())
#	DebugDraw.set_text("State Vel", state_machine.state.velocity)
#	DebugDraw.set_text("State Pos", state_machine.state.position)
#	DebugDraw.set_text("State Rot", state_machine.state.rotation)
#	DebugDraw.set_text("Action", state_machine.state.action)
	DebugDraw.set_text("Jump force", jump_force)


func init_hud(level_data: LevelData):
	hud.initialize(level_data)


func win():
	game_over = true
	hud.show_win()


func lose():
	game_over = true
	hud.show_lost()


# Signals:

func _init_connections():
	if is_network_master():
		camera_controller.init_connections_for_player(self)


func _on_Hazard_body_entered(body):
	if is_network_master() and body == self:
			translation = spawn.translation
			rotation = spawn.rotation


func _on_TongueHelper_ready_to_register_collision():
	if tongue_collider and is_network_master():
		if tongue_collider is Fly:
			tongue_helper.eat_fly(tongue_collider)


func _on_ReplayButton_pressed():
	if is_network_master():
		get_parent().rpc_unreliable("reset")
		tongue_helper.reset()
		hud.reset()
		game_over = false


func _on_InMouthDetector_area_entered(area):
	if area is Fly and is_network_master():
		area.rpc_unreliable("get_eaten")
		hud.increment_fly_count()
		for node in get_tree().get_nodes_in_group(Strings.FLIES_GROUP_ID):
			if node.is_inside_tree():
				return
	
		win()


func _on_Main_ready_with_data(data):
	if is_network_master():
		init_hud(data)
		camera.current = true


func _on_Timer_timeout():
	if is_network_master():
		lose()
