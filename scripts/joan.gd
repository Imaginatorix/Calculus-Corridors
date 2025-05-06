extends CharacterBody2D

var SPEED = GlobVars.powerUpSpeed

var player_chase = false
var player = null

var power_up_name = "freeze"

var alive = true

func _ready():
	$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	if !alive:
		return

	SPEED = GlobVars.powerUpSpeed

	if player_chase:
		if (player.position - position).length() <= 30:
			velocity = Vector2(0, 0)
			$AnimatedSprite2D.play("idle")
		else:
			velocity = (player.position - position).normalized() * SPEED
			$AnimatedSprite2D.play("walk")

			if velocity.x > 0:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
		

	move_and_slide()

func die():
	# Animate death
	$AnimatedSprite2D.play("idle")
	$Halo.play("death")
	# Stop moving
	alive = false


func chase_player(body):
	if !player_chase:
		$Interaction.play()
		$Label.hide()
		$CollisionShape2D.queue_free()
		player = body
		player.power_ups.append(self)
		player_chase = true


func power_up():
	$Usage.play()
	var temp = GlobVars.enemySpeed
	GlobVars.enemySpeed = 0
	GlobVars.frozen = true
	await get_tree().create_timer(10).timeout
	GlobVars.enemySpeed = temp
	GlobVars.frozen = false


func _on_detection_area_body_entered(body):
	chase_player(body)


func _on_detection_area_body_exited(body):
	pass
