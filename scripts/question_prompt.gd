extends Control

var choice_map = ["A", "B", "C", "D"]
var choices = GlobVars.choices

func _ready():
	remove_screen()
	$AnimationPlayer.play("RESET")
	$BattleMusic.stop()

func _process(delta):
	$Background/Time.text = GlobVars.timeLeft

func remove_screen():
	$BattleMusic.stop()
	get_tree().paused = false
	for i in $Background.get_children():
		if i.has_method("mouse_filter"):
			i.mouse_filter = MOUSE_FILTER_IGNORE
	$AnimationPlayer.play_backwards("blur")

func show_screen():
	$BattleMusic.play()
	get_tree().paused = true
	render_question()
	GlobVars.state = GlobVars.STATE_ASKING
	for i in $Background.get_children():
		if i.has_method("mouse_filter"):
			i.mouse_filter = MOUSE_FILTER_STOP
	$AnimationPlayer.play("blur")

func render_question():
	var name = {
		"Ma'am Gen": "Genile",
		"Sir Lyndon": "Lyndon",
		"Sir Nicky": "Nicky",
		"Ma'am Ronna": "Ronna"
	}

	$Background/Teacher.text = GlobVars.asker.enemy_name+":"
	$Background/Face.texture = ResourceLoader.load("res://assets/Face/" + name[GlobVars.asker.enemy_name] + ".png")
	$Background/Face.flip_h = true
	$Background/Face.scale = Vector2(5, 5)
	$Background/Question.texture = ResourceLoader.load(GlobVars.question+"Question.png")
	
	$Background/A.icon = ResourceLoader.load(GlobVars.question+choice_map[choices[0]]+".png")
	$Background/B.icon = ResourceLoader.load(GlobVars.question+choice_map[choices[1]]+".png")
	$Background/C.icon = ResourceLoader.load(GlobVars.question+choice_map[choices[2]]+".png")
	$Background/D.icon = ResourceLoader.load(GlobVars.question+choice_map[choices[3]]+".png")

func damage_player():
	GlobVars.player.damage()
	# Blink for damage
	GlobVars.player.get_node("AnimatedSprite2D").modulate = Color(1, 0, 0)
	GlobVars.player.get_node("Camera2D/Heart").modulate = Color(0, 0, 0)
	await get_tree().create_timer(0.25).timeout
	GlobVars.player.get_node("AnimatedSprite2D").modulate = Color(1, 1, 1)
	GlobVars.player.get_node("Camera2D/Heart").modulate = Color(1, 1, 1)
	await get_tree().create_timer(0.25).timeout
	GlobVars.player.get_node("AnimatedSprite2D").modulate = Color(1, 0, 0)
	GlobVars.player.get_node("Camera2D/Heart").modulate = Color(0, 0, 0)
	await get_tree().create_timer(0.25).timeout
	GlobVars.player.get_node("AnimatedSprite2D").modulate = Color(1, 1, 1)
	GlobVars.player.get_node("Camera2D/Heart").modulate = Color(1, 1, 1)

func _on_a_pressed():
	if choices[0] != GlobVars.correct_answer:
		GlobVars.wrong_sound.play()
		damage_player()
	else:
		GlobVars.correct_sound.play()

	GlobVars.asker.die()
	GlobVars.asker = null
	if GlobVars.state == GlobVars.STATE_ASKING:
		GlobVars.state = GlobVars.STATE_PLAYING
	get_tree().paused = false

func _on_b_pressed():
	if choices[1] != GlobVars.correct_answer:
		GlobVars.wrong_sound.play()
		damage_player()
	else:
		GlobVars.correct_sound.play()

	GlobVars.asker.die()
	GlobVars.asker = null
	if GlobVars.state == GlobVars.STATE_ASKING:
		GlobVars.state = GlobVars.STATE_PLAYING
	get_tree().paused = false

func _on_c_pressed():
	if choices[2] != GlobVars.correct_answer:
		GlobVars.wrong_sound.play()
		damage_player()
	else:
		GlobVars.correct_sound.play()

	GlobVars.asker.die()
	GlobVars.asker = null
	if GlobVars.state == GlobVars.STATE_ASKING:
		GlobVars.state = GlobVars.STATE_PLAYING
	get_tree().paused = false

func _on_d_pressed():
	if choices[3] != GlobVars.correct_answer:
		GlobVars.wrong_sound.play()
		damage_player()
	else:
		GlobVars.correct_sound.play()

	GlobVars.asker.die()
	GlobVars.asker = null
	if GlobVars.state == GlobVars.STATE_ASKING:
		GlobVars.state = GlobVars.STATE_PLAYING
	get_tree().paused = false
