class_name Coin
extends Node2D

var texture: Texture2D
var pulse: Tween
var collected := false


func _ready() -> void:
	var path := "res://art/coin.png"
	if ResourceLoader.exists(path):
		texture = load(path)
	get_tree().create_timer(randf() * 0.8).timeout.connect(_start_pulse)


func _start_pulse() -> void:
	if collected:
		return
	pulse = create_tween().set_loops()
	pulse.tween_property(self, "scale", Vector2(1.18, 1.18), 0.5).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)


func _draw() -> void:
	draw_circle(Vector2(0, 11), 7.0, Color(0, 0, 0, 0.25))
	if texture != null:
		var size := texture.get_size() * Entity.TEXTURE_SCALE
		draw_texture_rect(texture, Rect2(-size / 2.0, size), false)
		return
	draw_circle(Vector2.ZERO, 10.0, Palette.GOLD_DARK)
	draw_circle(Vector2.ZERO, 8.0, Palette.GOLD)
	draw_rect(Rect2(-1, -5, 2, 10), Palette.GOLD_DARK)
	draw_rect(Rect2(-5, -5, 2, 2), Palette.GOLD_LIGHT)


func collect(points: int) -> void:
	collected = true
	var parent := get_parent()
	for i in 6:
		var spark := ColorRect.new()
		spark.size = Vector2(4, 4)
		spark.color = Palette.GOLD_LIGHT
		spark.position = position - Vector2(2, 2)
		parent.add_child(spark)
		var dir := Vector2.from_angle(TAU * i / 6.0 + randf() * 0.5)
		var st := spark.create_tween().set_parallel(true)
		st.tween_property(spark, "position", spark.position + dir * 26.0, 0.3).set_ease(Tween.EASE_OUT)
		st.tween_property(spark, "modulate:a", 0.0, 0.3)
		st.chain().tween_callback(spark.queue_free)

	var label := Label.new()
	label.text = "+%d" % points
	label.position = position + Vector2(-16, -34)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Palette.GOLD_LIGHT)
	label.add_theme_color_override("font_outline_color", Palette.INK)
	label.add_theme_constant_override("outline_size", 5)
	parent.add_child(label)
	var lt := label.create_tween().set_parallel(true)
	lt.tween_property(label, "position:y", label.position.y - 26.0, 0.7)
	lt.tween_property(label, "modulate:a", 0.0, 0.7).set_delay(0.3)
	lt.chain().tween_callback(label.queue_free)

	if pulse != null:
		pulse.kill()
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "scale", Vector2(2.0, 2.0), 0.18)
	t.tween_property(self, "modulate:a", 0.0, 0.18)
	t.chain().tween_callback(queue_free)
