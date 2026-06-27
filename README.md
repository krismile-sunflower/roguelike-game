# 整理时光

一个基于 Godot 4.7 的单屏整理谜题原型。玩家通过鼠标拖放物品，把它们放回合适的位置，完成一页页安静、温柔的整理场景。

当前工程名仍是 `GodotDemo`，对外玩法名称使用“整理时光”。

## 当前可玩内容

- 中文主菜单：`开始整理 / 继续整理 / 玩法说明 / 退出游戏`
- 3 个单屏整理关卡：归位、排序、分类
- 鼠标拖放交互：拾取、拖动、放下、吸附、回位
- 首关分步教学与游戏内帮助入口
- 暂停、提示、重置本关
- 本地进度保存：继续整理、教程状态、提示次数、关卡完成记录

## 操作说明

- 鼠标左键按住物品：拿起并拖动
- 松开鼠标左键：放下物品
- 放对位置：物品会自动吸附
- 放错位置：物品会回到原位
- `Esc`：打开或关闭暂停

## 当前状态

项目已经可以导入并游玩，主流程是完整的中文整理原型，但仍处于首版垂直切片阶段。

目前已经完成：

- 启动后先进入主菜单，而不是直接进关
- 整理主循环、过关反馈、继续整理流程
- 中文 HUD、中文说明页、中文教学提示
- 无音频资源和无粒子资源时的安全降级

目前仍在迭代：

- 素材、美术和统一视觉包装
- 更丰富的完成反馈和动画细节
- 更多关卡与更稳的关卡数据组织方式
- 更完整的音频、粒子和叙事表达

## 运行方式

1. 使用 Godot 4.7 打开项目目录。
2. 导入后确认入口场景为 `res://scenes/main.tscn`。
3. 直接运行项目或运行主场景即可。

`project.godot` 中当前配置：

- 主入口：`res://scenes/main.tscn`
- AutoLoad：`GameData`、`GameState`、`AudioManager`、`ParticleManager`、`SaveManager`
- 目标分辨率：`1280 x 720`

## 项目结构

```text
roguelike-game/
├─ project.godot
├─ scenes/
│  ├─ main.tscn
│  ├─ draggable_item.tscn
│  └─ drop_target.tscn
├─ scripts/
│  ├─ main.gd
│  ├─ hud.gd
│  ├─ draggable_item.gd
│  ├─ drop_target.gd
│  ├─ game_data.gd
│  ├─ game_state.gd
│  ├─ save_manager.gd
│  ├─ audio_manager.gd
│  └─ particle_manager.gd
└─ docs/
   ├─ architecture.md
   ├─ development-guide.md
   ├─ gdscript-guide.md
   └─ next-steps.md
```

当前主流程重点文件：

- `scenes/main.tscn`：唯一运行入口
- `scripts/main.gd`：菜单、关卡、教程、完成流程
- `scripts/hud.gd`：顶部信息栏、帮助/提示/重置按钮
- `scripts/draggable_item.gd`：可拖动物品
- `scripts/drop_target.gd`：目标区域与接收规则

## 已知限制

- 当前素材大多是代码绘制或占位表现，不是最终美术资源。
- `AudioManager` 和 `ParticleManager` 目前是安全降级实现，没有资源时也不会报错。
- 仓库里仍保留了一些旧平台跳跃时期的脚本和场景文件名，但它们已经不参与当前主流程。
- 文档只描述当前整理玩法，不再覆盖旧的 Roguelike、战斗、跳跃或随机地牢方向。

## 文档索引

- [架构说明](docs/architecture.md)
- [开发指南](docs/development-guide.md)
- [GDScript 约定](docs/gdscript-guide.md)
- [后续计划](docs/next-steps.md)
