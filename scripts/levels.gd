class_name Levels
extends RefCounted

const DATA: Array = [
	{
		"tip": "Hold Shift to sneak. Guards can't spot you from as far away.",
		"guard_speed": 0.85, "sight": 210.0, "alert": false, "par_time": 45,
		"map": [
			"####################",
			"#P........#......C.#",
			"#.........#........#",
			"#..C......#........#",
			"#..............##..#",
			"#..##....G.....##..#",
			"#..##.........C....#",
			"#..................#",
			"#.C......##......C.#",
			"#........##........#",
			"#.................E#",
			"####################",
		],
	},
	{
		"tip": "The long hall is a shooting gallery. Duck into the cells.",
		"guard_speed": 0.95, "sight": 225.0, "alert": false, "par_time": 50,
		"map": [
			"####################",
			"#.....#......#.....#",
			"#.....#......#.....#",
			"#..C..#...C..#..C..#",
			"####.#####.#####.###",
			"#P.................#",
			"#.................E#",
			"##.#####.#########.#",
			"#.....#......#...G.#",
			"#.....#......#.....#",
			"#..C..#...C..#..C..#",
			"####################",
		],
	},
	{
		"tip": "Guards now call for backup when they spot you.",
		"guard_speed": 1.0, "sight": 240.0, "alert": true, "par_time": 70,
		"map": [
			"####################",
			"#P.....#......#...C#",
			"#.####.#.####.#.##.#",
			"#.#C...#.#..#...#..#",
			"#.#.####.#..#####..#",
			"#...#....#.G..#C...#",
			"#..C#..####.###....#",
			"#.###..#C.....#.#..#",
			"#......#.####.#....#",
			"#.#####..#..#...##.#",
			"#.C...G..#........E#",
			"####################",
		],
	},
	{
		"tip": "Red guards try to cut you off.",
		"guard_speed": 1.0, "sight": 250.0, "alert": true, "par_time": 70,
		"map": [
			"####################",
			"#P..#.........#...C#",
			"#...#.#######.#....#",
			"#...#.#C...#..#.##.#",
			"#.###.#.#.##..#.#C.#",
			"#.....#.#.....#.#..#",
			"#.#####.#.H######..#",
			"#.#C..#.#......#...#",
			"#.#...#.######.#.###",
			"#.#.###........#...#",
			"#...G..C.#####....E#",
			"####################",
		],
	},
	{
		"tip": "Everything at once. Good luck.",
		"guard_speed": 1.1, "sight": 275.0, "alert": true, "par_time": 80,
		"map": [
			"####################",
			"#P..#...C.#...#...C#",
			"#...#.###.#.#.#.##.#",
			"#.#...#.C...#...#..#",
			"#.#.###.###.#####..#",
			"#.#...#G...H#...C#.#",
			"#.####.####.#.####.#",
			"#...#...H...#......#",
			"#.#.#.#####.######.#",
			"#.#.C.#.G.#.....C#.#",
			"#.#######...###...E#",
			"####################",
		],
	},
]


static func count() -> int:
	return DATA.size()


static func get_level(index: int) -> Dictionary:
	return DATA[clampi(index, 0, DATA.size() - 1)]


static func validate_all() -> Array[String]:
	var problems: Array[String] = []
	for i in DATA.size():
		var lv: Dictionary = DATA[i]
		var label := "Level %d" % (i + 1)
		var map: Array = lv["map"]
		var width: int = map[0].length()
		var players := 0
		var exits := 0
		var allowed := "#.PEC" + "".join(GameWorld.guard_types().keys())
		for y in map.size():
			if map[y].length() != width:
				problems.append("%s: row %d has %d characters, expected %d" % [label, y + 1, map[y].length(), width])
			for ch in map[y]:
				if ch == "P": players += 1
				if ch == "E": exits += 1
				if not allowed.contains(ch):
					problems.append("%s: row %d contains '%s', which is not a known map letter" % [label, y + 1, ch])
		if players != 1:
			problems.append("%s: needs exactly one P, found %d" % [label, players])
		if exits != 1:
			problems.append("%s: needs exactly one E, found %d" % [label, exits])
	return problems
