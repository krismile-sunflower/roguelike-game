extends Node2D

signal placement_progress_changed(placed_count: int, total_count: int)
signal level_loaded(level_data: Dictionary)

const ITEM_SCENE := preload("res://scenes/draggable_item.tscn")
const TARGET_SCENE := preload("res://scenes/drop_target.tscn")

const TEXT_MAIN_TITLE := "\u6574\u7406\u65f6\u5149"
const TEXT_MAIN_SUBTITLE := "\u628a\u6563\u843d\u7684\u5c0f\u7269\u4ef6\uff0c\u6162\u6162\u653e\u56de\u5b83\u4eec\u8212\u670d\u7684\u4f4d\u7f6e\u3002"
const TEXT_START := "\u5f00\u59cb\u6574\u7406"
const TEXT_CONTINUE := "\u7ee7\u7eed\u6574\u7406"
const TEXT_INSTRUCTIONS := "\u73a9\u6cd5\u8bf4\u660e"
const TEXT_QUIT := "\u9000\u51fa\u6e38\u620f"
const TEXT_BACK := "\u8fd4\u56de"
const TEXT_PAUSE_TITLE := "\u5148\u6b47\u4e00\u4f1a\u513f"
const TEXT_RESET_LEVEL := "\u91cd\u7f6e\u672c\u5173"
const TEXT_RETURN_HOME := "\u56de\u5230\u4e3b\u9875"
const TEXT_NEXT_LEVEL := "\u4e0b\u4e00\u5173"
const TEXT_COMPLETE_TITLE := "\u6574\u7406\u597d\u4e86"
const TEXT_COMPLETE_SPARKLE := "\u8fd9\u4e00\u5c0f\u7247\u65e5\u5e38\uff0c\u5df2\u7ecf\u56de\u5230\u8212\u670d\u7684\u6a21\u6837\u3002"
const TEXT_LEVEL_DONE := "\u5173\u5361\u5b8c\u6210\u3002\u7ee7\u7eed\u628a\u8fd9\u4e00\u4efd\u8212\u670d\uff0c\u5e26\u53bb\u4e0b\u4e00\u9875\u5427\u3002"
const TEXT_LAST_LEVEL_DONE := "\u8fd9\u4e00\u9875\u65e5\u5e38\u5df2\u7ecf\u6574\u7406\u59a5\u5f53\u3002"
const TEXT_TUTORIAL_START := "\u6b22\u8fce\u6765\u5230\u6574\u7406\u65f6\u5149\u3002\u5148\u8bd5\u7740\u62ff\u8d77\u4e00\u4e2a\u7269\u54c1\u5427\u3002"
const TEXT_TUTORIAL_DRAG := "\u5f88\u597d\uff0c\u62d6\u5230\u5b83\u5408\u9002\u7684\u4f4d\u7f6e\u540e\u677e\u5f00\u9f20\u6807\u3002"
const TEXT_TUTORIAL_SNAP := "\u653e\u5bf9\u540e\u4f1a\u8f7b\u8f7b\u5438\u9644\u5230\u4f4d\uff0c\u653e\u9519\u5219\u4f1a\u56de\u5230\u539f\u5904\u3002"
const TEXT_TUTORIAL_FINISH := "\u6162\u6162\u6574\u7406\u5b8c\u8fd9\u5173\u7684\u5168\u90e8\u7269\u54c1\uff0c\u5c31\u80fd\u7ee7\u7eed\u4e0b\u4e00\u6bb5\u6e29\u67d4\u65e5\u5e38\u3002"
const TEXT_INSTRUCTION_BODY := "1. \u6309\u4f4f\u9f20\u6807\u5de6\u952e\u62ff\u8d77\u7269\u54c1\u3002\n2. \u62d6\u5230\u5408\u9002\u7684\u4f4d\u7f6e\u540e\u677e\u5f00\u9f20\u6807\u3002\n3. \u653e\u5bf9\u4f1a\u81ea\u52a8\u5438\u9644\uff0c\u653e\u9519\u4f1a\u56de\u5230\u539f\u4f4d\u3002\n4. \u6574\u7406\u5b8c\u672c\u5173\u5168\u90e8\u7269\u54c1\uff0c\u5c31\u80fd\u8fdb\u5165\u4e0b\u4e00\u5173\u3002\n5. \u6309 Esc \u53ef\u4ee5\u6682\u505c\u6216\u7ee7\u7eed\u3002\n6. \u6e38\u620f\u5185\u53ef\u4ee5\u4f7f\u7528\u63d0\u793a\u3001\u5e2e\u52a9\u548c\u91cd\u7f6e\u672c\u5173\u3002"

const LEVELS := [
	{
		"title": "\u6668\u95f4\u4e66\u67b6",
		"goal": "\u628a\u8fd9\u4e9b\u966a\u4f34\u6e05\u6668\u7684\u5c0f\u7269\u4ef6\uff0c\u8f7b\u8f7b\u653e\u56de\u5b83\u4eec\u719f\u6089\u7684\u4f4d\u7f6e\u3002",
		"background_color": Color(0.97, 0.94, 0.89, 1.0),
		"desk_color": Color(0.84, 0.73, 0.62, 1.0),
		"targets": [
			{
				"id": "lamp_slot",
				"label": "\u53f0\u706f",
				"mode": "single",
				"accepted_item_ids": ["lamp"],
				"position": Vector2(295, 310),
				"size": Vector2(140, 120),
				"color": Color(0.79, 0.77, 0.70, 0.5),
			},
			{
				"id": "book_slot",
				"label": "\u7b14\u8bb0\u672c",
				"mode": "single",
				"accepted_item_ids": ["book"],
				"position": Vector2(640, 320),
				"size": Vector2(150, 90),
				"color": Color(0.78, 0.74, 0.67, 0.5),
			},
			{
				"id": "camera_slot",
				"label": "\u76f8\u673a",
				"mode": "single",
				"accepted_item_ids": ["camera"],
				"position": Vector2(960, 315),
				"size": Vector2(150, 100),
				"color": Color(0.78, 0.74, 0.67, 0.5),
			},
		],
		"items": [
			{
				"id": "lamp",
				"label": "\u5c0f\u53f0\u706f",
				"target_id": "lamp_slot",
				"home_position": Vector2(240, 575),
				"size": Vector2(135, 86),
				"color": Color(0.98, 0.87, 0.57, 1.0),
			},
			{
				"id": "book",
				"label": "\u65c5\u884c\u7b14\u8bb0",
				"target_id": "book_slot",
				"home_position": Vector2(600, 600),
				"size": Vector2(148, 76),
				"color": Color(0.75, 0.86, 0.96, 1.0),
			},
			{
				"id": "camera",
				"label": "\u80f6\u7247\u76f8\u673a",
				"target_id": "camera_slot",
				"home_position": Vector2(980, 585),
				"size": Vector2(142, 82),
				"color": Color(0.96, 0.80, 0.78, 1.0),
			},
		],
	},
	{
		"title": "\u4e66\u810a\u6392\u6392\u7ad9",
		"goal": "\u6309\u7167\u4ece\u77ee\u5230\u9ad8\u7684\u987a\u5e8f\uff0c\u628a\u4e09\u672c\u4e66\u6162\u6162\u6392\u597d\u3002",
		"background_color": Color(0.93, 0.93, 0.9, 1.0),
		"desk_color": Color(0.71, 0.76, 0.73, 1.0),
		"targets": [
			{
				"id": "book_small",
				"label": "\u7b2c\u4e00\u683c",
				"mode": "single",
				"accepted_item_ids": ["book_short"],
				"position": Vector2(385, 360),
				"size": Vector2(120, 150),
				"color": Color(0.72, 0.69, 0.80, 0.5),
			},
			{
				"id": "book_medium",
				"label": "\u7b2c\u4e8c\u683c",
				"mode": "single",
				"accepted_item_ids": ["book_mid"],
				"position": Vector2(640, 360),
				"size": Vector2(120, 170),
				"color": Color(0.72, 0.69, 0.80, 0.5),
			},
			{
				"id": "book_tall",
				"label": "\u7b2c\u4e09\u683c",
				"mode": "single",
				"accepted_item_ids": ["book_tall"],
				"position": Vector2(895, 360),
				"size": Vector2(120, 200),
				"color": Color(0.72, 0.69, 0.80, 0.5),
			},
		],
		"items": [
			{
				"id": "book_mid",
				"label": "\u82d4\u8272\u624b\u8d26",
				"target_id": "book_medium",
				"home_position": Vector2(280, 590),
				"size": Vector2(120, 130),
				"color": Color(0.72, 0.84, 0.68, 1.0),
			},
			{
				"id": "book_tall",
				"label": "\u7d20\u63cf\u96c6",
				"target_id": "book_tall",
				"home_position": Vector2(645, 600),
				"size": Vector2(120, 160),
				"color": Color(0.96, 0.78, 0.62, 1.0),
			},
			{
				"id": "book_short",
				"label": "\u53e3\u888b\u8bd7\u96c6",
				"target_id": "book_small",
				"home_position": Vector2(1000, 592),
				"size": Vector2(120, 95),
				"color": Color(0.65, 0.78, 0.95, 1.0),
			},
		],
	},
	{
		"title": "\u6e29\u67d4\u5206\u7c7b",
		"goal": "\u628a\u53a8\u623f\u5c0f\u7269\u653e\u8fdb\u6258\u76d8\uff0c\u628a\u753b\u753b\u5de5\u5177\u6536\u8fdb\u7bee\u5b50\u91cc\u3002",
		"background_color": Color(0.94, 0.95, 0.91, 1.0),
		"desk_color": Color(0.76, 0.82, 0.73, 1.0),
		"targets": [
			{
				"id": "kitchen_bin",
				"label": "\u53a8\u623f\u6258\u76d8",
				"mode": "category_bin",
				"accepted_category": "kitchen",
				"position": Vector2(385, 340),
				"size": Vector2(260, 170),
				"slot_positions": [
					Vector2(-68, -22),
					Vector2(0, 18),
					Vector2(72, -10),
				],
				"color": Color(0.84, 0.78, 0.66, 0.55),
			},
			{
				"id": "art_bin",
				"label": "\u753b\u6750\u7bee",
				"mode": "category_bin",
				"accepted_category": "art",
				"position": Vector2(895, 340),
				"size": Vector2(260, 170),
				"slot_positions": [
					Vector2(-70, -18),
					Vector2(2, 16),
					Vector2(74, -8),
				],
				"color": Color(0.72, 0.83, 0.88, 0.55),
			},
		],
		"items": [
			{
				"id": "mug",
				"label": "\u8336\u676f",
				"target_id": "kitchen_bin",
				"category": "kitchen",
				"home_position": Vector2(215, 595),
				"size": Vector2(112, 76),
				"color": Color(0.98, 0.88, 0.70, 1.0),
			},
			{
				"id": "spoon",
				"label": "\u6728\u52fa",
				"target_id": "kitchen_bin",
				"category": "kitchen",
				"home_position": Vector2(450, 608),
				"size": Vector2(118, 60),
				"color": Color(0.86, 0.72, 0.56, 1.0),
			},
			{
				"id": "tea_tin",
				"label": "\u8336\u53f6\u7f50",
				"target_id": "kitchen_bin",
				"category": "kitchen",
				"home_position": Vector2(655, 600),
				"size": Vector2(112, 82),
				"color": Color(0.79, 0.90, 0.70, 1.0),
			},
			{
				"id": "brush",
				"label": "\u753b\u7b14",
				"target_id": "art_bin",
				"category": "art",
				"home_position": Vector2(848, 600),
				"size": Vector2(110, 62),
				"color": Color(0.99, 0.80, 0.71, 1.0),
			},
			{
				"id": "paint",
				"label": "\u989c\u6599\u7ba1",
				"target_id": "art_bin",
				"category": "art",
				"home_position": Vector2(1048, 595),
				"size": Vector2(118, 78),
				"color": Color(0.72, 0.77, 0.97, 1.0),
			},
			{
				"id": "scissors",
				"label": "\u526a\u5200",
				"target_id": "art_bin",
				"category": "art",
				"home_position": Vector2(1180, 610),
				"size": Vector2(100, 74),
				"color": Color(0.95, 0.67, 0.67, 1.0),
			},
		],
	},
]

@onready var background: ColorRect = $Background
@onready var backdrop_glow: ColorRect = $BackdropGlow
@onready var desk_surface: ColorRect = $DeskSurface
@onready var decor_layer: Node2D = $DecorLayer
@onready var targets_layer: Node2D = $TargetsLayer
@onready var items_layer: Node2D = $ItemsLayer
@onready var completion_layer: CanvasLayer = $CompletionLayer
@onready var completion_shade: ColorRect = $CompletionLayer/CompletionShade
@onready var completion_panel: Panel = $CompletionLayer/CompletionPanel
@onready var completion_title: Label = $CompletionLayer/CompletionPanel/CompletionTitle
@onready var completion_label: Label = $CompletionLayer/CompletionPanel/CompletionLabel
@onready var next_button: Button = $CompletionLayer/CompletionPanel/NextButton
@onready var hud: CanvasLayer = $HUD
@onready var menu_layer: CanvasLayer = $MenuLayer
@onready var menu_title: Label = $MenuLayer/MenuPanel/TitleLabel
@onready var menu_subtitle: Label = $MenuLayer/MenuPanel/SubtitleLabel
@onready var start_button: Button = $MenuLayer/MenuPanel/StartButton
@onready var continue_button: Button = $MenuLayer/MenuPanel/ContinueButton
@onready var instructions_button: Button = $MenuLayer/MenuPanel/InstructionsButton
@onready var quit_button: Button = $MenuLayer/MenuPanel/QuitButton
@onready var instructions_layer: CanvasLayer = $InstructionsLayer
@onready var instructions_title: Label = $InstructionsLayer/InstructionsPanel/TitleLabel
@onready var instructions_body: Label = $InstructionsLayer/InstructionsPanel/BodyLabel
@onready var instructions_back_button: Button = $InstructionsLayer/InstructionsPanel/BackButton
@onready var pause_layer: CanvasLayer = $PauseLayer
@onready var pause_title: Label = $PauseLayer/PausePanel/TitleLabel
@onready var pause_resume_button: Button = $PauseLayer/PausePanel/ResumeButton
@onready var pause_reset_button: Button = $PauseLayer/PausePanel/ResetButton
@onready var pause_home_button: Button = $PauseLayer/PausePanel/HomeButton
@onready var tutorial_layer: CanvasLayer = $TutorialLayer
@onready var tutorial_panel: Panel = $TutorialLayer/TutorialPanel
@onready var tutorial_label: Label = $TutorialLayer/TutorialPanel/TutorialLabel

var current_level_data: Dictionary = {}
var current_loaded_level_index: int = 0
var active_targets: Array[DropTarget] = []
var active_items: Array[DraggableItem] = []
var active_drag_item: DraggableItem = null
var instruction_return_state: int = GameState.Menu
var tutorial_active: bool = false
var tutorial_step: int = -1
var tutorial_sequence_running: bool = false
var save_available_before_session: bool = false


func _ready() -> void:
	save_available_before_session = SaveManager.has_save_data()
	_set_static_copy()
	_style_overlay_panels()
	_configure_overlay_input()
	_connect_buttons()

	GameState.state_changed.connect(_on_game_state_changed)
	GameState.level_completed.connect(_on_game_state_level_completed)

	GameData.configure_levels(LEVELS.size())
	var progress := SaveManager.get_progress_data()
	GameData.restore_progress(
		progress.get("completed_levels", []),
		int(progress.get("current_level_index", 0)),
		int(progress.get("hint_count", 0)),
		bool(progress.get("has_seen_tutorial", false))
	)

	_refresh_continue_button()
	show_menu()


func start_new_game() -> void:
	GameData.reset_progress()
	GameData.reset_hint_count()
	load_level(0)


func continue_game() -> void:
	if not SaveManager.has_save_data():
		return
	load_level(GameData.current_level_index)


func load_level(level_id: int) -> void:
	var index := clampi(level_id, 0, LEVELS.size() - 1)
	current_loaded_level_index = index
	current_level_data = LEVELS[index]
	_clear_level_nodes()
	_build_level(current_level_data, index)
	GameData.start_level(index)
	GameState.start_level(index)
	completion_layer.visible = false
	level_loaded.emit(current_level_data)
	_emit_progress()
	_save_progress(true)
	_maybe_start_tutorial(index)


func reset_level() -> void:
	load_level(current_loaded_level_index)


func show_hint() -> void:
	if GameState.current_state != GameState.Playing:
		return

	for item in active_items:
		if not item.is_correctly_placed():
			item.pulse_hint()
			var target := _find_target_by_id(item.solution_target_id)
			if target != null:
				target.pulse_hint()
			GameData.register_hint()
			_save_progress(true)
			return


func show_menu() -> void:
	_hide_tutorial()
	GameState.show_menu()
	_refresh_continue_button()


func show_instructions() -> void:
	if GameState.current_state == GameState.Instructions:
		return
	instruction_return_state = GameState.current_state
	GameState.show_instructions()


func hide_instructions() -> void:
	if instruction_return_state == GameState.Menu:
		GameState.show_menu()
	else:
		GameState.set_state(instruction_return_state)


func pause_game() -> void:
	if GameState.current_state == GameState.Playing:
		GameState.set_state(GameState.Paused)


func resume_game() -> void:
	if GameState.current_state == GameState.Paused:
		GameState.set_state(GameState.Playing)


func get_current_level_data() -> Dictionary:
	return current_level_data


func get_current_level_index() -> int:
	return current_loaded_level_index


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match GameState.current_state:
			GameState.Instructions:
				hide_instructions()
				get_viewport().set_input_as_handled()
				return
			GameState.Playing:
				pause_game()
				get_viewport().set_input_as_handled()
				return
			GameState.Paused:
				resume_game()
				get_viewport().set_input_as_handled()
				return

	if GameState.current_state != GameState.Playing:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_begin_drag(event.position)
		else:
			_try_finish_drag()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and active_drag_item != null:
		active_drag_item.drag_to(event.position)
		get_viewport().set_input_as_handled()


func _try_begin_drag(mouse_position: Vector2) -> void:
	for index in range(active_items.size() - 1, -1, -1):
		var item := active_items[index]
		if item.contains_point(mouse_position):
			if item.current_target != null:
				item.current_target.remove_item(item)
				item.current_target = null
			active_drag_item = item
			active_drag_item.pick_up()
			items_layer.move_child(item, items_layer.get_child_count() - 1)
			AudioManager.play_sound("pickup")
			return


func _try_finish_drag() -> void:
	if active_drag_item == null:
		return

	active_drag_item.drop()
	var matched_target := _find_target_under_point(active_drag_item.global_position, active_drag_item)

	if matched_target != null:
		var snap_position := matched_target.assign_item(active_drag_item)
		active_drag_item.current_target = matched_target
		active_drag_item.snap_to_position(snap_position)
		AudioManager.play_sound("drop_success")
		_on_item_correctly_placed(active_drag_item)
	else:
		active_drag_item.reset_to_home()
		AudioManager.play_sound("drop_reset")

	active_drag_item = null
	_emit_progress()
	_check_level_completion()


func _find_target_under_point(point: Vector2, item: DraggableItem) -> DropTarget:
	for target in active_targets:
		if target.contains_point(point) and target.can_accept(item):
			return target
	return null


func _check_level_completion() -> void:
	for item in active_items:
		if not item.is_correctly_placed():
			return

	var completed_index := current_loaded_level_index
	GameData.complete_level(completed_index)
	if completed_index < LEVELS.size() - 1:
		GameData.set_current_level(completed_index + 1)
	_save_progress(true)
	GameState.complete_level(completed_index)


func _emit_progress() -> void:
	var placed := 0
	for item in active_items:
		if item.is_correctly_placed():
			placed += 1
	placement_progress_changed.emit(placed, active_items.size())


func _on_game_state_changed(new_state: int) -> void:
	menu_layer.visible = new_state == GameState.Menu
	instructions_layer.visible = new_state == GameState.Instructions
	pause_layer.visible = new_state == GameState.Paused
	hud.visible = (
		new_state == GameState.Playing
		or new_state == GameState.Paused
		or new_state == GameState.Completed
	)

	if new_state != GameState.Completed:
		completion_layer.visible = false

	tutorial_layer.visible = tutorial_active and new_state == GameState.Playing


func _on_game_state_level_completed(level_index: int) -> void:
	var is_last_level := level_index >= LEVELS.size() - 1
	completion_title.text = TEXT_COMPLETE_TITLE
	completion_label.text = TEXT_LAST_LEVEL_DONE if is_last_level else TEXT_LEVEL_DONE
	next_button.text = TEXT_RETURN_HOME if is_last_level else TEXT_NEXT_LEVEL
	completion_layer.visible = true
	_pulse_completion_panel()
	AudioManager.play_sound("complete")


func _on_next_button_pressed() -> void:
	completion_layer.visible = false
	if current_loaded_level_index >= LEVELS.size() - 1:
		show_menu()
		return
	load_level(GameData.current_level_index)


func _on_item_pickup_started(_item: DraggableItem) -> void:
	if tutorial_active and tutorial_step == 0:
		tutorial_step = 1
		_show_tutorial_message(TEXT_TUTORIAL_DRAG)


func _on_item_correctly_placed(_item: DraggableItem) -> void:
	if tutorial_active and tutorial_step == 1 and not tutorial_sequence_running:
		tutorial_sequence_running = true
		_run_tutorial_success_sequence()


func _run_tutorial_success_sequence() -> void:
	tutorial_step = 2
	_show_tutorial_message(TEXT_TUTORIAL_SNAP)
	await get_tree().create_timer(1.5).timeout
	if not tutorial_active or current_loaded_level_index != 0:
		tutorial_sequence_running = false
		return
	tutorial_step = 3
	_show_tutorial_message(TEXT_TUTORIAL_FINISH)
	await get_tree().create_timer(2.3).timeout
	if not tutorial_active or current_loaded_level_index != 0:
		tutorial_sequence_running = false
		return
	GameData.mark_tutorial_seen()
	_save_progress(true)
	_hide_tutorial()


func _build_level(level_data: Dictionary, level_index: int) -> void:
	background.color = level_data.get("background_color", Color.WHITE)
	desk_surface.color = level_data.get("desk_color", Color(0.8, 0.7, 0.6, 1.0))
	backdrop_glow.color = Color(level_data.get("background_color", Color.WHITE)).lightened(0.08)
	_build_level_decor(level_index, level_data)

	for target_data in level_data.get("targets", []):
		var target: DropTarget = TARGET_SCENE.instantiate()
		targets_layer.add_child(target)
		target.configure(target_data)
		active_targets.append(target)

	for item_data in level_data.get("items", []):
		var item: DraggableItem = ITEM_SCENE.instantiate()
		items_layer.add_child(item)
		item.configure(item_data)
		item.pickup_started.connect(_on_item_pickup_started)
		active_items.append(item)


func _clear_level_nodes() -> void:
	for decor in decor_layer.get_children():
		decor.queue_free()

	for target in active_targets:
		target.queue_free()
	active_targets.clear()

	for item in active_items:
		item.queue_free()
	active_items.clear()

	active_drag_item = null


func _find_target_by_id(target_id: String) -> DropTarget:
	for target in active_targets:
		if target.target_id == target_id:
			return target
	return null


func _save_progress(force: bool = false) -> void:
	if not force and not save_available_before_session and current_level_data.is_empty():
		return
	SaveManager.save_progress(
		GameData.current_level_index,
		GameData.completed_levels,
		GameData.hint_count,
		GameData.has_seen_tutorial
	)
	save_available_before_session = true
	_refresh_continue_button()


func _refresh_continue_button() -> void:
	continue_button.disabled = not SaveManager.has_save_data()


func _maybe_start_tutorial(level_index: int) -> void:
	tutorial_sequence_running = false
	if level_index == 0 and not GameData.has_seen_tutorial:
		tutorial_active = true
		tutorial_step = 0
		_show_tutorial_message(TEXT_TUTORIAL_START)
	else:
		_hide_tutorial()


func _show_tutorial_message(message: String) -> void:
	tutorial_label.text = message
	tutorial_layer.visible = GameState.current_state == GameState.Playing


func _hide_tutorial() -> void:
	tutorial_active = false
	tutorial_step = -1
	tutorial_sequence_running = false
	tutorial_layer.visible = false


func _connect_buttons() -> void:
	next_button.pressed.connect(_on_next_button_pressed)
	start_button.pressed.connect(start_new_game)
	continue_button.pressed.connect(continue_game)
	instructions_button.pressed.connect(show_instructions)
	quit_button.pressed.connect(_on_quit_button_pressed)
	instructions_back_button.pressed.connect(hide_instructions)
	pause_resume_button.pressed.connect(resume_game)
	pause_reset_button.pressed.connect(_on_pause_reset_pressed)
	pause_home_button.pressed.connect(show_menu)


func _on_pause_reset_pressed() -> void:
	load_level(current_loaded_level_index)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _set_static_copy() -> void:
	menu_title.text = TEXT_MAIN_TITLE
	menu_subtitle.text = TEXT_MAIN_SUBTITLE
	start_button.text = TEXT_START
	continue_button.text = TEXT_CONTINUE
	instructions_button.text = TEXT_INSTRUCTIONS
	quit_button.text = TEXT_QUIT

	instructions_title.text = TEXT_INSTRUCTIONS
	instructions_body.text = TEXT_INSTRUCTION_BODY
	instructions_back_button.text = TEXT_BACK

	pause_title.text = TEXT_PAUSE_TITLE
	pause_resume_button.text = TEXT_CONTINUE
	pause_reset_button.text = TEXT_RESET_LEVEL
	pause_home_button.text = TEXT_RETURN_HOME
	completion_title.text = TEXT_COMPLETE_TITLE
	completion_label.text = TEXT_COMPLETE_SPARKLE


func _style_overlay_panels() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.985, 0.965, 0.93, 0.95)
	panel_style.corner_radius_top_left = 28
	panel_style.corner_radius_top_right = 28
	panel_style.corner_radius_bottom_right = 28
	panel_style.corner_radius_bottom_left = 28
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.58, 0.48, 0.38, 0.26)
	panel_style.shadow_color = Color(0.23, 0.19, 0.14, 0.12)
	panel_style.shadow_size = 10

	for panel in [
		completion_panel,
		$MenuLayer/MenuPanel,
		$InstructionsLayer/InstructionsPanel,
		$PauseLayer/PausePanel,
		tutorial_panel,
	]:
		panel.add_theme_stylebox_override("panel", panel_style)

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
	button_style.border_color = Color(0.43, 0.33, 0.25, 0.22)

	var button_hover := button_style.duplicate()
	button_hover.bg_color = Color(0.88, 0.76, 0.61, 1.0)

	for button in [
		next_button,
		start_button,
		continue_button,
		instructions_button,
		quit_button,
		instructions_back_button,
		pause_resume_button,
		pause_reset_button,
		pause_home_button,
	]:
		button.add_theme_stylebox_override("normal", button_style)
		button.add_theme_stylebox_override("hover", button_hover)
		button.add_theme_stylebox_override("pressed", button_hover)
		button.add_theme_color_override("font_color", Color(0.25, 0.18, 0.13, 1.0))

	var button_disabled := button_style.duplicate()
	button_disabled.bg_color = Color(0.79, 0.75, 0.71, 1.0)
	continue_button.add_theme_stylebox_override("disabled", button_disabled)

	completion_title.add_theme_color_override("font_color", Color(0.31, 0.21, 0.15, 1.0))
	completion_label.add_theme_color_override("font_color", Color(0.36, 0.26, 0.19, 0.92))

	tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _configure_overlay_input() -> void:
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desk_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$MenuLayer/Shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$InstructionsLayer/Shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$PauseLayer/Shade.mouse_filter = Control.MOUSE_FILTER_IGNORE

	$HUD/TopBar.mouse_filter = Control.MOUSE_FILTER_PASS
	$HUD/BottomBar.mouse_filter = Control.MOUSE_FILTER_PASS
	completion_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	completion_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	$MenuLayer/MenuPanel.mouse_filter = Control.MOUSE_FILTER_PASS
	$InstructionsLayer/InstructionsPanel.mouse_filter = Control.MOUSE_FILTER_PASS
	$PauseLayer/PausePanel.mouse_filter = Control.MOUSE_FILTER_PASS

	for control in [
		completion_label,
		menu_title,
		menu_subtitle,
		instructions_title,
		instructions_body,
		pause_title,
		$HUD/TopBar/TitleLabel,
		$HUD/TopBar/GoalLabel,
		$HUD/TopBar/ProgressLabel,
		$HUD/TopBar/LevelLabel,
		$HUD/TopBar/HintLabel,
		$HUD/BottomBar/StatusLabel,
		tutorial_label,
	]:
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _pulse_completion_panel() -> void:
	completion_panel.scale = Vector2(0.94, 0.94)
	completion_panel.modulate = Color(1, 1, 1, 0.0)
	completion_shade.modulate = Color(1, 1, 1, 0.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(completion_panel, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(completion_panel, "modulate", Color(1, 1, 1, 1), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(completion_shade, "modulate", Color(1, 1, 1, 1), 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _build_level_decor(level_index: int, level_data: Dictionary) -> void:
	var paper_color: Color = Color(level_data.get("background_color", Color.WHITE)).lightened(0.03)
	var accent_color: Color = Color(level_data.get("desk_color", Color(0.8, 0.7, 0.6, 1.0))).darkened(0.12)
	var warm_shadow: Color = Color(0.3, 0.22, 0.15, 0.08)

	_add_rect(decor_layer, Vector2(118, 188), Vector2(1044, 24), warm_shadow)
	_add_rect(decor_layer, Vector2(126, 176), Vector2(1028, 20), accent_color.darkened(0.1))
	_add_rect(decor_layer, Vector2(150, 220), Vector2(980, 280), paper_color)

	match level_index:
		0:
			_build_shelf_decor()
		1:
			_build_library_decor()
		2:
			_build_sorting_decor()
		_:
			_build_generic_decor()


func _build_shelf_decor() -> void:
	_add_rect(decor_layer, Vector2(188, 138), Vector2(900, 18), Color(0.74, 0.64, 0.52, 0.95))
	_add_rect(decor_layer, Vector2(232, 98), Vector2(88, 32), Color(0.94, 0.86, 0.74, 1.0))
	_add_rect(decor_layer, Vector2(344, 84), Vector2(46, 46), Color(0.87, 0.76, 0.60, 1.0))
	_add_rect(decor_layer, Vector2(948, 86), Vector2(110, 44), Color(0.96, 0.91, 0.84, 1.0))
	_add_rect(decor_layer, Vector2(930, 260), Vector2(180, 118), Color(1.0, 0.97, 0.91, 0.52))
	_add_plant(decor_layer, Vector2(1030, 128), Color(0.52, 0.69, 0.45, 1.0), Color(0.87, 0.74, 0.56, 1.0))
	_add_cloth(decor_layer, Vector2(176, 470), Vector2(250, 122), Color(0.86, 0.77, 0.68, 0.4))


func _build_library_decor() -> void:
	_add_rect(decor_layer, Vector2(206, 88), Vector2(856, 212), Color(0.98, 0.96, 0.92, 0.45))
	_add_rect(decor_layer, Vector2(280, 118), Vector2(88, 146), Color(0.73, 0.79, 0.62, 0.75))
	_add_rect(decor_layer, Vector2(384, 106), Vector2(54, 158), Color(0.88, 0.72, 0.59, 0.78))
	_add_rect(decor_layer, Vector2(456, 136), Vector2(70, 128), Color(0.66, 0.75, 0.9, 0.8))
	_add_rect(decor_layer, Vector2(770, 304), Vector2(72, 190), Color(0.69, 0.65, 0.78, 0.22))
	_add_rect(decor_layer, Vector2(436, 514), Vector2(470, 76), Color(0.95, 0.91, 0.84, 0.56))
	_add_cloth(decor_layer, Vector2(294, 484), Vector2(590, 130), Color(0.83, 0.76, 0.90, 0.28))


func _build_sorting_decor() -> void:
	_add_rect(decor_layer, Vector2(186, 90), Vector2(884, 170), Color(1.0, 0.99, 0.95, 0.42))
	_add_rect(decor_layer, Vector2(196, 490), Vector2(886, 104), Color(0.93, 0.90, 0.82, 0.42))
	_add_cloth(decor_layer, Vector2(160, 474), Vector2(394, 128), Color(0.89, 0.8, 0.72, 0.3))
	_add_cloth(decor_layer, Vector2(740, 474), Vector2(380, 128), Color(0.76, 0.86, 0.89, 0.28))
	_add_plant(decor_layer, Vector2(228, 144), Color(0.51, 0.69, 0.54, 1.0), Color(0.92, 0.84, 0.72, 1.0))
	_add_jar(decor_layer, Vector2(986, 146), Color(0.96, 0.94, 0.87, 1.0), Color(0.84, 0.72, 0.58, 1.0))


func _build_generic_decor() -> void:
	_add_rect(decor_layer, Vector2(182, 104), Vector2(884, 160), Color(1.0, 0.99, 0.95, 0.3))


func _add_rect(parent: Node, position_value: Vector2, size_value: Vector2, color_value: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = position_value
	rect.size = size_value
	rect.color = color_value
	parent.add_child(rect)
	return rect


func _add_polygon(parent: Node, position_value: Vector2, points: PackedVector2Array, color_value: Color) -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.position = position_value
	polygon.polygon = points
	polygon.color = color_value
	parent.add_child(polygon)
	return polygon


func _add_cloth(parent: Node, position_value: Vector2, size_value: Vector2, color_value: Color) -> void:
	_add_polygon(
		parent,
		position_value,
		PackedVector2Array([
			Vector2(0, 8),
			Vector2(size_value.x * 0.16, 0),
			Vector2(size_value.x * 0.42, 16),
			Vector2(size_value.x * 0.67, 4),
			Vector2(size_value.x, 18),
			Vector2(size_value.x * 0.92, size_value.y),
			Vector2(size_value.x * 0.18, size_value.y * 0.92),
			Vector2(0, size_value.y * 0.7),
		]),
		color_value
	)


func _add_plant(parent: Node, position_value: Vector2, leaf_color: Color, pot_color: Color) -> void:
	_add_rect(parent, position_value + Vector2(-24, 30), Vector2(48, 28), pot_color)
	_add_polygon(parent, position_value + Vector2(-6, 26), PackedVector2Array([
		Vector2(0, 0), Vector2(30, -48), Vector2(18, -6)
	]), leaf_color)
	_add_polygon(parent, position_value + Vector2(10, 24), PackedVector2Array([
		Vector2(0, 0), Vector2(36, -34), Vector2(24, 4)
	]), leaf_color.darkened(0.08))
	_add_polygon(parent, position_value + Vector2(-18, 22), PackedVector2Array([
		Vector2(0, 0), Vector2(-34, -42), Vector2(-20, 2)
	]), leaf_color.lightened(0.05))


func _add_jar(parent: Node, position_value: Vector2, glass_color: Color, lid_color: Color) -> void:
	_add_rect(parent, position_value + Vector2(-28, 8), Vector2(56, 64), glass_color)
	_add_rect(parent, position_value + Vector2(-20, 0), Vector2(40, 12), lid_color)
	_add_rect(parent, position_value + Vector2(-14, 20), Vector2(28, 32), glass_color.darkened(0.05))
