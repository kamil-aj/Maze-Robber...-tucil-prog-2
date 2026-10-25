class_name SaveManager
extends RefCounted

const PATH := "user://savegame.json"
const VERSION := 2
const REQUIRED_KEYS := ["version", "level", "player", "guards", "coins", "score", "level_start_score", "run_time", "level_time"]


static func has_save() -> bool:
	return FileAccess.file_exists(PATH)


static func save(data: Dictionary) -> bool:
	data["version"] = VERSION
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(data, "\t"))
	return true


static func load_data() -> Dictionary:
	if not has_save():
		return {}
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return {}
	var json := JSON.new()
	if json.parse(f.get_as_text()) != OK:
		return {}
	if json.data is Dictionary:
		return json.data
	return {}


static func is_valid(d: Dictionary) -> bool:
	for key in REQUIRED_KEYS:
		if not d.has(key):
			return false
	if int(d["version"]) != VERSION:
		return false
	if not (d["player"] is Array and d["player"].size() == 2):
		return false
	return d["guards"] is Array and d["coins"] is Array


static func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
