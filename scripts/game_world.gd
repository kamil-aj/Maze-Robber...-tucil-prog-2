class_name GameWorld
extends Node2D

enum State { MENU, PLAYING, PAUSED, CLEARED, LOST, VICTORY }

const TILE := 48
const COIN_VALUE := 100
const TIME_BONUS_PER_SEC := 5
const GRACE_TIME := 1.5
const ALERT_RADIUS := 288.0
const PICKUP_DISTANCE := 24.0
const EXIT_DISTANCE := 22.0

var state: State = State.MENU

var level_index := 0
var level: Dictionary = {}
var rows: Array = []
var cols := 0
var astar := AStarGrid2D.new()
var floor_cells: Array[Vector2i] = []
var player_start := Vector2.ZERO
var guard_starts: Array[Dictionary] = []
var coin_starts: Array[Vector2] = []
var exit_pos := Vector2.ZERO
var exit_open := false

var player: Player
var guards: Array[Guard] = []
var coins: Array[Coin] = []
var walls_root: Node2D
var entity_root: Node2D
var hud: HUD

var score := 0
var level_start_score := 0
var run_time := 0.0
var level_time := 0.0
var grace_left := 0.0
var last_bonus := 0
var caught_by := ""


static func guard_types() -> Dictionary:
	return {"G": Guard, "H": Hunter}


func _ready() -> void:
	randomize()
	for problem in Levels.validate_all():
		push_warning("Level problem: " + problem)
	walls_root = Node2D.new()
	add_child(walls_root)
	entity_root = Node2D.new()
	add_child(entity_root)
	hud = HUD.new()
	add_child(hud)
	hud.setup(self)
	_setup_level(0)
	go_menu()


func _setup_level(index: int, data: Dictionary = {}) -> void:
	level_index = clampi(index, 0, Levels.count() - 1)
	level = Levels.get_level(level_index)
	_parse_map()
	_spawn_entities(data)
	queue_redraw()


func _parse_map() -> void:
	rows = level["map"]
	cols = 0
	for r in rows:
		cols = maxi(cols, r.length())

	for n in walls_root.get_children():
		walls_root.remove_child(n)
		n.queue_free()
	floor_cells.clear()
	guard_starts.clear()
	coin_starts.clear()
	player_start = Vector2.ZERO
	exit_pos = Vector2.ZERO

	astar = AStarGrid2D.new()
	astar.region = Rect2i(0, 0, cols, rows.size())
	astar.cell_size = Vector2(TILE, TILE)
	astar.offset = Vector2(TILE, TILE) / 2.0
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()

	var found_player := false
	for y in rows.size():
		for x in cols:
			var c := Vector2i(x, y)
			var ch := tile_at(c)
			if ch == "#":
				astar.set_point_solid(c, true)
				_make_wall_body(c)
				continue
			floor_cells.append(c)
			var pos := cell_center(c)
			if guard_types().has(ch):
				guard_starts.append({"pos": pos, "kind": ch})
			match ch:
				"P":
					player_start = pos
					found_player = true
				"C": coin_starts.append(pos)
				"E": exit_pos = pos
	if not found_player and not floor_cells.is_empty():
		player_start = cell_center(floor_cells[0])


func _make_wall_body(c: Vector2i) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(TILE, TILE)
	shape.shape = rect
	body.add_child(shape)
	body.position = cell_center(c)
	walls_root.add_child(body)


func _spawn_entities(data: Dictionary) -> void:
	for n in entity_root.get_children():
		entity_root.remove_child(n)
		n.queue_free()
	guards.clear()
	coins.clear()
	player = null

	var coin_positions: Array = coin_starts.duplicate()
	var player_pos := player_start
	var guard_positions: Array = []
	for g in guard_starts:
		guard_positions.append(g["pos"])

	if not data.is_empty():
		player_pos = Vector2(data["player"][0], data["player"][1])
		coin_positions = []
		for c in data["coins"]:
			coin_positions.append(Vector2(c[0], c[1]))
		for i in mini(guard_positions.size(), data["guards"].size()):
			guard_positions[i] = Vector2(data["guards"][i][0], data["guards"][i][1])

	for cp in coin_positions:
		var coin := Coin.new()
		coin.position = cp
		entity_root.add_child(coin)
		coins.append(coin)

	for i in guard_starts.size():
		var g: Guard = guard_types()[guard_starts[i]["kind"]].new()
		g.world = self
		g.apply_level(level)
		g.position = guard_positions[i]
		entity_root.add_child(g)
		guards.append(g)

	player = Player.new()
	player.world = self
	player.position = player_pos
	entity_root.add_child(player)

	exit_open = coins.is_empty()


func _draw() -> void:
	for y in rows.size():
		for x in cols:
			var c := Vector2i(x, y)
			if tile_at(c) != "#":
				_draw_floor(c)
	for y in rows.size():
		for x in cols:
			var c := Vector2i(x, y)
			if tile_at(c) == "#":
				_draw_wall(c)
	if exit_pos != Vector2.ZERO:
		_draw_exit()


func _draw_floor(c: Vector2i) -> void:
	var r := Rect2(c.x * TILE, c.y * TILE, TILE, TILE)
	var base := Palette.FLOOR_A if (c.x + c.y) % 2 == 0 else Palette.FLOOR_B
	draw_rect(r, base.lightened(float((c.x * 7 + c.y * 13) % 4) * 0.012))
	draw_rect(r, Palette.FLOOR_GROUT, false, 1.0)
	for i in 2:
		var sx := (c.x * 37 + c.y * 11 + i * 23) % 38 + 4
		var sy := (c.x * 17 + c.y * 29 + i * 31) % 38 + 4
		draw_rect(Rect2(r.position + Vector2(sx, sy), Vector2(3, 2)), Palette.FLOOR_GROUT)
	if tile_at(c + Vector2i.UP) == "#":
		draw_rect(Rect2(r.position, Vector2(TILE, 7)), Color(0, 0, 0, 0.25))


func _draw_wall(c: Vector2i) -> void:
	var x := float(c.x * TILE)
	var y := float(c.y * TILE)
	var open_below := tile_at(c + Vector2i.DOWN) != "#"
	var front := 14.0 if open_below else 0.0
	draw_rect(Rect2(x, y, TILE, TILE - front), Palette.WALL_TOP)
	if tile_at(c + Vector2i.UP) != "#":
		draw_rect(Rect2(x, y, TILE, 3), Palette.WALL_LIGHT)
	if tile_at(c + Vector2i.LEFT) != "#":
		draw_rect(Rect2(x, y, 2, TILE - front), Palette.WALL_EDGE)
	if tile_at(c + Vector2i.RIGHT) != "#":
		draw_rect(Rect2(x + TILE - 2, y, 2, TILE - front), Palette.WALL_EDGE)
	if open_below:
		draw_rect(Rect2(x, y + TILE - front, TILE, front), Palette.WALL_FRONT)
		draw_rect(Rect2(x, y + TILE - front, TILE, 2), Palette.WALL_EDGE)
		var shift := 0.0 if c.x % 2 == 0 else 8.0
		for jx in [8.0, 32.0]:
			draw_rect(Rect2(x + jx + shift, y + TILE - front + 2, 2, front - 2), Palette.WALL_EDGE)


func _draw_exit() -> void:
	var r := Rect2(exit_pos - Vector2(16, 20), Vector2(32, 40))
	draw_rect(r.grow(3), Palette.WALL_EDGE)
	draw_rect(r, Palette.DOOR_OPEN if exit_open else Palette.DOOR_LOCKED)
	draw_rect(Rect2(r.position.x + 5, r.position.y + 5, 22, 3), Palette.INK)
	var font := ThemeDB.fallback_font
	draw_string(font, exit_pos + Vector2(-12, 12), "EXIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Palette.TEXT)


func tile_at(c: Vector2i) -> String:
	if c.y < 0 or c.y >= rows.size():
		return "#"
	var row: String = rows[c.y]
	if c.x < 0 or c.x >= row.length():
		return "#"
	return row[c.x]


func cell_center(c: Vector2i) -> Vector2:
	return Vector2(c.x * TILE + TILE / 2.0, c.y * TILE + TILE / 2.0)


func pixel_to_cell(p: Vector2) -> Vector2i:
	return Vector2i(clampi(int(p.x / TILE), 0, cols - 1), clampi(int(p.y / TILE), 0, rows.size() - 1))


func is_wall_pixel(p: Vector2) -> bool:
	return tile_at(pixel_to_cell(p)) == "#"


func can_stand(pos: Vector2, r: float) -> bool:
	var k := r - 1.0
	for off in [Vector2(-k, -k), Vector2(k, -k), Vector2(-k, k), Vector2(k, k)]:
		if is_wall_pixel(pos + off):
			return false
	return true


func has_line_of_sight(from: Vector2, to: Vector2, max_range: float) -> bool:
	if from.distance_to(to) > max_range:
		return false
	var query := PhysicsRayQueryParameters2D.create(from, to)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	return hit.is_empty()


func find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var path := astar.get_point_path(pixel_to_cell(from), pixel_to_cell(to))
	if path.size() > 1 and (path[1] - path[0]).dot(from - path[0]) > 0.0:
		path.remove_at(0)
	return path


func random_floor_position() -> Vector2:
	return cell_center(floor_cells[randi() % floor_cells.size()])


func coins_total() -> int:
	return coin_starts.size()


func in_grace() -> bool:
	return grace_left > 0.0


func alert_guards(source: Guard, where: Vector2) -> void:
	for g in guards:
		if g != source and g.position.distance_to(source.position) < ALERT_RADIUS:
			g.investigate(where)


func _process(delta: float) -> void:
	if state != State.PLAYING:
		return
	run_time += delta
	level_time += delta
	grace_left = maxf(0.0, grace_left - delta)

	for c in coins.duplicate():
		var coin: Coin = c
		if player.position.distance_to(coin.position) < PICKUP_DISTANCE:
			_collect(coin)

	if exit_open and (exit_pos == Vector2.ZERO or player.position.distance_to(exit_pos) < EXIT_DISTANCE):
		_clear_level()
	hud.update_stats()


func _collect(coin: Coin) -> void:
	coins.erase(coin)
	coin.collect(COIN_VALUE)
	score += COIN_VALUE
	player.blink(2, 0.06)
	if coins.is_empty():
		exit_open = true
		queue_redraw()
		hud.toast("All loot taken. Get to the exit!")


func _clear_level() -> void:
	last_bonus = maxi(0, int(level["par_time"] - level_time)) * TIME_BONUS_PER_SEC
	score += last_bonus
	if level_index >= Levels.count() - 1:
		state = State.VICTORY
		hud.show_victory()
	else:
		state = State.CLEARED
		hud.show_cleared()


func player_caught(by: Guard) -> void:
	if state != State.PLAYING or in_grace():
		return
	state = State.LOST
	caught_by = by.get_label()
	hud.show_lost()


func load_level(index: int) -> void:
	_setup_level(index)
	level_start_score = score
	level_time = 0.0
	_begin_play()
	hud.toast("Level %d" % (level_index + 1))
	var tip: String = level["tip"]
	var idx := level_index
	get_tree().create_timer(2.4).timeout.connect(func():
		if state == State.PLAYING and level_index == idx:
			hud.toast(tip, 3.5))


func _begin_play() -> void:
	grace_left = GRACE_TIME
	player.blink(4, 0.18)
	state = State.PLAYING
	hud.hide_panel()
	hud.update_stats()


func start_new_game() -> void:
	score = 0
	run_time = 0.0
	load_level(0)


func restart_level() -> void:
	score = level_start_score
	load_level(level_index)


func next_level() -> void:
	load_level(level_index + 1)


func go_menu() -> void:
	state = State.MENU
	hud.show_menu()


func resume() -> void:
	state = State.PLAYING
	hud.hide_panel()


func save_game() -> void:
	if state != State.PLAYING and state != State.PAUSED:
		return
	var data := {
		"level": level_index,
		"player": [player.position.x, player.position.y],
		"guards": guards.map(func(g): return [g.position.x, g.position.y]),
		"coins": coins.map(func(c): return [c.position.x, c.position.y]),
		"score": score,
		"level_start_score": level_start_score,
		"run_time": run_time,
		"level_time": level_time,
	}
	hud.toast("Game saved" if SaveManager.save(data) else "Could not save the game")


func load_game() -> void:
	var data := SaveManager.load_data()
	if not SaveManager.is_valid(data):
		hud.toast("No usable save file found")
		return
	_setup_level(int(data["level"]), data)
	score = int(data["score"])
	level_start_score = int(data["level_start_score"])
	run_time = float(data["run_time"])
	level_time = float(data["level_time"])
	_begin_play()
	hud.toast("Game loaded")


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_ESCAPE, KEY_P:
			if state == State.PLAYING:
				state = State.PAUSED
				hud.show_pause()
			elif state == State.PAUSED:
				resume()
		KEY_F5:
			save_game()
		KEY_F9:
			if state != State.MENU:
				load_game()
