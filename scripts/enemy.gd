extends CharacterBody2D

@onready var walk_timer = $WalkTimer
@onready var idle_timer = $IdleTimer

const SPEED = 120.0

var player_chase = false
var random_walk = false
var random_walk_dir = Vector2.ZERO
var player = null
var question = null
var enemy_name = "Mx. Slime"
var difficulty
var subject

var alive = true

func _ready():
	idle_timer.one_shot = true
	walk_timer.one_shot = true

	idle_timer.wait_time = get_random_time(2, 4)
	idle_timer.start()

	walk_timer.timeout.connect(stop_walking)
	idle_timer.timeout.connect(start_walking)

func _physics_process(delta):
	if !alive:
		return

	if player_chase:
		velocity = (player.position - position).normalized() * SPEED
		$AnimatedSprite2D.play("walk")
		
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true
	else:
		if random_walk:
			velocity = random_walk_dir * SPEED/4
			
			$AnimatedSprite2D.play("walk")
			if velocity.x > 0:
				$AnimatedSprite2D.flip_h = false
			else:
				$AnimatedSprite2D.flip_h = true
		else:
			velocity = Vector2.ZERO
			$AnimatedSprite2D.play("idle")

	move_and_slide()

func get_random_dir():
	var rand_gen = RandomNumberGenerator.new()
	rand_gen.randomize()
	var random_x = rand_gen.randf_range(-1, 1)
	var random_y = rand_gen.randf_range(-1, 1)
	random_walk_dir = Vector2(random_x, random_y).normalized()


func get_random_time(mini, maxi):
	var rand_gen = RandomNumberGenerator.new()
	rand_gen.randomize()
	return rand_gen.randf_range(mini, maxi)

func start_walking():
	get_random_dir()
	random_walk = true
	walk_timer.wait_time = get_random_time(1, 3)
	walk_timer.start()


func stop_walking():
	random_walk_dir = Vector2.ZERO
	random_walk = false
	idle_timer.wait_time = get_random_time(2, 4)
	idle_timer.start()

func die():
	# Animate death
	$AnimatedSprite2D.play("death")
	# Stop moving
	alive = false
	$CollisionShape2D.queue_free()


func _on_detection_area_body_entered(body):
	if !alive or GlobVars.state == GlobVars.STATE_GAME_OVER or GlobVars.state == GlobVars.STATE_COMPLETED:
		return

	player = body
	player_chase = true


func _on_detection_area_body_exited(body):
	if !alive or GlobVars.state == GlobVars.STATE_GAME_OVER or GlobVars.state == GlobVars.STATE_COMPLETED:
		return

	player = null
	player_chase = false


func _on_interact_area_body_entered(body):
	if !alive or GlobVars.state == GlobVars.STATE_GAME_OVER or GlobVars.state == GlobVars.STATE_COMPLETED:
		return

	if body != null and body == player:
		ask_random()
		GlobVars.state = GlobVars.STATE_ASKING


func ask_random():
	randomize()
	var random_question = (randi() % 5)
	GlobVars.question = "res://sprites/questions/algebra/easy/" + str(random_question+1) + "/"
	GlobVars.choices.shuffle()
	GlobVars.correct_answer = GlobVars.ALGEBRA_EASY[random_question]
	GlobVars.asker = self

func _on_interact_area_body_exited(body):
	pass
