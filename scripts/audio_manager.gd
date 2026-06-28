extends Node

const SOUND_PATHS := {
	"pickup": "res://assets/audio/kenney_interface-sounds/Audio/click_003.ogg",
	"drop_success": "res://assets/audio/kenney_interface-sounds/Audio/drop_003.ogg",
	"drop_reset": "res://assets/audio/kenney_interface-sounds/Audio/error_004.ogg",
	"complete": "res://assets/audio/kenney_interface-sounds/Audio/confirmation_001.ogg",
	"hint": "res://assets/audio/kenney_interface-sounds/Audio/click_005.ogg",
	"button": "res://assets/audio/kenney_interface-sounds/Audio/click_002.ogg",
}

var sfx_enabled: bool = true
var bgm_enabled: bool = true
var sfx_volume: float = 1.0
var bgm_volume: float = 1.0

var _sound_cache: Dictionary = {}
var _active_sfx: Dictionary = {}
var _bgm_player: AudioStreamPlayer = null


func play_sound(sound_key: String, loop: bool = false) -> void:
	if not sfx_enabled:
		return

	var stream := _get_sound_stream(sound_key)
	if stream == null:
		return

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = _volume_to_db(sfx_volume)
	player.finished.connect(_on_sfx_finished.bind(sound_key, player))
	add_child(player)

	if loop and stream.has_method("set_loop"):
		stream.set_loop(true)

	if not _active_sfx.has(sound_key):
		_active_sfx[sound_key] = []
	_active_sfx[sound_key].append(player)
	player.play()


func stop_sound(sound_key: String) -> void:
	if not _active_sfx.has(sound_key):
		return

	for player in _active_sfx[sound_key]:
		if is_instance_valid(player):
			player.stop()
			player.queue_free()
	_active_sfx.erase(sound_key)


func stop_all_sounds() -> void:
	for sound_key in _active_sfx.keys():
		stop_sound(sound_key)


func play_bgm(_bgm_key: String, _fade_in_seconds: float = 0.0) -> void:
	return


func stop_bgm(_fade_out_seconds: float = 0.0) -> void:
	if _bgm_player != null and is_instance_valid(_bgm_player):
		_bgm_player.stop()


func toggle_bgm_pause() -> void:
	if _bgm_player == null or not is_instance_valid(_bgm_player):
		return
	_bgm_player.stream_paused = not _bgm_player.stream_paused


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	for players in _active_sfx.values():
		for player in players:
			if is_instance_valid(player):
				player.volume_db = _volume_to_db(sfx_volume)


func set_bgm_volume(volume: float) -> void:
	bgm_volume = clampf(volume, 0.0, 1.0)
	if _bgm_player != null and is_instance_valid(_bgm_player):
		_bgm_player.volume_db = _volume_to_db(bgm_volume)


func toggle_sfx(enabled: bool) -> void:
	sfx_enabled = enabled


func toggle_bgm(enabled: bool) -> void:
	bgm_enabled = enabled


func save_volume_settings() -> void:
	return


func load_volume_settings() -> void:
	return


func _get_sound_stream(sound_key: String) -> AudioStream:
	if _sound_cache.has(sound_key):
		return _sound_cache[sound_key]

	if not SOUND_PATHS.has(sound_key):
		return null

	var stream := load(SOUND_PATHS[sound_key])
	if stream is AudioStream:
		_sound_cache[sound_key] = stream
		return stream
	return null


func _on_sfx_finished(sound_key: String, player: AudioStreamPlayer) -> void:
	if _active_sfx.has(sound_key):
		_active_sfx[sound_key].erase(player)
		if _active_sfx[sound_key].is_empty():
			_active_sfx.erase(sound_key)

	if is_instance_valid(player):
		player.queue_free()


func _volume_to_db(volume: float) -> float:
	if volume <= 0.0:
		return -80.0
	return linear_to_db(clampf(volume, 0.0, 1.0))
