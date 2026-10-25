class_name GameTheme
extends RefCounted


static func build() -> Theme:
	var t := Theme.new()
	t.default_font_size = 18
	t.set_color("font_color", "Label", Palette.TEXT)

	t.set_stylebox("panel", "PanelContainer", box(Palette.PANEL, Palette.PANEL_EDGE, 3, 24))

	t.set_stylebox("normal", "Button", box(Palette.BUTTON, Palette.PANEL_EDGE, 2, 10))
	t.set_stylebox("hover", "Button", box(Palette.BUTTON_HOVER, Palette.TEXT_DIM, 2, 10))
	t.set_stylebox("pressed", "Button", box(Palette.INK, Palette.GOLD, 2, 10))
	t.set_stylebox("disabled", "Button", box(Palette.PANEL, Palette.BUTTON, 2, 10))
	var focus := box(Color(0, 0, 0, 0), Palette.GOLD, 2, 10)
	focus.draw_center = false
	t.set_stylebox("focus", "Button", focus)

	t.set_color("font_color", "Button", Palette.TEXT)
	t.set_color("font_hover_color", "Button", Palette.TEXT)
	t.set_color("font_focus_color", "Button", Palette.TEXT)
	t.set_color("font_pressed_color", "Button", Palette.GOLD_LIGHT)
	t.set_color("font_disabled_color", "Button", Palette.TEXT_DIM)
	return t


static func box(fill: Color, border: Color, border_width: int, padding: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(border_width)
	s.set_content_margin_all(padding)
	return s
