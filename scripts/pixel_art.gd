class_name PixelArt
extends RefCounted

const PIXEL_SIZE := 4.0

const PLAYER: Array = [
	"..hhhh..",
	".hhhhhh.",
	".hssssh.",
	".mwmmwm.",
	".hssssh.",
	"..bbbb..",
	".bbbbbb.",
	"sbbbbbbs",
	".bbgggb.",
	"..l..l..",
]
const PLAYER_COLORS := {
	"h": Color("3f6b4a"),
	"s": Color("d9a67a"),
	"m": Color("15130f"),
	"w": Color("f4f0e6"),
	"b": Color("558f60"),
	"g": Color("d8a73f"),
	"l": Color("22301f"),
}

const GUARD: Array = [
	"..cccc..",
	".cccccc.",
	"vvvvvvvv",
	".ssssss.",
	".sesses.",
	"..uuuu..",
	".uuuyuu.",
	"suuuuuus",
	".ubbbbu.",
	"..k..k..",
]
const GUARD_COLORS := {
	"c": Color("2b3a55"),
	"v": Color("15130f"),
	"s": Color("d9a67a"),
	"e": Color("15130f"),
	"u": Color("5b6b8a"),
	"y": Color("d8a73f"),
	"b": Color("15130f"),
	"k": Color("15130f"),
}

const HUNTER_COLORS := {
	"c": Color("5a2a2a"),
	"v": Color("15130f"),
	"s": Color("d9a67a"),
	"e": Color("15130f"),
	"u": Color("7a4a42"),
	"y": Color("d8a73f"),
	"b": Color("15130f"),
	"k": Color("15130f"),
}


static func draw(canvas: CanvasItem, rows: Array, palette: Dictionary) -> void:
	var width: int = rows[0].length()
	var origin := Vector2(-width * PIXEL_SIZE / 2.0, -rows.size() * PIXEL_SIZE)
	for y in rows.size():
		for x in width:
			var ch: String = rows[y][x]
			if ch == "." or not palette.has(ch):
				continue
			canvas.draw_rect(Rect2(origin + Vector2(x, y) * PIXEL_SIZE, Vector2(PIXEL_SIZE, PIXEL_SIZE)), palette[ch])
