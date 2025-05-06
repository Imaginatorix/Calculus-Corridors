extends Node2D


func _ready():
	$AnimatedSprite2D.play("idle")

func _on_interaction_area_body_entered(body):
	if body == GlobVars.player:
		GlobVars.state = GlobVars.STATE_COMPLETED
