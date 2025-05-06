extends Control

func _ready():
	remove_screen()
	$PanelContainer/MarginContainer/VBoxContainer/AnimatedSprite2D.play("yay")
	$AnimationPlayer.play("RESET")

func remove_screen():
	$WinnerMusic.stop()
	for i in $PanelContainer/MarginContainer/VBoxContainer.get_children():
		if i.has_method("mouse_filter"):
			i.mouse_filter = MOUSE_FILTER_IGNORE
	$AnimationPlayer.play_backwards("blur")

func show_screen():
	$WinnerMusic.play()
	for i in $PanelContainer/MarginContainer/VBoxContainer.get_children():
		if i.has_method("mouse_filter"):
			i.mouse_filter = MOUSE_FILTER_STOP
	$AnimationPlayer.play("blur")

func _on_restart_pressed():
	remove_screen()
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	remove_screen()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
