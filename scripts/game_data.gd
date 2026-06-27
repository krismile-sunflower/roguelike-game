extends Node

signal level_progress_changed(current_level_index: int, completed_count: int, total_levels: int)
signal hint_count_changed(hint_count: int)
signal score_changed(new_score: int)
signal health_changed(new_health: int)
signal tutorial_state_changed(has_seen_tutorial: bool)

var current_level_index: int = 0
var total_levels: int = 0
var completed_levels: Array[bool] = []
var hint_count: int = 0
var level_start_time_msec: int = 0
var score: int = 0
var player_health: int = 3
var has_seen_tutorial: bool = false


func configure_levels(count: int) -> void:
	total_levels = maxi(count, 0)
	completed_levels.resize(total_levels)
	for i in range(completed_levels.size()):
		if typeof(completed_levels[i]) != TYPE_BOOL:
			completed_levels[i] = false
	_emit_progress()


func restore_progress(saved_completed_levels: Array, last_level_index: int, saved_hint_count: int, saved_has_seen_tutorial: bool = false) -> void:
	if total_levels <= 0:
		return

	var restored: Array[bool] = []
	restored.resize(total_levels)
	for i in range(total_levels):
		var value := false
		if i < saved_completed_levels.size():
			value = bool(saved_completed_levels[i])
		restored[i] = value

	completed_levels = restored
	current_level_index = clampi(last_level_index, 0, maxi(total_levels - 1, 0))
	hint_count = maxi(saved_hint_count, 0)
	has_seen_tutorial = saved_has_seen_tutorial
	hint_count_changed.emit(hint_count)
	tutorial_state_changed.emit(has_seen_tutorial)
	_emit_progress()


func start_level(level_index: int) -> void:
	current_level_index = clampi(level_index, 0, maxi(total_levels - 1, 0))
	level_start_time_msec = Time.get_ticks_msec()
	_emit_progress()


func complete_level(level_index: int) -> void:
	if level_index >= 0 and level_index < completed_levels.size():
		completed_levels[level_index] = true
	current_level_index = clampi(level_index, 0, maxi(total_levels - 1, 0))
	_emit_progress()


func reset_hint_count() -> void:
	hint_count = 0
	hint_count_changed.emit(hint_count)


func register_hint() -> void:
	hint_count += 1
	hint_count_changed.emit(hint_count)


func reset_progress() -> void:
	current_level_index = 0
	hint_count = 0
	level_start_time_msec = 0
	completed_levels.resize(total_levels)
	for i in range(completed_levels.size()):
		completed_levels[i] = false
	hint_count_changed.emit(hint_count)
	_emit_progress()


func set_current_level(level_index: int) -> void:
	current_level_index = clampi(level_index, 0, maxi(total_levels - 1, 0))
	_emit_progress()


func mark_tutorial_seen() -> void:
	has_seen_tutorial = true
	tutorial_state_changed.emit(has_seen_tutorial)


func reset() -> void:
	score = 0
	player_health = 3
	score_changed.emit(score)
	health_changed.emit(player_health)


func add_score(amount: int) -> void:
	score = maxi(score + amount, 0)
	score_changed.emit(score)


func take_damage(amount: int = 1) -> void:
	player_health = maxi(player_health - amount, 0)
	health_changed.emit(player_health)


func heal(amount: int = 1) -> void:
	player_health = mini(player_health + amount, 3)
	health_changed.emit(player_health)


func get_completed_count() -> int:
	var count := 0
	for is_completed in completed_levels:
		if is_completed:
			count += 1
	return count


func get_level_elapsed_seconds() -> float:
	if level_start_time_msec <= 0:
		return 0.0
	return float(Time.get_ticks_msec() - level_start_time_msec) / 1000.0


func _emit_progress() -> void:
	level_progress_changed.emit(current_level_index, get_completed_count(), total_levels)
