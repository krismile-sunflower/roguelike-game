# GDScript 约定

## 坐标

- 逻辑层使用 `Vector2i` 网格坐标。
- 渲染层使用 `_cell_to_world(cell)` 转成像素坐标。
- 不要在战斗、寻路或拾取逻辑中直接比较像素位置。

## 输入

当前主循环使用 `_input(event)` 处理键盘：

- 方向键 / WASD / HJKL 转为 `Vector2i` 方向，并由 `_process(delta)` 轮询实现按住连续移动。
- Shift 调用 `_attempt_dash()`，向当前方向短冲刺最多 2 格。
- Space 和 `.` 会清空当前移动方向，让玩家停下脚步重新观察。
- Esc 根据当前状态暂停、继续或返回菜单。
- R 重开当前层。

新增快捷键时，先确认不会和 Godot UI 按钮焦点冲突。

## 配置数据

楼层、敌人和素材路径暂时放在 `scripts/main.gd` 顶部的常量字典中。

约定：

- 字典字段使用英文 snake_case。
- 展示文本可以使用中文。
- 新增贴图时先注册 `TEXTURE_PATHS`，再在逻辑中引用贴图键。
- 不要在逻辑中散落裸路径。

## 动态节点

主场景保持轻量，节点由 `main.gd` 动态创建：

- `map_layer`：地面和墙。
- `decor_layer`：非阻挡装饰。
- `item_layer`：药水、金币、装备。
- `item_layer`：药水、金币、装备、宝箱和喷泉。
- `actor_layer`：玩家、敌人、出口。
- `fx_layer`：预留特效层。
- `ui_layer`：HUD。

清理楼层时使用 `_clear_layer()`，不要手动逐个删除某一类节点。

## 资源引用

- 使用 `res://assets/...` 路径。
- 下载或新增第三方资源后，必须更新 `assets/licenses/SOURCES.md`。
- 像素素材的 `Sprite2D.texture_filter` 设为 `CanvasItem.TEXTURE_FILTER_NEAREST`。

## 实时格子逻辑

玩家输入与移动入口集中在：

- `_process(delta)`
- `_tick_player_movement(delta)`
- `_get_held_direction()`
- `_attempt_player_step(direction)`
- `_attempt_dash()`
- `_handle_player_landing()`
- `_wait_turn()`

敌人行动集中在：

- `_tick_enemies(delta)`
- `_run_single_enemy(enemy)`
- `_best_enemy_step(enemy)`
- `_enemy_attack_player(enemy)`
- `_trigger_boss_phase(enemy)`

互动物集中在：

- `_open_chest_at(cell)`
- `_use_fountain_at(cell)`
- `_chest_at(cell)`
- `_fountain_at(cell)`

楼层祝福集中在：

- `_show_reward_choices()`
- `_apply_reward(reward)`

避免让玩家或敌人在动画 tween 完成后再改变逻辑坐标；逻辑坐标应当先更新，动画只负责表现。

## 存档

`SaveManager` 当前保存的是轻量进度：

- 当前层级。
- 已完成层记录。
- 最高分。
- 少量历史字段。

它不保存层内地图、敌人状态或背包。继续游戏会从保存层级重新生成一层地牢。
