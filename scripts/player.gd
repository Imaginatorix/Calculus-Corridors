extends CharacterBody2D

@onready var timer = $Timer

var MAX_SPEED = GlobVars.playerSpeed
const ACCELERATION = 1500.00
const FRICTION = 100000.00

var input = Vector2.ZERO
var current_direction = "down"

var power_ups = []

var alive = true
var life = 3

func _ready():
	$Camera2D/Heart.play("life_3")
	$AnimatedSprite2D.play("front_idle")

func start_timer(timeLimit):
	timer.timeout.connect(die)
	timer.wait_time = timeLimit
	timer.one_shot = true
	timer.start()

func _physics_process(delta):
	if timer:
		var seconds = int(timer.time_left) % 60
		var minutes = timer.time_left / 60
		var timeLeft = "%02d:%02d" % [minutes, seconds]
		$Camera2D/TimerLabel.text = timeLeft
		GlobVars.timeRem = timer.time_left
		GlobVars.timeLeft = timeLeft

	if !get_tree().paused and alive:
		player_movement(delta)

func damage():
	life -= 1
	if life == 3:
		$Camera2D/Heart.play("life_3")
	elif life == 2:
		$Camera2D/Heart.play("life_2")
	elif life == 1:
		$Camera2D/Heart.play("life_1")
	elif life <= 0:
		die()


func die():
	GlobVars.state = GlobVars.STATE_GAME_OVER
	# Empty life
	$Camera2D/Heart.play("dead")
	# Animate death
	$AnimatedSprite2D.play("death")
	timer.stop()
	# Stop input
	alive = false


func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()

func identify_direction(input):
	if abs(input.x) > abs(input.y):
		if input.x > 0:
			current_direction = "right"
		else:
			current_direction = "left"
	elif abs(input.x) < abs(input.y):
		if input.y > 0:
			current_direction = "down"
		else:
			current_direction = "up"

func play_anim():
	var direction = current_direction
	var anim = $AnimatedSprite2D

	if direction == "right":
		anim.flip_h = false
		if velocity != Vector2.ZERO:
			anim.play("side_walk")
		else:
			anim.play("side_idle")
	if direction == "left":
		anim.flip_h = true
		if velocity != Vector2.ZERO:
			anim.play("side_walk")
		else:
			anim.play("side_idle")
	if direction == "down":
		if velocity != Vector2.ZERO:
			anim.play("front_walk")
		else:
			anim.play("front_idle")
	if direction == "up":
		if velocity != Vector2.ZERO:
			anim.play("back_walk")
		else:
			anim.play("back_idle")

func player_movement(delta):
	input = get_input()
	identify_direction(input)
	play_anim()

	MAX_SPEED = GlobVars.playerSpeed

	if input == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			velocity -= velocity.normalized() * (FRICTION * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * ACCELERATION * delta)
		velocity = velocity.limit_length(MAX_SPEED)

	move_and_slide()
