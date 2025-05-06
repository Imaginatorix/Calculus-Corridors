extends RigidBody2D

var ENEMY_NICKY = preload("res://scenes/nicky.tscn")
var ENEMY_LYNDON = preload("res://scenes/lyndon.tscn")
var ENEMY_RONNA = preload("res://scenes/ronna.tscn")
var ENEMY_GENILE = preload("res://scenes/genile.tscn")
var POWER_UP_JOAN = preload("res://scenes/joan.tscn")
var POWER_UP_JUMAWAN = preload("res://scenes/jumawan.tscn")
var POWER_UP_DOM = preload("res://scenes/dominic.tscn")
var POWER_UP_NUR = preload("res://scenes/nur.tscn")
var PORTAL = preload("res://scenes/portal.tscn")

var size
var room_type
var depth

func make_room(_pos, _size):
	position = _pos
	size = _size
	var s = RectangleShape2D.new()
	s.custom_solver_bias = 0.75
	s.extents = size
	$CollisionShape2D.shape = s

func weighted_random_choice(items, weights):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var accumulated_weights = []
	var sum = 0.0
	for weight in weights:
		sum += weight
		accumulated_weights.append(sum)
	var random_number = rng.randf_range(0.0, sum)
	var index = accumulated_weights.bsearch(random_number)
	return items[index]


func customize(world):
	if depth == 0:
		room_type = "START"
	elif depth >= 1 and depth < 3:
		room_type = "TEACHER_SHALLOW"
	elif depth >= 3 and depth < 5:
		room_type = "TEACHER_AVERAGE"
	elif depth >= 5:
		room_type = "TEACHER_DEEP"

	#$Label.text = str(depth)
	$Label.position = position-($Label.size/2)
	
	# Spawn enemy in center
	if room_type != "START":
		var enemy
		for i in range(min(1 + randi() % 4, depth)):
			var mode = weighted_random_choice([0, 1, 2, 3], [depth, 2 + depth, max(1, 8 - depth), max(1, 4 - depth)])
			if mode == 0:
				enemy = ENEMY_NICKY.instantiate()
			elif mode == 1:
				enemy = ENEMY_LYNDON.instantiate()
			elif mode == 2:
				enemy = ENEMY_RONNA.instantiate()
			elif mode == 3:
				enemy = ENEMY_GENILE.instantiate()
			
			if room_type == "TEACHER_SHALLOW":
				enemy.difficulty = "easy"
			elif room_type == "TEACHER_AVERAGE":
				enemy.difficulty = "average"
			elif room_type == "TEACHER_DEEP":
				enemy.difficulty = "difficult"

			world.add_child(enemy)
			enemy.position = position + Vector2(pow(-1, randi() % 2)*(randi() % 16), pow(-1, randi() % 2)*(randi() % 16))
	
	if depth == -1:
		var power_up
		var mode = weighted_random_choice([0, 1, 2, 3], [0.25, 0.05, 1, 1])
		if mode == 0:
			power_up = POWER_UP_JOAN.instantiate()
		elif mode == 1:
			power_up = POWER_UP_JUMAWAN.instantiate()
		elif mode == 2:
			power_up = POWER_UP_DOM.instantiate()
		elif mode == 3:
			power_up = POWER_UP_NUR.instantiate()

		world.add_child(power_up)
		power_up.position = position
	
	if depth == -2:
		var portal = PORTAL.instantiate()
		world.add_child(portal)
		portal.position = position
