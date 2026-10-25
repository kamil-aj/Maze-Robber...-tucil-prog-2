class_name Guard
extends Entity

enum Mode { PATROL, CHASE, SEARCH }

const SEARCH_TIME := 2.0
const REPATH_TIME := 0.25
const CATCH_DISTANCE := 24.0

var mode: Mode = Mode.PATROL
var path: PackedVector2Array = PackedVector2Array()
var patrol_speed: float = 80.0
var chase_speed: float = 120.0
var speed_mult: float = 1.0
var sight_range: float = 240.0
var sees_player: bool = false
var last_seen: Vector2 = Vector2.ZERO
var wait_timer: float = 0.0
var repath_timer: float = 0.0


func _init() -> void:
	sprite_name = "guard"
	art_rows = PixelArt.GUARD
	art_palette = PixelArt.GUARD_COLORS


func apply_level(level: Dictionary) -> void:
	speed_mult = level["guard_speed"]
	sight_range = level["sight"]


func _process(delta: float) -> void:
	if world.state != GameWorld.State.PLAYING or world.player == null:
		return
	_look()
	_think(delta)
	_move(delta)
	if not world.in_grace() and position.distance_to(world.player.position) < CATCH_DISTANCE:
		world.player_caught(self)
	queue_redraw()


func _look() -> void:
	var view_distance := sight_range * world.player.visibility
	sees_player = not world.in_grace() and world.has_line_of_sight(position, world.player.position, view_distance)
	if sees_player:
		last_seen = world.player.position
		if mode != Mode.CHASE:
			_start_chase()
	elif mode == Mode.CHASE:
		mode = Mode.SEARCH
		wait_timer = SEARCH_TIME
		path = world.find_path(position, last_seen)


func _start_chase() -> void:
	mode = Mode.CHASE
	repath_timer = 0.0
	if world.level["alert"]:
		world.alert_guards(self, world.player.position)


func investigate(where: Vector2) -> void:
	if mode != Mode.PATROL:
		return
	mode = Mode.SEARCH
	last_seen = where
	wait_timer = SEARCH_TIME
	path = world.find_path(position, where)


func _think(delta: float) -> void:
	repath_timer -= delta
	match mode:
		Mode.CHASE:
			speed = chase_speed * speed_mult
			if repath_timer <= 0.0:
				path = world.find_path(position, _chase_target())
				repath_timer = REPATH_TIME
		Mode.SEARCH:
			speed = patrol_speed * 1.3 * speed_mult
			if path.is_empty():
				wait_timer -= delta
				if wait_timer <= 0.0:
					mode = Mode.PATROL
					wait_timer = 0.0
		Mode.PATROL:
			speed = patrol_speed * speed_mult
			if path.is_empty():
				wait_timer -= delta
				if wait_timer <= 0.0:
					path = world.find_path(position, world.random_floor_position())
					wait_timer = randf_range(0.3, 1.2)


func _chase_target() -> Vector2:
	return world.player.position


func _move(delta: float) -> void:
	var before := position
	var to_player := world.player.position - position
	if mode == Mode.CHASE and sees_player and to_player.length() < GameWorld.TILE * 1.2:
		try_move(to_player.normalized() * speed * delta)
	else:
		_follow_path(delta)
	var moved := position - before
	moving = moved.length() > 0.01
	if moving:
		facing = moved.normalized()


func _follow_path(delta: float) -> void:
	if path.is_empty():
		return
	var target := path[0]
	var step := speed * delta
	if position.distance_to(target) <= step:
		position = target
		path.remove_at(0)
	else:
		position += (target - position).normalized() * step


func get_label() -> String:
	return "Guard"
