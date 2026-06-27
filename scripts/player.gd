# Player - 玩家角色控制脚本
# 使用 CharacterBody2D 实现移动和跳跃
# 挂载在玩家节点上，负责处理键盘输入和物理移动
extends CharacterBody2D

# ==================== 常量配置 ====================

# 水平移动速度（像素/秒），数值越大移动越快
const SPEED: float = 200.0

# 跳跃初速度（负值表示向上），数值越大跳得越高
const JUMP_VELOCITY: float = -400.0

# ==================== 变量 ====================

# 重力加速度（像素/秒²），根据游戏手感可调
var gravity: float = 980.0

# 无敌时间（受伤后短暂免疫伤害，单位：秒）
var invincible_time: float = 1.5

# 无敌计时器
var invincible_timer: float = 0.0

# 是否处于无敌状态
var is_invincible: bool = false

# 屏幕震动强度
var shake_intensity: float = 0.0


# ==================== 生命周期 ====================

# 场景初始化时调用一次
func _ready() -> void:
	# 获取当前场景的重力参数（支持不同重力设置的世界）
	gravity = get_gravity().y
	print("玩家角色已就绪，重力:", gravity)


# ==================== 每帧物理更新 ====================

# _physics_process 是处理物理逻辑的地方
# Godot 以固定频率调用此函数，保证物理模拟稳定
# delta: 上一帧到当前帧的时间间隔（秒）
func _physics_process(delta: float) -> void:
	# ---------- 0. 无敌时间递减 ----------
	if is_invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			is_invincible = false
			invincible_timer = 0
			# 恢复可见性
			if $Sprite2D:
				$Sprite2D.modulate = Color.WHITE

	# ---------- 1. 应用重力 ----------
	# 将重力累加到垂直速度上
	# 如果角色在地面上，is_on_floor() 返回 true，重力会被 move_and_slide() 处理
	velocity.y += gravity * delta

	# ---------- 2. 处理水平移动 ----------
	# Input.get_axis 返回 -1 到 1 之间的值
	# 按下左键返回 -1，按下右键返回 1，都没按返回 0
	var direction: float = Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		# 有输入时，速度直接设为目标值
		velocity.x = direction * SPEED
	else:
		# 无输入时，平滑减速到 0
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# ---------- 3. 处理跳跃 ----------
	# is_action_just_pressed 只在按下那一帧返回 true
	# 防止按住空格一直跳，只允许在地面时起跳
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY  # 赋予向上的初速度
		# 播放跳跃音效
		if AudioManager:
			AudioManager.play_sound("jump")

	# ---------- 4. 执行移动并处理碰撞 ----------
	# move_and_slide() 会自动处理：
	# - 沿地面滑动
	# - 撞墙停止
	# - 爬上斜坡
	# - 检测是否着地
	move_and_slide()


# ==================== 公共方法 ====================

# 受到伤害
# damage: 伤害值（默认 1）
func take_damage(damage: int = 1) -> void:
	# 如果处于无敌状态，忽略伤害
	if is_invincible:
		return

	# 通知全局数据减少生命值
	GameData.take_damage(damage)

	# 播放受伤音效
	if AudioManager:
		AudioManager.play_sound("hurt")

	# 播放受伤粒子效果
	if ParticleManager:
		ParticleManager.play_hurt_effect(global_position)

	# 进入无敌状态
	is_invincible = true
	invincible_timer = invincible_time

	# 闪烁效果（通过改变透明度表示无敌）
	if $Sprite2D:
		$Sprite2D.modulate = Color(1, 1, 1, 0.5)

	# 屏幕震动
	shake_intensity = 5.0


# 恢复生命值
func heal(amount: int = 1) -> void:
	GameData.heal(amount)
	print("玩家恢复了", amount, "点生命")


# 获得双倍分数效果
func activate_double_score(duration: float) -> void:
	print("双倍分数效果激活！持续", duration, "秒")
	# 这里可以添加视觉反馈（如光环）


# 获得护盾效果
func activate_shield() -> void:
	print("护盾激活！可抵挡一次伤害")
	# 这里可以添加视觉反馈（如护盾光圈）


# ==================== 私有方法 ====================

# 每帧更新（用于屏幕震动等视觉效果）
func _process(delta: float) -> void:
	# 屏幕震动效果
	if shake_intensity > 0:
		position += Vector2(randf() - 0.5, randf() - 0.5) * shake_intensity
		shake_intensity *= 0.9  # 逐渐衰减
		if shake_intensity < 0.1:
			shake_intensity = 0
			position = position  # 归位
