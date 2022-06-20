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

export var TURNING_SENSITIVITY: float = 0.02

onready var wobbler: Wobbler = $Wobbler
var should_wobble := false

onready var on_floor_detector: OnFloorDetector = $OnFloorDetector
onready var on_floor_cooldown: Timer = $OnFloorDetectionCooldown

onready var jump_power_ui = $HUD/Label

onready var mesh := $Mesh

onready var spawn = get_parent().get_node("Spawn")

func _ready():
	pass # Replace with function body.


func _process(delta):
	debug_draw()
	should_wobble = false
	
	_register_input(delta)
		
	if (not on_floor_detector.is_colliding()):
		velocity = _apply_gravity(velocity)
	
	velocity = move_and_slide(velocity, Vector3.UP, true)
	if should_wobble:
		wobbler.wobble()
	else:
		wobbler.dewobble()


func _register_input(delta):
	if (Input.is_action_pressed("forward")):
		if (on_floor()):
			power_up_jump(delta)
			velocity = Vector3.ZERO
	elif (Input.is_action_just_released("forward")):
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
	
	if (Input.is_action_pressed("backward") and on_floor()):
		_go_back(delta)


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


func on_floor():
	if on_floor_cooldown.is_stopped():
		return on_floor_detector.is_colliding()
	
	return false


func debug_draw():
	DebugDraw.set_text("Velocity", velocity)


func _on_Area_body_entered(body):
	translation = spawn.translation
	rotation = Vector3.ZERO
