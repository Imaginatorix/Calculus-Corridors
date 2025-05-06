extends Node2D

var Room = preload("res://scenes/room.tscn")
var Player = preload("res://scenes/player.tscn")
@onready var Map = $TileMapLayer

var tile_size = 16
var num_rooms = 5 + 2 * (GlobVars.currentLevel - 1)
var min_size = 6
var max_size = 11
var cull = -1
var path
var start_room
var player
var playing = false

func _ready():
	GlobVars.state = GlobVars.STATE_PLAYING
	randomize()
	make_rooms()


func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(0, 0)
		var r = Room.instantiate()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$rooms.add_child(r)
	# Wait for rooms to stop moving
	await get_tree().create_timer(1.1).timeout
	# Cull rooms
	var room_positions = []
	for room in $rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.freeze = true
			room_positions.append(room.position)
	await get_tree().process_frame
	# Generate Minimum Spanning Tree
	path = find_mst(room_positions)
	# Assign type of room
	initialize_rooms()
	make_map()

	player = Player.instantiate()
	$entities.add_child(player)
	player.position = start_room.position
	player.start_timer(GlobVars.timeLimit)
	playing = true
	$Camera2D.enabled = false
	GlobVars.player = player


func _draw():
	if !playing:
		for room in $rooms.get_children():
			draw_rect(Rect2(room.position - room.size, room.size * 2), Color(32, 228, 0), false)
		#if path:
			#for p in path.get_point_ids():
				#for c in path.get_point_connections(p):
					#var pp = path.get_point_position(p)
					#var cp = path.get_point_position(c)
					#draw_line(pp, cp, Color(1, 1, 0), 4, true)


func _process(delta):
	queue_redraw()


func _input(event):
	if event.is_action_pressed("ui_select"):
		get_tree().reload_current_scene()
		#Map.clear()
		#playing = false
		#$Camera2D.enabled = true
		#for n in $rooms.get_children():
			#n.queue_free()
		#for m in $entities.get_children():
			#m.queue_free()
		#path = null
		#make_rooms()


func find_mst(nodes):
	# Prim's Algorithm
	var path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	# Add all nodes to path
	while nodes:
		var min_dist = INF
		var min_p = null
		var p = null
		
		for p1_id in path.get_point_ids():
			var p1 = path.get_point_position(p1_id)
			for p2 in nodes:
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(min_p)
	
	return path


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

func make_wall(x, y):
	randomize()
	var mode = weighted_random_choice([0, 1], [0.95, 0.05])
	if mode == 0:
		Map.set_cell(Vector2i(x, y), 0, Vector2i(0, 3))
	else:
		Map.set_cell(Vector2i(x, y), 6, Vector2i(0, 3))

func make_floor(x, y):
	randomize()
	var mode = weighted_random_choice([0, 1, 2, 3, 4], [0.05, 0.05, 0.05, 0.05, 2])
	if mode == 0:
		Map.set_cell(Vector2i(x, y), 8, Vector2i(0, 0))
	elif mode == 1:
		Map.set_cell(Vector2i(x, y), 8, Vector2i(1, 0))
	elif mode == 2:
		Map.set_cell(Vector2i(x, y), 9, Vector2i(0, 0))
	elif mode == 3:
		Map.set_cell(Vector2i(x, y), 9, Vector2i(1, 0))
	else:
		Map.set_cell(Vector2i(x, y), 7, Vector2i(0, 0))

func make_map():
	# Fill up with non-walkable tiles
	var full_rect = Rect2()
	for room in $rooms.get_children():
		var r = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
		full_rect = full_rect.merge(r)
	var top_left = Map.local_to_map(full_rect.position)
	var bottom_right = Map.local_to_map(full_rect.end)
	
	var padding = 5
	for x in range(top_left.x - padding, bottom_right.x + padding):
		for y in range(top_left.y - padding, bottom_right.y + padding):
			make_wall(x, y)
	
	# Carve paths
	var corridors = [] # One corridor per connection
	for room in $rooms.get_children():
		var s = (room.size / tile_size).floor()
		var pos = Map.local_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				make_floor(ul.x + x, ul.y + y)

		# Carve connection
		var p = path.get_closest_point(room.position)
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.local_to_map(path.get_point_position(p))
				var end = Map.local_to_map(path.get_point_position(conn))
				carve_path(start, end)
		corridors.append(p)


func carve_path(pos1, pos2):
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	
	if x_diff == 0:
		x_diff = pow(-1, randi() % 2)
	if y_diff == 0:
		y_diff = pow(-1, randi() % 2)
	
	# Choose either x then y or y then x
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		make_floor(x, x_y.y)
		make_floor(x, x_y.y + y_diff)
	for y in range(pos1.y, pos2.y, y_diff):
		make_floor(y_x.x, y)
		make_floor(y_x.x + x_diff, y)


func initialize_rooms():
	var rooms = $rooms.get_children()

	var dist = []
	var index = {}
	
	var i = 0
	for room in rooms:
		index[room.position] = i
		i += 1
		dist.push_back(0)

	# Pick a random room as starting point
	start_room = rooms[randi() % rooms.size()]
	
	# Complete search and assign
	var p_start = path.get_closest_point(start_room.position)
	var frontier = [[p_start]]
	var visited = [p_start]
	var depth = 1
	
	var last_room = null
	while frontier.size() != 0:
		var cur_layer = frontier.pop_front()
		var layer = []
		for p1 in cur_layer:
			last_room = p1

			var all_visited = true
			for p2 in path.get_point_connections(p1):
				if p2 in visited:
					continue
				all_visited = false
				layer.push_back(p2)
				visited.push_back(p2)
				dist[index[path.get_point_position(p2)]] = depth

			if all_visited:
				dist[index[path.get_point_position(p1)]] = -1 # End room is special room (reward or smtg)
			
		if layer.size() != 0:
			frontier.push_back(layer)
			depth += 1

	# Mark lastest room
	dist[index[path.get_point_position(last_room)]] = -2
	
	for n in range(dist.size()):
		rooms[n].depth = dist[n]
		rooms[n].customize($entities)
