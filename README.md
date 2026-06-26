# Godot 2D 入门 Demo 项目
# 一个基础的可玩原型，展示玩家移动、跳跃、收集物品和计分
#
# 项目结构：
#   project.godot      - Godot 项目配置（窗口大小、输入映射、自动加载）
#   scripts/           - 所有 GDScript 脚本
#   scenes/            - 场景文件（.tscn，需用 Godot 编辑器创建）
#   README.md          - 项目说明文档
#
# 核心概念：
#   1. CharacterBody2D - 玩家控制器，处理移动和物理碰撞
#   2. Area2D          - 收集品检测区域，触发碰撞时加分
#   3. CanvasLayer     - HUD 界面，始终显示在最上层
#   4. Signal          - 信号系统，实现数据和 UI 的解耦
#   5. AutoLoad         - 全局单例，游戏任意处可访问
#   6. GameState       - 游戏状态管理（开始、暂停、结束）
#   7. LevelGenerator  - 随机地图生成器（Roguelike 核心）

## 快速开始

### 1. 安装 Godot
从 https://godotengine.org/ 下载并安装 Godot 4.x

### 2. 打开项目
启动 Godot → 点击 "Import" → 选择 godot-demo 文件夹

### 3. 创建场景（在 Godot 编辑器中）
按以下层级搭建场景：

**主场景 (main.tscn):**
```
MainScene (Node2D)
├── Player (场景引用 player.tscn)
├── LevelGenerator (场景引用 level_generator.tscn)
├── Collectible (场景引用 collectible.tscn) × 多个
├── Enemy (场景引用 enemy.tscn) × 多个
├── PowerUp (场景引用 power_up.tscn) × 多个
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
├── ScoreLabel (Label)   - 显示分数
├── HealthLabel (Label)  - 显示生命
├── LevelLabel (Label)   - 显示关卡
├── EffectsLabel (Label) - 显示道具效果
└── GameOverLabel (Label)- 显示游戏结束信息
```

### 4. 链接脚本
在 Godot 编辑器中，选中对应节点 → 右侧面板 → "Attach Script"
- Player 节点 → player.gd
- Collectible 节点 → collectible.gd
- Enemy 节点 → enemy.gd
- PowerUp 节点 → power_up.gd
- HUD 节点 → hud.gd
- LevelGenerator 节点 → level_generator.gd

### 5. 运行
点击编辑器顶部的绿色三角按钮，或按 F5

### 6. 操作说明
- ← → 方向键：左右移动
- 空格键：跳跃
- ESC 键：暂停/继续
- Enter 键：游戏结束后重新开始
- 碰到金色收集品：增加分数
- 碰到红色敌人：扣除生命
- 碰到彩色道具：获得特殊效果

## 新增功能说明

### 敌人系统 (enemy.gd)
- 左右巡逻 AI
- 碰到玩家造成伤害
- 接触后销毁（一次性攻击）

### 道具系统 (power_up.gd)
- 三种道具：护盾、双倍分数、回血
- 随机生成，各有不同颜色标识
- 时效性道具自动过期

### 随机地图 (level_generator.gd)
- 网格化地图生成
- 可配置障碍物密度
- 自动分布收集品、敌人、道具
- 支持重新生成（下一关）

### 游戏状态 (game_state.gd)
- 四种状态：空闲、进行中、暂停、结束
- ESC 切换暂停
- 生命值归零自动结束
- 自动记录最高分

## 技术要点详解

### 信号系统 (Signal)
Godot 的信号系统是事件驱动的核心：
- GameData 发出 score_changed / health_changed 信号
- GameState 发出 state_changed / level_changed 信号
- HUD 连接这些信号，自动更新显示
- 好处：数据和 UI 完全解耦，互不依赖

### 物理移动
- CharacterBody2D.velocity 存储当前速度
- move_and_slide() 自动处理碰撞和地面检测
- is_on_floor() 判断是否着地，用于限制跳跃

### 单例模式 (AutoLoad)
- GameData 和 GameState 在 project.godot 中注册为 AutoLoad
- 游戏启动时自动创建，销毁时自动移除
- 任何脚本都可直接通过 GameData.xxx / GameState.xxx 访问

### 随机地图生成
- 二维数组存储地图数据（0 = 空地，1 = 障碍物）
- 边缘自动设为围墙
- 内部按概率随机生成障碍物
- 收集品、敌人、道具随机放置在空地上

## 下一步扩展方向

### 短期扩展
1. 添加音效（跳跃、收集、受伤、敌人死亡）
2. 添加动画（行走、跳跃、收集、受伤）
3. 添加粒子效果（收集闪光、受伤火花）
4. 添加关卡过渡动画

### 中期扩展（Roguelike 方向）
1. 多房间地图（而非单一网格）
2. 局内成长系统（升级、技能解锁）
3. 道具/技能组合系统
4. 掉落池设计和权重

### 长期扩展
1. 关卡选择/进度系统
2. 存档系统（JSON 序列化）
3. 多人合作/对抗模式
4. 发布到 itch.io / Steam

## 常见问题

### Q: 如何改变移动速度？
A: 修改 player.gd 中的 SPEED 常量

### Q: 如何改变跳跃高度？
A: 修改 player.gd 中的 JUMP_VELOCITY（更负 = 跳得更高）

### Q: 如何改变重力？
A: 修改 player.gd 中的 gravity 变量，或在 project.godot 中调整全局重力

### Q: 收集品分数怎么改？
A: 在 Godot 编辑器中选中 Collectible 节点，Inspector 面板修改 "Points" 属性

### Q: 如何调整地图难度？
A: 在 Godot 编辑器中选中 LevelGenerator 节点，调整:
   - obstacle_probability: 障碍物概率
   - enemy_count: 敌人数量
   - collectible_count: 收集品数量

### Q: 如何添加新道具类型？
A: 在 power_up.gd 的 PowerUpType 枚举中添加新类型，然后在 _activate_power_up() 中添加对应逻辑

## 许可证
MIT License - 可自由用于个人和商业项目
