extends Node2D

@export var grid_width: int = 20
@export var grid_height: int = 12
@export var cell_size: int = 64


func generate_level() -> void:
	return


func clear_level() -> void:
	return


func get_random_empty_cell() -> Vector2i:
	return Vector2i.ZERO


func get_random_empty_cell_in_room(_room: Room) -> Vector2i:
	return Vector2i.ZERO
