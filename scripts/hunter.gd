class_name Hunter
extends Guard


func _init() -> void:
	super()
	sprite_name = "hunter"
	art_palette = PixelArt.HUNTER_COLORS
	patrol_speed = 85.0
	chase_speed = 128.0


func _chase_target() -> Vector2:
	var p := world.player
	if p.move_dir == Vector2.ZERO:
		return p.position
	for tiles in [3, 2, 1]:
		var ahead: Vector2 = p.position + p.move_dir * tiles * GameWorld.TILE
		if world.has_line_of_sight(p.position, ahead, 9999.0):
			return ahead
	return p.position


func get_label() -> String:
	return "Hunter"
