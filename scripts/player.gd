extends CharacterBody2D

const SPEED := 220.0
const JUMP_VELOCITY := -420.0
const RESPAWN_POSITION := Vector2(160.0, 616.0)

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var invincible_duration: float = 1.0
var invincible_timer: float = 0.0
var is_invincible: bool = false


func _ready() -> void:
	global_position = RESPAWN_POSITION


func _physics_process(delta: float) -> void:
	if GameState.current_state != GameState.Playing:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_invincible:
		invincible_timer -= delta
		if invincible_timer <= 0.0:
			is_invincible = false
			$Visual.modulate = Color.WHITE

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := _get_horizontal_input()
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		AudioManager.play_sound("jump")

	move_and_slide()


func take_damage(amount: int = 1) -> void:
	if GameState.current_state != GameState.Playing:
		return
	if is_invincible:
		return

	GameData.take_damage(amount)
	AudioManager.play_sound("hurt")
	ParticleManager.play_hurt_effect(global_position)

	is_invincible = true
	invincible_timer = invincible_duration
	$Visual.modulate = Color(1.0, 1.0, 1.0, 0.45)


func heal(amount: int = 1) -> void:
	GameData.heal(amount)


func activate_double_score(_duration: float) -> void:
	return


func activate_shield() -> void:
	return


func reset_for_new_game() -> void:
	global_position = RESPAWN_POSITION
	velocity = Vector2.ZERO
	is_invincible = false
	invincible_timer = 0.0
	$Visual.modulate = Color.WHITE


func _get_horizontal_input() -> float:
	return Input.get_axis("ui_left", "ui_right")
