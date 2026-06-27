# Enemy - 敌人脚本
# 继承自 CharacterBody2D，实现简单的巡逻AI
# 碰到玩家时造成伤害
extends CharacterBody2D

# ==================== 导出属性 ====================

# 敌人移动速度（像素/秒）
@export var speed: float = 100.0

# 敌人伤害值（碰到玩家时扣除的生命值）
@export var damage: int = 1

# 巡逻范围（像素），敌人会在初始位置左右各巡逻此距离
@export var patrol_range: float = 200.0

# 敌人类型（影响外观和行为）
enum EnemyType {
	BASIC,     # 基础敌人
	FAST,      # 快速敌人
	TANKY,     # 耐打敌人
}

@export var enemy_type: EnemyType = EnemyType.BASIC


# ==================== 变量 ====================

# 巡逻方向（1 = 向右，-1 = 向左）
var patrol_direction: int = 1

# 初始位置（用于计算巡逻边界）
var start_position: float = 0.0

# 是否存活
var is_alive: bool = true

# 碰撞检测区域
var collision_area: Area2D

# 根据类型调整属性
var adjusted_speed: float = 0.0
var adjusted_damage: int = 0


# ==================== 生命周期 ====================

# 场景初始化
func _ready() -> void:
	# 记录初始X坐标，用于巡逻边界计算
	start_position = position.x

	# 根据敌人类型调整属性
	_adjust_properties()

	# 查找碰撞检测用的 Area2D 节点
	collision_area = $CollisionArea
	if collision_area:
		# 连接 body_entered 信号，检测玩家进入
		collision_area.body_entered.connect(_on_body_entered)
		print("敌人已创建，类型:", _get_type_name(), "，伤害:", adjusted_damage)
	else:
		print("警告: 未找到 CollisionArea 节点")


# ==================== 每帧物理更新 ====================

# 敌人的AI逻辑：左右巡逻
func _physics_process(delta: float) -> void:
	if not is_alive:
		return  # 已销毁，不再处理

	# 计算当前X坐标相对于初始位置的距离
	var distance_from_start := position.x - start_position

	# 到达巡逻边界时，反转方向
	if distance_from_start >= patrol_range:
		patrol_direction = -1
	elif distance_from_start <= -patrol_range:
		patrol_direction = 1

	# 设置移动速度
	velocity.x = patrol_direction * adjusted_speed

	# 执行移动
	move_and_slide()

	# 根据移动方向翻转精灵（面向移动方向）
	if $Sprite2D:
		$Sprite2D.flip_h = (patrol_direction < 0)


# ==================== 信号回调 ====================

# 当有身体进入碰撞区域时调用（通常是玩家）
func _on_body_entered(body: Node2D) -> void:
	if not is_alive:
		return  # 已销毁，不再响应

	# 检查进入的是否为玩家
	if body.is_class("CharacterBody2D"):
		# 通知玩家受到伤害
		if body.has_method("take_damage"):
			body.take_damage(adjusted_damage)

		# 播放敌人死亡音效
		if AudioManager:
			AudioManager.play_sound("enemy_die")

		# 播放爆炸粒子效果
		if ParticleManager:
			ParticleManager.play_enemy_die_effect(global_position)

		# 销毁敌人（避免重复触发）
		_play_hit_effect()


# ==================== 私有方法 ====================

# 根据敌人类型调整属性
func _adjust_properties() -> void:
	match enemy_type:
	(EnemyType.BASIC):
		adjusted_speed = speed
		adjusted_damage = damage
	(EnemyType.FAST):
		adjusted_speed = speed * 1.5
		adjusted_damage = damage
	(EnemyType.TANKY):
		adjusted_speed = speed * 0.7
		adjusted_damage = damage * 2


# 播放敌人被击中的视觉效果
func _play_hit_effect() -> void:
	is_alive = false  # 标记为已销毁

	# 创建闪烁动画
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)  # 0.3秒内淡出
	tween.tween_callback(queue_free)  # 淡出后销毁


# 获取敌人类型名称
func _get_type_name() -> String:
	match enemy_type:
	(EnemyType.BASIC):
		return "基础"
	(EnemyType.FAST):
		return "快速"
	(EnemyType.TANKY):
		return "耐打"
	_:
		return "未知"
