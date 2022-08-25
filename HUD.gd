extends Control

onready var fly_counter := $GameplayHud/FlyCounter
onready var countdown := $GameplayHud/Countdown
onready var crosshair := $GameplayHud/Crosshair

var num_flies_eaten = 0

var level_data: LevelData


func initialize(level_data: LevelData) -> void:
	self.level_data = level_data
	set_total_flys(get_tree().get_nodes_in_group(Strings.FLIES_GROUP_ID).size())
	countdown.set_time(level_data.base_time_to_complete_level_in_seconds)


func _process(_delta):
	fly_counter.numerator.text = str(num_flies_eaten)


func show_aiming_hud():
	crosshair.visible = true


func hide_aiming_hud():
	crosshair.visible = false


func set_total_flys(total: int) -> void:
	fly_counter.denominator.text = str(total)


func update_fly_count(fly_count: int) -> void:
	num_flies_eaten = fly_count


func increment_fly_count(amount: int = 1) -> void:
	num_flies_eaten += amount


func reset_timer(time: int = -1):
	if time >= 0:
		countdown.set_time(time)
	else:
		countdown.reset()


func show_win():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	countdown.stop()
	$GameplayHud.visible = false
	$WinHud.visible = true


func show_lost():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$GameplayHud.visible = false
	$LostHud.visible = true


func reset():
	$GameplayHud.visible = true
	$WinHud.visible = false
	$LostHud.visible = false
	update_fly_count(0)
	reset_timer()
