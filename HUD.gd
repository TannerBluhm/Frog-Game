extends Control

func show_win():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$GameplayHud.visible = false
	$WinHud.visible = true


func reset():
	$GameplayHud.visible = true
	$WinHud.visible = false
