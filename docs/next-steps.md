# Godot 2D Roguelike Demo - 后续操作清单

## 当前状态

项目已完成以下开发：

- ✅ 基础移动和跳跃系统
- ✅ 敌人巡逻 AI（3种类型）
- ✅ 收集品和道具系统
- ✅ 随机地图生成（网格 + 地下城）
- ✅ 音频管理（SFX + BGM）
- ✅ 粒子效果（4种）
- ✅ 存档系统（JSON 持久化）
- ✅ UI 显示（HUD + 游戏结束面板）
- ✅ 游戏状态管理（开始/暂停/结束）
- ✅ 详细注释和文档

---

## 你需要做的（按优先级排序）

### 第一阶段：跑通游戏（1-2 小时）

#### 1. 在 Godot 编辑器中创建场景

**步骤：**
1. 打开 Godot
2. Import → 选择 `/root/project/godot-demo`
3. 按开发指南中的场景层级搭建

**需要创建的场景文件：**
- `scenes/player.tscn` — 玩家场景
- `scenes/collectible.tscn` — 收集品场景
- `scenes/enemy.tscn` — 敌人场景
- `scenes/power_up.tscn` — 道具场景
- `scenes/hud.tscn` — HUD 场景
- `scenes/main.tscn` — 主场景

**关键操作：**
- 每个节点附加对应的脚本
- 调整节点位置和属性
- 设置碰撞形状

#### 2. 运行测试

- 按 F5 运行
- 测试移动、跳跃、收集、受伤
- 检查控制台输出

#### 3. 调整参数

- 在编辑器中调整敌人数量、收集品位置
- 调整玩家移动速度和跳跃力度
- 测试不同难度

---

### 第二阶段：美化游戏（半天 - 1 天）

#### 4. 添加图片素材

**需要准备：**
- 玩家角色图片（32x32 或 64x64）
- 敌人图片
- 收集品图片（金币/宝石）
- 道具图片
- 背景图片
- UI 字体

**操作：**
1. 创建 `assets/images/` 目录
2. 放入图片文件
3. 在 Godot 中拖拽到节点的 Sprite2D.Texture 属性

**免费资源推荐：**
- https://kenney.nl/assets （免费像素素材）
- https://opengameart.org/ （开源游戏素材）
- https://itch.io/game-assets/free （itch.io 免费素材）

#### 5. 添加音效

**需要准备：**
- 跳跃音效
- 收集音效
- 受伤音效
- 敌人死亡音效
- 道具音效
- 背景音乐

**操作：**
1. 创建 `assets/audio/sfx/` 和 `assets/audio/bgm/` 目录
2. 放入 OGG 或 WAV 文件
3. 在 `audio_manager.gd` 的预设字典中添加映射

**免费资源推荐：**
- https://freesound.org/ （免费音效）
- https://opengameart.org/audio （开源音频）
- https://kenney.nl/assets （含音效素材包）

#### 6. 调整 UI 样式

- 修改 Label 的字体和大小
- 调整 HUD 布局
- 美化游戏结束面板

---

### 第三阶段：功能扩展（按需）

#### 7. 添加更多敌人类型

**步骤：**
1. 在 `enemy.gd` 的 `EnemyType` 枚举中添加新类型
2. 在 `_adjust_properties()` 中定义新属性
3. 在编辑器中创建新敌人场景

#### 8. 添加更多道具

**步骤：**
1. 在 `power_up.gd` 的 `PowerUpType` 枚举中添加新类型
2. 在 `_activate_power_up()` 中添加效果逻辑
3. 设计新道具外观

#### 9. 添加音效和粒子

**步骤：**
1. 在 `audio_manager.gd` 中添加新音效预设
2. 在 `particle_manager.gd` 中添加新粒子效果
3. 在相应脚本中调用

#### 10. 添加关卡过渡

**步骤：**
1. 创建关卡过渡场景
2. 在 `game_state.gd` 中添加关卡切换逻辑
3. 添加过渡动画

---

### 第四阶段：发布准备（1-2 天）

#### 11. 完整测试

- [ ] 测试所有功能是否正常
- [ ] 测试不同难度配置
- [ ] 测试存档功能
- [ ] 测试音效和粒子
- [ ] 测试边界情况（快速点击、异常输入）

#### 12. 打包发布

**itch.io 发布：**
- [ ] 创建 itch.io 账号
- [ ] 创建项目页面
- [ ] 打包 PC 版本（Windows/Mac/Linux）
- [ ] 上传构建文件
- [ ] 设置价格和描述
- [ ] 添加截图和预览

**Steam 发布（可选）：**
- [ ] 申请 Steam Direct Fee
- [ ] 创建 Steamworks 账号
- [ ] 准备商店页面素材
- [ ] 上传构建包
- [ ] 等待审核

#### 13. 文档完善

- [ ] 更新 README.md
- [ ] 添加游戏截图
- [ ] 编写操作说明
- [ ] 添加联系方式/社交媒体

---

## 时间估算

| 阶段 | 任务 | 预计时间 |
|---|---|---|
| 第一阶段 | 场景搭建 + 运行测试 | 1-2 小时 |
| 第二阶段 | 添加素材 + 美化 | 半天 - 1 天 |
| 第三阶段 | 功能扩展（按需） | 视需求而定 |
| 第四阶段 | 测试 + 发布 | 1-2 天 |

---

## 常见问题

### Q: 我在 Godot 编辑器里找不到某个节点怎么办？

A: 检查 Inspector 面板的 "Node" 标签，确认节点名称是否正确。也可以在场景树中搜索。

### Q: 脚本报错怎么办？

A: 查看底部 "Output" 面板的错误信息，根据错误提示修改脚本。

### Q: 碰撞不触发怎么办？

A: 检查两个节点的 CollisionShape2D 是否都已设置，且物理层配置正确。

### Q: 音效不播放怎么办？

A: 确认音频文件路径正确，且在 `audio_manager.gd` 的预设字典中有映射。

### Q: 存档文件在哪里？

A:
- Linux: `~/.local/share/godot/app_userdata/GodotDemo/savegame.json`
- Windows: `%APPDATA%\Godot\app_userdata\GodotDemo\savegame.json`
- Mac: `~/Library/Application Support/Godot/app_userdata/GodotDemo/savegame.json`

---

## 下一步建议

根据你的兴趣，可以选择：

1. **继续完善游戏** → 添加更多内容、美术、音效
2. **学习 Godot 进阶** → 网络多人、编辑器插件、自定义渲染
3. **发布游戏** → itch.io 或 Steam
4. **开始新项目** → 用学到的知识做不同类型的游戏

---

## 参考资源

- Godot 官方文档: https://docs.godot.org/
- Godot 官方教程: https://godotengine.org/article/your-first-2d-game
- GDScript 参考: https://docs.godot.org/latest/tutorials/scripting/gdscript/gdscript_basics.html
- 免费素材: https://kenney.nl/
- 社区论坛: https://forum.godotengine.org/
