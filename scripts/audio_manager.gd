extends Node

var sfx_enabled: bool = true
var bgm_enabled: bool = true
var sfx_volume: float = 1.0
var bgm_volume: float = 1.0


func play_sound(_sound_key: String, _loop: bool = false) -> void:
	return


func stop_sound(_sound_key: String) -> void:
	return


func stop_all_sounds() -> void:
	return


func play_bgm(_bgm_key: String, _fade_in_seconds: float = 0.0) -> void:
	return


func stop_bgm(_fade_out_seconds: float = 0.0) -> void:
	return


func toggle_bgm_pause() -> void:
	return


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)


func set_bgm_volume(volume: float) -> void:
	bgm_volume = clampf(volume, 0.0, 1.0)


func toggle_sfx(enabled: bool) -> void:
	sfx_enabled = enabled


func toggle_bgm(enabled: bool) -> void:
	bgm_enabled = enabled


func save_volume_settings() -> void:
	return


func load_volume_settings() -> void:
	return
