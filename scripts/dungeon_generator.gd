extends Node2D

signal dungeon_generated(dungeon_data: Dictionary)
signal player_entered_room(room: Room)

var rooms: Array[Room] = []
var spawn_position: Vector2 = Vector2.ZERO
var exit_room: Room = null
var current_dungeon_level: int = 1


func generate_dungeon(player: CharacterBody2D) -> Dictionary:
	spawn_position = player.global_position
	var info := {
		"level": current_dungeon_level,
		"rooms": rooms.size(),
		"connections": 0,
		"spawn": spawn_position,
		"exit": exit_room.global_position if exit_room else Vector2.ZERO,
	}
	dungeon_generated.emit(info)
	return info


func get_rooms() -> Array[Room]:
	return rooms


func get_spawn_position() -> Vector2:
	return spawn_position


func get_exit_room() -> Room:
	return exit_room


func are_all_rooms_clean() -> bool:
	return true
