# LevelGenerator - 随机地图生成器
# 用于 Roguelike 游戏的房间/障碍物生成
# 提供简单的网格化随机地图生成逻辑
extends Node2D

# ==================== 配置参数 ====================

# 地图网格大小（格子数）
@export var grid_width: int = 20
@export var grid_height: int = 15

# 每个格子的大小（像素）
@export var cell_size: int = 64

# 障碍物概率（0.0 = 无障碍，1.0 = 全部障碍）
@export var obstacle_probability: float = 0.3

# 收集品数量
@export var collectible_count: int = 10

# 敌人数量
@export var enemy_count: int = 5

# 道具数量
@export var powerup_count: int = 3


# ==================== 运行时数据 ====================

# 地图数据：0 = 空地，1 = 障碍物
var map_data: Array = []

# 生成的障碍物节点列表（用于清理）
var obstacle_nodes: Array = []

# 生成的收集品节点列表
var collectible_nodes: Array = []

# 生成的敌人节点列表
var enemy_nodes: Array = []

# 生成的道具节点列表
var powerup_nodes: Array = []


# ==================== 生命周期 ====================

# 场景初始化
func _ready() -> void:
    # 自动生成地图
    generate_level()
    print("地图已生成，大小:", grid_width, "x", grid_height)


# ==================== 公共方法 ====================

# 生成完整关卡
# 包括：障碍物、收集品、敌人、道具
func generate_level() -> void:
    # 清理上一关的所有生成物
    clear_level()

    # 1. 生成地图数据
    _generate_map_data()

    # 2. 放置障碍物
    _place_obstacles()

    # 3. 放置收集品
    _place_collectibles()

    # 4. 放置敌人
    _place_enemies()

    # 5. 放置道具
    _place_powerups()

    print("关卡生成完毕:")
    print("  障碍物:", obstacle_nodes.size(), "个")
    print("  收集品:", collectible_nodes.size(), "个")
    print("  敌人:", enemy_nodes.size(), "个")
    print("  道具:", powerup_nodes.size(), "个")


# 清空当前关卡
func clear_level() -> void:
    # 销毁所有障碍物
    for obstacle in obstacle_nodes:
        obstacle.queue_free()
    obstacle_nodes.clear()

    # 销毁所有收集品
    for collectible in collectible_nodes:
        collectible.queue_free()
    collectible_nodes.clear()

    # 销毁所有敌人
    for enemy in enemy_nodes:
        enemy.queue_free()
    enemy_nodes.clear()

    # 销毁所有道具
    for powerup in powerup_nodes:
        powerup.queue_free()
    powerup_nodes.clear()

    # 清空地图数据
    map_data = []


# 获取指定格子的状态
# 返回: 0 = 空地, 1 = 障碍物
func get_cell_state(x: int, y: int) -> int:
    if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
        return 1  # 边界视为障碍物
    return map_data[y][x]


# 检查指定位置是否可放置
func can_place(x: int, y: int) -> bool:
    if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
        return false
    return map_data[y][x] == 0


# 获取随机空地坐标（返回 Vector2i，x/y=-1 表示没有空地）
func get_random_empty_cell() -> Vector2i:
    # 收集所有空地
var empty_cells = []

    for y in range(grid_height):
        for x in range(grid_width):
            if map_data[y][x] == 0:
                empty_cells.append(Vector2i(x, y))

    # 随机选择一个
    if empty_cells.size() > 0:
        return empty_cells[randi() % empty_cells.size()]
    return Vector2i(-1, -1)  # 没有空地


# 在房间内获取随机空位
func get_random_empty_cell_in_room(room: Room) -> Vector2i:
    """返回房间网格内的随机坐标"""
var half_w = room.width / 2

var half_h = room.height / 2

var x = randi() % room.width

var y = randi() % room.height

    return Vector2i(x, y)


# ==================== 私有方法 ====================

# 生成地图数据（随机填充障碍物）
func _generate_map_data() -> void:
    map_data = []
    for y in range(grid_height):
var row = []

        for x in range(grid_width):
            # 边缘格子设为障碍物（围墙）
            if x == 0 or x == grid_width - 1 or y == 0 or y == grid_height - 1:
                row.append(1)
            # 内部格子按概率生成障碍物
            elif randf() < obstacle_probability:
                row.append(1)
            else:
                row.append(0)
        map_data.append(row)


# 在地图上放置障碍物视觉节点
func _place_obstacles() -> void:
    for y in range(grid_height):
        for x in range(grid_width):
            if map_data[y][x] == 1:
                _create_obstacle_visual(x, y)


# 创建单个障碍物视觉节点
func _create_obstacle_visual(x: int, y: int) -> void:
var obstacle = StaticBody2D.new()

    obstacle.position = Vector2(x * cell_size + cell_size / 2, y * cell_size + cell_size / 2)

    # 添加碰撞形状
var collision = CollisionShape2D.new()

var shape = RectangleShape2D.new()

    shape.size = Vector2(cell_size - 4, cell_size - 4)
    collision.shape = shape
    obstacle.add_child(collision)

    # 添加视觉（灰色方块）
var sprite = Sprite2D.new()

    sprite.texture = _create_placeholder_texture(Color(0.4, 0.4, 0.4))
    sprite.position = Vector2(-cell_size / 2 + 2, -cell_size / 2 + 2)
    sprite.scale = Vector2(cell_size - 4, cell_size - 4)
    obstacle.add_child(sprite)

    add_child(obstacle)
    obstacle_nodes.append(obstacle)


# 放置收集品
func _place_collectibles() -> void:
var placed = 0

var attempts = 0

    while placed < collectible_count and attempts < 500:
        attempts += 1
var pos = get_random_empty_cell()

        if pos.x >= 0 and pos.y >= 0:
            _create_collectible(pos.x, pos.y)
            placed += 1


# 放置敌人
func _place_enemies() -> void:
var placed = 0

var attempts = 0

    while placed < enemy_count and attempts < 500:
        attempts += 1
var pos = get_random_empty_cell()

        if pos.x >= 0 and pos.y >= 0:
            _create_enemy(pos.x, pos.y)
            placed += 1


# 放置道具
func _place_powerups() -> void:
var placed = 0

var attempts = 0

    while placed < powerup_count and attempts < 500:
        attempts += 1
var pos = get_random_empty_cell()

        if pos.x >= 0 and pos.y >= 0:
            _create_powerup(pos.x, pos.y)
            placed += 1


# 创建收集品实例
func _create_collectible(grid_x: int, grid_y: int) -> void:
var collectible = Node2D.new()

    collectible.position = Vector2(grid_x * cell_size + cell_size / 2, grid_y * cell_size + cell_size / 2)

    # 添加视觉（黄色方块代表金币）
var sprite = Sprite2D.new()

    sprite.texture = _create_placeholder_texture(Color.YELLOW)
    sprite.position = Vector2(-16, -16)
    sprite.scale = Vector2(32, 32)
    collectible.add_child(sprite)

    add_child(collectible)
    collectible_nodes.append(collectible)


# 创建敌人实例
func _create_enemy(grid_x: int, grid_y: int) -> void:
var enemy = Node2D.new()

    enemy.position = Vector2(grid_x * cell_size + cell_size / 2, grid_y * cell_size + cell_size / 2)

    # 添加视觉（红色方块代表敌人）
var sprite = Sprite2D.new()

    sprite.texture = _create_placeholder_texture(Color.RED)
    sprite.position = Vector2(-16, -16)
    sprite.scale = Vector2(32, 32)
    enemy.add_child(sprite)

    add_child(enemy)
    enemy_nodes.append(enemy)


# 创建道具实例
func _create_powerup(grid_x: int, grid_y: int) -> void:
var powerup = Node2D.new()

    powerup.position = Vector2(grid_x * cell_size + cell_size / 2, grid_y * cell_size + cell_size / 2)

    # 添加视觉（紫色方块代表道具）
var sprite = Sprite2D.new()

    sprite.texture = _create_placeholder_texture(Color.MAGENTA)
    sprite.position = Vector2(-16, -16)
    sprite.scale = Vector2(32, 32)
    powerup.add_child(sprite)

    add_child(powerup)
    powerup_nodes.append(powerup)


# 创建占位纹理（用于测试，无需外部图片）
func _create_placeholder_texture(color: Color) -> Texture2D:
    """创建一个纯色贴图作为占位符"""
var image = Image.create(cell_size, cell_size, false, Image.FORMAT_RGBA8)

    image.fill(color)
var texture = ImageTexture.create_from_image(image)

    return texture
