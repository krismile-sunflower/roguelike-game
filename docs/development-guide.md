# 开发指南

## 推荐验证流程

每次改动主循环后，至少做一轮快速验证：

1. 使用 Godot 4 打开项目并运行 `res://scenes/main.tscn`。
2. 从主菜单开始新探险。
3. 按住方向键 / WASD / HJKL，确认连续移动正常。
4. 使用 Shift 冲刺，确认不能穿墙或穿过敌人。
5. 在第二层以后踩一次陷阱，确认扣血、变暗和日志提示正常。
6. 拾取药水、金币、余烬碎片、短剑或盾牌，确认 HUD 更新。
7. 收集 3 个余烬碎片，确认共鸣反馈触发。
8. 打开宝箱并使用喷泉，确认贴图/颜色状态变化。
9. 遇到烛影侍从时测试直线施法，确认墙体或其他敌人能挡住视线。
10. 清掉一层敌人，确认出口点亮、祝福面板出现并能进入下一层。
11. 按 Esc 暂停再继续，按 R 重开当前层。
12. 第五层把 Boss 打到半血，确认变色、加速并召唤低血游魂。
13. 故意死亡一次，确认失败面板和重新开始可用。
14. 回主菜单点击继续探险，确认能从保存层级继续。

命令行可用时，可以先跑一次 headless 启动检查：

```powershell
& 'C:\Users\89221\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\learning\game\roguelike-game' --quit-after 2
```

## 新增或调整楼层

楼层配置在 `scripts/main.gd` 的 `LEVEL_DEFS` 中。

字段说明：

- `title`：HUD、日志和祝福面板中显示的楼层名称。
- `goal`：右侧 HUD 中显示的本层目标。
- `room_count`：随机生成时尝试放置的房间数量。
- `enemy_groups`：敌人类型和数量。
- `potions`：药水数量。
- `coins`：金币数量。
- `embers`：余烬碎片数量。
- `gear`：固定装备列表，例如 `sword` 或 `shield`。
- `chests`：宝箱数量。
- `fountains`：一次性治疗喷泉数量。
- `traps`：尖刺陷阱数量。
- `reward_count`：清层后的祝福候选数量，最终层为 0。
- `theme_color`：本层地面主题调色。
- `boss_rules`：Boss 特殊规则，例如半血召唤数量。

调整楼层后需要检查：

- 第一层不要过早引入复杂机制。
- 第二层以后再使用陷阱和远程压力。
- 补给、陷阱和敌人数量要随楼层逐步递进。
- `_find_empty_floor_cell()` 使用的保留格子是否覆盖新增对象。
- README、`docs/game-goal.md` 和 `docs/next-steps.md` 是否需要同步。

## 新增或调整敌人

敌人配置在 `scripts/main.gd` 的 `ENEMY_TYPES` 中。

基础字段：

- `name`：中文显示名。
- `hp`：基础生命，当前实现会随楼层略微提高。
- `attack`：近战攻击力。
- `score`：击杀分数。
- `texture`：`TEXTURE_PATHS` 中的贴图键。
- `role`：行为定位，例如 `slow`、`fast`、`caster`、`heavy`、`boss`。
- `awareness`：感知范围。
- `move_interval`：移动冷却，越低越快。
- `attack_interval`：攻击冷却。

可选字段：

- `ranged_range`：远程施法距离，当前用于烛影侍从。
- `ranged_damage`：远程伤害。
- `phase_move_interval`：Boss 二阶段移动冷却。
- `phase_attack_interval`：Boss 二阶段攻击冷却。
- `summon_on_half_hp`：Boss 半血召唤数量。

新增敌人后，需要：

1. 在 `TEXTURE_PATHS` 中注册贴图键。
2. 在 `ENEMY_TYPES` 中定义属性。
3. 如需特殊行为，在 `_tick_enemies()` 或 `_run_single_enemy()` 接入。
4. 加入某层 `enemy_groups`。
5. 跑一轮楼层测试，确认不会卡在墙里、出口上或互动物上。

## 新增道具或互动物

普通拾取物走 `items` 数组：

1. 在 `TEXTURE_PATHS` 中注册贴图。
2. 在 `_make_item()` 确认贴图键。
3. 在 `_collect_item_at()` 写拾取效果。
4. 在 `_populate_level()` 中生成。
5. 在 `_refresh_minimap()` 中给小地图颜色。

独立互动物使用单独数组：

- 宝箱：`chests`、`_make_chest()`、`_open_chest_at()`、`_chest_at()`。
- 喷泉：`fountains`、`_make_fountain()`、`_use_fountain_at()`、`_fountain_at()`。
- 陷阱：`traps`、`_make_trap()`、`_trigger_trap_at()`、`_trap_at()`。

新增资源后必须更新 `assets/licenses/SOURCES.md`。

## HUD 与小地图

HUD 由 `_build_hud()` 创建，由 `_refresh_hud()` 刷新。

小地图由 `_refresh_minimap()` 重绘：

- 地面：低对比灰绿。
- 玩家：余烬金。
- 出口：锁定为灰，开启为金。
- 敌人：红色。
- 道具：金币/余烬为暖色，药水为绿色。
- 喷泉：青色。
- 宝箱：棕金色。
- 陷阱：红色，触发后不再显示为威胁。

如果新增对象会影响玩家决策，应同步显示在威胁摘要或小地图中。

## 地图生成约束

- 地图尺寸由 `GRID_WIDTH`、`GRID_HEIGHT` 和 `TILE_SIZE` 控制。
- HUD 位于右侧，调整地图宽度时要保留 `PANEL_X` 之后的 UI 空间。
- 玩家出生在第一间房，出口在最后一间房。
- `_find_empty_floor_cell()` 负责避开已占用格子。
- 敌人召唤使用 `_can_spawn_enemy_at()`，需要排除玩家、出口、敌人、道具、宝箱、喷泉和陷阱。
- 装饰物不能覆盖会交互的对象。

## 当前重构建议

`scripts/main.gd` 仍然是单文件主循环。后续如果继续扩展，建议按下面顺序拆分：

1. `DungeonGenerator.gd`：房间、走廊、保底地图和空格查找。
2. `EntityFactory.gd`：玩家、敌人、道具、装饰和 UI 节点创建。
3. `CombatController.gd`：攻击、伤害、死亡、掉落、Boss 阶段。
4. `InteractionController.gd`：拾取、开箱、喷泉、陷阱、出口。
5. `RogueHud.gd`：HUD、小地图、菜单和结果面板。
6. `LevelData` 资源或 JSON：楼层、敌人、祝福和数值配置。
