extends Control

func _on_ready():
	$Label.text = "Level 1"
	$Level.value = GlobVars.currentLevel

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_level_value_changed(value: float):
	$Label.text = "Level " + str(value)
	GlobVars.currentLevel = value
	
