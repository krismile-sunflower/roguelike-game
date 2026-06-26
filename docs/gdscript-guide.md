# Godot 2D Roguelike Demo - GDScript 开发指南

## 1. GDScript 基础

### 1.1 变量声明

```gdscript
# 基本类型
var score: int = 0
var health: float = 100.0
var name: String = "Player"
var is_alive: bool = true

# 集合类型
var positions: Array = []
var config: Dictionary = {}

# 常量（不可修改）
const MAX_HEALTH: int = 100
const SPEED: float = 200.0

# 导出变量（可在编辑器中修改）
@export var enemy_count: int = 5
@export var damage: float = 10.0
```

### 1.2 函数定义

```gdscript
# 基本函数
func greet(name: String) -> void:
    print("Hello, ", name)

# 带返回值
func calculate_score(base: int, multiplier: float) -> int:
    return int(base * multiplier)

# 异步函数（协程）
func wait_and_do() -> void:
    await get_tree().create_timer(2.0).timeout
    print("2秒后执行")
```

### 1.3 生命周期函数

```gdscript
func _ready() -> void:
    """场景树就绪后调用一次"""
    pass

func _process(delta: float) -> void:
    """每帧调用（渲染帧率）"""
    pass

func _physics_process(delta: float) -> void:
    """每物理帧调用（固定帧率）"""
    pass

func _input(event: InputEvent) -> void:
    """输入事件"""
    pass

func _notification(what: int) -> void:
    """节点通知"""
    if what == NOTIFICATION_ENTER_TREE:
        print("进入场景树")
    elif what == NOTIFICATION_EXIT_TREE:
        print("离开场景树")
```

---

## 2. 节点系统

### 2.1 节点类型速查

| 节点类型 | 用途 | 继承自 |
|---|---|---|
| Node2D | 2D场景根节点 | Node |
| CharacterBody2D | 角色控制器 | PhysicsBody2D |
| Area2D | 检测区域 | PhysicsBody2D |
| StaticBody2D | 静态碰撞体 | PhysicsBody2D |
| Sprite2D | 2D精灵（图片） | Node2D |
| CollisionShape2D | 碰撞形状 | Node2D |
| Label | 文本标签 | Control |
| CanvasLayer | UI层 | Node |
| AudioStreamPlayer | 音频播放 | Node |
| GPUParticles2D | GPU粒子 | Node2D |
| Tween | 动画 | Object |

### 2.2 节点操作

```gdscript
# 创建节点
var sprite := Sprite2D.new()
add_child(sprite)

# 查找子节点
var label := $ScoreLabel  # 通过路径查找
var sprite := get_node("Sprite2D")

# 删除节点
sprite.queue_free()  # 安全删除

# 节点层级
add_child(child)      # 添加到末尾
add_child(child, true) # 添加到前面（z-index）
remove_child(child)    # 移除子节点

# 节点类型检查
if node.is_class("CharacterBody2D"):
    print("是角色节点")
```

### 2.3 信号连接

```gdscript
# 连接信号
func _ready() -> void:
    button.pressed.connect(_on_button_pressed)
    area.body_entered.connect(_on_body_entered)

# 定义信号
signal score_changed(new_score: int)
signal health_changed(new_health: int)

# 发出信号
score_changed.emit(100)
health_changed.emit(2)

# 断开信号
button.pressed.disconnect(_on_button_pressed)
```

---

## 3. 物理系统

### 3.1 CharacterBody2D 移动

```gdscript
extends CharacterBody2D

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -400.0

func _physics_process(delta: float) -> void:
    # 应用重力
    velocity.y += get_gravity().y * delta
    
    # 水平移动
    var direction := Input.get_axis("ui_left", "ui_right")
    velocity.x = direction * SPEED
    
    # 跳跃
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
    
    # 移动并处理碰撞
    move_and_slide()
```

### 3.2 碰撞检测

```gdscript
# Area2D 碰撞检测
extends Area2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.is_class("CharacterBody2D"):
        print("玩家进入了区域")

# 物理层碰撞（CharacterBody2D）
# 需要在项目设置中配置物理层
```

### 3.3 碰撞形状

```gdscript
# 矩形碰撞体
var shape := CollisionShape2D.new()
var rect := RectangleShape2D.new()
rect.size = Vector2(32, 32)
shape.shape = rect
add_child(shape)

# 圆形碰撞体
var circle := CircleShape2D.new()
circle.radius = 16
shape.shape = circle
```

---

## 4. 输入系统

### 4.1 输入映射

```gdscript
# 获取输入轴（-1 到 1）
var axis := Input.get_axis("ui_left", "ui_right")

# 按键按下
if Input.is_action_pressed("jump"):
    print("跳跃键按住中")

# 按键按下（仅触发一次）
if Input.is_action_just_pressed("jump"):
    print("跳跃键按下")

# 按键释放
if Input.is_action_just_released("jump"):
    print("跳跃键释放")
```

### 4.2 鼠标输入

```gdscript
# 鼠标位置
var mouse_pos := get_global_mouse_position()

# 鼠标点击
if Input.is_action_just_pressed("mouse_left"):
    print("鼠标左键点击")

# 鼠标移动
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        print("鼠标移动: ", event.relative)
```

---

## 5. 动画系统

### 5.1 Tween 动画

```gdscript
# 创建动画
var tween := create_tween()

# 属性渐变
tween.tween_property(node, "position:x", 500.0, 1.0)
tween.tween_property(node, "modulate:a", 0.0, 0.5)

# 链式动画
tween.tween_property(node, "scale", Vector2(1.5, 1.5), 0.1)
tween.tween_property(node, "modulate:a", 0.0, 0.2)
tween.tween_callback(queue_free)

# 并行动画
var parallel := create_tween().set_parallel(true)
parallel.tween_property(node, "position:x", 100.0, 1.0)
parallel.tween_property(node, "position:y", 200.0, 1.0)
```

### 5.2 动画库

```gdscript
# 创建动画库
var animation_library := AnimationLibrary.new()

# 添加动画
var animation := Animation.new()
animation.track_insert_key(0, 0.0, Vector2(0, 0))
animation.track_insert_key(0, 1.0, Vector2(100, 0))

animation_library.add_animation("walk", animation)
get_node("AnimationPlayer").add_animation_library("", animation_library)
```

---

## 6. 资源管理

### 6.1 加载资源

```gdscript
# 预加载（编译时加载）
@export var player_texture: Texture2D

# 动态加载
var texture := load("res://assets/images/player.png")

# 音频加载
var audio := load("res://assets/audio/sfx/jump.ogg")

# 场景加载
var scene := load("res://scenes/enemy.tscn")
var instance := scene.instantiate()
add_child(instance)
```

### 6.2 资源路径

```
res://          # 项目根目录
res://assets/   # 资源目录
res://scripts/  # 脚本目录
res://scenes/   # 场景目录
```

---

## 7. 数学工具

### 7.1 向量运算

```gdscript
# 向量创建
var v := Vector2(100, 200)
var v2 := Vector2.RIGHT * 50

# 向量运算
var sum := v + v2
var diff := v - v2
var scaled := v * 2.0
var normalized := v.normalized()

# 距离和插值
var dist := v.distance_to(v2)
var lerp := v.linear_interpolate(v2, 0.5)

# 角度
var angle := v.angle()
```

### 7.2 随机数

```gdscript
# 随机整数
var rand_int := randi() % 10  # 0-9

# 随机浮点数
var rand_float := randf()     # 0.0-1.0

# 随机向量
var rand_vec := Vector2(randf(), randf())

# 随机选择
var items := ["apple", "banana", "cherry"]
var chosen := items[randi() % items.size()]
```

---

## 8. 文件系统

### 8.1 文件读写

```gdscript
# 写入文件
var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
file.store_string("Hello, World!")
file.close()

# 读取文件
if FileAccess.file_exists("user://savegame.json"):
    var file := FileAccess.open("user://savegame.json", FileAccess.READ)
    var content := file.get_as_text()
    file.close()

# 删除文件
DirAccess.remove_absolute("user://savegame.json")
```

### 8.2 JSON 序列化

```gdscript
# 序列化
var data := {"score": 100, "level": 3}
var json_str := JSON.stringify(data)

# 反序列化
var parsed := JSON.parse_string(json_str)
if parsed is Dictionary:
    print(parsed["score"])  # 100
```

---

## 9. 调试技巧

### 9.1 打印调试

```gdscript
print("变量值: ", variable)
printerr("错误信息")
push_warning("警告信息")
push_error("错误信息")
```

### 9.2 断言

```gdscript
assert(variable != null, "变量不应为空")
assert(score >= 0, "分数不应为负")
```

### 9.3 性能监控

```gdscript
# FPS 监控
func _process(delta: float) -> void:
    print("FPS: ", Engine.get_frames_per_second())
    print("Delta: ", delta)
```

---

## 10. 最佳实践

### 10.1 命名规范

```gdscript
# 变量和函数：snake_case
var player_score: int = 0
func calculate_damage() -> int:

# 常量：CONSTANT_CASE
const MAX_HEALTH: int = 100

# 类名：PascalCase
class_name MyComponent

# 节点路径：$开头
var label := $ScoreLabel
```

### 10.2 代码组织

```gdscript
# 推荐的文件结构
extends CharacterBody2D

# ==================== 常量 ====================
const SPEED: float = 200.0

# ==================== 属性 ====================
var health: int = 100

# ==================== 信号 ====================
signal died

# ==================== 生命周期 ====================
func _ready() -> void:
    pass

func _physics_process(delta: float) -> void:
    pass

# ==================== 公共方法 ====================
func take_damage(amount: int) -> void:
    pass

# ==================== 私有方法 ====================
func _calculate_damage() -> int:
    pass
```

### 10.3 性能优化

```gdscript
# 避免在 _process 中创建对象
var cached_node: Node2D  # 预先缓存

# 使用信号代替轮询
# 错误做法：每帧检查
func _process(delta: float):
    if player.is_colliding():
        handle_collision()

# 正确做法：使用信号
func _ready():
    player.collision_signal.connect(handle_collision)
```
