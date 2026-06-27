# GameState - 游戏状态管理器
# 管理游戏的整体流程：开始、进行中、暂停、结束
# 负责关卡切换、分数结算、重新开始
extends Node

# ==================== 游戏状态枚举 ====================

enum GameState {
	IDLE,        # 空闲（未开始）
	PLAYING,     # 游戏中
	PAUSED,      # 暂停
	GAME_OVER    # 游戏结束
}

# 别名，方便 HUD 等脚本使用
const Idle := GameState.IDLE
const Playing := GameState.PLAYING
const Paused := GameState.PAUSED
const GameOver := GameState.GAME_OVER


# ==================== 信号 ====================

# 游戏状态变化时发出
signal state_changed(new_state: GameState)

# 关卡切换时发出
signal level_changed(level_number: int)

# 游戏结束时发出
signal game_over(final_score: int)

# 进入下一关时发出
signal next_level_requested


# ==================== 运行时变量 ====================

# 当前游戏状态
var current_state: GameState = GameState.IDLE

# 当前关卡编号
var current_level: int = 1

# 最高分记录
var high_score: int = 0

# 游戏开始时间（毫秒）
var game_start_time: int = 0

# 暂停时的时间戳
var paused_at: int = 0

# 本局是否通关
var level_cleared: bool = false


# ==================== 生命周期 ====================

# 场景初始化
func _ready() -> void:
	print("游戏状态管理器已就绪")
	set_state(GameState.IDLE)


# 每帧处理（用于处理暂停等状态）
func _process(delta: float) -> void:
	# 如果游戏暂停，不做额外处理
	pass


# ==================== 公共方法 ====================

# 设置游戏状态
func set_state(new_state: GameState) -> void:
	var old_state := current_state
	current_state = new_state
	state_changed.emit(current_state)

	# 根据状态执行相应操作
	match current_state:
		GameState.PLAYING:
			print("游戏开始！")
			game_start_time = Time.get_ticks_msec()

		GameState.PAUSED:
			print("游戏暂停")
			paused_at = Time.get_ticks_msec()
			# 暂停背景音乐
			if AudioManager:
				AudioManager.toggle_bgm_pause()

		GameState.GAME_OVER:
			print("游戏结束！最终分数:", GameData.score)
			# 更新最高分
			if GameData.score > high_score:
				high_score = GameData.score
				print("新纪录！最高分:", high_score)
			# 保存最高分到存档
			if SaveManager:
				SaveManager.save_high_score(high_score)
			# 保存游玩统计
			if SaveManager:
				SaveManager.increment_stats(level_cleared)
				SaveManager.save_play_time(get_play_time())
			# 发出游戏结束信号
			game_over.emit(GameData.score)
			# 停止背景音乐
			if AudioManager:
				AudioManager.stop_bgm()

		GameState.IDLE:
			print("游戏空闲")


# 切换暂停状态
func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		set_state(GameState.PAUSED)
	elif current_state == GameState.PAUSED:
		set_state(GameState.PLAYING)


# 开始新游戏
func start_new_game() -> void:
	# 重置游戏数据
	GameData.reset()

	# 重置到第一关
	current_level = 1
	level_cleared = false

	# 设置状态为游戏中
	set_state(GameState.PLAYING)

	# 发出关卡变化信号
	level_changed.emit(current_level)

	# 播放背景音乐
	if AudioManager:
		AudioManager.play_bgm("gameplay")


# 进入下一关
func advance_to_next_level() -> void:
	level_cleared = true
	current_level += 1
	level_changed.emit(current_level)
	next_level_requested.emit()
	print("进入第", current_level, "关")

	# 保存关卡进度
	if SaveManager:
		SaveManager.save_level_progress(current_level)


# 游戏结束
func end_game() -> void:
	set_state(GameState.GAME_OVER)


# 获取游戏时长（秒）
func get_play_time() -> float:
	if current_state == GameState.PLAYING:
		return (Time.get_ticks_msec() - game_start_time) / 1000.0
	elif current_state == GameState.PAUSED:
		return (paused_at - game_start_time) / 1000.0
	return 0.0


# 获取当前关卡信息
func get_level_info() -> Dictionary:
	"""返回当前关卡的详细信息"""
	return {
		"level": current_level,
		"state": current_state,
		"score": GameData.score,
		"health": GameData.player_health,
		"high_score": high_score,
		"play_time": get_play_time(),
		"level_cleared": level_cleared,
	}


# ==================== 输入处理 ====================

# 处理全局输入（如暂停键、重新开始键）
func _input(event: InputEvent) -> void:
	# ESC 键切换暂停
	if event.is_action_pressed("ui_escape"):
		if current_state == GameState.PLAYING or current_state == GameState.PAUSED:
			toggle_pause()

	# R 键重新开始（仅在游戏结束时）
	if event.is_action_pressed("ui_select") and current_state == GameState.GAME_OVER:
		start_new_game()

	# F5 强制保存（调试用）
	if event.is_action_pressed("ui_cancel"):  # 用 cancel 键
		if SaveManager:
			SaveManager.save_all()
			print("存档已手动保存")
