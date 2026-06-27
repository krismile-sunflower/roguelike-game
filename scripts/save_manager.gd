extends Node

const SAVE_PATH := "user://savegame.json"

var save_data: Dictionary = {
	"current_level_index": 0,
	"completed_levels": [],
	"hint_count": 0,
	"high_score": 0,
	"has_seen_tutorial": false,
	"has_save_data": false,
}


func _ready() -> void:
	load_save()


func load_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()

	if parsed is Dictionary:
		save_data["current_level_index"] = int(parsed.get("current_level_index", 0))
		save_data["completed_levels"] = parsed.get("completed_levels", [])
		save_data["hint_count"] = int(parsed.get("hint_count", 0))
		save_data["high_score"] = int(parsed.get("high_score", 0))
		save_data["has_seen_tutorial"] = bool(parsed.get("has_seen_tutorial", false))
		save_data["has_save_data"] = bool(parsed.get("has_save_data", true))
		return true

	return false


func save_all() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return

	file.store_string(JSON.stringify(save_data))
	file.close()


func save_progress(level_index: int, completed_levels: Array, hint_count: int, has_seen_tutorial: bool = false) -> void:
	save_data["current_level_index"] = maxi(level_index, 0)
	save_data["completed_levels"] = completed_levels.duplicate()
	save_data["hint_count"] = maxi(hint_count, 0)
	save_data["has_seen_tutorial"] = has_seen_tutorial
	save_data["has_save_data"] = true
	save_all()


func get_high_score() -> int:
	return int(save_data.get("high_score", 0))


func save_high_score(score: int) -> void:
	save_data["high_score"] = maxi(score, 0)
	save_all()


func has_save_data() -> bool:
	return bool(save_data.get("has_save_data", false))


func get_progress_data() -> Dictionary:
	return {
		"current_level_index": int(save_data.get("current_level_index", 0)),
		"completed_levels": save_data.get("completed_levels", []),
		"hint_count": int(save_data.get("hint_count", 0)),
		"has_seen_tutorial": bool(save_data.get("has_seen_tutorial", false)),
		"has_save_data": bool(save_data.get("has_save_data", false)),
	}
