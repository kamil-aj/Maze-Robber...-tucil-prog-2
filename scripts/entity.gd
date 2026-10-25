class_name Entity
extends Node2D

const FEET_Y := 14.0
const TEXTURE_SCALE := 2.0

var world: GameWorld
var speed: float = 150.0
var radius: float = 13.0
var facing: Vector2 = Vector2.DOWN
var moving: bool = false
var squash: float = 1.0

var sprite_name: String = ""
var art_rows: Array = []
var art_palette: Dictionary = {}
var texture: Texture2D


func _ready() -> void:
	if sprite_name != "":
		var path := "res://art/%s.png" % sprite_name
		if ResourceLoader.exists(path):
			texture = load(path)


func _draw() -> void:
	_draw_shadow()
	var bob := 0.0
	if moving:
		bob = -absf(sin(Time.get_ticks_msec() * 0.015)) * 2.0
	var flip := -1.0 if facing.x < 0.0 else 1.0
	draw_set_transform(Vector2(0, FEET_Y + bob), 0.0, Vector2(flip, squash))
	if texture != null:
		var size := texture.get_size() * TEXTURE_SCALE
		draw_texture_rect(texture, Rect2(Vector2(-size.x / 2.0, -size.y), size), false)
	elif not art_rows.is_empty():
		PixelArt.draw(self, art_rows, art_palette)
	else:
		draw_circle(Vector2(0, -radius), radius, Color.WHITE)
	draw_set_transform(Vector2.ZERO)


func _draw_shadow() -> void:
	var points := PackedVector2Array()
	for i in 12:
		var a := TAU * i / 12.0
		points.append(Vector2(cos(a) * 11.0, FEET_Y - 1.0 + sin(a) * 4.0))
	draw_colored_polygon(points, Color(0, 0, 0, 0.3))


func try_move(offset: Vector2) -> void:
	var p := position
	var nx := Vector2(p.x + offset.x, p.y)
	if world.can_stand(nx, radius):
		p = nx
	var ny := Vector2(p.x, p.y + offset.y)
	if world.can_stand(ny, radius):
		p = ny
	position = p


func get_label() -> String:
	return "Entity"
