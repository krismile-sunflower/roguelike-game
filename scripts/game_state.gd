extends Node

enum State {
	MENU,
	INSTRUCTIONS,
	PLAYING,
	PAUSED,
	COMPLETED,
}

const Menu := State.MENU
const Instructions := State.INSTRUCTIONS
const Playing := State.PLAYING
const Paused := State.PAUSED
const Completed := State.COMPLETED

signal state_changed(new_state: int)
signal level_changed(level_index: int)
signal level_completed(level_index: int)

var current_state: int = State.MENU
var current_level: int = 0
var high_score: int = 0


func _ready() -> void:
	high_score = SaveManager.get_high_score()
	set_state(State.MENU)


func set_state(new_state: int) -> void:
	current_state = new_state
	state_changed.emit(current_state)


func start_level(level_index: int) -> void:
	current_level = level_index
	set_state(State.PLAYING)
	level_changed.emit(level_index)


func complete_level(level_index: int) -> void:
	current_level = level_index
	high_score = maxi(high_score, GameData.get_completed_count())
	SaveManager.save_high_score(high_score)
	set_state(State.COMPLETED)
	level_completed.emit(level_index)


func toggle_pause() -> void:
	if current_state == State.PLAYING:
		set_state(State.PAUSED)
	elif current_state == State.PAUSED:
		set_state(State.PLAYING)


func start_new_game() -> void:
	GameData.reset_progress()
	GameData.reset_hint_count()
	GameData.set_current_level(0)
	start_level(0)


func show_menu() -> void:
	set_state(State.MENU)


func show_instructions() -> void:
	set_state(State.INSTRUCTIONS)
