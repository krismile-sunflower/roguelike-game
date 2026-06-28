extends CanvasLayer

const TEXT_DEFAULT_TITLE := "\u6574\u7406\u5b8c\u6210"
const TEXT_DEFAULT_GOAL := "\u8f7b\u6309\u9f20\u6807\uff0c\u628a\u7269\u54c1\u653e\u56de\u5b83\u8be5\u5728\u7684\u4f4d\u7f6e\u3002"
const TEXT_HINT_BUTTON := "\u63d0\u793a"
const TEXT_HELP_BUTTON := "\u5e2e\u52a9"
const TEXT_RESET_BUTTON := "\u91cd\u7f6e"

@onready var title_label: Label = $TopBar/TitleLabel
@onready var goal_label: Label = $TopBar/GoalLabel
@onready var progress_label: Label = $TopBar/ProgressLabel
@onready var level_label: Label = $TopBar/LevelLabel
@onready var hint_label: Label = $TopBar/HintLabel
@onready var status_label: Label = $BottomBar/StatusLabel
@onready var hint_button: Button = $BottomBar/HintButton
@onready var help_button: Button = $BottomBar/HelpButton
@onready var reset_button: Button = $BottomBar/ResetButton


func _ready() -> void:
	_apply_styles()
	_set_static_copy()
	hint_button.pressed.connect(_on_hint_button_pressed)
	help_button.pressed.connect(_on_help_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)

	GameState.state_changed.connect(_on_state_changed)
	GameState.level_changed.connect(_on_level_changed)
	GameState.level_completed.connect(_on_level_completed)
	GameData.level_progress_changed.connect(_on_level_progress_changed)
	GameData.hint_count_changed.connect(_on_hint_count_changed)

	_connect_scene_signals()
	_on_state_changed(GameState.current_state)
	_on_level_progress_changed(
		GameData.current_level_index,
		GameData.get_completed_count(),
		GameData.total_levels
	)
	_on_hint_count_changed(GameData.hint_count)


func _connect_scene_signals() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return

	if scene.has_signal("level_loaded") and not scene.level_loaded.is_connected(_on_level_loaded):
		scene.level_loaded.connect(_on_level_loaded)

	if scene.has_signal("placement_progress_changed") and not scene.placement_progress_changed.is_connected(_on_placement_progress_changed):
		scene.placement_progress_changed.connect(_on_placement_progress_changed)

	if scene.has_method("get_current_level_data"):
		var level_data: Dictionary = scene.get_current_level_data()
		if not level_data.is_empty():
			_on_level_loaded(level_data)


func _on_level_loaded(level_data: Dictionary) -> void:
	title_label.text = str(level_data.get("title", TEXT_DEFAULT_TITLE))
	goal_label.text = str(level_data.get("goal", TEXT_DEFAULT_GOAL))
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("_emit_progress"):
		scene._emit_progress()


func _on_placement_progress_changed(placed_count: int, total_count: int) -> void:
	progress_label.text = "\u5df2\u5f52\u4f4d %d / %d" % [placed_count, total_count]


func _on_level_progress_changed(current_level_index: int, completed_count: int, total_levels: int) -> void:
	level_label.text = "\u7b2c %d \u5173 / \u5171 %d \u5173" % [current_level_index + 1, maxi(total_levels, 1)]
	status_label.text = "\u5df2\u5b8c\u6210 %d / %d \u4e2a\u573a\u666f" % [completed_count, total_levels]


func _on_hint_count_changed(hint_count: int) -> void:
	hint_label.text = "\u63d0\u793a\u6b21\u6570\uff1a%d" % hint_count


func _on_state_changed(new_state: int) -> void:
	match new_state:
		GameState.State.MENU:
			status_label.text = "\u6b22\u8fce\u56de\u6765\u3002"
		GameState.State.INSTRUCTIONS:
			status_label.text = "\u8f7b\u8f7b\u770b\u4e00\u773c\u8bf4\u660e\uff0c\u518d\u5f00\u59cb\u4e5f\u4e0d\u8fdf\u3002"
		GameState.State.PLAYING:
			status_label.text = "\u5148\u628a\u773c\u524d\u7684\u5c0f\u7269\u4ef6\u6574\u7406\u59a5\u5f53\u5427\u3002"
		GameState.State.PAUSED:
			status_label.text = "\u6682\u505c\u4e2d"
		GameState.State.COMPLETED:
			status_label.text = "\u8fd9\u4e00\u5173\u5df2\u7ecf\u6536\u62fe\u597d\u4e86\u3002"


func _on_level_changed(level_index: int) -> void:
	level_label.text = "\u7b2c %d \u5173 / \u5171 %d \u5173" % [level_index + 1, maxi(GameData.total_levels, 1)]
	_connect_scene_signals()


func _on_level_completed(_level_index: int) -> void:
	status_label.text = "\u8fd9\u4e00\u5173\u5df2\u7ecf\u6536\u62fe\u597d\u4e86\u3002"


func _on_hint_button_pressed() -> void:
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("show_hint"):
		scene.show_hint()


func _on_help_button_pressed() -> void:
	AudioManager.play_sound("button")
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("show_instructions"):
		scene.show_instructions()


func _on_reset_button_pressed() -> void:
	AudioManager.play_sound("button")
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("reset_level"):
		scene.reset_level()


func _set_static_copy() -> void:
	title_label.text = TEXT_DEFAULT_TITLE
	goal_label.text = TEXT_DEFAULT_GOAL
	progress_label.text = "\u5df2\u5f52\u4f4d 0 / 0"
	level_label.text = "\u7b2c 1 \u5173 / \u5171 3 \u5173"
	hint_label.text = "\u63d0\u793a\u6b21\u6570\uff1a0"
	status_label.text = "\u8f7b\u6309\u9f20\u6807\uff0c\u628a\u7269\u54c1\u653e\u56de\u5b83\u8be5\u5728\u7684\u4f4d\u7f6e\u3002"
	hint_button.text = TEXT_HINT_BUTTON
	help_button.text = TEXT_HELP_BUTTON
	reset_button.text = TEXT_RESET_BUTTON


func _apply_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.985, 0.965, 0.93, 0.9)
	panel_style.corner_radius_top_left = 24
	panel_style.corner_radius_top_right = 24
	panel_style.corner_radius_bottom_right = 24
	panel_style.corner_radius_bottom_left = 24
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.56, 0.47, 0.39, 0.22)
	panel_style.shadow_color = Color(0.2, 0.16, 0.12, 0.1)
	panel_style.shadow_size = 8

	$TopBar.add_theme_stylebox_override("panel", panel_style)
	$BottomBar.add_theme_stylebox_override("panel", panel_style)

	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color(0.79, 0.66, 0.52, 1.0)
	button_style.corner_radius_top_left = 18
	button_style.corner_radius_top_right = 18
	button_style.corner_radius_bottom_right = 18
	button_style.corner_radius_bottom_left = 18
	button_style.border_width_left = 2
	button_style.border_width_top = 2
	button_style.border_width_right = 2
	button_style.border_width_bottom = 2
	button_style.border_color = Color(0.43, 0.33, 0.25, 0.2)

	var button_hover := button_style.duplicate()
	button_hover.bg_color = Color(0.88, 0.76, 0.61, 1.0)

	for button in [hint_button, help_button, reset_button]:
		button.add_theme_stylebox_override("normal", button_style)
		button.add_theme_stylebox_override("hover", button_hover)
		button.add_theme_stylebox_override("pressed", button_hover)
		button.add_theme_color_override("font_color", Color(0.25, 0.18, 0.13, 1.0))

	title_label.add_theme_color_override("font_color", Color(0.28, 0.2, 0.15, 1.0))
	goal_label.add_theme_color_override("font_color", Color(0.36, 0.28, 0.21, 0.84))
	progress_label.add_theme_color_override("font_color", Color(0.36, 0.28, 0.21, 0.84))
	level_label.add_theme_color_override("font_color", Color(0.36, 0.28, 0.21, 0.84))
	hint_label.add_theme_color_override("font_color", Color(0.36, 0.28, 0.21, 0.84))
	status_label.add_theme_color_override("font_color", Color(0.34, 0.26, 0.19, 0.92))
