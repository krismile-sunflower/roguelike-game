extends CharacterBody2D

@export var speed: float = 90.0
@export var damage: int = 1
@export var patrol_distance: float = 120.0

var start_x: float = 0.0
var direction: float = 1.0


func _ready() -> void:
	start_x = global_position.x
	$HitArea.body_entered.connect(_on_hit_area_body_entered)


func _physics_process(_delta: float) -> void:
	if GameState.current_state != GameState.Playing:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if global_position.x >= start_x + patrol_distance:
		direction = -1.0
	elif global_position.x <= start_x - patrol_distance:
		direction = 1.0

	velocity.x = direction * speed
	move_and_slide()

	if $Visual:
		$Visual.scale.x = -1.0 if direction < 0.0 else 1.0


func _on_hit_area_body_entered(body: Node) -> void:
	if GameState.current_state != GameState.Playing:
		return
	if not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
