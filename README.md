# Godot 2D 入门 Demo 项目
# 一个基础的可玩原型，展示玩家移动、跳跃、收集物品和计分

## 项目结构
```
godot-demo/
├── project.godot          # 项目配置文件
├── scenes/                # 场景文件
│   ├── player.tscn        # 玩家场景
│   ├── collectible.tscn   # 收集品场景
│   └── main.tscn          # 主场景
├── scripts/               # 脚本文件
│   ├── game_data.gd       # 全局游戏数据（分数、生命）
│   ├── player.gd          # 玩家控制（移动、跳跃）
│   ├── collectible.gd     # 收集品逻辑（碰到加分）
│   └── hud.gd             # 抬头显示（UI）
└── README.md              # 本文件
```

## 快速开始

### 1. 安装 Godot
从 https://godotengine.org/ 下载并安装 Godot 4.x

### 2. 打开项目
启动 Godot → "Import" → 选择 `godot-demo` 文件夹

### 3. 运行
点击编辑器顶部的绿色三角按钮，或按 F5

### 4. 操作说明
- **← →** 左右移动
- **空格键** 跳跃
- 碰到金色收集品会增加分数

## 技术要点
- 使用 CharacterBody2D 实现玩家移动
- 使用 Area2D 实现收集品检测
- 使用信号系统连接 UI 和游戏逻辑
- 使用单例（AutoLoad）管理全局状态

## 下一步扩展
- 添加敌人
- 添加随机地图（Roguelike）
- 添加道具系统
- 添加音效和动画
