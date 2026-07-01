# GDScript 约定

## 坐标约定

- 逻辑层使用 `Vector2i` 网格坐标。
- 渲染层使用 `_cell_to_world(cell)` 转成像素坐标。
- 不要在战斗、寻路、拾取或陷阱逻辑中直接比较像素位置。
- 逻辑坐标先更新，Tween 只负责表现移动。

## 输入约定

当前主循环使用 `_input(event)` 处理按键，用 `_process(delta)` 推进持续移动和敌人 AI。

- 方向键 / WASD / HJKL：更新移动方向。
- Shift：调用 `_attempt_dash()`，向当前方向短冲刺最多 2 格。
- Space / `.`：调用 `_wait_turn()`，停止当前移动方向。
- Esc：根据状态暂停、继续或关闭说明。
- R：重开当前层。
- Enter：在菜单或完成状态下执行默认操作。

新增快捷键时，先确认不会和 Godot UI 按钮焦点冲突。

## 配置数据

楼层、敌人、祝福和贴图路径暂时位于 `scripts/main.gd` 顶部。

约定：

- 字典字段使用英文 snake_case。
- 展示文本可以使用中文。
- 贴图必须先注册到 `TEXTURE_PATHS`，逻辑中只引用贴图键。
- 音效必须先注册到 `AudioManager.SOUND_PATHS`，逻辑中只引用音效键。
- 不要在逻辑中散落裸 `res://` 路径。

## 动态节点层级

主场景保持轻量，运行时由 `main.gd` 创建节点：

- `background_layer`：背景和地图底板。
- `map_layer`：地面和墙体。
- `decor_layer`：非阻挡装饰。
- `item_layer`：药水、金币、余烬、装备、宝箱、喷泉、陷阱。
- `actor_layer`：玩家、敌人、出口。
- `fx_layer`：攻击、受伤、施法等短特效。
- `ui_layer`：HUD。
- 菜单类 CanvasLayer：主菜单、说明、暂停、结果和祝福面板。

清理楼层时使用 `_clear_layer()`，不要手动逐个删除某一类节点。

## 资源引用

- 使用 `res://assets/...` 路径。
- 新增第三方资源后，必须更新 `assets/licenses/SOURCES.md`。
- 像素素材的 `Sprite2D.texture_filter` 设为 `CanvasItem.TEXTURE_FILTER_NEAREST`。
- 新增贴图时，优先使用已导入 Kenney Tiny Dungeon 中风格一致的瓦片。

## 玩家主循环

玩家输入和移动入口集中在：

- `_process(delta)`
- `_tick_player_movement(delta)`
- `_get_held_direction()`
- `_attempt_player_step(direction)`
- `_attempt_dash()`
- `_handle_player_landing()`
- `_wait_turn()`

关键约定：

- 普通移动和冲刺都要经过落点处理。
- 冲刺经过陷阱时会提前结束并触发伤害。
- 玩家撞向敌人时攻击，不移动到敌人格。
- 触发出口完成后不要继续执行后续落点逻辑。

## 敌人主循环

敌人行动集中在：

- `_tick_enemies(delta)`
- `_run_single_enemy(enemy)`
- `_best_enemy_step(enemy)`
- `_enemy_attack_player(enemy)`
- `_can_enemy_cast(enemy, distance)`
- `_enemy_ranged_attack_player(enemy)`
- `_trigger_boss_phase(enemy)`

关键约定：

- 敌人用 `move_cooldown` 和 `attack_cooldown` 独立计时。
- 近战优先级高于移动。
- 烛影侍从施法要求同一行或列，并通过 `_has_line_of_sight()` 检查墙体和敌人阻挡。
- Boss 半血阶段只触发一次，用 `phase_triggered` 标记。

## 互动物

普通拾取物：

- `_make_item(item_type, cell)`
- `_collect_item_at(cell)`
- `_item_at(cell)`

独立互动物：

- 宝箱：`_make_chest()`、`_open_chest_at()`、`_chest_at()`。
- 喷泉：`_make_fountain()`、`_use_fountain_at()`、`_fountain_at()`。
- 陷阱：`_make_trap()`、`_trigger_trap_at()`、`_trap_at()`、`_count_armed_traps()`。

新增互动物时，需要同步：

- 放置时加入 `reserved`，避免重叠。
- 装饰生成时加入保留列表。
- 敌人召唤检查中排除。
- HUD 和小地图中体现。

## UI 刷新

- 所有战术 HUD 文本由 `_refresh_hud()` 更新。
- 出口颜色和脉冲由 `_refresh_exit()` 管理。
- 小地图由 `_refresh_minimap()` 每次重绘，使用 `_add_minimap_rect()` 添加色块。
- 日志使用 `_add_log()`，当前限制最近 5 行，避免挤压小地图。

## 存档

`SaveManager` 当前保存轻量进度：

- 当前层级。
- 已完成层记录。
- 最高分。
- 是否看过教程等少量历史字段。

它不保存层内地图、敌人状态、道具状态或玩家临时战斗位置。继续游戏会从保存层级重新生成一层地牢。
