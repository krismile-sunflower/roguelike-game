extends Area2D

enum PowerUpType {
	HEAL,
	SCORE,
}

@export var power_up_type: PowerUpType = PowerUpType.HEAL
@export var score_bonus: int = 25
@export var heal_amount: int = 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("pickup")


func _on_body_entered(body: Node) -> void:
	if GameState.current_state != GameState.Playing:
		return
	if not body.is_in_group("player"):
		return

	match power_up_type:
		PowerUpType.HEAL:
			GameData.heal(heal_amount)
			AudioManager.play_sound("powerup")
		PowerUpType.SCORE:
			GameData.add_score(score_bonus)
			AudioManager.play_sound("powerup")

	ParticleManager.play_powerup_appear_effect(global_position)
	queue_free()
