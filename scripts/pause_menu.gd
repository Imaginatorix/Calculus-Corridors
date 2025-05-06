extends Control

func _ready():
	resume()
	$AnimationPlayer.play("RESET")

func remove_screen():
	GlobVars.paused = false
	for i in $PanelContainer/MarginContainer/VBoxContainer.get_children():
		i.mouse_filter = MOUSE_FILTER_IGNORE
	$AnimationPlayer.play_backwards("blur")

func resume():
	get_tree().paused = false
	remove_screen()

func show_screen():
	GlobVars.paused = true
	for i in $PanelContainer/MarginContainer/VBoxContainer.get_children():
		i.mouse_filter = MOUSE_FILTER_STOP
	$AnimationPlayer.play("blur")

func pause():
	get_tree().paused = true
	show_screen()
	
func _on_resume_pressed():
	if GlobVars.STATE_PLAYING:
		resume()
	else:
		remove_screen()

func _on_restart_pressed():
	resume()
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	resume()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
