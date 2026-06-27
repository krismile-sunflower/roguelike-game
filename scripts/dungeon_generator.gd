# DungeonGenerator - 地下城地图生成器
# Roguelike 核心：生成由房间组成的随机地下城
# 使用 BSP 简化算法：先生成房间，再随机连接
extends Node2D

# ==================== 配置参数 ====================

# 每层房间的总数
@export var total_rooms: int = 8

# 最小房间宽度
@export var min_room_width: int = 5

# 最大房间宽度
@export var max_room_width: int = 12

# 最小房间高度
@export var min_room_height: int = 4

# 最大房间高度
@export var max_room_height: int = 8

# 格子大小（像素）
@export var cell_size: int = 64

# 房间间走廊宽度
@export var corridor_width: int = 2


# ==================== 运行时数据 ====================

# 所有房间列表
var rooms: Array = []

# 房间之间的连接关系
var connections: Array = []

# 出生点（第一个房间的中心）
var spawn_position: Vector2 = Vector2.ZERO

# 出口房间
var exit_room: Room = null

# 当前层数
var current_dungeon_level: int = 1

# 已生成的房间计数
var rooms_generated: int = 0


# ==================== 信号 ====================

# 地下城生成完成时发出
signal dungeon_generated(dungeon_data: Dictionary)

# 玩家进入新房间时发出
signal player_entered_room(room: Room)


# ==================== 生命周期 ====================

# 场景初始化
func _ready() -> void:
	print("地下城生成器已就绪")


# ==================== 公共方法 ====================

# 生成新的地下城
# player: 玩家节点引用，用于设置出生点
func generate_dungeon(player: CharacterBody2D) -> Dictionary:
	# 清理旧数据
	_clear_old_dungeon()

	# 生成房间
	_generate_rooms()

	# 连接房间
	_connect_rooms()

	# 放置出生点和出口
	_setup_spawn_and_exit(player)

	# 填充房间内容
	_populate_rooms()

	# 输出生成结果
	print("地下城 #%d 生成完毕:" % current_dungeon_level)
	print("  房间数:", rooms.size())
	print("  连接数:", connections.size())

	# 发出信号
	dungeon_generated.emit(_get_dungeon_info())

	return _get_dungeon_info()


# 获取所有房间
func get_rooms() -> Array:
	return rooms


# 获取出生点
func get_spawn_position() -> Vector2:
	return spawn_position


# 获取出口房间
func get_exit_room() -> Room:
	return exit_room


# 检查是否所有房间都已清理
func are_all_rooms_clean() -> bool:
	for room in rooms:
		if room is Room and not room.is_room_clean():
			return false
	return true


# ==================== 私有方法：房间生成 ====================

# 生成所有房间
func _generate_rooms() -> void:
	rooms_generated = 0
	var attempts := 0
	var max_attempts := total_rooms * 20  # 防止无限循环

	while rooms_generated < total_rooms and attempts < max_attempts:
		attempts += 1

		# 随机房间尺寸
		var rw := randi() % (max_room_width - min_room_width + 1) + min_room_width
		var rh := randi() % (max_room_height - min_room_height + 1) + min_room_height

		# 随机位置（留出边距）
		var rx := randi() % (1200 - rw * cell_size)
		var ry := randi() % (800 - rh * cell_size)

		var new_room := Rect2(rx, ry, rw * cell_size, rh * cell_size)

		# 检查是否与现有房间重叠
		if _overlaps_any_room(new_room):
			continue

		# 创建房间节点
		var room := Room.new()
		room.room_id = rooms_generated
		room.width = rw
		room.height = rh
		room.cell_size = cell_size
		room.position = Vector2(rx + rw * cell_size / 2, ry + rh * cell_size / 2)

		# 随机分配房间类型（第一个是 START，最后一个是 EXIT）
		if rooms_generated == 0:
			room.room_type = Room.RoomType.START
		elif rooms_generated == total_rooms - 1:
			room.room_type = Room.RoomType.EXIT
			exit_room = room
		else:
			# 随机类型
			var type_roll := randi() % 100
			if type_roll < 50:
				room.room_type = Room.RoomType.NORMAL
			elif type_roll < 70:
				room.room_type = Room.RoomType.RICH
			elif type_roll < 85:
				room.room_type = Room.RoomType.SHOP
			elif type_roll < 95:
				room.room_type = Room.RoomType.BOSS
			else:
				room.room_type = Room.RoomType.NORMAL

		add_child(room)
		rooms.append(room)
		rooms_generated += 1


# 检查房间是否与其他房间重叠
func _overlaps_any_room(rect: Rect2) -> bool:
	for room in rooms:
		if room is Room:
			var room_rect := Rect2(
				room.position.x - room.width * room.cell_size / 2,
				room.position.y - room.height * room.cell_size / 2,
				room.width * room.cell_size,
				room.height * room.cell_size
			)
			if rect.intersects(room_rect):
				return true
	return false


# ==================== 私有方法：房间连接 ====================

# 连接所有房间（保证连通性）
func _connect_rooms() -> void:
	if rooms.size() < 2:
		return

	# 按生成顺序依次连接相邻房间
	for i in range(rooms.size() - 1):
		var room_a := rooms[i] as Room
		var room_b := rooms[i + 1] as Room

		if room_a and room_b:
			# 创建连接
			connections.append({
				"from": room_a,
				"to": room_b,
			})

			# 设置出口标志
			var dx := room_b.position.x - room_a.position.x
			var dy := room_b.position.y - room_a.position.y

			if abs(dx) > abs(dy):
				# 水平连接
				if dx > 0:
					room_a.set_exit("east", true)
					room_b.set_exit("west", true)
				else:
					room_a.set_exit("west", true)
					room_b.set_exit("east", true)
			else:
				# 垂直连接
				if dy > 0:
					room_a.set_exit("south", true)
					room_b.set_exit("north", true)
				else:
					room_a.set_exit("north", true)
					room_b.set_exit("south", true)

			# 绘制连接走廊（可视化）
			_draw_corridor(room_a.position, room_b.position)


# 绘制房间间的走廊
func _draw_corridor(from: Vector2, to: Vector2) -> void:
	# 简单的 L 形走廊
	var mid := Vector2(to.x, from.y)

	# 走廊线段 1：from -> mid
	_line(from, mid, Color(0.2, 0.2, 0.2))
	# 走廊线段 2：mid -> to
	_line(mid, to, Color(0.2, 0.2, 0.2))


# 绘制一条线（走廊可视化）
func _line(from: Vector2, to: Vector2, color: Color) -> void:
	var length := from.distance_to(to)
	if length < 10:
		return

	var segments := int(length / cell_size)
	for i in segments:
		var t := float(i) / float(segments)
		var pos := from.lerp(to, t)
		var block := ColorRect.new()
		block.size = Vector2(cell_size, cell_size)
		block.color = color
		block.position = pos - Vector2(cell_size / 2, cell_size / 2)
		add_child(block)


# ==================== 私有方法：出生点和出口 ====================

# 设置出生点和出口
func _setup_spawn_and_exit(player: CharacterBody2D) -> void:
	if rooms.size() > 0:
		# 出生点在第一个房间（START 房间）中心
		var start_room := rooms[0] as Room
		if start_room:
			spawn_position = start_room.get_world_center()
			player.position = spawn_position
			print("出生点设置在房间 #0 中心")

		# 出口在最后一个房间
		if exit_room:
			print("出口设置在房间 #%d" % exit_room.room_id)


# ==================== 私有方法：填充房间 ====================

# 填充所有房间的内容
func _populate_rooms() -> void:
	for room in rooms:
		if room is Room:
			room.populate(self)


# ==================== 辅助方法 ====================

# 在房间内获取随机空位
func get_random_empty_cell_in_room(room: Room) -> Vector2i:
	"""返回房间内的随机格子坐标"""
	var half_w := room.width / 2
	var half_h := room.height / 2
	var x := randi() % room.width
	var y := randi() % room.height
	return Vector2i(x, y)


# 获取地下城信息
func _get_dungeon_info() -> Dictionary:
	return {
		"level": current_dungeon_level,
		"rooms": rooms.size(),
		"connections": connections.size(),
		"spawn": spawn_position,
		"exit": exit_room.position if exit_room else Vector2.ZERO,
	}
