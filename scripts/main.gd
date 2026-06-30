extends Node2D

enum Tile {
	WALL,
	FLOOR,
}

enum RunOutcome {
	NONE,
	LEVEL_COMPLETE,
	VICTORY,
	GAME_OVER,
}

const WINDOW_SIZE := Vector2(1280, 720)
const TILE_SIZE := 32
const GRID_WIDTH := 30
const GRID_HEIGHT := 18
const MAP_ORIGIN := Vector2(28, 92)
const MAP_SIZE := Vector2(GRID_WIDTH * TILE_SIZE, GRID_HEIGHT * TILE_SIZE)
const PANEL_X := 1016.0
const MAX_LEVELS := 5

const DIRECTIONS := [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]

const TEXTURE_PATHS := {
	"floor": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0048.png",
	"floor_alt": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0049.png",
	"floor_mark": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0042.png",
	"wall": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0014.png",
	"wall_dark": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0040.png",
	"door": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0045.png",
	"player": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0085.png",
	"slime": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0120.png",
	"bat": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0122.png",
	"cultist": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0112.png",
	"ghost": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0096.png",
	"brute": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0110.png",
	"boss": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0123.png",
	"potion": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0114.png",
	"coin": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0113.png",
	"sword": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0103.png",
	"shield": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0102.png",
	"chest": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0079.png",
	"rubble": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0053.png",
	"torch": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0029.png",
}

const ENEMY_TYPES := {
	"slime": {
		"name": "黏液",
		"hp": 3,
		"attack": 1,
		"score": 18,
		"texture": "slime",
		"awareness": 5,
	},
	"bat": {
		"name": "蝙蝠",
		"hp": 2,
		"attack": 1,
		"score": 20,
		"texture": "bat",
		"awareness": 7,
	},
	"cultist": {
		"name": "烛影侍从",
		"hp": 4,
		"attack": 2,
		"score": 35,
		"texture": "cultist",
		"awareness": 6,
	},
	"ghost": {
		"name": "游魂",
		"hp": 5,
		"attack": 2,
		"score": 45,
		"texture": "ghost",
		"awareness": 8,
	},
	"brute": {
		"name": "赤甲守卫",
		"hp": 7,
		"attack": 3,
		"score": 70,
		"texture": "brute",
		"awareness": 6,
	},
	"boss": {
		"name": "深井看守",
		"hp": 13,
		"attack": 3,
		"score": 180,
		"texture": "boss",
		"awareness": 10,
	},
}

const LEVEL_DEFS := [
	{
		"title": "第一层：旧井门厅",
		"goal": "摸清地形，清掉守在门厅里的弱小怪物。",
		"room_count": 7,
		"enemy_groups": [
			{"type": "slime", "count": 3},
			{"type": "bat", "count": 1},
		],
		"potions": 2,
		"coins": 4,
		"gear": ["sword"],
	},
	{
		"title": "第二层：潮湿回廊",
		"goal": "回廊更窄，敌人会更快靠近。",
		"room_count": 8,
		"enemy_groups": [
			{"type": "slime", "count": 3},
			{"type": "bat", "count": 3},
			{"type": "cultist", "count": 1},
		],
		"potions": 2,
		"coins": 5,
		"gear": [],
	},
	{
		"title": "第三层：碎骨仓库",
		"goal": "优先处理远处游荡的敌人，别被夹在墙角。",
		"room_count": 9,
		"enemy_groups": [
			{"type": "bat", "count": 3},
			{"type": "cultist", "count": 3},
			{"type": "ghost", "count": 1},
		],
		"potions": 3,
		"coins": 6,
		"gear": ["shield"],
	},
	{
		"title": "第四层：熄火祭室",
		"goal": "赤甲守卫会重击，药水要留到真正需要时。",
		"room_count": 10,
		"enemy_groups": [
			{"type": "cultist", "count": 3},
			{"type": "ghost", "count": 2},
			{"type": "brute", "count": 2},
		],
		"potions": 3,
		"coins": 7,
		"gear": [],
	},
	{
		"title": "第五层：深井王座",
		"goal": "击败深井看守，带着宝物离开地牢。",
		"room_count": 10,
		"enemy_groups": [
			{"type": "ghost", "count": 2},
			{"type": "brute", "count": 2},
			{"type": "boss", "count": 1},
		],
		"potions": 4,
		"coins": 8,
		"gear": ["sword", "shield"],
	},
]

var rng := RandomNumberGenerator.new()
var textures: Dictionary = {}
var dungeon: Array = []
var rooms: Array[Rect2i] = []
var current_level_index := 0
var run_outcome := RunOutcome.NONE

var player_cell := Vector2i.ZERO
var player_hp := 8
var player_max_hp := 8
var player_attack := 2
var exit_cell := Vector2i.ZERO
var exit_open := false

var enemies: Array[Dictionary] = []
var items: Array[Dictionary] = []
var log_lines: Array[String] = []

var background_layer: CanvasLayer
var map_layer: Node2D
var decor_layer: Node2D
var item_layer: Node2D
var actor_layer: Node2D
var fx_layer: Node2D
var ui_layer: CanvasLayer

var player_node: Node2D
var exit_node: Sprite2D
var title_label: Label
var goal_label: Label
var hp_label: Label
var attack_label: Label
var score_label: Label
var depth_label: Label
var enemies_label: Label
var status_label: Label
var log_label: Label
var continue_button: Button
var menu_layer: CanvasLayer
var instructions_layer: CanvasLayer
var pause_layer: CanvasLayer
var result_layer: CanvasLayer
var result_title_label: Label
var result_body_label: Label
var result_primary_button: Button
var result_secondary_button: Button


func _ready() -> void:
	rng.randomize()
	_load_textures()
	_build_scene()
	GameData.configure_levels(LEVEL_DEFS.size())
	_refresh_continue_button()
	show_menu()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_handle_escape()
			return

		if GameState.current_state == GameState.Playing:
			var direction := _direction_from_key(key_event.keycode)
			if direction != Vector2i.ZERO:
				_attempt_player_step(direction)
				return
			if key_event.keycode == KEY_SPACE or key_event.keycode == KEY_PERIOD:
				_wait_turn()
				return
			if key_event.keycode == KEY_R:
				restart_level()
				return

		if GameState.current_state == GameState.Menu and key_event.keycode == KEY_ENTER:
			start_new_run()
			return

		if GameState.current_state == GameState.Completed and key_event.keycode == KEY_ENTER:
			_on_result_primary_pressed()


func show_menu() -> void:
	GameState.show_menu()
	menu_layer.visible = true
	instructions_layer.visible = false
	pause_layer.visible = false
	result_layer.visible = false
	_set_hud_visible(false)
	_refresh_continue_button()


func show_instructions() -> void:
	GameState.show_instructions()
	menu_layer.visible = false
	instructions_layer.visible = true
	pause_layer.visible = false
	result_layer.visible = false
	_set_hud_visible(false)


func hide_instructions() -> void:
	show_menu()


func start_new_run() -> void:
	GameData.configure_levels(LEVEL_DEFS.size())
	GameData.reset_progress()
	GameData.reset_hint_count()
	GameData.reset()
	player_max_hp = 8
	player_hp = player_max_hp
	player_attack = 2
	GameData.player_health = player_hp
	GameData.health_changed.emit(player_hp)
	GameData.set_current_level(0)
	run_outcome = RunOutcome.NONE
	log_lines.clear()
	_add_log("你推开旧井门，火把在潮湿空气里亮了一下。")
	_load_level(0)


func continue_run() -> void:
	if not SaveManager.has_save_data():
		start_new_run()
		return

	var progress := SaveManager.get_progress_data()
	GameData.configure_levels(LEVEL_DEFS.size())
	GameData.restore_progress(
		progress.get("completed_levels", []),
		int(progress.get("current_level_index", 0)),
		int(progress.get("hint_count", 0)),
		bool(progress.get("has_seen_tutorial", false))
	)
	player_max_hp = 8
	player_hp = player_max_hp
	player_attack = 2
	GameData.reset()
	GameData.player_health = player_hp
	GameData.health_changed.emit(player_hp)
	run_outcome = RunOutcome.NONE
	log_lines.clear()
	_add_log("你从上次记录的楼层继续深入。")
	_load_level(GameData.current_level_index)


func restart_level() -> void:
	player_hp = player_max_hp
	GameData.player_health = player_hp
	GameData.health_changed.emit(player_hp)
	_add_log("你重新整理装备，再次踏入这一层。")
	_load_level(current_level_index)


func resume_game() -> void:
	if GameState.current_state == GameState.Paused:
		GameState.set_state(GameState.Playing)
		pause_layer.visible = false
		_set_hud_visible(true)


func pause_game() -> void:
	if GameState.current_state != GameState.Playing:
		return
	GameState.set_state(GameState.Paused)
	pause_layer.visible = true
	_set_hud_visible(true)


func _load_level(level_index: int) -> void:
	current_level_index = clampi(level_index, 0, LEVEL_DEFS.size() - 1)
	GameData.start_level(current_level_index)
	GameState.start_level(current_level_index)
	menu_layer.visible = false
	instructions_layer.visible = false
	pause_layer.visible = false
	result_layer.visible = false
	_set_hud_visible(true)

	_generate_dungeon()
	_populate_level()
	_render_level()
	_refresh_hud()
	_add_log("进入 " + str(LEVEL_DEFS[current_level_index]["title"]) + "。")


func _load_textures() -> void:
	for key in TEXTURE_PATHS.keys():
		var loaded := load(str(TEXTURE_PATHS[key]))
		if loaded is Texture2D:
			textures[key] = loaded


func _build_scene() -> void:
	background_layer = CanvasLayer.new()
	add_child(background_layer)
	var background := ColorRect.new()
	background.size = WINDOW_SIZE
	background.color = Color(0.075, 0.09, 0.085, 1.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_layer.add_child(background)

	var map_backing := ColorRect.new()
	map_backing.position = MAP_ORIGIN - Vector2(8, 8)
	map_backing.size = MAP_SIZE + Vector2(16, 16)
	map_backing.color = Color(0.04, 0.045, 0.044, 1.0)
	map_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_layer.add_child(map_backing)

	map_layer = Node2D.new()
	map_layer.name = "MapLayer"
	add_child(map_layer)

	decor_layer = Node2D.new()
	decor_layer.name = "DecorLayer"
	add_child(decor_layer)

	item_layer = Node2D.new()
	item_layer.name = "ItemLayer"
	add_child(item_layer)

	actor_layer = Node2D.new()
	actor_layer.name = "ActorLayer"
	add_child(actor_layer)

	fx_layer = Node2D.new()
	fx_layer.name = "FxLayer"
	add_child(fx_layer)

	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	add_child(ui_layer)
	_build_hud()
	_build_menu()
	_build_instructions()
	_build_pause()
	_build_result_layer()


func _build_hud() -> void:
	var panel := Panel.new()
	panel.position = Vector2(PANEL_X, 28)
	panel.size = Vector2(236, 664)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.105, 0.125, 0.115, 0.96), Color(0.35, 0.46, 0.34, 0.9)))
	ui_layer.add_child(panel)

	title_label = _make_label(panel, Vector2(18, 18), Vector2(200, 58), "", 24, Color(0.96, 0.92, 0.74, 1.0))
	goal_label = _make_label(panel, Vector2(18, 80), Vector2(200, 74), "", 15, Color(0.78, 0.84, 0.74, 1.0))
	depth_label = _make_label(panel, Vector2(18, 168), Vector2(200, 28), "", 17, Color(0.98, 0.75, 0.42, 1.0))
	hp_label = _make_label(panel, Vector2(18, 212), Vector2(200, 28), "", 18, Color(0.95, 0.46, 0.36, 1.0))
	attack_label = _make_label(panel, Vector2(18, 244), Vector2(200, 28), "", 18, Color(0.78, 0.86, 0.98, 1.0))
	score_label = _make_label(panel, Vector2(18, 276), Vector2(200, 28), "", 18, Color(0.94, 0.82, 0.45, 1.0))
	enemies_label = _make_label(panel, Vector2(18, 308), Vector2(200, 28), "", 18, Color(0.83, 0.74, 0.96, 1.0))
	status_label = _make_label(panel, Vector2(18, 354), Vector2(200, 70), "", 15, Color(0.78, 0.86, 0.80, 1.0))
	log_label = _make_label(panel, Vector2(18, 438), Vector2(200, 178), "", 14, Color(0.68, 0.74, 0.70, 1.0))

	var hint := _make_label(panel, Vector2(18, 622), Vector2(200, 28), "Esc 暂停  |  R 重开本层", 13, Color(0.55, 0.63, 0.58, 1.0))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _build_menu() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.name = "MenuLayer"
	add_child(menu_layer)
	_add_overlay_shade(menu_layer, Color(0.03, 0.04, 0.04, 0.72))

	var panel := _make_center_panel(menu_layer, Vector2(540, 420))
	_make_label(panel, Vector2(38, 30), Vector2(464, 48), "井下余烬", 38, Color(0.98, 0.88, 0.58, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	_make_label(panel, Vector2(58, 88), Vector2(424, 70), "一款小型回合制地牢 roguelike。清理每层敌人，搜刮补给，走到出口继续深入。", 17, Color(0.72, 0.82, 0.74, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	var start_button := _make_button(panel, Vector2(154, 178), Vector2(232, 44), "开始新探险")
	start_button.pressed.connect(start_new_run)
	continue_button = _make_button(panel, Vector2(154, 232), Vector2(232, 44), "继续探险")
	continue_button.pressed.connect(continue_run)
	var instructions_button := _make_button(panel, Vector2(154, 286), Vector2(232, 44), "探索指南")
	instructions_button.pressed.connect(show_instructions)
	var quit_button := _make_button(panel, Vector2(154, 340), Vector2(232, 44), "退出")
	quit_button.pressed.connect(_quit_game)


func _build_instructions() -> void:
	instructions_layer = CanvasLayer.new()
	instructions_layer.name = "InstructionsLayer"
	instructions_layer.visible = false
	add_child(instructions_layer)
	_add_overlay_shade(instructions_layer, Color(0.03, 0.04, 0.04, 0.76))

	var panel := _make_center_panel(instructions_layer, Vector2(690, 470))
	_make_label(panel, Vector2(42, 30), Vector2(606, 44), "探索指南", 32, Color(0.98, 0.88, 0.58, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	var body := "方向键 / WASD / HJKL：移动；撞向敌人即可攻击。\n\nSpace 或 .：原地等待一回合。敌人会在你行动后移动或攻击。\n\n药水会立刻治疗，金币给分，剑提高攻击，盾提高最大生命。\n\n清掉本层所有敌人后，出口会点亮。踩上出口进入下一层。"
	_make_label(panel, Vector2(60, 96), Vector2(570, 260), body, 18, Color(0.75, 0.84, 0.76, 1.0))
	var back_button := _make_button(panel, Vector2(236, 382), Vector2(218, 44), "返回主菜单")
	back_button.pressed.connect(hide_instructions)


func _build_pause() -> void:
	pause_layer = CanvasLayer.new()
	pause_layer.name = "PauseLayer"
	pause_layer.visible = false
	add_child(pause_layer)
	_add_overlay_shade(pause_layer, Color(0.03, 0.04, 0.04, 0.58))

	var panel := _make_center_panel(pause_layer, Vector2(420, 304))
	_make_label(panel, Vector2(40, 28), Vector2(340, 42), "暂停", 32, Color(0.98, 0.88, 0.58, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	var resume_button := _make_button(panel, Vector2(104, 98), Vector2(212, 42), "继续")
	resume_button.pressed.connect(resume_game)
	var restart_button := _make_button(panel, Vector2(104, 152), Vector2(212, 42), "重开本层")
	restart_button.pressed.connect(restart_level)
	var home_button := _make_button(panel, Vector2(104, 206), Vector2(212, 42), "回到主菜单")
	home_button.pressed.connect(show_menu)


func _build_result_layer() -> void:
	result_layer = CanvasLayer.new()
	result_layer.name = "ResultLayer"
	result_layer.visible = false
	add_child(result_layer)
	_add_overlay_shade(result_layer, Color(0.02, 0.025, 0.025, 0.72))

	var panel := _make_center_panel(result_layer, Vector2(560, 342))
	result_title_label = _make_label(panel, Vector2(42, 30), Vector2(476, 46), "", 32, Color(0.98, 0.88, 0.58, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	result_body_label = _make_label(panel, Vector2(60, 96), Vector2(440, 116), "", 18, Color(0.76, 0.86, 0.78, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	result_primary_button = _make_button(panel, Vector2(90, 248), Vector2(176, 42), "继续")
	result_primary_button.pressed.connect(_on_result_primary_pressed)
	result_secondary_button = _make_button(panel, Vector2(294, 248), Vector2(176, 42), "主菜单")
	result_secondary_button.pressed.connect(show_menu)


func _generate_dungeon() -> void:
	dungeon.clear()
	rooms.clear()
	for _y in range(GRID_HEIGHT):
		var row := []
		for _x in range(GRID_WIDTH):
			row.append(Tile.WALL)
		dungeon.append(row)

	var level_def: Dictionary = LEVEL_DEFS[current_level_index]
	var target_rooms := int(level_def.get("room_count", 7))
	var attempts := 0
	while rooms.size() < target_rooms and attempts < 180:
		attempts += 1
		var room_width := rng.randi_range(4, 8)
		var room_height := rng.randi_range(3, 6)
		var room_x := rng.randi_range(1, GRID_WIDTH - room_width - 2)
		var room_y := rng.randi_range(1, GRID_HEIGHT - room_height - 2)
		var candidate := Rect2i(room_x, room_y, room_width, room_height)
		if _room_overlaps(candidate):
			continue
		rooms.append(candidate)
		_carve_room(candidate)

	if rooms.size() < 2:
		_build_fallback_dungeon()
	else:
		for i in range(1, rooms.size()):
			_carve_corridor(_room_center(rooms[i - 1]), _room_center(rooms[i]))

	player_cell = _room_center(rooms[0])
	exit_cell = _room_center(rooms[rooms.size() - 1])
	exit_open = false


func _build_fallback_dungeon() -> void:
	rooms.clear()
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			dungeon[y][x] = Tile.WALL

	var first := Rect2i(2, 3, 8, 5)
	var second := Rect2i(19, 10, 8, 5)
	rooms.append(first)
	rooms.append(second)
	_carve_room(first)
	_carve_room(second)
	_carve_corridor(_room_center(first), _room_center(second))


func _populate_level() -> void:
	enemies.clear()
	items.clear()

	var reserved: Array[Vector2i] = [player_cell, exit_cell]
	var level_def: Dictionary = LEVEL_DEFS[current_level_index]

	for group in level_def.get("enemy_groups", []):
		var enemy_type := str(group.get("type", "slime"))
		var count := int(group.get("count", 0))
		for _i in range(count):
			var cell := _find_empty_floor_cell(reserved, true)
			reserved.append(cell)
			enemies.append(_make_enemy(enemy_type, cell))

	for _i in range(int(level_def.get("potions", 0))):
		var potion_cell := _find_empty_floor_cell(reserved, false)
		reserved.append(potion_cell)
		items.append(_make_item("potion", potion_cell))

	for _i in range(int(level_def.get("coins", 0))):
		var coin_cell := _find_empty_floor_cell(reserved, false)
		reserved.append(coin_cell)
		items.append(_make_item("coin", coin_cell))

	for gear in level_def.get("gear", []):
		var gear_cell := _find_empty_floor_cell(reserved, true)
		reserved.append(gear_cell)
		items.append(_make_item(str(gear), gear_cell))


func _render_level() -> void:
	_clear_layer(map_layer)
	_clear_layer(decor_layer)
	_clear_layer(item_layer)
	_clear_layer(actor_layer)
	_clear_layer(fx_layer)

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var cell := Vector2i(x, y)
			if dungeon[y][x] == Tile.WALL:
				var wall_key := "wall_dark" if (x + y + current_level_index) % 5 == 0 else "wall"
				_make_tile_sprite(wall_key, cell, map_layer, 0)
			else:
				var floor_key := "floor_alt" if (x * 7 + y * 3 + current_level_index) % 9 == 0 else "floor"
				if (x * 11 + y * 5) % 17 == 0:
					floor_key = "floor_mark"
				_make_tile_sprite(floor_key, cell, map_layer, 0)

	_add_decor()
	exit_node = _make_tile_sprite("door", exit_cell, actor_layer, 1)
	exit_node.modulate = Color(0.42, 0.47, 0.49, 0.84)

	for item in items:
		item["node"] = _make_tile_sprite(str(item["texture"]), item["cell"], item_layer, 1)

	player_node = Node2D.new()
	player_node.position = _cell_to_world(player_cell)
	actor_layer.add_child(player_node)
	var player_sprite := Sprite2D.new()
	player_sprite.texture = textures.get("player")
	player_sprite.scale = Vector2.ONE * 2.0
	player_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player_node.add_child(player_sprite)

	for enemy in enemies:
		enemy["node"] = _make_enemy_node(enemy)

	_refresh_exit()


func _add_decor() -> void:
	var decor_keys: Array[String] = ["rubble", "torch", "chest"]
	var decor_count := 10 + current_level_index * 2
	var reserved: Array[Vector2i] = [player_cell, exit_cell]
	for enemy in enemies:
		reserved.append(enemy["cell"])
	for item in items:
		reserved.append(item["cell"])

	for _i in range(decor_count):
		var cell := _find_empty_floor_cell(reserved, false)
		if cell == Vector2i.ZERO:
			continue
		reserved.append(cell)
		var key: String = decor_keys[rng.randi_range(0, decor_keys.size() - 1)]
		var sprite := _make_tile_sprite(key, cell, decor_layer, 0)
		sprite.modulate = Color(1, 1, 1, 0.48 if key != "torch" else 0.68)


func _attempt_player_step(direction: Vector2i) -> void:
	if GameState.current_state != GameState.Playing:
		return

	var target := player_cell + direction
	if not _is_inside(target) or _tile_at(target) == Tile.WALL:
		_add_log("石墙挡住了去路。")
		AudioManager.play_sound("blocked")
		_bump_node(player_node, direction)
		return

	var enemy: Variant = _enemy_at(target)
	if enemy != null:
		_attack_enemy(enemy)
		if GameState.current_state == GameState.Playing:
			_run_enemy_turns()
		_refresh_hud()
		return

	player_cell = target
	_tween_node_to_cell(player_node, player_cell, 0.08)
	_collect_item_at(player_cell)

	if player_cell == exit_cell and exit_open:
		_complete_current_level()
		return
	elif player_cell == exit_cell and not exit_open:
		_add_log("出口还没有回应。先清掉本层敌人。")

	if GameState.current_state == GameState.Playing:
		_run_enemy_turns()
	_refresh_hud()


func _wait_turn() -> void:
	if GameState.current_state != GameState.Playing:
		return
	_add_log("你屏住呼吸，听见远处有脚步声。")
	_run_enemy_turns()
	_refresh_hud()


func _attack_enemy(enemy: Dictionary) -> void:
	var damage := player_attack + rng.randi_range(0, 1)
	enemy["hp"] = int(enemy["hp"]) - damage
	AudioManager.play_sound("attack")
	_add_log("你击中 " + str(enemy["name"]) + "，造成 " + str(damage) + " 点伤害。")
	_flash_node(enemy.get("node"), Color(1.0, 0.62, 0.45, 1.0))

	if int(enemy["hp"]) <= 0:
		_kill_enemy(enemy)


func _kill_enemy(enemy: Dictionary) -> void:
	AudioManager.play_sound("enemy_down")
	ParticleManager.play_enemy_die_effect(_cell_to_world(enemy["cell"]))
	GameData.add_score(int(enemy["score"]))
	_add_log(str(enemy["name"]) + " 倒下了。")

	var node: Variant = enemy.get("node")
	if node != null and is_instance_valid(node):
		node.queue_free()

	var dead_cell: Vector2i = enemy["cell"]
	enemies.erase(enemy)
	if rng.randf() < 0.24:
		var drop_type := "potion" if rng.randf() < 0.36 else "coin"
		var item := _make_item(drop_type, dead_cell)
		items.append(item)
		item["node"] = _make_tile_sprite(str(item["texture"]), dead_cell, item_layer, 1)

	_refresh_exit()


func _run_enemy_turns() -> void:
	for enemy in enemies.duplicate():
		if GameState.current_state != GameState.Playing:
			return
		if not enemies.has(enemy):
			continue
		var enemy_cell: Vector2i = enemy["cell"]
		var distance := _manhattan(enemy_cell, player_cell)
		if distance <= 1:
			_enemy_attack_player(enemy)
			continue

		var next_cell := enemy_cell
		if distance <= int(enemy["awareness"]):
			next_cell = _best_enemy_step(enemy)
		elif rng.randf() < 0.24:
			var direction: Vector2i = DIRECTIONS[rng.randi_range(0, DIRECTIONS.size() - 1)]
			var wander_cell := enemy_cell + direction
			if _can_enemy_enter(wander_cell, enemy):
				next_cell = wander_cell

		if next_cell != enemy_cell:
			enemy["cell"] = next_cell
			_tween_node_to_cell(enemy.get("node"), next_cell, 0.12)


func _enemy_attack_player(enemy: Dictionary) -> void:
	var damage := int(enemy["attack"])
	player_hp = maxi(player_hp - damage, 0)
	GameData.player_health = player_hp
	GameData.health_changed.emit(player_hp)
	AudioManager.play_sound("hurt")
	ParticleManager.play_hurt_effect(_cell_to_world(player_cell))
	_flash_node(player_node, Color(1.0, 0.36, 0.28, 1.0))
	_add_log(str(enemy["name"]) + " 攻击你，造成 " + str(damage) + " 点伤害。")

	if player_hp <= 0:
		_game_over()


func _collect_item_at(cell: Vector2i) -> void:
	var item: Variant = _item_at(cell)
	if item == null:
		return

	match str(item["type"]):
		"potion":
			var before := player_hp
			player_hp = mini(player_hp + 3, player_max_hp)
			GameData.player_health = player_hp
			GameData.health_changed.emit(player_hp)
			_add_log("喝下药水，恢复 " + str(player_hp - before) + " 点生命。")
			AudioManager.play_sound("potion")
		"coin":
			GameData.add_score(25)
			_add_log("捡到一袋旧金币。")
			AudioManager.play_sound("coin")
		"sword":
			player_attack += 1
			GameData.add_score(45)
			_add_log("你找到一柄短剑，攻击力 +1。")
			AudioManager.play_sound("gear")
		"shield":
			player_max_hp += 2
			player_hp = mini(player_hp + 2, player_max_hp)
			GameData.player_health = player_hp
			GameData.health_changed.emit(player_hp)
			GameData.add_score(45)
			_add_log("盾牌扣上手臂，最大生命 +2。")
			AudioManager.play_sound("gear")

	ParticleManager.play_collect_effect(_cell_to_world(cell))
	var node: Variant = item.get("node")
	if node != null and is_instance_valid(node):
		node.queue_free()
	items.erase(item)


func _complete_current_level() -> void:
	GameData.complete_level(current_level_index)
	var is_last_level := current_level_index >= LEVEL_DEFS.size() - 1
	if is_last_level:
		run_outcome = RunOutcome.VICTORY
		_save_high_score()
		SaveManager.save_progress(0, GameData.completed_levels, GameData.hint_count, GameData.has_seen_tutorial)
		_show_result("地牢清空", "你带着余烬和战利品回到井口。\n最终得分：" + str(GameData.score), "再来一局", "主菜单")
		AudioManager.play_sound("victory")
	else:
		run_outcome = RunOutcome.LEVEL_COMPLETE
		GameData.set_current_level(current_level_index + 1)
		SaveManager.save_progress(GameData.current_level_index, GameData.completed_levels, GameData.hint_count, GameData.has_seen_tutorial)
		_show_result("楼层清理完毕", "出口的火光亮起。下一层会更危险。\n当前得分：" + str(GameData.score), "进入下一层", "主菜单")
		AudioManager.play_sound("stairs")


func _game_over() -> void:
	run_outcome = RunOutcome.GAME_OVER
	_save_high_score()
	_show_result("探险失败", "你倒在第 " + str(current_level_index + 1) + " 层。\n最终得分：" + str(GameData.score), "重新开始", "主菜单")
	AudioManager.play_sound("death")


func _show_result(title: String, body: String, primary_text: String, secondary_text: String) -> void:
	GameState.set_state(GameState.Completed)
	result_title_label.text = title
	result_body_label.text = body
	result_primary_button.text = primary_text
	result_secondary_button.text = secondary_text
	result_layer.visible = true
	pause_layer.visible = false
	menu_layer.visible = false
	instructions_layer.visible = false
	_set_hud_visible(true)


func _on_result_primary_pressed() -> void:
	match run_outcome:
		RunOutcome.LEVEL_COMPLETE:
			_load_level(GameData.current_level_index)
		RunOutcome.VICTORY:
			start_new_run()
		RunOutcome.GAME_OVER:
			start_new_run()
		_:
			show_menu()


func _refresh_hud() -> void:
	var level_def: Dictionary = LEVEL_DEFS[current_level_index]
	title_label.text = str(level_def["title"])
	goal_label.text = str(level_def["goal"])
	depth_label.text = "深度 " + str(current_level_index + 1) + " / " + str(LEVEL_DEFS.size())
	hp_label.text = "生命 " + str(player_hp) + " / " + str(player_max_hp)
	attack_label.text = "攻击 " + str(player_attack) + " - " + str(player_attack + 1)
	score_label.text = "得分 " + str(GameData.score)
	enemies_label.text = "敌人 " + str(enemies.size())
	status_label.text = "出口已开启。" if exit_open else "清理所有敌人后，出口会开启。"
	log_label.text = "\n".join(log_lines)
	_refresh_exit()


func _refresh_exit() -> void:
	exit_open = enemies.is_empty()
	if exit_node != null and is_instance_valid(exit_node):
		if exit_open:
			exit_node.modulate = Color(1.0, 0.92, 0.45, 1.0)
		else:
			exit_node.modulate = Color(0.42, 0.47, 0.49, 0.84)


func _add_log(message: String) -> void:
	log_lines.push_front(message)
	while log_lines.size() > 6:
		log_lines.pop_back()
	if log_label != null:
		log_label.text = "\n".join(log_lines)


func _direction_from_key(keycode: Key) -> Vector2i:
	match keycode:
		KEY_LEFT, KEY_A, KEY_H:
			return Vector2i(-1, 0)
		KEY_RIGHT, KEY_D, KEY_L:
			return Vector2i(1, 0)
		KEY_UP, KEY_W, KEY_K:
			return Vector2i(0, -1)
		KEY_DOWN, KEY_S, KEY_J:
			return Vector2i(0, 1)
		_:
			return Vector2i.ZERO


func _handle_escape() -> void:
	match GameState.current_state:
		GameState.Playing:
			pause_game()
		GameState.Paused:
			resume_game()
		GameState.Instructions:
			hide_instructions()
		GameState.Completed:
			return
		_:
			return


func _make_enemy(enemy_type: String, cell: Vector2i) -> Dictionary:
	var definition: Dictionary = ENEMY_TYPES.get(enemy_type, ENEMY_TYPES["slime"])
	var hp := int(definition["hp"]) + maxi(0, current_level_index - 1)
	return {
		"type": enemy_type,
		"name": definition["name"],
		"hp": hp,
		"max_hp": hp,
		"attack": int(definition["attack"]),
		"score": int(definition["score"]),
		"texture": definition["texture"],
		"awareness": int(definition["awareness"]),
		"cell": cell,
		"node": null,
	}


func _make_item(item_type: String, cell: Vector2i) -> Dictionary:
	var texture_key := item_type
	if item_type == "coin":
		texture_key = "coin"
	return {
		"type": item_type,
		"texture": texture_key,
		"cell": cell,
		"node": null,
	}


func _make_enemy_node(enemy: Dictionary) -> Node2D:
	var node := Node2D.new()
	node.position = _cell_to_world(enemy["cell"])
	actor_layer.add_child(node)

	var sprite := Sprite2D.new()
	sprite.texture = textures.get(str(enemy["texture"]))
	sprite.scale = Vector2.ONE * 2.0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)

	return node


func _make_tile_sprite(texture_key: String, cell: Vector2i, parent: Node, z: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = textures.get(texture_key)
	sprite.position = _cell_to_world(cell)
	sprite.scale = Vector2.ONE * 2.0
	sprite.z_index = z
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(sprite)
	return sprite


func _room_overlaps(candidate: Rect2i) -> bool:
	var grown_candidate := Rect2i(candidate.position - Vector2i.ONE, candidate.size + Vector2i(2, 2))
	for room in rooms:
		var grown_room := Rect2i(room.position - Vector2i.ONE, room.size + Vector2i(2, 2))
		if grown_room.intersects(grown_candidate):
			return true
	return false


func _carve_room(room: Rect2i) -> void:
	for y in range(room.position.y, room.position.y + room.size.y):
		for x in range(room.position.x, room.position.x + room.size.x):
			_carve_cell(Vector2i(x, y))


func _carve_corridor(from_cell: Vector2i, to_cell: Vector2i) -> void:
	if rng.randi() % 2 == 0:
		_carve_horizontal(from_cell.x, to_cell.x, from_cell.y)
		_carve_vertical(from_cell.y, to_cell.y, to_cell.x)
	else:
		_carve_vertical(from_cell.y, to_cell.y, from_cell.x)
		_carve_horizontal(from_cell.x, to_cell.x, to_cell.y)


func _carve_horizontal(x1: int, x2: int, y: int) -> void:
	for x in range(mini(x1, x2), maxi(x1, x2) + 1):
		_carve_cell(Vector2i(x, y))


func _carve_vertical(y1: int, y2: int, x: int) -> void:
	for y in range(mini(y1, y2), maxi(y1, y2) + 1):
		_carve_cell(Vector2i(x, y))


func _carve_cell(cell: Vector2i) -> void:
	if _is_inside(cell):
		dungeon[cell.y][cell.x] = Tile.FLOOR


func _room_center(room: Rect2i) -> Vector2i:
	return room.position + Vector2i(room.size.x / 2, room.size.y / 2)


func _find_empty_floor_cell(reserved: Array[Vector2i], avoid_first_room: bool) -> Vector2i:
	if rooms.is_empty():
		return Vector2i.ZERO

	var first_room_index := 1 if avoid_first_room and rooms.size() > 1 else 0
	for _attempt in range(240):
		var room_index := rng.randi_range(first_room_index, rooms.size() - 1)
		var room := rooms[room_index]
		var cell := Vector2i(
			rng.randi_range(room.position.x, room.position.x + room.size.x - 1),
			rng.randi_range(room.position.y, room.position.y + room.size.y - 1)
		)
		if _tile_at(cell) == Tile.FLOOR and not reserved.has(cell):
			return cell

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var fallback := Vector2i(x, y)
			if _tile_at(fallback) == Tile.FLOOR and not reserved.has(fallback):
				return fallback

	return Vector2i.ZERO


func _best_enemy_step(enemy: Dictionary) -> Vector2i:
	var enemy_cell: Vector2i = enemy["cell"]
	var best_distance := 999
	var best_cells: Array[Vector2i] = []
	for raw_direction in DIRECTIONS:
		var direction: Vector2i = raw_direction
		var candidate: Vector2i = enemy_cell + direction
		if not _can_enemy_enter(candidate, enemy):
			continue
		var distance := _manhattan(candidate, player_cell)
		if distance < best_distance:
			best_distance = distance
			best_cells = [candidate]
		elif distance == best_distance:
			best_cells.append(candidate)

	if best_cells.is_empty():
		return enemy_cell
	return best_cells[rng.randi_range(0, best_cells.size() - 1)]


func _can_enemy_enter(cell: Vector2i, moving_enemy: Dictionary) -> bool:
	if not _is_inside(cell):
		return false
	if _tile_at(cell) == Tile.WALL:
		return false
	if cell == player_cell:
		return false
	for enemy in enemies:
		if enemy == moving_enemy:
			continue
		if enemy["cell"] == cell:
			return false
	return true


func _enemy_at(cell: Vector2i) -> Variant:
	for enemy in enemies:
		if enemy["cell"] == cell:
			return enemy
	return null


func _item_at(cell: Vector2i) -> Variant:
	for item in items:
		if item["cell"] == cell:
			return item
	return null


func _tile_at(cell: Vector2i) -> int:
	if not _is_inside(cell):
		return Tile.WALL
	return int(dungeon[cell.y][cell.x])


func _is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GRID_WIDTH and cell.y >= 0 and cell.y < GRID_HEIGHT


func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


func _cell_to_world(cell: Vector2i) -> Vector2:
	return MAP_ORIGIN + Vector2(cell.x * TILE_SIZE, cell.y * TILE_SIZE) + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)


func _tween_node_to_cell(node: Variant, cell: Vector2i, duration: float) -> void:
	if node == null or not is_instance_valid(node):
		return
	var tween := create_tween()
	tween.tween_property(node, "position", _cell_to_world(cell), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _bump_node(node: Variant, direction: Vector2i) -> void:
	if node == null or not is_instance_valid(node):
		return
	var start_position: Vector2 = node.position
	var bump_position := start_position + Vector2(direction.x, direction.y) * 6.0
	var tween := create_tween()
	tween.tween_property(node, "position", bump_position, 0.04)
	tween.tween_property(node, "position", start_position, 0.06)


func _flash_node(node: Variant, color: Color) -> void:
	if node == null or not is_instance_valid(node):
		return
	var tween := create_tween()
	tween.tween_property(node, "modulate", color, 0.04)
	tween.tween_property(node, "modulate", Color.WHITE, 0.12)


func _clear_layer(layer: Node) -> void:
	for child in layer.get_children():
		child.queue_free()


func _set_hud_visible(is_visible: bool) -> void:
	ui_layer.visible = is_visible


func _refresh_continue_button() -> void:
	if continue_button == null:
		return
	continue_button.disabled = not SaveManager.has_save_data()


func _save_high_score() -> void:
	var high_score := SaveManager.get_high_score()
	if GameData.score > high_score:
		SaveManager.save_high_score(GameData.score)


func _quit_game() -> void:
	get_tree().quit()


func _add_overlay_shade(layer: CanvasLayer, color: Color) -> void:
	var shade := ColorRect.new()
	shade.size = WINDOW_SIZE
	shade.color = color
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(shade)


func _make_center_panel(layer: CanvasLayer, size: Vector2) -> Panel:
	var panel := Panel.new()
	panel.position = (WINDOW_SIZE - size) * 0.5
	panel.size = size
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.105, 0.125, 0.115, 0.98), Color(0.48, 0.58, 0.38, 0.95)))
	layer.add_child(panel)
	return panel


func _make_label(
	parent: Node,
	position_value: Vector2,
	size_value: Vector2,
	text_value: String,
	font_size: int,
	color_value: Color,
	align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT,
	valign: VerticalAlignment = VERTICAL_ALIGNMENT_TOP
) -> Label:
	var label := Label.new()
	label.position = position_value
	label.size = size_value
	label.text = text_value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = align
	label.vertical_alignment = valign
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color_value)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _make_button(parent: Node, position_value: Vector2, size_value: Vector2, text_value: String) -> Button:
	var button := Button.new()
	button.position = position_value
	button.size = size_value
	button.text = text_value
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_stylebox_override("normal", _button_style(Color(0.36, 0.48, 0.32, 1.0)))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.47, 0.62, 0.38, 1.0)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.64, 0.49, 0.28, 1.0)))
	button.add_theme_stylebox_override("disabled", _button_style(Color(0.22, 0.27, 0.24, 1.0)))
	button.add_theme_color_override("font_color", Color(0.96, 0.94, 0.78, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.54, 0.58, 0.52, 1.0))
	button.add_theme_font_size_override("font_size", 17)
	button.pressed.connect(_play_button_sound)
	parent.add_child(button)
	return button


func _panel_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 8
	return style


func _button_style(bg_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.84, 0.72, 0.42, 0.45)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style


func _play_button_sound() -> void:
	AudioManager.play_sound("button")
