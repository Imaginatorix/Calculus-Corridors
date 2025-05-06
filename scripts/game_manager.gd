extends Node2D

@onready var GameOverCanvas = $"../GameOverCanvasLayer"
@onready var GameOverMenu = $"../GameOverCanvasLayer/GameOverMenu"
@onready var PauseCanvas = $"../PauseMenuCanvasLayer"
@onready var PauseMenu = $"../PauseMenuCanvasLayer/PauseMenu"
@onready var QuestionPromptCanvas = $"../QuestionPromptCanvasLayer"
@onready var QuestionPromptMenu = $"../QuestionPromptCanvasLayer/QuestionPrompt"
@onready var WinnerCanvas = $"../WinnerCanvasLayer"
@onready var WinnerMenu = $"../WinnerCanvasLayer/WinnerMenu"

var lastState
var shown_canvas = false

func _ready():
	GlobVars.frozen = false
	GlobVars.enemySpeed = 120
	GlobVars.playerSpeed = 125
	lastState = GlobVars.STATE_PLAYING
	close_canvas()
	$"../AudioStreamPlayer2D".play()

func _process(delta):
	if GlobVars.state == GlobVars.STATE_PLAYING:
		if Input.is_action_just_pressed("esc") and !get_tree().paused:
			PauseMenu.pause()
			show_canvas(lastState)
		elif Input.is_action_just_pressed("esc") and get_tree().paused:
			close_canvas()
			PauseMenu.resume()
		elif Input.is_action_just_pressed("1") and !get_tree().paused:
			for i in range(GlobVars.player.power_ups.size()):
				var power_up = GlobVars.player.power_ups[i]
				if power_up.power_up_name == "freeze":
					power_up.power_up()
					power_up.die()
					GlobVars.player.power_ups.remove_at(i)
					break
		elif Input.is_action_just_pressed("2") and !get_tree().paused:
			for i in range(GlobVars.player.power_ups.size()):
				var power_up = GlobVars.player.power_ups[i]
				if power_up.power_up_name == "add_time":
					power_up.power_up()
					power_up.die()
					GlobVars.player.power_ups.remove_at(i)
					break
		elif Input.is_action_just_pressed("4") and !get_tree().paused:
			for i in range(GlobVars.player.power_ups.size()):
				var power_up = GlobVars.player.power_ups[i]
				if power_up.power_up_name == "remove":
					power_up.power_up()
					power_up.die()
					GlobVars.player.power_ups.remove_at(i)
					break
	elif GlobVars.state == GlobVars.STATE_ASKING:
		if Input.is_action_just_pressed("esc") and !GlobVars.paused:
			close_canvas()
			PauseMenu.show_screen()
		elif Input.is_action_just_pressed("esc") and GlobVars.paused:
			PauseMenu.remove_screen()
			show_canvas(lastState)
		elif Input.is_action_just_pressed("2") and get_tree().paused:
			for i in range(GlobVars.player.power_ups.size()):
				var power_up = GlobVars.player.power_ups[i]
				if power_up.power_up_name == "add_time":
					power_up.power_up()
					power_up.die()
					GlobVars.player.power_ups.remove_at(i)
					break
		elif Input.is_action_just_pressed("3") and get_tree().paused:
			for i in range(GlobVars.player.power_ups.size()):
				var power_up = GlobVars.player.power_ups[i]
				if power_up.power_up_name == "skip":
					power_up.power_up()
					power_up.die()
					GlobVars.player.power_ups.remove_at(i)
					break

	if !GlobVars.paused:
		show_canvas(lastState)

	if lastState == GlobVars.state:
		return
	lastState = GlobVars.state

	close_canvas()
	if GlobVars.state == GlobVars.STATE_GAME_OVER:
		game_over()
	elif GlobVars.state == GlobVars.STATE_ASKING:
		ask()

func ask():
	show_canvas(GlobVars.STATE_ASKING)

func game_over():
	await get_tree().create_timer(1.5).timeout
	show_canvas(GlobVars.STATE_GAME_OVER)

func close_canvas():
	GameOverCanvas.hide()
	QuestionPromptCanvas.hide()
	WinnerCanvas.hide()
	GameOverMenu.remove_screen()
	QuestionPromptMenu.remove_screen()
	WinnerMenu.remove_screen()
	shown_canvas = false
	
func show_canvas(state):
	if !shown_canvas:
		if state == GlobVars.STATE_GAME_OVER:
			GameOverCanvas.show()
			GameOverMenu.show_screen()
			shown_canvas = true
		elif state == GlobVars.STATE_ASKING:
			QuestionPromptCanvas.show()
			QuestionPromptMenu.show_screen()
			shown_canvas = true
		elif state == GlobVars.STATE_COMPLETED:
			$"../AudioStreamPlayer2D".stop()
			WinnerCanvas.show()
			WinnerMenu.show_screen()
			shown_canvas = true
