class_name Player
extends Entity

const WALK_SPEED := 170.0
const SNEAK_SPEED := 85.0
const SNEAK_VISIBILITY := 0.5

var visibility: float = 1.0
var move_dir: Vector2 = Vector2.ZERO
var blink_tween: Tween


func _init() -> void:
	speed = WALK_SPEED
	sprite_name = "player"
	art_rows = PixelArt.PLAYER
	art_palette = PixelArt.PLAYER_COLORS


func _process(delta: float) -> void:
	if world.state != GameWorld.State.PLAYING:
		return
	var dir := Vector2.ZERO
	dir.x = int(_down(KEY_D, KEY_RIGHT)) - int(_down(KEY_A, KEY_LEFT))
	dir.y = int(_down(KEY_S, KEY_DOWN)) - int(_down(KEY_W, KEY_UP))

	var sneaking := Input.is_key_pressed(KEY_SHIFT)
	speed = SNEAK_SPEED if sneaking else WALK_SPEED
	visibility = SNEAK_VISIBILITY if sneaking else 1.0
	squash = 0.88 if sneaking else 1.0

	moving = dir != Vector2.ZERO
	if moving:
		move_dir = dir.normalized()
		facing = move_dir
		try_move(move_dir * speed * delta)
	else:
		move_dir = Vector2.ZERO
	queue_redraw()


func _down(k1: Key, k2: Key) -> bool:
	return Input.is_key_pressed(k1) or Input.is_key_pressed(k2)


func blink(times: int = 3, half_period: float = 0.08) -> void:
	if blink_tween != null:
		blink_tween.kill()
	modulate.a = 1.0
	blink_tween = create_tween()
	for i in times:
		blink_tween.tween_property(self, "modulate:a", 0.25, half_period)
		blink_tween.tween_property(self, "modulate:a", 1.0, half_period)


func get_label() -> String:
	return "Player"
