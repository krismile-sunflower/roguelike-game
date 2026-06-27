# Room - 房间节点
# 代表 Roguelike 中的一个独立房间
# 包含房间数据、出生点、出口、敌人分布
class_name Room extends Node2D

# ==================== 房间类型枚举 ====================

enum RoomType {
    START,       # 起始房间（安全）
    NORMAL,      # 普通房间（有敌人）
    RICH,        # 富饶房间（多收集品）
    BOSS,        # Boss 房间
    SHOP,        # 商店房间（道具）
    EXIT         # 出口房间（通向下一层）
}


# ==================== 导出属性 ====================

# 房间宽度（格子数）
@export var width: int = 8

# 房间高度（格子数）
@export var height: int = 6

# 格子大小（像素）
@export var cell_size: int = 64

# 房间类型
@export var room_type: RoomType = RoomType.NORMAL

# 房间唯一 ID
@export var room_id: int = 0


# ==================== 运行时数据 ====================

# 房间中心位置
var center_position: Vector2 = Vector2.ZERO

# 房间内的敌人列表
var enemies: Array = []

# 房间内的收集品列表
var collectibles: Array = []

# 房间内的道具列表
var powerups: Array = []

# 出口位置（连接到其他房间的端口）
var exits: Dictionary = {
    "north": false,
    "south": false,
    "east": false,
    "west": false,
}

# 是否已被清理
var is_cleaned: bool = false

# 房间视觉边界
var boundary_sprite: Sprite2D = null


# ==================== 生命周期 ====================

# 场景初始化
func _ready() -> void:
    center_position = position
    _create_boundary()
    print("房间 #%d 已创建，类型: %s, 大小: %dx%d" % [
        room_id, _get_room_type_name(), width, height
    ])


# ==================== 公共方法 ====================

# 初始化房间内容（生成敌人、收集品等）
func populate(level_generator: Node2D) -> void:
    match room_type:
    (RoomType.START):
        # 起始房间：安全，少量收集品
        _populate_start_room()

    (RoomType.NORMAL):
        # 普通房间：随机敌人 + 少量收集品
        _populate_normal_room(level_generator)

    (RoomType.RICH):
        # 富饶房间：多收集品，少敌人
        _populate_rich_room(level_generator)

    (RoomType.BOSS):
        # Boss 房间：强敌
        _populate_boss_room(level_generator)

    (RoomType.SHOP):
        # 商店房间：道具
        _populate_shop_room(level_generator)

    (RoomType.EXIT):
        # 出口房间
        _populate_exit_room(level_generator)


# 检查房间是否被清理（所有敌人都被消灭）
func is_room_clean() -> bool:
    if room_type == RoomType.START or room_type == RoomType.EXIT:
        return true
    return enemies.is_empty()


# 获取房间内剩余敌人数量
func get_remaining_enemies() -> int:
    return enemies.size()


# 获取出口方向
func get_exits() -> Array:
var exit_dirs = []

    for dir in exits:
        if exits[dir]:
            exit_dirs.append(dir)
    return exit_dirs


# 设置出口
func set_exit(direction: String, enabled: bool) -> void:
    if direction in exits:
        exits[direction] = enabled


# 获取房间中心的世界坐标
func get_world_center() -> Vector2:
    return global_position


# 获取房间边界矩形
func get_bounds() -> Rect2:
    return Rect2(
        global_position - Vector2(width * cell_size / 2, height * cell_size / 2),
        Vector2(width * cell_size, height * cell_size)
    )


# ==================== 私有方法 ====================

# 创建房间边界可视化
func _create_boundary() -> void:
    # 绘制房间边框
    boundary_sprite = Sprite2D.new()
    # 使用纯色占位（实际项目中可用边框贴图）
var image = Image.create(cell_size, cell_size, false, Image.FORMAT_RGBA8)

    image.fill(Color(0.3, 0.3, 0.3, 0.5))
var texture = ImageTexture.create_from_image(image)

    boundary_sprite.texture = texture
    boundary_sprite.position = Vector2(0, 0)
    boundary_sprite.scale = Vector2(width, height)
    add_child(boundary_sprite)


# 填充起始房间
func _populate_start_room() -> void:
    # 安全房间，不放敌人
    pass


# 填充普通房间
func _populate_normal_room(level_generator: Node2D) -> void:
    # 随机放置 1-3 个敌人
var enemy_count = randi() % 3 + 1

    for i in enemy_count:
var pos = level_generator.get_random_empty_cell_in_room(self)

        if pos.x >= 0:
            enemies.append(pos)


# 填充富饶房间
func _populate_rich_room(level_generator: Node2D) -> void:
    # 多放收集品
    pass


# 填充 Boss 房间
func _populate_boss_room(level_generator: Node2D) -> void:
    # 放置 Boss 敌人
    pass


# 填充商店房间
func _populate_shop_room(level_generator: Node2D) -> void:
    # 放置道具
    pass


# 填充出口房间
func _populate_exit_room(level_generator: Node2D) -> void:
    pass


# 获取房间类型名称
func _get_room_type_name() -> String:
    match room_type:
    (RoomType.START):
        return "起始"
    (RoomType.NORMAL):
        return "普通"
    (RoomType.RICH):
        return "富饶"
    (RoomType.BOSS):
        return "Boss"
    (RoomType.SHOP):
        return "商店"
    (RoomType.EXIT):
        return "出口"
    _:
        return "未知"
