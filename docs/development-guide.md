# Godot 2D Roguelike Demo - 开发指南

## 1. 环境搭建

### 1.1 安装 Godot

1. 访问 https://godotengine.org/download
2. 下载 Godot 4.3+ 稳定版
3. 解压即可使用（无需安装）

### 1.2 导入项目

1. 启动 Godot
2. 点击 "Import" 按钮
3. 选择 `/root/project/godot-demo` 文件夹
4. 点击 "Import & Edit"

### 1.3 项目配置检查

导入后，确认以下配置：

- **项目设置** → **Input Map**：检查输入映射是否正确
- **项目设置** → **Display** → **Window**：检查窗口大小
- **项目设置** → **Autoload**：检查 AutoLoad 单例是否注册

---

## 2. 场景搭建

### 2.1 创建主场景

1. 点击场景面板左上角 "+" 按钮
2. 选择 "2D Scene"
3. 根节点改为 `Node2D`
4. 命名为 `MainScene`
5. 保存为 `res://scenes/main.tscn`

### 2.2 搭建主场景层级

按照以下层级添加节点：

```
MainScene (Node2D)
├── Player (场景引用)
├── LevelGenerator (场景引用)
├── Collectible × 3
├── Enemy × 2
├── PowerUp × 1
└── HUD (场景引用)
```

**操作步骤：**

1. **添加玩家：**
   - 右键 MainScene → Add Child Node
   - 选择 "Scene" → "New Scene"
   - 根节点选 `CharacterBody2D`
   - 命名为 `Player`
   - 附加脚本 `player.gd`

2. **添加收集品：**
   - 右键 MainScene → Add Child Node
   - 选择 "Area2D"
   - 添加子节点 `Sprite2D` 和 `CollisionShape2D`
   - 附加脚本 `collectible.gd`
   - 复制 2 个，调整位置

3. **添加敌人：**
   - 右键 MainScene → Add Child Node
   - 选择 "CharacterBody2D"
   - 添加子节点 `Sprite2D`、`CollisionShape2D`、`Area2D(CollisionArea)`
   - 附加脚本 `enemy.gd`
   - 复制 1 个，调整位置

4. **添加道具：**
   - 右键 MainScene → Add Child Node
   - 选择 "Area2D"
   - 添加子节点 `Sprite2D` 和 `CollisionShape2D`
   - 附加脚本 `power_up.gd`

5. **添加 HUD：**
   - 右键 MainScene → Add Child Node
   - 选择 "CanvasLayer"
   - 命名为 `HUD`
   - 添加子节点 `Label` × 5
   - 分别命名为：`ScoreLabel`、`HealthLabel`、`LevelLabel`、`EffectsLabel`、`PanelGameOver`
   - 附加脚本 `hud.gd`

### 2.3 设置节点属性

**Player 节点：**
- 在 Inspector 中调整 Sprite2D 的 Texture（可选）
- 调整 CollisionShape2D 的大小

**Collectible 节点：**
- 设置 `points` 属性（默认 10）
- 调整 Sprite2D 的 Texture

**Enemy 节点：**
- 设置 `speed`、`damage`、`patrol_range`
- 设置 `enemy_type`（0=基础，1=快速，2=耐打）

**PowerUp 节点：**
- 设置 `power_up_type`（0=护盾，1=双倍分数，2=回血，3=随机）
- 设置 `duration`（默认 10 秒）

**HUD 节点：**
- 调整 Label 的位置和样式
- PanelGameOver 默认 `visible = false`

---

## 3. 脚本链接

### 3.1 链接脚本步骤

1. 在场景树中选择节点
2. 在右侧 Inspector 面板点击 "Attach Script"
3. 选择脚本文件路径
4. 点击 "Create"

### 3.2 需要链接的脚本

| 节点 | 脚本文件 |
|---|---|
| Player (CharacterBody2D) | scripts/player.gd |
| Collectible (Area2D) | scripts/collectible.gd |
| Enemy (CharacterBody2D) | scripts/enemy.gd |
| PowerUp (Area2D) | scripts/power_up.gd |
| HUD (CanvasLayer) | scripts/hud.gd |
| LevelGenerator (Node2D) | scripts/level_generator.gd |

---

## 4. 运行测试

### 4.1 启动游戏

- 点击顶部绿色三角按钮
- 或按 F5 快捷键

### 4.2 测试操作

| 操作 | 按键 | 预期效果 |
|---|---|---|
| 移动 | ← → | 角色左右移动 |
| 跳跃 | 空格 | 角色跳跃 |
| 收集 | 触碰金色方块 | 分数增加，粒子效果 |
| 受伤 | 触碰红色方块 | 生命减少，屏幕震动 |
| 道具 | 触碰紫色方块 | 获得效果 |
| 暂停 | ESC | 游戏暂停 |
| 结束 | 生命归零 | 显示游戏结束面板 |
| 重启 | Enter | 重新开始游戏 |

### 4.3 调试技巧

1. **查看输出：** 底部 "Output" 面板显示 print 信息
2. **检查节点：** 场景树面板查看节点层级
3. **调试变量：** 在 Inspector 中修改属性实时测试
4. **断点调试：** 在脚本行号左侧点击设置断点

---

## 5. 资源准备

### 5.1 目录结构

```
assets/
├── images/
│   ├── player.png       # 玩家图片
│   ├── enemy.png        # 敌人图片
│   ├── collectible.png  # 收集品图片
│   ├── powerup.png      # 道具图片
│   └── background.png   # 背景图片
├── audio/
│   ├── sfx/
│   │   ├── jump.ogg     # 跳跃音效
│   │   ├── collect.ogg  # 收集音效
│   │   ├── hurt.ogg     # 受伤音效
│   │   ├── enemy_die.ogg # 敌人死亡音效
│   │   ├── powerup.ogg  # 道具音效
│   │   └── game_over.ogg # 游戏结束音效
│   └── bgm/
│       ├── gameplay.ogg # 背景音乐
│       └── game_over.ogg # 结束音乐
└── fonts/
    └── font.ttf         # 自定义字体
```

### 5.2 导入资源

1. 将资源文件放入对应目录
2. 在 Godot 的 "FileSystem" 面板中右键 → "Reload"
3. 拖拽资源到 Inspector 的 Texture 属性

### 5.3 资源要求

- **图片格式：** PNG（支持透明）
- **音频格式：** OGG 或 WAV
- **字体格式：** TTF 或 OTF
- **建议尺寸：** 32x32 或 64x64 像素

---

## 6. 参数调优

### 6.1 玩家参数

在 `player.gd` 中调整：

```gdscript
const SPEED: float = 200.0        # 移动速度
const JUMP_VELOCITY: float = -400.0  # 跳跃力度
var gravity: float = 980.0        # 重力
var invincible_time: float = 1.5  # 无敌时间
```

### 6.2 地图参数

在 Godot 编辑器中选中 LevelGenerator 节点，调整：

| 参数 | 默认值 | 说明 |
|---|---|---|
| grid_width | 20 | 地图宽度（格子） |
| grid_height | 15 | 地图高度（格子） |
| cell_size | 64 | 格子大小（像素） |
| obstacle_probability | 0.3 | 障碍物概率 |
| collectible_count | 10 | 收集品数量 |
| enemy_count | 5 | 敌人数量 |
| powerup_count | 3 | 道具数量 |

### 6.3 敌人参数

在 Godot 编辑器中选中 Enemy 节点，调整：

| 参数 | 默认值 | 说明 |
|---|---|---|
| speed | 100 | 移动速度 |
| damage | 1 | 伤害值 |
| patrol_range | 200 | 巡逻范围 |
| enemy_type | 0 | 敌人类型 |

---

## 7. 常见问题排查

### 7.1 场景无法运行

**问题：** 点击运行后无反应

**解决：**
1. 检查 project.godot 中的 `run/main_scene` 是否正确
2. 确认主场景已保存
3. 检查控制台是否有错误信息

### 7.2 脚本未生效

**问题：** 脚本中的代码不执行

**解决：**
1. 确认脚本已正确链接到节点
2. 检查 `_ready()` 和 `_physics_process()` 是否拼写正确
3. 查看 Output 面板是否有报错

### 7.3 碰撞不触发

**问题：** 碰到收集品没有加分

**解决：**
1. 确认 Area2D 的 CollisionShape2D 已设置
2. 确认 CharacterBody2D 有 CollisionShape2D
3. 检查物理层设置（Project Settings → Physics → 2D Physics）

### 7.4 信号未触发

**问题：** 分数变化但 UI 不更新

**解决：**
1. 确认 `_ready()` 中已连接信号
2. 确认回调函数名称正确
3. 在回调函数中添加 print 调试

---

## 8. 发布准备

### 8.1 打包设置

1. 点击 "Project" → "Export..."
2. 添加平台（PC / Android / Web）
3. 配置导出模板

### 8.2 发布到 itch.io

1. 打包 PC 版本（Windows/Mac/Linux）
2. 创建 itch.io 项目页面
3. 上传构建文件
4. 设置价格和描述

### 8.3 发布到 Steam

1. 准备 Steam Direct Fee
2. 创建商店页面
3. 上传构建包
4. 等待审核

---

## 9. 性能优化

### 9.1 粒子优化

- 使用 `one_shot` 模式
- 控制粒子数量（建议 ≤ 50）
- 粒子结束后立即销毁

### 9.2 音频优化

- 使用 OGG 格式（体积小，音质好）
- 预加载常用音频
- 音效池复用

### 9.3 内存优化

- 避免在 `_process` 中创建对象
- 及时 `queue_free()` 不需要的节点
- 使用 `preload()` 预加载资源

---

## 10. 团队协作

### 10.1 Git 工作流

```bash
# 创建功能分支
git checkout -b feature/enemy-system

# 提交更改
git add -A
git commit -m "feat: 添加敌人系统"

# 合并到主分支
git checkout main
git merge feature/enemy-system
```

### 10.2 分支命名

| 类型 | 命名 | 示例 |
|---|---|---|
| 新功能 | feature/xxx | feature/player-animation |
| Bug修复 | fix/xxx | fix/collision-detection |
| 文档 | docs/xxx | docs/readme-update |
| 重构 | refactor/xxx | refactor/audio-system |
