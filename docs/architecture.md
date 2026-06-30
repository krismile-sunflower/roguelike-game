# 架构说明

## 概览

当前项目主线是一个 Godot 4 回合制 roguelike。主循环为：

`主菜单 -> 生成地牢层 -> 玩家回合 -> 敌人回合 -> 清理敌人 -> 出口开启 -> 下一层 / 胜利`

## 运行入口

- 主场景：`res://scenes/main.tscn`
- 根节点：`RoguelikeMain (Node2D)`
- 主脚本：`res://scripts/main.gd`

`main.tscn` 保持很薄，只挂载主脚本。地图层、实体层、特效层、HUD、菜单、说明、暂停和结果面板都由 `main.gd` 动态创建。

## 核心脚本职责

- `scripts/main.gd`
  - 生成房间和走廊式地牢。
  - 放置玩家、出口、敌人、补给、装备和装饰。
  - 处理键盘输入、移动、攻击、等待、重开和暂停。
  - 驱动敌人追踪、游荡和攻击。
  - 管理楼层完成、失败、胜利和 HUD 刷新。
- `scripts/game_data.gd`
  - 保存当前层、完成记录、分数、生命和提示计数等轻量运行数据。
- `scripts/game_state.gd`
  - 提供菜单、说明、游玩、暂停、完成等全局状态。
- `scripts/save_manager.gd`
  - 使用 `user://savegame.json` 保存继续游戏进度和最高分。
- `scripts/audio_manager.gd`
  - 加载并播放 Kenney Interface Sounds 中的短音效。
- `scripts/particle_manager.gd`
  - 生成拾取、受伤和敌人死亡的轻量代码粒子。

## 地牢生成

每层从全墙体网格开始：

1. 随机尝试放置多个不重叠房间。
2. 按放置顺序连接房间中心点。
3. 第一间房作为玩家出生点，最后一间房作为出口。
4. 根据楼层配置放置敌人、药水、金币和装备。
5. 随机补充不阻挡移动的装饰物。

## 回合规则

- 玩家移动到空地会消耗一回合。
- 玩家撞向敌人会攻击并消耗一回合。
- Space 或 `.` 会等待一回合。
- 敌人在感知范围内会尝试接近玩家。
- 敌人与玩家相邻时会攻击。
- 清理所有敌人后出口开启。

## 素材

当前视觉素材来自 `assets/art/kenney_tiny-dungeon/`，音效来自 `assets/audio/kenney_interface-sounds/`。来源、下载链接和许可证记录在 `assets/licenses/SOURCES.md`。

## 历史脚本

仓库里仍保留了早期横版和拖拽整理方向的脚本与场景，例如 `player.gd`、`enemy.gd`、`hud.gd`、`draggable_item.gd` 等。它们当前不在 `main.tscn` 启动链上，后续可以单独归档或清理。
