extends Area2D

signal collected(points: int)

@export var points: int = 10
@export var bob_height: float = 6.0
@export var bob_speed: float = 3.0

var base_position: Vector2


func _ready() -> void:
	base_position = position
	body_entered.connect(_on_body_entered)
	add_to_group("level_collectible")


func _process(_delta: float) -> void:
	position.y = base_position.y + sin(Time.get_ticks_msec() / 1000.0 * bob_speed) * bob_height


func _on_body_entered(body: Node) -> void:
	if GameState.current_state != GameState.Playing:
		return
	if not body.is_in_group("player"):
		return

	GameData.add_score(points)
	AudioManager.play_sound("collect")
	ParticleManager.play_collect_effect(global_position)
	collected.emit(points)
	queue_free()
