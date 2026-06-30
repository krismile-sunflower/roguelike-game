extends Node


func play_collect_effect(position: Vector2) -> void:
	_spawn_burst(position, [
		Color(0.96, 0.88, 0.45, 1.0),
		Color(0.64, 0.92, 0.70, 1.0),
	], 8, 28.0)


func play_hurt_effect(position: Vector2) -> void:
	_spawn_burst(position, [
		Color(1.0, 0.35, 0.25, 1.0),
		Color(0.95, 0.64, 0.38, 1.0),
	], 7, 22.0)


func play_enemy_die_effect(position: Vector2) -> void:
	_spawn_burst(position, [
		Color(0.75, 0.68, 0.95, 1.0),
		Color(0.36, 0.46, 0.42, 1.0),
		Color(0.96, 0.42, 0.34, 1.0),
	], 10, 34.0)


func play_powerup_appear_effect(position: Vector2) -> void:
	_spawn_burst(position, [
		Color(0.52, 0.86, 1.0, 1.0),
		Color(0.96, 0.88, 0.45, 1.0),
	], 9, 30.0)


func _spawn_burst(position: Vector2, colors: Array[Color], count: int, radius: float) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return

	for i in range(count):
		var particle := ColorRect.new()
		particle.size = Vector2(5, 5)
		particle.position = position - particle.size * 0.5
		particle.color = colors[i % colors.size()]
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		scene.add_child(particle)

		var angle := TAU * float(i) / float(maxi(count, 1))
		var distance := radius * (0.55 + 0.45 * randf())
		var target := position + Vector2(cos(angle), sin(angle)) * distance
		var tween := scene.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate", Color(1, 1, 1, 0), 0.24)
		tween.finished.connect(particle.queue_free)
