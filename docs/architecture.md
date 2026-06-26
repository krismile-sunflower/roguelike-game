# Godot 2D Roguelike Demo - 项目架构文档

## 1. 项目概述

### 1.1 项目定位
本项目是一个基于 Godot 4.x 的 2D Roguelike 游戏原型，面向个人开发者学习和参考。
项目从入门级 demo 逐步演进为功能完整的可发布游戏，涵盖：
- 玩家控制与物理
- 敌人 AI 与战斗
- 道具系统与增益效果
- 随机地下城生成
- 音效与粒子效果
- 存档系统与数据统计
- UI 界面与游戏状态管理

### 1.2 技术栈
- **引擎**: Godot 4.3+
- **语言**: GDScript
- **架构**: 节点场景系统 + 信号驱动 + AutoLoad 单例

### 1.3 项目结构
```
godot-demo/
├── project.godot              # 项目配置
├── scenes/                    # 场景文件（.tscn）
├── scripts/                   # 脚本文件（.gd）
├── assets/                    # 资源目录（音频/图片/字体）
├── docs/                      # 文档目录
└── README.md                  # 项目说明
```

---

## 2. 核心架构

### 2.1 AutoLoad 单例系统

项目使用 Godot 的 AutoLoad 机制管理全局单例，这些单例在游戏启动时自动创建，销毁时自动移除，任何脚本都可以通过实例名直接访问。

| 单例名 | 脚本文件 | 职责 |
|---|---|---|
| GameData | scripts/game_data.gd | 分数、生命值管理，信号通知 |
| GameState | scripts/game_state.gd | 游戏状态机，暂停/结束/最高分 |
| AudioManager | scripts/audio_manager.gd | 音效和背景音乐管理 |
| ParticleManager | scripts/particle_manager.gd | 粒子效果统一管理 |
| SaveManager | scripts/save_manager.gd | 存档读写，数据持久化 |

**使用示例：**
```gdscript
# 在任何脚本中直接访问
GameData.add_score(10)           # 增加分数
GameState.toggle_pause()         # 切换暂停
AudioManager.play_sound("jump")  # 播放音效
SaveManager.save_all()           # 保存存档
```

### 2.2 信号系统

项目采用信号驱动的数据流架构，实现模块间的松耦合通信。

**数据流向：**
```
玩家行为 → GameData 变化 → 信号发出 → HUD 更新
                                    ↓
                              GameState 响应
                                    ↓
                              AudioManager / ParticleManager
```

**核心信号定义：**

| 信号来源 | 信号名 | 参数 | 触发时机 |
|---|---|---|---|
| GameData | score_changed | new_score: int | 分数变化时 |
| GameData | health_changed | new_health: int | 生命值变化时 |
| GameState | state_changed | new_state: int | 游戏状态切换时 |
| GameState | level_changed | level_number: int | 进入新关卡时 |
| GameState | game_over | final_score: int | 游戏结束时 |

**信号连接示例：**
```gdscript
# 在 _ready() 中连接信号
func _ready() -> void:
    GameData.score_changed.connect(_on_score_changed)
    GameData.health_changed.connect(_on_health_changed)

# 信号回调
func _on_score_changed(new_score: int) -> void:
    label_score.text = "分数: %d" % new_score
```

### 2.3 节点场景层级

**主场景 (main.tscn) 层级结构：**
```
MainScene (Node2D)
├── Player (CharacterBody2D)
│   ├── Sprite2D
│   └── CollisionShape2D
├── LevelGenerator (Node2D)
├── DungeonGenerator (Node2D)
├── Collectible × N (Area2D)
├── Enemy × N (CharacterBody2D)
├── PowerUp × N (Area2D)
└── HUD (CanvasLayer)
    ├── ScoreLabel
    ├── HealthLabel
    ├── LevelLabel
    ├── EffectsLabel
    └── PanelGameOver
        ├── FinalScoreLabel
        ├── HighScoreLabel
        ├── RestartHintLabel
        └── StatsLabel
```

---

## 3. 系统详解

### 3.1 游戏数据系统 (GameData)

**职责：** 集中管理游戏核心数值，通过 setter 和信号实现数据变化通知。

**核心属性：**
- `player_health`: 玩家生命值（0-3），setter 自动限制范围
- `score`: 当前分数，setter 确保非负
- `signals`: score_changed, health_changed

**核心方法：**
- `add_score(amount)`: 增加分数
- `take_damage(amount)`: 受到伤害
- `heal(amount)`: 恢复生命
- `reset()`: 重置所有数据

### 3.2 游戏状态系统 (GameState)

**职责：** 管理游戏生命周期，协调各个系统的状态切换。

**四种状态：**
1. **Idle**: 游戏未开始
2. **Playing**: 游戏进行中
3. **Paused**: 游戏暂停
4. **GameOver**: 游戏结束

**状态流转：**
```
Idle → Playing → Paused ↔ Playing → GameOver → Playing
```

**核心特性：**
- ESC 键切换暂停
- Enter 键游戏结束后重新开始
- 自动记录最高分和游玩统计
- 生命值归零自动触发 GameOver

### 3.3 音频管理系统 (AudioManager)

**职责：** 统一管理所有音效和背景音乐。

**双通道设计：**
- **SFX 通道**: 短促音效（跳跃、收集、受伤、敌人死亡）
- **BGM 通道**: 背景音乐（标题、游戏、结束）

**核心功能：**
- 音效池复用（预创建 AudioStreamPlayer）
- 音量独立调节
- 淡入淡出效果
- 开关切换
- 设置持久化（JSON 本地存储）

### 3.4 粒子效果系统 (ParticleManager)

**职责：** 统一管理游戏中的所有粒子效果。

**四种粒子效果：**
1. **收集闪光**: 金色粒子向外扩散
2. **受伤火花**: 红色粒子向外飞溅
3. **敌人爆炸**: 橙红色大范围爆发
4. **道具出现**: 紫色粒子旋转上升

**技术实现：**
- 使用 GPUParticles2D + ParticlesMaterial
- 自定义颜色渐变和缩放曲线
- 一次性粒子（one_shot），结束后自动销毁

### 3.5 存档系统 (SaveManager)

**职责：** 游戏数据的本地持久化存储。

**存档内容：**
- 最高分记录
- 最大关卡进度
- 总游玩时间
- 游戏次数统计
- 音频设置

**存储位置：**
- Linux: `~/.local/share/godot/app_userdata/GodotDemo/savegame.json`
- Windows: `%APPDATA%\Godot\app_userdata\GodotDemo\savegame.json`
- Mac: `~/Library/Application Support/Godot/app_userdata/GodotDemo/savegame.json`

**API：**
- `save_all()`: 保存完整存档
- `load_save()`: 加载存档
- `save_high_score(score)`: 保存最高分
- `increment_stats(won)`: 增加游玩统计
- `clear_save()`: 清除存档
- `export_save_string()`: 导出存档为字符串
- `import_save_string(json_str)`: 从字符串导入存档

### 3.6 地图生成系统

**两级生成架构：**

**LevelGenerator（网格地图）：**
- 二维数组存储地图数据
- 可配置障碍物概率
- 自动分布收集品、敌人、道具
- 边缘自动设为围墙

**DungeonGenerator（多房间地下城）：**
- 房间生成与连接
- 6种房间类型（起始/普通/富饶/Boss/商店/出口）
- 走廊可视化
- 出生点和出口设置

### 3.7 玩家控制系统

**核心机制：**
- CharacterBody2D + move_and_slide()
- 重力物理模拟
- 地面检测限制跳跃
- 平滑移动和减速

**增强特性：**
- 无敌时间（受伤后闪烁）
- 屏幕震动反馈
- 音效和粒子集成
- 道具效果接口（护盾/双倍分数）

### 3.8 敌人 AI 系统

**巡逻 AI：**
- 左右巡逻，到达边界反转
- 3种敌人类型，属性不同
- 碰撞检测触发伤害

**敌人类型：**
| 类型 | 速度 | 伤害 | 特点 |
|---|---|---|---|
| 基础 | 正常 | 1 | 标准敌人 |
| 快速 | 1.5x | 1 | 速度快 |
| 耐打 | 0.7x | 2 | 速度慢但伤害高 |

### 3.9 道具系统

**道具类型：**
| 类型 | 颜色 | 效果 | 持续时间 |
|---|---|---|---|
| 护盾 | 青色 | 抵挡一次伤害 | 永久 |
| 双倍分数 | 金色 | 得分翻倍 | 10秒 |
| 回血 | 绿色 | 恢复1点生命 | 即时 |

**运行机制：**
- 随机生成（也可手动指定）
- 浮动动画
- 碰撞检测触发效果
- 时效性道具自动过期

---

## 4. 数据流图

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Player    │────▶│   GameData   │────▶│    HUD      │
│  (输入/物理) │     │ (分数/生命值) │     │  (UI显示)    │
└─────────────┘     └──────────────┘     └─────────────┘
       │                                       ▲
       ▼                                       │
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Enemy     │────▶│   GameData   │────▶│    HUD      │
│  (碰撞伤害)  │     │ (生命值变化)  │     │  (生命更新)  │
└─────────────┘     └──────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐     ┌──────────────┐
│  AudioManager│◀────│   Enemy     │
│  (死亡音效)  │     │             │
└─────────────┘     └──────────────┘
       │
       ▼
┌─────────────┐
│ ParticleMgr │
│  (爆炸特效)  │
└─────────────┘
```

---

## 5. 配置说明

### 5.1 项目配置 (project.godot)

**关键配置项：**
- `config/name`: 项目名称
- `run/main_scene`: 主场景入口
- `config/features`: Godot 版本要求
- `[autoload]`: AutoLoad 单例注册
- `[input]`: 输入映射定义
- `[display]`: 窗口大小设置

### 5.2 输入映射

| Action | 按键 | 用途 |
|---|---|---|
| ui_left | ← | 向左移动 |
| ui_right | → | 向右移动 |
| jump | 空格 | 跳跃 |
| ui_escape | ESC | 暂停/继续 |
| ui_select | Enter | 重新开始 |

### 5.3 窗口设置

- 视口宽度: 1280px
- 视口高度: 720px
- 渲染器: GL Compatibility

---

## 6. 扩展指南

### 6.1 添加新音效
1. 在 `assets/audio/sfx/` 目录下放入音频文件
2. 在 `audio_manager.gd` 的 `sfx_presets` 字典中添加映射
3. 在需要的地方调用 `AudioManager.play_sound("音效名")`

### 6.2 添加新道具
1. 在 `power_up.gd` 的 `PowerUpType` 枚举中添加新类型
2. 在 `_activate_power_up()` 中添加对应逻辑
3. 在 `_set_color_by_type()` 中添加颜色标识

### 6.3 添加新敌人类型
1. 在 `enemy.gd` 的 `EnemyType` 枚举中添加新类型
2. 在 `_adjust_properties()` 中定义新属性
3. 调整 `_get_type_name()` 返回对应名称

### 6.4 添加新房间类型
1. 在 `room.gd` 的 `RoomType` 枚举中添加新类型
2. 在 `dungeon_generator.gd` 的房间类型分配逻辑中添加
3. 在 `room.gd` 的 `_populate_*_room()` 中添加对应内容

---

## 7. 性能优化建议

### 7.1 粒子效果
- 使用 `one_shot` 模式，结束后自动销毁
- 控制粒子数量，避免过多

### 7.2 音频管理
- 音效池复用，避免频繁创建/销毁
- 使用 `stream` 属性预加载音频资源

### 7.3 地图生成
- 限制随机尝试次数，避免无限循环
- 使用 `randi()` 和 `randf()` 时注意种子

### 7.4 存档系统
- 避免频繁保存，仅在关键节点保存
- 使用 JSON 而非二进制，便于调试

---

## 8. 版本历史

| 版本 | 日期 | 变更 |
|---|---|---|
| v0.1 | 2026-06-26 | 初始化项目，基础移动和收集 |
| v0.2 | 2026-06-26 | 添加敌人、道具、随机地图、游戏状态 |
| v0.3 | 2026-06-26 | 完善为完整 Roguelike，添加音频/粒子/存档 |
