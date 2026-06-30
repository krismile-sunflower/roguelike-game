# 开发指南

## 本地运行检查

每次改动主循环后，至少做一轮冒烟测试：

1. 运行 `res://scenes/main.tscn`。
2. 点击开始新探险。
3. 移动、攻击、等待、拾取药水和金币。
4. 清掉一层敌人，确认出口点亮并可进入下一层。
5. 按 Esc 暂停，再继续。
6. 按 R 重开当前层。
7. 故意死亡一次，确认失败面板和重新开始可用。
8. 从主菜单点击继续探险，确认能进入存档层级。

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

新增楼层后同步检查：

- `MAX_LEVELS` 是否仍有意义。
- README 和 `docs/game-goal.md` 是否需要更新层数说明。
- 难度是否随着敌人数量、攻击和补给合理递进。

## 新增敌人

敌人配置在 `scripts/main.gd` 的 `ENEMY_TYPES` 中。

字段说明：

- `name`：中文显示名。
- `hp`：基础生命。
- `attack`：攻击力。
- `score`：击杀分数。
- `texture`：`TEXTURE_PATHS` 中的贴图键。
- `awareness`：感知范围，越高越容易追踪玩家。

新增敌人后，把它加入某层的 `enemy_groups`，并跑一次完整楼层测试。

## 新增道具

道具生成在 `_populate_level()`，拾取效果在 `_collect_item_at()`。

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
