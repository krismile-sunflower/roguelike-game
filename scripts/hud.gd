# HUD - 抬头显示界面
# 显示分数、生命值、道具效果、关卡信息和最高分
# 通过监听 GameData 和 GameState 的信号来实时更新 UI
extends CanvasLayer

# ==================== 节点引用 ====================

# 分数显示标签
@onready var label_score: Label = $ScoreLabel

# 生命值显示标签
@onready var label_health: Label = $HealthLabel

# 关卡显示标签
@onready var label_level: Label = $LevelLabel

# 道具效果显示标签
@onready var label_effects: Label = $EffectsLabel

# 游戏结束信息面板
@onready var panel_game_over: Panel = $PanelGameOver

# 游戏结束分数标签
@onready var label_final_score: Label = $PanelGameOver/FinalScoreLabel

# 游戏结束最高分标签
@onready var label_high_score: Label = $PanelGameOver/HighScoreLabel

# 游戏结束提示标签
@onready var label_restart_hint: Label = $PanelGameOver/RestartHintLabel

# 统计信息标签
@onready var label_stats: Label = $PanelGameOver/StatsLabel


# ==================== 生命周期 ====================

# 场景初始化
func _ready() -> void:
    # 连接全局数据信号
    GameData.score_changed.connect(_on_score_changed)
    GameData.health_changed.connect(_on_health_changed)

    # 连接游戏状态信号
    GameState.state_changed.connect(_on_state_changed)
    GameState.level_changed.connect(_on_level_changed)
    GameState.game_over.connect(_on_game_over)

    # 初始化显示
    _update_display()

    # 游戏结束时隐藏面板
    panel_game_over.visible = false

    print("HUD 界面已就绪")


# 每帧更新（用于实时更新道具效果）
func _process(delta: float) -> void:
    # 如果游戏正在进行，更新道具效果显示
    if GameState.current_state == GameState.Playing:
        _update_effects_display()


# ==================== 公共方法 ====================

# 更新所有显示内容
func _update_display() -> void:
    label_score.text = "分数: %d" % GameData.score
    label_health.text = "生命: %d" % GameData.player_health
    label_level.text = "关卡: %d" % GameState.current_level


# 更新道具效果显示
func _update_effects_display() -> void:
    pass  # 可扩展为显示当前激活的道具图标


# 显示游戏结束信息
func show_game_over(final_score: int) -> void:
    panel_game_over.visible = true

    # 显示最终分数
    label_final_score.text = "最终分数: %d" % final_score

    # 显示最高分
var hs = SaveManager.get_high_score() if SaveManager else 0

    label_high_score.text = "最高分: %hs" % hs

    # 显示重新开始提示
    label_restart_hint.text = "按 Enter 重新开始"

    # 显示统计数据
    if SaveManager:
var stats = SaveManager.get_play_stats()

        label_stats.text = "游戏次数: %d | 胜利: %d | 总时长: %.0f秒" % [
            stats.games_played, stats.games_won, stats.total_play_time
        ]


# 隐藏游戏结束信息
func hide_game_over() -> void:
    panel_game_over.visible = false


# ==================== 信号回调 ====================

# 分数变化时调用
func _on_score_changed(new_score: int) -> void:
    label_score.text = "分数: %d" % new_score


# 生命值变化时调用
func _on_health_changed(new_health: int) -> void:
    label_health.text = "生命: %d" % new_health

    # 生命值归零时触发游戏结束（由 GameState 处理）


# 游戏状态变化时调用
func _on_state_changed(new_state: int) -> void:
    match new_state:
        GameState.State.PLAYING:
            panel_game_over.visible = false
            label_effects.text = ""
        GameState.State.PAUSED:
            label_effects.text = "⏸ 已暂停"
        GameState.State.GAME_OVER:
            # 游戏结束由 _on_game_over 处理
            pass
        GameState.State.IDLE:
            label_effects.text = ""


# 关卡变化时调用
func _on_level_changed(level_number: int) -> void:
    label_level.text = "关卡: %d" % level_number

    # 播放关卡开始音效
    if AudioManager:
        AudioManager.play_sound("level_start")


# 游戏结束时调用
func _on_game_over(final_score: int) -> void:
    show_game_over(final_score)

    # 播放游戏结束音效
    if AudioManager:
        AudioManager.play_sound("game_over")
