class_name HUD
extends CanvasLayer

var world: GameWorld
var root: Control
var level_label: Label
var loot_label: Label
var score_label: Label
var time_label: Label
var toast_panel: PanelContainer
var toast_label: Label
var toast_tween: Tween
var dim: ColorRect
var center: CenterContainer
var box: VBoxContainer


func setup(w: GameWorld) -> void:
	world = w
	root = Control.new()
	root.theme = GameTheme.build()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_vignette()
	_build_top_bar()
	_build_bottom_bar()
	_build_toast()
	_build_modal()


func _build_vignette() -> void:
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	grad.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 0.5)])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 256
	tex.height = 256
	var v := TextureRect.new()
	v.texture = tex
	v.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	v.stretch_mode = TextureRect.STRETCH_SCALE
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(v)
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _strip() -> PanelContainer:
	var p := PanelContainer.new()
	var style := GameTheme.box(Palette.INK, Palette.INK, 0, 0)
	style.content_margin_left = 20
	style.content_margin_right = 20
	p.add_theme_stylebox_override("panel", style)
	p.custom_minimum_size = Vector2(0, GameWorld.TILE)
	return p


func _build_top_bar() -> void:
	var bar := _strip()
	root.add_child(bar)
	bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	var row := HBoxContainer.new()
	bar.add_child(row)
	level_label = _bar_label(row, HORIZONTAL_ALIGNMENT_LEFT)
	loot_label = _bar_label(row, HORIZONTAL_ALIGNMENT_CENTER)
	score_label = _bar_label(row, HORIZONTAL_ALIGNMENT_CENTER)
	time_label = _bar_label(row, HORIZONTAL_ALIGNMENT_RIGHT)


func _bar_label(parent: Control, align: HorizontalAlignment) -> Label:
	var l := Label.new()
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(l)
	return l


func _build_bottom_bar() -> void:
	var bar := _strip()
	root.add_child(bar)
	bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -GameWorld.TILE
	bar.offset_bottom = 0
	var hint := Label.new()
	hint.text = "WASD / Arrows: move     Shift: sneak     Esc: pause     F5: save     F9: load"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Palette.TEXT_DIM)
	bar.add_child(hint)


func _build_toast() -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(row)
	row.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	row.offset_top = GameWorld.TILE + 12
	row.offset_bottom = GameWorld.TILE + 56
	toast_panel = PanelContainer.new()
	toast_panel.add_theme_stylebox_override("panel", GameTheme.box(Palette.PANEL, Palette.GOLD_DARK, 2, 10))
	toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_panel.modulate.a = 0.0
	row.add_child(toast_panel)
	toast_label = Label.new()
	toast_panel.add_child(toast_label)


func _build_modal() -> void:
	dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	root.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	center = CenterContainer.new()
	root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 0)
	center.add_child(panel)

	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)


func update_stats() -> void:
	var got := world.coins_total() - world.coins.size()
	level_label.text = "LEVEL %d/%d" % [world.level_index + 1, Levels.count()]
	if world.exit_open:
		loot_label.text = "GO TO THE EXIT"
		loot_label.add_theme_color_override("font_color", Palette.GOLD_LIGHT)
	else:
		loot_label.text = "LOOT %d/%d" % [got, world.coins_total()]
		loot_label.remove_theme_color_override("font_color")
	score_label.text = "SCORE %d" % world.score
	time_label.text = "TIME " + _fmt_time(world.level_time)


func _fmt_time(t: float) -> String:
	return "%d:%04.1f" % [floori(t / 60.0), fmod(t, 60.0)]


func toast(msg: String, seconds: float = 1.8) -> void:
	if toast_tween != null:
		toast_tween.kill()
	toast_label.text = msg
	toast_panel.modulate.a = 0.0
	toast_tween = create_tween()
	toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.15)
	toast_tween.tween_interval(seconds)
	toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.4)


func hide_panel() -> void:
	dim.visible = false
	center.visible = false


func _show_panel() -> void:
	dim.visible = true
	center.visible = true
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


func _title(text: String, size: int = 32) -> void:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Palette.GOLD)
	box.add_child(l)
	var rule := ColorRect.new()
	rule.color = Palette.GOLD_DARK
	rule.custom_minimum_size = Vector2(0, 3)
	box.add_child(rule)


func _text(text: String, color: Color = Palette.TEXT, size: int = 18) -> void:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	box.add_child(l)


func _gap(h: float = 6.0) -> void:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, h)
	box.add_child(s)


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 42)
	b.pressed.connect(cb)
	box.add_child(b)
	return b


func show_menu() -> void:
	_show_panel()
	_title("MAZE ROBBER", 40)
	_text("Grab the loot. Reach the exit.", Palette.TEXT_DIM, 16)
	_gap()
	var first := _button("New Game", world.start_new_game)
	var cont := _button("Continue", world.load_game)
	cont.disabled = not SaveManager.has_save()
	_button("How to Play", show_help)
	_button("Quit", func(): get_tree().quit())
	first.grab_focus()


func show_help() -> void:
	_show_panel()
	_title("HOW TO PLAY", 30)
	_text("Collect every coin, then walk through the exit door.")
	_text("Guards see you only when nothing blocks the line between you. Break line of sight to lose them.", Palette.TEXT)
	_text("Hold Shift to sneak: slower, but guards must be much closer to spot you.", Palette.TEXT)
	_text("Hunters (the red guards) don't just follow you. They run ahead to cut you off.", Palette.TEXT)
	_gap()
	var back := _button("Back", world.go_menu)
	back.grab_focus()


func show_pause() -> void:
	_show_panel()
	_title("PAUSED")
	var first := _button("Resume", world.resume)
	_button("Save Game  (F5)", world.save_game)
	_button("Main Menu", world.go_menu)
	first.grab_focus()


func show_cleared() -> void:
	_show_panel()
	_title("LEVEL CLEARED")
	var loot := world.score - world.level_start_score - world.last_bonus
	_text("Loot   +%d" % loot)
	_text("Time bonus   +%d" % world.last_bonus)
	_text("Score   %d" % world.score, Palette.GOLD_LIGHT, 22)
	_gap()
	var first := _button("Next Level", world.next_level)
	_button("Main Menu", world.go_menu)
	first.grab_focus()


func show_lost() -> void:
	_show_panel()
	_title("BUSTED")
	_text("You were caught by a %s." % world.caught_by.to_lower())
	_gap()
	var first := _button("Try Again", world.restart_level)
	_button("Main Menu", world.go_menu)
	first.grab_focus()


func show_victory() -> void:
	_show_panel()
	_title("YOU WIN")
	_text("You cleared all five levels.")
	_text("Final score   %d" % world.score, Palette.GOLD_LIGHT, 22)
	_text("Total time   " + _fmt_time(world.run_time))
	_gap()
	var first := _button("Play Again", world.start_new_game)
	_button("Main Menu", world.go_menu)
	first.grab_focus()
