# 开发指南

## 本地运行检查

每次改动主循环后，至少做一轮冒烟测试：

1. 运行 `res://scenes/main.tscn`。
2. 点击开始新探险。
3. 按住方向连续移动，按 Shift 短冲刺，确认不能穿墙或穿怪。
4. 攻击、停下观察、拾取药水和金币，打开宝箱并使用喷泉。
5. 停在原地观察怪物是否仍会持续靠近；清掉一层敌人，确认出口点亮。
6. 选择 1 个楼层祝福，确认效果生效并进入下一层。
7. 按 Esc 暂停，再继续；按 R 重开当前层。
8. 在第五层把 Boss 打到半血，确认变色、加速并召唤低血游魂。
9. 故意死亡一次，确认失败面板和重新开始可用。
10. 从主菜单点击继续探险，确认能进入存档层级。

## 新增楼层

楼层配置目前在 `scripts/main.gd` 的 `LEVEL_DEFS` 中。

每层需要提供：

- `title`：HUD 和日志中显示的楼层名称。
- `goal`：本层简短目标。
- `room_count`：尝试生成的房间数。
- `enemy_groups`：敌人类型与数量。
- `potions`：药水数量。
- `coins`：金币数量。
- `gear`：本层固定装备，例如 `sword` 或 `shield`。
- `chests`：可开启宝箱数量。
- `fountains`：一次性治疗喷泉数量。
- `reward_count`：清层后的祝福候选数量，非最终层通常为 3。
- `theme_color`：本层地面主题调色。
- `boss_rules`：Boss 特殊规则，例如半血召唤数量。

新增楼层后同步检查：

- `MAX_LEVELS` 是否仍有意义。
- README 和 `docs/game-goal.md` 是否需要更新层数说明。
- 难度是否随着敌人数量、攻击和补给合理递进。
- 宝箱、喷泉和固定装备是否不会与玩家、出口、敌人重叠。

## 新增敌人

敌人配置在 `scripts/main.gd` 的 `ENEMY_TYPES` 中。

字段说明：

- `name`：中文显示名。
- `hp`：基础生命。
- `attack`：攻击力。
- `score`：击杀分数。
- `texture`：`TEXTURE_PATHS` 中的贴图键。
- `awareness`：感知范围，越高越容易追踪玩家。
- `move_interval`：移动冷却，数值越低行动越快。
- `attack_interval`：攻击冷却，避免相邻后一帧内连续扣血。
- `role`：敌人定位，用于 HUD/特殊逻辑识别。
- Boss 可额外配置 `phase_move_interval`、`phase_attack_interval`、`summon_on_half_hp`。

新增敌人后，把它加入某层的 `enemy_groups`，并跑一次完整楼层测试。

## 新增道具

道具生成在 `_populate_level()`，拾取效果在 `_collect_item_at()`。宝箱和喷泉使用独立的 `chests`、`fountains` 数组，并分别由 `_open_chest_at()`、`_use_fountain_at()` 处理。

新增道具需要：

1. 在 `TEXTURE_PATHS` 中注册贴图。
2. 在 `_make_item()` 中确认贴图键。
3. 在 `_collect_item_at()` 中写效果。
4. 更新 `assets/licenses/SOURCES.md` 的素材引用说明。

## 地图生成约束

- 地图尺寸由 `GRID_WIDTH`、`GRID_HEIGHT` 和 `TILE_SIZE` 控制。
- HUD 位于右侧，调整地图宽度时要保留面板空间。
- 玩家出生在第一间房，出口在最后一间房。
- `_find_empty_floor_cell()` 负责避开已占用格子。
- 如果随机房间生成失败，会使用 `_build_fallback_dungeon()` 保底。

## 当前拆分建议

`scripts/main.gd` 已经承载完整玩法，后续应优先拆分：

- `DungeonGenerator.gd`：房间、走廊和放置点。
- `CombatController.gd`：攻击、伤害、死亡、掉落。
- `RogueHud.gd`：HUD 和菜单面板。
- `EntityFactory.gd`：玩家、敌人、道具、装饰节点创建。
