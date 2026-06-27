# Collectible - 可收集物品脚本
# 继承自 Area2D，用于金币、道具等可拾取物品
# 当玩家进入其碰撞范围时，触发加分并销毁
extends Area2D

# ==================== 导出属性 ====================

# 收集此物品后增加的分数
# @export 允许在 Godot 编辑器中直接修改此值
# 不同收集品可以设置不同的分数（如普通金币=10，稀有道具=50）
@export var points: int = 10

# 浮动动画的速度
@export var float_speed: float = 2.0

# 浮动动画的幅度
@export var float_amount: float = 5.0

# 初始 Y 偏移（用于浮动动画）
var initial_y: float = 0.0


# ==================== 生命周期 ====================

# 场景初始化时调用一次
func _ready() -> void:
	# 记录初始 Y 位置，用于浮动动画
	initial_y = position.y

	# 连接 body_entered 信号
	# 当任何物理身体进入此 Area2D 范围时，会自动调用 _on_body_entered
	body_entered.connect(_on_body_entered)

	# 播放出现效果
	if ParticleManager:
		ParticleManager.play_collect_effect(global_position)

	# 播放收集音效（出现时的提示音）
	if AudioManager:
		AudioManager.play_sound("collect")

	print("收集品已创建，分数价值:", points)


# ==================== 每帧更新 ====================

# 实现上下浮动效果（让收集品看起来在"呼吸"）
func _process(delta: float) -> void:
	position.y = initial_y + sin(Time.get_ticks_msec() / 300.0) * float_amount


# ==================== 信号回调 ====================

# 当有物理身体进入此区域时调用
# body: 进入的身体节点（可能是玩家、敌人等）
func _on_body_entered(body: Node2D) -> void:
	# 检查进入的是否为玩家（CharacterBody2D）
	# is_class 检查节点类型，避免敌人或其他物体误触
	if body.is_class("CharacterBody2D"):
		# 通知全局数据增加分数
		GameData.add_score(points)

		# 播放收集音效
		if AudioManager:
			AudioManager.play_sound("collect")

		# 播放收集粒子效果
		if ParticleManager:
			ParticleManager.play_collect_effect(global_position)

		# 播放销毁动画：先放大，再淡出，最后从场景中移除
		_play_destroy_animation()


# ==================== 私有方法 ====================

# 播放物品被收集时的销毁动画
func _play_destroy_animation() -> void:
	# 创建 Tween 动画对象
	var tween: Tween = create_tween()

	# 第1步：0.1秒内放大到1.5倍
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)

	# 第2步：0.2秒内透明度（alpha）变为 0，即完全透明
	tween.tween_property(self, "modulate:a", 0.0, 0.2)

	# 第3步：动画结束后，从场景中移除（queue_free 安全销毁）
	tween.tween_callback(queue_free)
