class_name Room
extends Node2D

enum RoomType {
	START,
	NORMAL,
	EXIT,
}

@export var width: int = 8
@export var height: int = 6
@export var cell_size: int = 64
@export var room_type: RoomType = RoomType.NORMAL
@export var room_id: int = 0

var exits: Dictionary = {
	"north": false,
	"south": false,
	"east": false,
	"west": false,
}


func populate(_level_generator: Node) -> void:
	return


func is_room_clean() -> bool:
	return true


func set_exit(direction: String, enabled: bool) -> void:
	if exits.has(direction):
		exits[direction] = enabled


func get_world_center() -> Vector2:
	return global_position
