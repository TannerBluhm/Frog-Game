extends Control

onready var timer: Timer = $Timer
onready var label = $TimeLeft

func _process(_delta):
	label.text = str(int(timer.time_left))


func set_time(time: int) -> void:
	timer.start(time)


func reset():
	timer.start()


func stop():
	timer.stop()
