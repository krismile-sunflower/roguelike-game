# 开发指南

## 环境要求

- Godot 版本：4.7
- 当前目标平台：桌面端
- 当前窗口分辨率：`1280 x 720`
- 主入口场景：`res://scenes/main.tscn`

项目入口仍是单场景结构，不拆分独立菜单场景。

## 导入与启动

1. 用 Godot 4.7 导入项目目录。
2. 打开后确认 `project.godot` 中主场景仍是 `res://scenes/main.tscn`。
3. 检查 AutoLoad 是否存在：
   - `GameData`
   - `GameState`
   - `AudioManager`
   - `ParticleManager`
   - `SaveManager`
4. 直接运行项目。

首次进入时，预期应先看到中文主菜单，而不是直接进入关卡。

## 主场景调试路径

当前建议按下面顺序检查主流程：

1. 主菜单是否正常显示：
   - `开始整理`
   - `继续整理`
   - `玩法说明`
   - `退出游戏`
2. 点击 `开始整理` 后是否进入第 1 关。
3. 首关是否出现中文分步教学。
4. 物品是否可以鼠标拖放。
5. 正确摆放后是否吸附，错误摆放后是否回位。
6. 完成一关后是否出现完成反馈。
7. `继续整理` 是否能从已有进度进入。
8. `Esc` 是否能打开暂停并恢复。

## 关卡数据位置

当前关卡不是独立资源文件，也不是外部 JSON。

它们直接定义在 `scripts/main.gd` 的 `LEVELS` 常量中。每个关卡都是一个字典，内部包含当前关的背景、目标区域和物品定义。

这样做的好处是：

- 当前原型阶段改动快
- 不需要额外编辑器和序列化层
- 主流程逻辑和数据能一起调试

限制也很明确：

- 关卡多起来后会变得难维护
- 不利于内容和逻辑分工

## 如何新增一个整理关

在 `LEVELS` 里追加一项关卡字典，至少补齐以下字段：

- `title`
- `goal`
- `background_color`
- `desk_color`
- `targets`
- `items`

### 新增目标区域

每个 target 至少需要：

- `id`
- `label`
- `mode`
- `position`
- `size`

`mode` 当前支持：

- `single`
- `category_bin`

如果是单一归位，需要填 `accepted_item_ids`。

如果是分类收纳，需要填：

- `accepted_category`
- `slot_positions`

### 新增物品

每个 item 至少需要：

- `id`
- `label`
- `target_id`
- `home_position`
- `size`
- `color`

分类收纳关需要再加：

- `category`

`target_id` 必须能匹配到本关某个 `target.id`。

## 如何调试拖放问题

拖放问题优先看这几层：

### 1. 输入链路

当前拖拽依赖 `main.gd` 的 `_input()`。

如果拖不动，先确认：

- 事件没有被错误改回 `_unhandled_input()`
- 当前状态确实是 `GameState.Playing`
- 鼠标左键事件能进入 `_try_begin_drag()` 和 `_try_finish_drag()`

### 2. UI 输入遮挡

整理原型里有很多 `CanvasLayer` 和 `Control`。

如果 UI 设置不当，会直接截走鼠标事件。优先检查：

- 装饰性 `ColorRect`
- 教学文案层
- HUD 面板
- 完成面板和遮罩

非交互控件应使用合适的 `mouse_filter`，避免挡住物品拖拽。

### 3. 命中范围

`DraggableItem.contains_point()` 和 `DropTarget.contains_point()` 都基于矩形范围判断。

如果视觉位置和点击位置不一致，重点检查：

- `global_position`
- `size`
- `home_position`
- 目标 `position`

### 4. 放置规则

如果能拖动但无法放下，优先看：

- `DropTarget.can_accept(item)`
- `accepted_item_ids`
- `accepted_category`
- `target_id`
- `category`

### 5. 反馈表现

如果逻辑正确但玩家感觉“不知道发生了什么”，优先补：

- 吸附动画
- 完成面板
- 状态文案
- 教学提示

## 中文文案维护规则

当前项目玩家可见内容统一使用简体中文。

建议规则：

- 玩家看到的标题、按钮、提示、说明全部写中文
- 内部字段名、脚本名、节点名继续使用英文
- 文案集中放在脚本常量区，避免散落在逻辑分支里
- 如需规避编码污染，可以继续使用稳定的 UTF-8 文件或常量集中管理

## 当前相关脚本

接手当前整理玩法时，优先关注：

- `scripts/main.gd`
- `scripts/hud.gd`
- `scripts/draggable_item.gd`
- `scripts/drop_target.gd`
- `scripts/game_data.gd`
- `scripts/game_state.gd`
- `scripts/save_manager.gd`

## 当前不再使用的旧路线

不要再按旧文档那样去搭建：

- 玩家移动和跳跃主循环
- 敌人战斗主循环
- 地牢或房间生成主循环
- 旧版 HUD 分数/生命值面板

这些旧脚本仍然留在仓库里，但它们不是当前开发的默认入口。
