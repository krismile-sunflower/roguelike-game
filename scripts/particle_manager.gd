# ParticleManager - 粒子效果管理器
# 统一管理游戏中的所有粒子效果
# 支持收集闪光、受伤火花、死亡爆炸等效果
extends Node

# ==================== 粒子预设 ====================

# 粒子预设字典：key 为效果名称，value 为 ParticleProcessMaterial
var particle_presets: Dictionary = {}

# 粒子发射器池
var emitter_pool: Array = []


# ==================== 生命周期 ====================

# 场景初始化
func _ready() -> void:
    print("粒子管理器已就绪")


# ==================== 公共方法 ====================

# 播放收集闪光效果
# position: 粒子产生的世界坐标
func play_collect_effect(position: Vector2) -> void:
    var emitter := _create_emitter()
    emitter.position = position

    # 创建金色闪光粒子材质
    var material := GPUParticles2D.create_material()
    material.set_process_material(_create_collect_material())

    var particles := GPUParticles2D.new()
    particles.process_material = material
    particles.one_shot = true
    particles.lifetime = 0.5
    particles.emitting = true
    particles.amount = 12
    particles.position_range_x = 5.0
    particles.position_range_y = 5.0

    add_child(particles)

    # 粒子结束后自动销毁
    await get_tree().create_timer(0.6).timeout
    if particles.is_inside_tree():
        particles.queue_free()


# 播放受伤火花效果
# position: 粒子产生的世界坐标
func play_hurt_effect(position: Vector2) -> void:
    var emitter := _create_emitter()
    emitter.position = position

    var material := GPUParticles2D.create_material()
    material.set_process_material(_create_hurt_material())

    var particles := GPUParticles2D.new()
    particles.process_material = material
    particles.one_shot = true
    particles.lifetime = 0.4
    particles.emitting = true
    particles.amount = 8
    particles.position_range_x = 8.0
    particles.position_range_y = 8.0

    add_child(particles)

    await get_tree().create_timer(0.5).timeout
    if particles.is_inside_tree():
        particles.queue_free()


# 播放敌人死亡爆炸效果
# position: 粒子产生的世界坐标
func play_enemy_die_effect(position: Vector2) -> void:
    var material := GPUParticles2D.create_material()
    material.set_process_material(_create_explosion_material())

    var particles := GPUParticles2D.new()
    particles.process_material = material
    particles.one_shot = true
    particles.lifetime = 0.6
    particles.emitting = true
    particles.amount = 20
    particles.position_range_x = 10.0
    particles.position_range_y = 10.0

    add_child(particles)

    await get_tree().create_timer(0.7).timeout
    if particles.is_inside_tree():
        particles.queue_free()


# 播放道具出现效果
# position: 粒子产生的世界坐标
func play_powerup_appear_effect(position: Vector2) -> void:
    var material := GPUParticles2D.create_material()
    material.set_process_material(_create_powerup_material())

    var particles := GPUParticles2D.new()
    particles.process_material = material
    particles.one_shot = true
    particles.lifetime = 0.8
    particles.emitting = true
    particles.amount = 15
    particles.position_range_x = 6.0
    particles.position_range_y = 6.0

    add_child(particles)

    await get_tree().create_timer(0.9).timeout
    if particles.is_inside_tree():
        particles.queue_free()


# ==================== 私有方法：创建粒子材质 ====================

# 收集闪光材质（金色粒子向外扩散）
func _create_collect_material() -> ParticlesMaterial:
    var material := ParticlesMaterial.new()
    material.speed_scale = 1.0
    material.direction = Vector3.RIGHT
    material.spread = 360.0
    material.initial_velocity_min = 50.0
    material.initial_velocity_max = 150.0
    material.acceleration = Vector3(0, -50, 0)  # 轻微向上飘
    material.random_offset_x = 10.0
    material.random_offset_y = 10.0
    material.color_ramp = _create_color_ramp([
        Color(1.0, 0.84, 0.0, 1.0),   # 金色
        Color(1.0, 1.0, 0.5, 0.8),    # 浅黄
        Color(1.0, 1.0, 1.0, 0.0),    # 白色透明
    ])
    return material


# 受伤火花材质（红色粒子向外飞溅）
func _create_hurt_material() -> ParticlesMaterial:
    var material := ParticlesMaterial.new()
    material.speed_scale = 1.5
    material.direction = Vector3.RIGHT
    material.spread = 360.0
    material.initial_velocity_min = 80.0
    material.initial_velocity_max = 200.0
    material.acceleration = Vector3(0, 100, 0)  # 向下落
    material.random_offset_x = 15.0
    material.random_offset_y = 15.0
    material.color_ramp = _create_color_ramp([
        Color(1.0, 0.0, 0.0, 1.0),    # 红色
        Color(1.0, 0.5, 0.0, 0.6),    # 橙色
        Color(1.0, 1.0, 1.0, 0.0),    # 白色透明
    ])
    return material


# 敌人爆炸材质（橙红色大爆发）
func _create_explosion_material() -> ParticlesMaterial:
    var material := ParticlesMaterial.new()
    material.speed_scale = 2.0
    material.direction = Vector3.RIGHT
    material.spread = 360.0
    material.initial_velocity_min = 100.0
    material.initial_velocity_max = 300.0
    material.acceleration = Vector3(0, 80, 0)
    material.random_offset_x = 20.0
    material.random_offset_y = 20.0
    material.color_ramp = _create_color_ramp([
        Color(1.0, 0.3, 0.0, 1.0),    # 橙红
        Color(1.0, 0.8, 0.0, 0.7),    # 黄色
        Color(1.0, 1.0, 1.0, 0.0),    # 白色透明
    ])
    material.scale_curve = _create_scale_curve([
        0.0, 1.5,
        0.3, 1.0,
        1.0, 0.0,
    ])
    return material


# 道具出现材质（紫色粒子旋转上升）
func _create_powerup_material() -> ParticlesMaterial:
    var material := ParticlesMaterial.new()
    material.speed_scale = 0.8
    material.direction = Vector3.UP
    material.spread = 120.0
    material.initial_velocity_min = 30.0
    material.initial_velocity_max = 80.0
    material.acceleration = Vector3(0, -30, 0)  # 向上飘
    material.random_offset_x = 8.0
    material.random_offset_y = 8.0
    material.color_ramp = _create_color_ramp([
        Color(0.8, 0.0, 1.0, 1.0),    # 紫色
        Color(0.5, 0.0, 1.0, 0.7),    # 蓝紫
        Color(1.0, 1.0, 1.0, 0.0),    # 白色透明
    ])
    return material


# 创建颜色渐变
func _create_color_ramp(colors: Array) -> Gradient:
    var gradient := Gradient.new()
    for i in range(colors.size()):
        gradient.set_color(i, colors[i])
        gradient.set_offset(float(i) / float(colors.size() - 1))
    return gradient


# 创建缩放曲线
func _create_scale_curve(points: Array) -> Curve2D:
    var curve := Curve2D.new()
    for i in range(0, points.size(), 2):
        curve.add_point(Vector2(points[i], points[i + 1]))
    return curve


# 从粒子池获取发射器
func _create_emitter() -> Node2D:
    if emitter_pool.size() > 0:
        return emitter_pool.pop_back()
    return Node2D.new()
