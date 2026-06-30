# Emberwell Roguelike

一个基于 Godot 4 的小型动作轻肉鸽。玩家在程序生成的多层地牢中按住方向连续移动、短冲刺、攻击、打开宝箱和选择楼层祝福，清理每层敌人后从出口进入下一层，最终击败第五层的深井看守。

## 当前可玩内容

- 5 个递进地牢层级：旧井门厅、潮湿回廊、碎骨仓库、熄火祭室、深井王座，每层有不同压力和补给结构。
- 实时格子移动与战斗：玩家可按住方向连续移动，Shift 可短冲刺；敌人会按自己的节奏持续追踪、游荡或攻击。
- 敌人类型：黏液、蝙蝠、烛影侍从、游魂、赤甲守卫、深井看守。
- 掉落与成长：药水治疗、金币得分、短剑提高攻击、盾牌提高最大生命；清层后从 3 个楼层祝福中选择 1 个。
- 地图互动：宝箱可打开并给金币、治疗或强化；治疗喷泉每层最多 1 个，使用后变暗。
- Boss 流程：深井看守半血后会加速并召唤低血游魂。
- 完整流程：主菜单、继续游戏、说明、暂停、重开本层、楼层完成、失败、通关胜利。
- 素材整合：Kenney Tiny Dungeon 像素地牢素材 + Kenney Interface Sounds 音效，均记录在 `assets/licenses/SOURCES.md`。

## 操作

- 方向键 / WASD / HJKL：按住连续移动。
- Shift：向当前方向短冲刺，最多 2 格，不能穿墙或穿过敌人。
- 撞向敌人：攻击。
- Space 或 `.`：停下脚步，方便重新观察。
- 清完非最终层：选择 1 个楼层祝福后进入下一层。
- Esc：暂停 / 继续。
- R：重开当前层。

## 运行方式

1. 使用 Godot 4 打开项目目录。
2. 确认入口场景为 `res://scenes/main.tscn`。
3. 运行项目即可进入主菜单。

`project.godot` 当前配置：

- 项目名：`Emberwell Roguelike`
- 主入口：`res://scenes/main.tscn`
- 目标分辨率：`1280 x 720`
- AutoLoad：`GameData`、`GameState`、`AudioManager`、`ParticleManager`、`SaveManager`

## 项目结构

```text
roguelike-game/
├── project.godot
├── scenes/
│   └── main.tscn
├── scripts/
│   ├── main.gd
│   ├── game_data.gd
│   ├── game_state.gd
│   ├── save_manager.gd
│   ├── audio_manager.gd
│   └── particle_manager.gd
├── assets/
│   ├── art/kenney_tiny-dungeon/
│   ├── audio/kenney_interface-sounds/
│   └── licenses/SOURCES.md
└── docs/
```

旧的拖拽整理玩法脚本和横版原型脚本仍保留在仓库中，但当前主入口已经切换为新的 roguelike 主循环。
