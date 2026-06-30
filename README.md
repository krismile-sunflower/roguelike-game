# Emberwell Roguelike

一个基于 Godot 4 的小型回合制 roguelike。玩家在程序生成的多层地牢中移动、攻击、拾取补给和装备，清理每层敌人后从出口进入下一层，最终击败第五层的看守。

## 当前可玩内容

- 5 个递进地牢层级，每层会生成不同房间、走廊、敌人、补给和装饰。
- 回合制移动与战斗：玩家行动一次后，敌人会追踪、游荡或攻击。
- 敌人类型：黏液、蝙蝠、烛影侍从、游魂、赤甲守卫、深井看守。
- 掉落与成长：药水治疗、金币得分、短剑提高攻击、盾牌提高最大生命。
- 完整流程：主菜单、继续游戏、说明、暂停、重开本层、楼层完成、失败、通关胜利。
- 素材整合：Kenney Tiny Dungeon 像素地牢素材 + Kenney Interface Sounds 音效，均记录在 `assets/licenses/SOURCES.md`。

## 操作

- 方向键 / WASD / HJKL：移动。
- 撞向敌人：攻击。
- Space 或 `.`：等待一回合。
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
