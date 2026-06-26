# Godot 2D Roguelike Demo 项目
# 一个完整的 2D Roguelike 游戏原型
# 包含：玩家控制、敌人AI、道具系统、随机地下城、存档、音效、粒子效果

## 项目结构
```
godot-demo/
├── project.godot              # 项目配置（AutoLoad: GameData, GameState, AudioManager, ParticleManager, SaveManager）
├── .gitignore                 # Git 忽略规则
├── README.md                  # 本文件
├── scenes/                    # 场景文件（需在 Godot 编辑器中创建）
│   ├── player.tscn            # 玩家场景
│   ├── collectible.tscn       # 收集品场景
│   ├── enemy.tscn             # 敌人场景
│   ├── power_up.tscn          # 道具场景
│   ├── level_generator.tscn   # 地图生成器场景
│   ├── dungeon_generator.tscn # 地下城生成器场景
│   └── main.tscn              # 主场景
└── scripts/                   # 脚本文件
    ├── game_data.gd           # 全局游戏数据（分数、生命、信号）
    ├── game_state.gd          # 游戏状态管理（开始/暂停/结束/最高分）
    ├── audio_manager.gd       # 音频管理器（SFX + BGM，音量设置，本地持久化）
    ├── particle_manager.gd    # 粒子效果管理器（收集闪光、受伤火花、爆炸）
    ├── save_manager.gd        # 存档管理器（JSON 序列化，最高分/进度/统计）
    ├── player.gd              # 玩家控制（移动、跳跃、重力、无敌时间、屏幕震动）
    ├── collectible.gd         # 收集品逻辑（碰撞加分、浮动动画、粒子效果）
    ├── enemy.gd               # 敌人AI（巡逻、3种类型、碰撞伤害、死亡特效）
    ├── power_up.gd            # 道具系统（护盾/双倍分数/回血、随机生成）
    ├── room.gd                # 房间节点（Roguelike 房间类、类型枚举）
    ├── dungeon_generator.gd   # 地下城生成器（房间生成、连接、走廊）
    ├── level_generator.gd     # 网格地图生成器（障碍物、自动分布）
    └── hud.gd                 # UI 显示（分数、生命、关卡、道具效果、游戏结束面板）
```

## 核心系统

### 1. 游戏数据 (game_data.gd)
- 分数和生命值管理
- 信号通知 UI 实时更新
- 加减血、恢复生命

### 2. 游戏状态 (game_state.gd)
- 四种状态：空闲/进行中/暂停/结束
- ESC 切换暂停，Enter 重新开始
- 自动记录最高分和游玩统计
- 背景音乐播放控制

### 3. 音频管理 (audio_manager.gd)
- 音效(SFX)和背景音乐(BGM)分离
- 音量设置本地持久化(JSON)
- 淡入淡出效果
- 开关切换

### 4. 粒子效果 (particle_manager.gd)
- 收集闪光（金色扩散）
- 受伤火花（红色飞溅）
- 敌人爆炸（橙红爆发）
- 道具出现（紫色上升）

### 5. 存档系统 (save_manager.gd)
- JSON 序列化存档
- 最高分、关卡进度、游玩统计
- 音量设置持久化
- 支持导出/导入存档字符串

### 6. 玩家控制 (player.gd)
- 左右移动 + 跳跃 + 重力
- 无敌时间（受伤后闪烁）
- 屏幕震动反馈
- 护盾/双倍分数效果接口

### 7. 敌人系统 (enemy.gd)
- 左右巡逻 AI
- 3种类型：基础/快速/耐打
- 碰撞伤害 + 死亡特效
- 接触后销毁

### 8. 道具系统 (power_up.gd)
- 3种道具：护盾/双倍分数/回血
- 随机生成，颜色区分
- 时效性道具自动过期
- 浮动动画

### 9. 地图生成 (level_generator.gd + dungeon_generator.gd)
- 网格地图：障碍物 + 自动分布
- 地下城：多房间 + 走廊连接
- 可配置难度参数

### 10. UI 显示 (hud.gd)
- 分数、生命、关卡实时显示
- 道具效果指示
- 暂停提示
- 游戏结束面板（最终分数、最高分、统计、重新开始）

## 快速开始

### 1. 安装 Godot
从 https://godotengine.org/ 下载并安装 Godot 4.x

### 2. 打开项目
启动 Godot → 点击 "Import" → 选择 godot-demo 文件夹

### 3. 创建场景（在 Godot 编辑器中）

**主场景 (main.tscn):**
```
MainScene (Node2D)
├── Player (场景引用 player.tscn)
├── LevelGenerator (场景引用 level_generator.tscn)
├── DungeonGenerator (场景引用 dungeon_generator.tscn)
├── Collectible × 多个
├── Enemy × 多个
├── PowerUp × 多个
└── HUD (场景引用 hud.tscn)
```

**玩家场景 (player.tscn):**
```
Player (CharacterBody2D)
├── Sprite2D          - 显示玩家图片
└── CollisionShape2D  - 矩形碰撞体
```

**收集品场景 (collectible.tscn):**
```
Collectible (Area2D)
├── Sprite2D          - 显示金币/道具图片
└── CollisionShape2D  - 圆形碰撞体
```

**敌人场景 (enemy.tscn):**
```
Enemy (CharacterBody2D)
├── Sprite2D          - 显示敌人图片
├── CollisionShape2D  - 矩形碰撞体
└── CollisionArea (Area2D)
    └── CollisionShape2D - 圆形碰撞体
```

**HUD 场景 (hud.tscn):**
```
HUD (CanvasLayer)
├── ScoreLabel (Label)
├── HealthLabel (Label)
├── LevelLabel (Label)
├── EffectsLabel (Label)
├── PanelGameOver (Panel)
│   ├── FinalScoreLabel (Label)
│   ├── HighScoreLabel (Label)
│   ├── RestartHintLabel (Label)
│   └── StatsLabel (Label)
```

### 4. 链接脚本
在 Godot 编辑器中，选中对应节点 → 右侧面板 → "Attach Script"

### 5. 运行
点击编辑器顶部的绿色三角按钮，或按 F5

### 6. 操作说明
| 按键 | 功能 |
|---|---|
| ← → | 左右移动 |
| 空格 | 跳跃 |
| ESC | 暂停/继续 |
| Enter | 游戏结束后重新开始 |

## 技术要点

### AutoLoad 单例
GameData, GameState, AudioManager, ParticleManager, SaveManager 都在 project.godot 中注册为 AutoLoad，游戏任意脚本可直接通过 `GameData.xxx` 访问。

### 信号系统
- GameData → score_changed, health_changed
- GameState → state_changed, level_changed, game_over
- HUD 连接这些信号，自动更新显示

### 存档持久化
- 使用 `user://` 目录保存 JSON 文件
- 自动保存：最高分、关卡进度、游玩统计、音量设置
- 手动保存：按特定键触发

## 下一步扩展方向

### 短期
1. 添加真实音效文件（替换占位）
2. 添加像素美术资源
3. 添加行走/跳跃/受伤动画
4. 添加关卡过渡动画

### 中期（Roguelike 深化）
1. 多房间地下城（BSP 算法）
2. 局内成长系统（升级、技能树）
3. 道具/技能组合系统
4. 掉落池设计和权重

### 长期
1. 关卡选择/进度系统
2. 成就系统
3. 多人合作/对抗模式
4. 发布到 itch.io / Steam

## 常见问题

### Q: 如何改变移动速度？
A: 修改 player.gd 中的 SPEED 常量

### Q: 如何改变跳跃高度？
A: 修改 player.gd 中的 JUMP_VELOCITY

### Q: 如何调整地图难度？
A: 在 Godot 编辑器中选中 LevelGenerator/DungeonGenerator，调整:
- obstacle_probability: 障碍物概率
- enemy_count: 敌人数量
- collectible_count: 收集品数量

### Q: 如何添加新道具类型？
A: 在 power_up.gd 的 PowerUpType 枚举中添加新类型，然后在 _activate_power_up() 中添加对应逻辑

### Q: 存档文件在哪里？
A: Linux 下位于 `~/.local/share/godot/app_userdata/GodotDemo/savegame.json`

## 许可证
MIT License - 可自由用于个人和商业项目
