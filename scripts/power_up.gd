# PowerUp - 道具脚本
# 继承自 Area2D，代表各种增益道具
# 收集后触发不同效果（护盾、双倍分数、回血等）
extends Area2D

# ==================== 道具类型枚举 ====================

# 定义所有可用的道具类型
enum PowerUpType {
    SHIELD,        # 护盾：抵挡一次伤害
    DOUBLE_SCORE,  # 双倍分数：10秒内得分翻倍
    HEALTH,        # 回血：恢复1点生命
    RANDOM         # 随机道具
}


# ==================== 导出属性 ====================

# 道具类型
@export var power_up_type: PowerUpType = PowerUpType.RANDOM

# 道具图标（在编辑器中指定）
@export var icon_texture: Texture2D

# 持续时间（仅对时效性道具有效，单位：秒）
@export var duration: float = 10.0

# 浮动动画速度
@export var float_speed: float = 2.0

# 初始 Y 偏移
var initial_y: float = 0.0


# ==================== 运行时变量 ====================

# 双倍分数效果的激活时间戳
var double_score_until: float = 0.0

# 护盾是否激活
var shield_active: bool = false

# 当前分数倍率（1 = 正常，2 = 双倍）
var score_multiplier: float = 1.0


# ==================== 生命周期 ====================

# 场景初始化
func _ready() -> void:
    # 记录初始 Y 位置
    initial_y = position.y

    # 连接碰撞信号
    body_entered.connect(_on_body_entered)

    # 如果道具类型为 RANDOM，随机分配一个类型
    if power_up_type == PowerUpType.RANDOM:
        power_up_type = PowerUpType.values()[randi() % 4]

    # 根据类型设置外观颜色（便于调试）
    _set_color_by_type()

    # 播放出现粒子效果
    if ParticleManager:
        ParticleManager.play_powerup_appear_effect(global_position)

    # 播放道具音效
    if AudioManager:
        AudioManager.play_sound("powerup")

    print("道具已创建，类型:", _get_type_name())


# ==================== 每帧更新 ====================

# 实现上下浮动效果
func _process(delta: float) -> void:
    position.y = initial_y + sin(Time.get_ticks_msec() / 300.0) * 5.0

    # 检查效果是否过期
    cleanup_expired_effects()


# ==================== 信号回调 ====================

# 当有身体进入碰撞区域时调用
func _on_body_entered(body: Node2D) -> void:
    # 检查进入的是否为玩家
    if body.is_class("CharacterBody2D"):
        # 激活道具效果
        _activate_power_up()

        # 播放收集动画并销毁
        _play_collect_animation()


# ==================== 公共方法 ====================

# 激活道具效果
func _activate_power_up() -> void:
    match power_up_type:
        PowerUpType.SHIELD:
            # 护盾：标记激活状态
            shield_active = true
            if body_has_method("activate_shield"):
                $body.call("activate_shield")
            print("获得护盾！可抵挡一次伤害")

        PowerUpType.DOUBLE_SCORE:
            # 双倍分数：设置倍率和过期时间
            score_multiplier = 2.0
            double_score_until = Time.get_ticks_msec() / 1000.0 + duration
            if body_has_method("activate_double_score"):
                $body.call("activate_double_score", duration)
            print("获得双倍分数！持续", duration, "秒")

        PowerUpType.HEALTH:
            # 回血：直接恢复生命值
            GameData.heal(1)
            print("恢复1点生命！")


# 检查当前是否有活跃的效果
func get_active_effects() -> Dictionary:
    """返回当前激活的效果列表"""
    var effects := {}

    if shield_active:
        effects.shield = true

    if score_multiplier > 1.0 and Time.get_ticks_msec() / 1000.0 < double_score_until:
        effects.double_score = true

    return effects


# 清理过期的效果
func cleanup_expired_effects() -> void:
    """检查并清理已过期的道具效果"""
    # 检查双倍分数是否过期
    if score_multiplier > 1.0 and Time.get_ticks_msec() / 1000.0 >= double_score_until:
        score_multiplier = 1.0
        print("双倍分数效果已过期")


# ==================== 私有方法 ====================

# 根据道具类型设置颜色（用于可视化区分）
func _set_color_by_type() -> void:
    match power_up_type:
        PowerUpType.SHIELD:
            modulate = Color.CYAN  # 青色 = 护盾
        PowerUpType.DOUBLE_SCORE:
            modulate = Color.GOLD  # 金色 = 双倍分数
        PowerUpType.HEALTH:
            modulate = Color.GREEN  # 绿色 = 回血


# 获取道具类型的中文名称
func _get_type_name() -> String:
    match power_up_type:
        PowerUpType.SHIELD:
            return "护盾"
        PowerUpType.DOUBLE_SCORE:
            return "双倍分数"
        PowerUpType.HEALTH:
            return "回血"
        _:
            return "未知"


# 播放收集动画
func _play_collect_animation() -> void:
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.15)  # 快速放大
    tween.tween_property(self, "modulate:a", 0.0, 0.2)             # 淡出
    tween.tween_callback(queue_free)                                 # 销毁


# 辅助：检查节点是否有某个方法
func body_has_method(body: Node2D, method: String) -> bool:
    return body.has_method(method)
