# 架构说明

## 概览

当前项目是一个单屏整理谜题原型，主循环固定为：

`主菜单 → 进入关卡 → 拖放整理 → 完成反馈 → 下一关或回到主页`

项目不再以玩家移动、敌人碰撞、战斗或随机地牢为主流程。当前所有运行逻辑都围绕单场景整理体验展开。

## 运行入口

- 主入口场景：`res://scenes/main.tscn`
- 根节点：`MainScene (Node2D)`
- 主控制脚本：`res://scripts/main.gd`

`main.tscn` 是唯一运行入口，负责承载：

- 背景与桌面视觉层
- 目标区域层 `TargetsLayer`
- 可拖动物品层 `ItemsLayer`
- HUD
- 主菜单层
- 说明页层
- 暂停层
- 教学层
- 完成反馈层

## 主流程脚本

当前运行链的核心脚本如下：

- `main.gd`
  - 管理菜单、说明页、暂停、教程、关卡加载、完成流程
  - 保存当前关卡数据
  - 处理拖拽输入与放置判定
- `hud.gd`
  - 显示关卡标题、目标说明、整理进度、提示次数、状态文案
  - 提供提示、帮助、重置入口
- `draggable_item.gd`
  - 定义物品的拾取、拖动、放下、回位、吸附表现
- `drop_target.gd`
  - 定义目标区域规则、命中范围、可接收条件和吸附槽位

## AutoLoad 职责

### `GameData`

负责轻量进度数据：

- `current_level_index`
- `completed_levels`
- `hint_count`
- `total_levels`
- `has_seen_tutorial`

同时保留了旧阶段遗留的 `score` 和 `player_health` 字段，但它们不再属于当前整理玩法的核心数据。

### `GameState`

负责整理流程状态机：

- `MENU`
- `INSTRUCTIONS`
- `PLAYING`
- `PAUSED`
- `COMPLETED`

主要信号：

- `state_changed`
- `level_changed`
- `level_completed`

### `SaveManager`

负责本地 JSON 存档，当前重点保存：

- 当前关卡索引
- 完成记录
- 提示次数
- 是否看过教程
- 是否已有存档

### `AudioManager`

当前为安全空实现，保留接口但不依赖资源存在。

### `ParticleManager`

当前为安全空实现，保留特效接口但不阻塞运行。

## 关卡数据组织

当前 10 个关卡数据直接写在 `main.gd` 的 `LEVELS` 常量中。每一关包含：

- `title`
- `goal`
- `background_color`
- `desk_color`
- `targets`
- `items`

### 目标区域

每个 target 至少包含：

- `id`
- `label`
- `mode`
- `position`
- `size`

按模式不同，还会使用：

- `accepted_item_ids`
- `accepted_category`
- `slot_positions`

### 可拖动物品

每个 item 至少包含：

- `id`
- `label`
- `target_id`
- `home_position`
- `size`
- `color`

分类关还会带：

- `category`

## 拖放与判定

当前拖放由 `main.gd` 统一处理输入：

- 鼠标按下时，从顶层物品开始命中检测
- 拾取后将物品提升到最上层
- 鼠标移动时持续更新物品位置
- 鼠标释放时，遍历 `DropTarget` 进行命中和可接收判断

判定结果分两类：

- 正确命中：目标接收物品，返回吸附位置，物品平滑吸附
- 错误命中或未命中：物品回到原位

## UI 分层

当前 UI 基于 `CanvasLayer + Control` 组织。

重要约束：

- 游戏拖拽使用 `_input()`，不是 `_unhandled_input()`
- 非交互 UI 要正确设置 `mouse_filter`
- 装饰性遮罩和文案不能抢走拖拽输入

这部分是当前整理玩法能否正常操作的关键前提。

## 旧脚本的地位

仓库内仍保留以下旧方向脚本：

- `player.gd`
- `enemy.gd`
- `power_up.gd`
- `level_generator.gd`
- `dungeon_generator.gd`
- `room.gd`
- `collectible.gd`

它们目前的定位是：

- 仍存在于仓库中
- 可能还能被 Godot 资源扫描到
- 但已经退出当前主流程
- 文档与后续开发默认不再围绕这些脚本设计新玩法

如果后续需要清理历史包袱，应当单独做“历史脚本归档或删除”工作，而不是在当前主流程文档里继续把它们当主系统介绍。
