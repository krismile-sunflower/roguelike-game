# 项目目标：整理时光

## 核心定位

把当前项目打磨成一款完整可玩的单屏整理解谜游戏。玩家通过拖拽物品、观察场景提示、按归位/排序/分类/组合规则完成一组温暖日常场景。

项目当前仓库名仍是 `roguelike-game`，但现有主线已经不是战斗、地牢或随机 roguelike。后续默认沿着“整理时光”这个方向推进，除非明确决定重启旧 roguelike 玩法。

## 最终可玩标准

- 有清晰的主菜单、继续游戏、说明、暂停、重置和通关流程。
- 至少包含 8 到 10 个可完成关卡，每关有独立主题、目标文案和整理规则。
- 关卡难度逐步增加：单物归位、顺序排序、分类收纳、混合规则、轻量观察谜题。
- 有统一视觉主题：温暖室内、手账感、柔和纸质色彩、低压力反馈。
- 有正式素材替换当前代码绘制占位图，包含物品、家具/背景、UI、音效和完成反馈。
- 有基础存档：当前关卡、已完成关卡、提示次数、新手教程状态。
- 有完整反馈：拾取、放下、吸附、错误回弹、提示、高亮、通关庆祝。
- 可以从 Godot 直接运行，并能导出一个桌面可玩的版本。

## 关卡设计路线

### 第一章：熟悉整理

1. 晨间书架：台灯、笔记本、相机归位。
2. 书脊排排站：按高度从矮到高排序。
3. 温柔分类：厨房小物和绘画工具分类收纳。

### 第二章：生活角落

4. 茶点托盘：茶杯、茶包、饼干、勺子按托盘位置归位。
5. 画具桌面：画笔、颜料、剪刀、胶带按用途分类。
6. 邮件与票根：信封、明信片、车票、照片按时间或类型整理。

### 第三章：更复杂的观察题

7. 夜晚床头柜：根据光影/轮廓把物品放回正确位置。
8. 厨房抽屉：长短、材质、用途混合规则排序。
9. 旅行收纳：把物品放进行李箱、随身包、洗漱袋三类容器。
10. 回忆展示架：按颜色、大小和主题组合完成最终陈列。

## 素材方向

优先使用许可证清晰、风格统一、适合 Godot 导入的素材。当前建议从下面几类开始筛选：

- Kenney 家具和室内素材：适合背景、家具、收纳容器。Kenney 官方支持页说明 asset pages 上的游戏素材为 CC0，可商用且不要求署名。
- Kenney UI / Audio / All-in-1：适合按钮、面板、提示音和轻量背景音。All-in-1 包含 2D、3D、UI、音频、字体等大量统一风格资源。
- itch.io cozy/top-down/interior 免费素材：适合补充厨房、客厅、卧室、茶点等主题，但每个包必须逐一核对 license。
- OpenGameArt CC0 素材：适合作为补充来源，尤其是食物图标、小物件、家具或通用音效，但要保留 credits/license 记录。

推荐素材链接：

- Kenney assets: https://kenney.nl/assets
- Kenney support/license: https://kenney.nl/support
- Kenney Furniture Kit: https://kenney.nl/assets/furniture-kit
- Kenney Top-down Shooter: https://www.kenney.nl/assets/top-down-shooter
- Kenney All-in-1: https://kenney.itch.io/kenney-game-assets
- itch.io free cozy 2D assets: https://itch.io/game-assets/free/tag-2d/tag-cozy
- itch.io free kitchen assets: https://itch.io/game-assets/free/tag-kitchen
- OpenGameArt CC0 resources: https://opengameart.org/content/cc0-resources

## 技术路线

- 短期保留单入口 `scenes/main.tscn` 和当前拖拽核心，先把它做扎实。
- 把 `scripts/main.gd` 里的 `LEVELS` 逐步拆出到独立关卡数据脚本或资源文件，方便扩展到 8 到 10 关。
- 给 `DraggableItem` 增加素材贴图能力：优先显示 Sprite2D/TextureRect，缺素材时继续使用当前代码绘制占位图。
- 给 `DropTarget` 增加轮廓/阴影/容器贴图能力，用素材替换纯色目标框。
- 实现 `AudioManager` 的真实音效播放：pickup、drop_success、drop_reset、hint、complete。
- 增强 `ParticleManager`：吸附时轻量闪光、错误时柔和波纹、完成时纸屑或星点。
- 每新增 2 到 3 关后做一次完整游玩验证，避免关卡数据堆积后才发现流程问题。

## 近期执行清单

1. 确认沿“整理时光”方向继续，而不是恢复旧 roguelike。
2. 建立素材目录：`assets/art`、`assets/audio`、`assets/ui`、`assets/licenses`。
3. 下载并导入第一批 CC0 素材，先覆盖 3 个已有关卡的物品和背景。
4. 抽离关卡数据，新增第 4 到第 6 关。
5. 完成真实音效和基础粒子反馈。
6. 运行项目检查：无 Godot 报错、所有关卡可完成、存档和继续游戏正常。
