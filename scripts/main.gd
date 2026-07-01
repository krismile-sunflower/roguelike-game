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
const PLAYER_BLOCKED_INTERVAL := 0.08
const PLAYER_ATTACK_INTERVAL := 0.18
const PLAYER_MOVE_TWEEN_DURATION := 0.08
const ENEMY_MOVE_TWEEN_DURATION := 0.12
const DASH_RANGE := 2
const DASH_COOLDOWN_MAX := 1.4
const DASH_TWEEN_DURATION := 0.06
const MIN_PLAYER_STEP_INTERVAL := 0.08
const FOUNTAIN_HEAL_AMOUNT := 2
const TRAP_DAMAGE := 1
const EMBER_RESONANCE_COUNT := 3

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
	"fountain": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0032.png",
	"trap": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0041.png",
	"ember": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0101.png",
	"chest_open": "res://assets/art/kenney_tiny-dungeon/Tiles/tile_0090.png",
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
		"role": "slow",
		"awareness": 5,
		"move_interval": 0.68,
		"attack_interval": 1.10,
	},
	"bat": {
		"name": "蝙蝠",
		"hp": 2,
		"attack": 1,
		"score": 20,
		"texture": "bat",
		"role": "fast",
		"awareness": 7,
		"move_interval": 0.42,
		"attack_interval": 0.95,
	},
	"cultist": {
		"name": "烛影侍从",
		"hp": 4,
		"attack": 2,
		"score": 35,
		"texture": "cultist",
		"role": "caster",
		"awareness": 6,
		"move_interval": 0.58,
		"attack_interval": 0.95,
		"ranged_range": 5,
		"ranged_damage": 1,
	},
	"ghost": {
		"name": "游魂",
		"hp": 5,
		"attack": 2,
		"score": 45,
		"texture": "ghost",
		"role": "fast",
		"awareness": 8,
		"move_interval": 0.46,
		"attack_interval": 0.90,
	},
	"brute": {
		"name": "赤甲守卫",
		"hp": 7,
		"attack": 3,
		"score": 70,
		"texture": "brute",
		"role": "heavy",
		"awareness": 6,
		"move_interval": 0.76,
		"attack_interval": 1.15,
	},
	"boss": {
		"name": "深井看守",
		"hp": 13,
		"attack": 3,
		"score": 180,
		"texture": "boss",
		"role": "boss",
		"awareness": 10,
		"move_interval": 0.66,
		"attack_interval": 0.85,
		"phase_move_interval": 0.44,
		"phase_attack_interval": 0.72,
		"summon_on_half_hp": 2,
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
		"chests": 0,
		"fountains": 0,
		"traps": 0,
		"embers": 0,
		"reward_count": 3,
		"theme_color": Color(0.38, 0.47, 0.34, 1.0),
		"boss_rules": {},
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
		"chests": 1,
		"fountains": 0,
		"traps": 2,
		"embers": 2,
		"reward_count": 3,
		"theme_color": Color(0.25, 0.42, 0.48, 1.0),
		"boss_rules": {},
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
		"chests": 1,
		"fountains": 1,
		"traps": 4,
		"embers": 3,
		"reward_count": 3,
		"theme_color": Color(0.47, 0.40, 0.35, 1.0),
		"boss_rules": {},
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
		"potions": 2,
		"coins": 7,
		"gear": [],
		"chests": 1,
		"fountains": 0,
		"traps": 5,
		"embers": 3,
		"reward_count": 3,
		"theme_color": Color(0.50, 0.29, 0.26, 1.0),
		"boss_rules": {},
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
		"chests": 2,
		"fountains": 1,
		"traps": 4,
		"embers": 4,
		"reward_count": 0,
		"theme_color": Color(0.38, 0.30, 0.50, 1.0),
		"boss_rules": {"summon_on_half_hp": 2},
	},
]

const REWARD_POOL := [
	{
		"id": "attack",
		"title": "锋刃祝福",
		"description": "攻击力 +1。",
		"type": "attack",
		"amount": 1,
	},
	{
		"id": "max_hp",
		"title": "余烬护身",
		"description": "最大生命 +2，并恢复 2 点生命。",
		"type": "max_hp",
		"amount": 2,
	},
	{
		"id": "move_speed",
		"title": "轻步",
		"description": "按住移动更快，移动间隔 -0.015 秒。",
		"type": "move_speed",
		"amount": 0.015,
	},
	{
		"id": "potion_heal",
		"title": "药剂熟手",
		"description": "药水额外恢复 1 点生命。",
		"type": "potion_heal",
		"amount": 1,
	},
	{
		"id": "kill_heal",
		"title": "战后喘息",
		"description": "击杀敌人有 18% 概率恢复 1 点生命。",
		"type": "kill_heal",
		"amount": 0.18,
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
var player_step_interval := 0.14
var player_step_timer := 0.0
var last_input_direction := Vector2i.ZERO
var dash_cooldown := 0.0
var dash_cooldown_max := DASH_COOLDOWN_MAX
var potion_heal_amount := 3
var kill_heal_chance := 0.0
var ember_shards := 0
var selected_rewards: Array[String] = []
var reward_choices: Array[Dictionary] = []
var enemy_ai_enabled := false
var exit_cell := Vector2i.ZERO
var exit_open := false
var exit_pulse_tween: Tween

var enemies: Array[Dictionary] = []
var items: Array[Dictionary] = []
var chests: Array[Dictionary] = []
var fountains: Array[Dictionary] = []
var traps: Array[Dictionary] = []
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
var dash_label: Label
var enemies_label: Label
var threat_label: Label
var status_label: Label
var minimap_root: Control
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
var reward_layer: CanvasLayer
var reward_title_label: Label
var reward_body_label: Label
var reward_buttons: Array[Button] = []


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
			if key_event.keycode == KEY_SHIFT or key_event.physical_keycode == KEY_SHIFT:
				_attempt_dash()
				return
			var direction := _direction_from_key(key_event.keycode)
			if direction != Vector2i.ZERO:
				last_input_direction = direction
				player_step_timer = 0.0
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
			if reward_layer != null and reward_layer.visible and not reward_choices.is_empty():
				_on_reward_button_pressed(0)
			else:
				_on_result_primary_pressed()


func _process(delta: float) -> void:
	if GameState.current_state != GameState.Playing:
		return

	if dash_cooldown > 0.0:
		dash_cooldown = maxf(dash_cooldown - delta, 0.0)
		_refresh_hud()

	_tick_player_movement(delta)
	if enemy_ai_enabled:
		_tick_enemies(delta)


func _tick_player_movement(delta: float) -> void:
	if player_step_timer > 0.0:
		player_step_timer = maxf(player_step_timer - delta, 0.0)

	var direction := _get_held_direction()
	if direction == Vector2i.ZERO:
		player_step_timer = 0.0
		return

	if player_step_timer <= 0.0:
		_attempt_player_step(direction)


func show_menu() -> void:
	GameState.show_menu()
	enemy_ai_enabled = false
	menu_layer.visible = true
	instructions_layer.visible = false
	pause_layer.visible = false
	result_layer.visible = false
	if reward_layer != null:
		reward_layer.visible = false
	_set_hud_visible(false)
	_refresh_continue_button()


func show_instructions() -> void:
	GameState.show_instructions()
	enemy_ai_enabled = false
	menu_layer.visible = false
	instructions_layer.visible = true
	pause_layer.visible = false
	result_layer.visible = false
	if reward_layer != null:
		reward_layer.visible = false
	_set_hud_visible(false)


func hide_instructions() -> void:
	show_menu()


func _reset_run_modifiers() -> void:
	player_max_hp = 8
	player_hp = player_max_hp
	player_attack = 2
	player_step_interval = 0.14
	player_step_timer = 0.0
	dash_cooldown = 0.0
	dash_cooldown_max = DASH_COOLDOWN_MAX
	potion_heal_amount = 3
	kill_heal_chance = 0.0
	ember_shards = 0
	selected_rewards.clear()
	reward_choices.clear()


func start_new_run() -> void:
	GameData.configure_levels(LEVEL_DEFS.size())
	GameData.reset_progress()
	GameData.reset_hint_count()
	GameData.reset()
	_reset_run_modifiers()
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
	_reset_run_modifiers()
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
	enemy_ai_enabled = false
	dash_cooldown = 0.0
	_add_log("你重新整理装备，再次踏入这一层。")
	_load_level(current_level_index)


func resume_game() -> void:
	if GameState.current_state == GameState.Paused:
		GameState.set_state(GameState.Playing)
		enemy_ai_enabled = true
		pause_layer.visible = false
		_set_hud_visible(true)


func pause_game() -> void:
	if GameState.current_state != GameState.Playing:
		return
	GameState.set_state(GameState.Paused)
	enemy_ai_enabled = false
	pause_layer.visible = true
	_set_hud_visible(true)


func _load_level(level_index: int) -> void:
	current_level_index = clampi(level_index, 0, LEVEL_DEFS.size() - 1)
	GameData.start_level(current_level_index)
	GameState.start_level(current_level_index)
	player_step_timer = 0.0
	dash_cooldown = 0.0
	last_input_direction = Vector2i.ZERO
	enemy_ai_enabled = false
	menu_layer.visible = false
	instructions_layer.visible = false
	pause_layer.visible = false
	result_layer.visible = false
	if reward_layer != null:
		reward_layer.visible = false
	_set_hud_visible(true)

	_generate_dungeon()
	_populate_level()
	_render_level()
	_refresh_hud()
	enemy_ai_enabled = true
	_add_log("进入 " + str(LEVEL_DEFS[current_level_index]["title"]) + "。")


func _load_textures() -> void:
	for key in TEXTURE_PATHS.keys():
		var loaded := load(str(TEXTURE_PATHS[key]))
		if loaded is Texture2D:
			textures[key] = loaded


func _build_scene() -> void:
	background_layer = CanvasLayer.new()
	background_layer.layer = -10
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
	ui_layer.layer = 10
	add_child(ui_layer)
	_build_hud()
	_build_menu()
	_build_instructions()
	_build_pause()
	_build_result_layer()
	_build_reward_layer()


func _build_hud() -> void:
	var panel := Panel.new()
	panel.position = Vector2(PANEL_X, 28)
	panel.size = Vector2(236, 664)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.105, 0.125, 0.115, 0.96), Color(0.35, 0.46, 0.34, 0.9)))
	ui_layer.add_child(panel)

	title_label = _make_label(panel, Vector2(18, 14), Vector2(200, 46), "", 21, Color(0.96, 0.92, 0.74, 1.0))
	depth_label = _make_label(panel, Vector2(18, 66), Vector2(200, 22), "", 15, Color(0.98, 0.75, 0.42, 1.0))
	hp_label = _make_label(panel, Vector2(18, 96), Vector2(200, 24), "", 17, Color(0.95, 0.46, 0.36, 1.0))
	attack_label = _make_label(panel, Vector2(18, 122), Vector2(200, 22), "", 15, Color(0.78, 0.86, 0.98, 1.0))
	dash_label = _make_label(panel, Vector2(18, 146), Vector2(200, 22), "", 15, Color(0.78, 0.92, 0.92, 1.0))
	score_label = _make_label(panel, Vector2(18, 170), Vector2(200, 22), "", 15, Color(0.94, 0.82, 0.45, 1.0))
	enemies_label = _make_label(panel, Vector2(18, 194), Vector2(200, 22), "", 15, Color(0.83, 0.74, 0.96, 1.0))
	threat_label = _make_label(panel, Vector2(18, 222), Vector2(200, 48), "", 14, Color(0.88, 0.78, 0.64, 1.0))
	goal_label = _make_label(panel, Vector2(18, 280), Vector2(200, 54), "", 14, Color(0.78, 0.84, 0.74, 1.0))
	status_label = _make_label(panel, Vector2(18, 344), Vector2(200, 48), "", 14, Color(0.78, 0.86, 0.80, 1.0))
	_make_label(panel, Vector2(18, 406), Vector2(200, 20), "小地图", 13, Color(0.70, 0.78, 0.68, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	minimap_root = Control.new()
	minimap_root.position = Vector2(18, 430)
	minimap_root.size = Vector2(200, 82)
	panel.add_child(minimap_root)
	log_label = _make_label(panel, Vector2(18, 526), Vector2(200, 88), "", 13, Color(0.68, 0.74, 0.70, 1.0))

	var hint := _make_label(panel, Vector2(18, 622), Vector2(200, 34), "Shift 冲刺  |  Esc 暂停  |  R 重开", 12, Color(0.55, 0.63, 0.58, 1.0))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _build_menu() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.name = "MenuLayer"
	menu_layer.layer = 20
	add_child(menu_layer)
	_add_overlay_shade(menu_layer, Color(0.03, 0.04, 0.04, 0.72))

	var panel := _make_center_panel(menu_layer, Vector2(540, 420))
	_make_label(panel, Vector2(38, 30), Vector2(464, 48), "井下余烬", 38, Color(0.98, 0.88, 0.58, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	_make_label(panel, Vector2(58, 88), Vector2(424, 70), "实时格子移动、Shift 短冲刺、逐层祝福。清理敌群，打开补给，活着走到深井王座。", 17, Color(0.72, 0.82, 0.74, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
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
	instructions_layer.layer = 20
	instructions_layer.visible = false
	add_child(instructions_layer)
	_add_overlay_shade(instructions_layer, Color(0.03, 0.04, 0.04, 0.76))

	var panel := _make_center_panel(instructions_layer, Vector2(690, 470))
	_make_label(panel, Vector2(42, 30), Vector2(606, 44), "探索指南", 32, Color(0.98, 0.88, 0.58, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	var body := "方向键 / WASD / HJKL：按住连续移动；撞向敌人即可攻击。\n\nShift：向当前方向短冲刺，最多 2 格，不能穿墙或穿过敌人，也会触发路上的陷阱。\n\n宝箱会给金币、治疗或临时强化；喷泉每层只能使用一次。\n\n烛影侍从会沿直线施法，墙体和其他敌人可以挡住视线。\n\n余烬碎片每收集 3 个会产生一次共鸣。清掉敌人后出口会点亮。"
	_make_label(panel, Vector2(60, 96), Vector2(570, 260), body, 18, Color(0.75, 0.84, 0.76, 1.0))
	var back_button := _make_button(panel, Vector2(236, 382), Vector2(218, 44), "返回主菜单")
	back_button.pressed.connect(hide_instructions)


func _build_pause() -> void:
	pause_layer = CanvasLayer.new()
	pause_layer.name = "PauseLayer"
	pause_layer.layer = 20
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
	result_layer.layer = 20
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


func _build_reward_layer() -> void:
	reward_layer = CanvasLayer.new()
	reward_layer.name = "RewardLayer"
	reward_layer.layer = 20
	reward_layer.visible = false
	add_child(reward_layer)
	_add_overlay_shade(reward_layer, Color(0.02, 0.025, 0.025, 0.70))

	var panel := _make_center_panel(reward_layer, Vector2(720, 390))
	reward_title_label = _make_label(panel, Vector2(42, 30), Vector2(636, 42), "楼层祝福", 32, Color(0.98, 0.88, 0.58, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	reward_body_label = _make_label(panel, Vector2(70, 84), Vector2(580, 54), "出口亮起，但井下还有回声。选择一个祝福，再继续深入。", 17, Color(0.76, 0.86, 0.78, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	for i in range(3):
		var button := _make_button(panel, Vector2(58 + i * 212, 166), Vector2(182, 134), "")
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(_on_reward_button_pressed.bind(i))
		reward_buttons.append(button)
	var hint := _make_label(panel, Vector2(70, 326), Vector2(580, 28), "Enter 选择第一项", 13, Color(0.58, 0.68, 0.60, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE


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
	chests.clear()
	fountains.clear()
	traps.clear()

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

	for _i in range(int(level_def.get("embers", 0))):
		var ember_cell := _find_empty_floor_cell(reserved, true)
		reserved.append(ember_cell)
		items.append(_make_item("ember", ember_cell))

	for gear in level_def.get("gear", []):
		var gear_cell := _find_empty_floor_cell(reserved, true)
		reserved.append(gear_cell)
		items.append(_make_item(str(gear), gear_cell))

	for _i in range(int(level_def.get("chests", 0))):
		var chest_cell := _find_empty_floor_cell(reserved, true)
		reserved.append(chest_cell)
		chests.append(_make_chest(chest_cell))

	for _i in range(int(level_def.get("fountains", 0))):
		var fountain_cell := _find_empty_floor_cell(reserved, true)
		reserved.append(fountain_cell)
		fountains.append(_make_fountain(fountain_cell))

	for _i in range(int(level_def.get("traps", 0))):
		var trap_cell := _find_empty_floor_cell(reserved, true)
		reserved.append(trap_cell)
		traps.append(_make_trap(trap_cell))


func _render_level() -> void:
	if exit_pulse_tween != null and exit_pulse_tween.is_valid():
		exit_pulse_tween.kill()
	exit_pulse_tween = null
	_clear_layer(map_layer)
	_clear_layer(decor_layer)
	_clear_layer(item_layer)
	_clear_layer(actor_layer)
	_clear_layer(fx_layer)
	var level_def: Dictionary = LEVEL_DEFS[current_level_index]
	var theme_color := Color.WHITE
	if level_def.has("theme_color") and level_def["theme_color"] is Color:
		theme_color = level_def["theme_color"]

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
				var floor_sprite := _make_tile_sprite(floor_key, cell, map_layer, 0)
				floor_sprite.modulate = theme_color.lerp(Color.WHITE, 0.68)

	_add_decor()
	exit_node = _make_tile_sprite("door", exit_cell, actor_layer, 1)
	exit_node.modulate = Color(0.42, 0.47, 0.49, 0.84)

	for item in items:
		item["node"] = _make_tile_sprite(str(item["texture"]), item["cell"], item_layer, 1)

	for chest in chests:
		chest["node"] = _make_tile_sprite("chest", chest["cell"], item_layer, 1)

	for fountain in fountains:
		var fountain_node := _make_tile_sprite("fountain", fountain["cell"], item_layer, 1)
		fountain_node.modulate = Color(0.72, 1.0, 0.92, 1.0)
		fountain["node"] = fountain_node

	for trap in traps:
		var trap_node := _make_tile_sprite("trap", trap["cell"], item_layer, 1)
		trap_node.modulate = Color(1.0, 0.50, 0.38, 0.82)
		trap["node"] = trap_node

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
	var decor_keys: Array[String] = ["rubble", "torch"]
	var decor_count := 10 + current_level_index * 2
	var reserved: Array[Vector2i] = [player_cell, exit_cell]
	for enemy in enemies:
		reserved.append(enemy["cell"])
	for item in items:
		reserved.append(item["cell"])
	for chest in chests:
		reserved.append(chest["cell"])
	for fountain in fountains:
		reserved.append(fountain["cell"])
	for trap in traps:
		reserved.append(trap["cell"])

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
		player_step_timer = PLAYER_BLOCKED_INTERVAL
		return

	var enemy: Variant = _enemy_at(target)
	if enemy != null:
		_attack_enemy(enemy)
		player_step_timer = PLAYER_ATTACK_INTERVAL
		_refresh_hud()
		return

	player_cell = target
	_tween_node_to_cell(player_node, player_cell, PLAYER_MOVE_TWEEN_DURATION)
	if _handle_player_landing():
		return

	player_step_timer = player_step_interval
	_refresh_hud()


func _attempt_dash() -> void:
	if GameState.current_state != GameState.Playing:
		return
	if dash_cooldown > 0.0:
		_add_log("冲刺还在冷却：" + str(snappedf(dash_cooldown, 0.1)) + " 秒。")
		_refresh_hud()
		return

	var previous_direction := last_input_direction
	var direction := _get_held_direction()
	if direction == Vector2i.ZERO:
		direction = previous_direction
	if direction == Vector2i.ZERO:
		_add_log("先按住一个方向，再短冲刺。")
		return

	var moved := 0
	for _i in range(DASH_RANGE):
		var candidate := player_cell + direction
		if not _is_inside(candidate) or _tile_at(candidate) == Tile.WALL:
			break
		if _enemy_at(candidate) != null:
			break
		player_cell = candidate
		moved += 1
		if _trigger_trap_at(player_cell):
			_tween_node_to_cell(player_node, player_cell, DASH_TWEEN_DURATION)
			dash_cooldown = dash_cooldown_max
			_refresh_hud()
			return
		_collect_item_at(player_cell)
		_open_chest_at(player_cell)
		_use_fountain_at(player_cell)
		if player_cell == exit_cell and exit_open:
			_tween_node_to_cell(player_node, player_cell, DASH_TWEEN_DURATION)
			dash_cooldown = dash_cooldown_max
			_complete_current_level()
			return

	if moved <= 0:
		_add_log("冲刺路线被挡住了。")
		AudioManager.play_sound("blocked")
		_bump_node(player_node, direction)
		player_step_timer = PLAYER_BLOCKED_INTERVAL
		return

	AudioManager.play_sound("dash")
	_tween_node_to_cell(player_node, player_cell, DASH_TWEEN_DURATION)
	dash_cooldown = dash_cooldown_max
	player_step_timer = player_step_interval
	if player_cell == exit_cell and not exit_open:
		_add_log("出口还没有回应。先清掉本层敌人。")
	_refresh_hud()


func _handle_player_landing() -> bool:
	if _trigger_trap_at(player_cell):
		return true

	_collect_item_at(player_cell)
	_open_chest_at(player_cell)
	_use_fountain_at(player_cell)

	if player_cell == exit_cell and exit_open:
		_complete_current_level()
		return true
	elif player_cell == exit_cell and not exit_open:
		_add_log("出口还没有回应。先清掉本层敌人。")

	return false


func _wait_turn() -> void:
	if GameState.current_state != GameState.Playing:
		return
	last_input_direction = Vector2i.ZERO
	player_step_timer = player_step_interval
	_add_log("你停下脚步，听见远处的脚步声仍在靠近。")
	_refresh_hud()


func _attack_enemy(enemy: Dictionary) -> void:
	var damage := player_attack + rng.randi_range(0, 1)
	enemy["hp"] = int(enemy["hp"]) - damage
	AudioManager.play_sound("attack")
	_add_log("你击中 " + str(enemy["name"]) + "，造成 " + str(damage) + " 点伤害。")
	_flash_enemy(enemy, Color(1.0, 0.62, 0.45, 1.0))
	_update_enemy_health_bar(enemy)

	if int(enemy["hp"]) <= 0:
		_kill_enemy(enemy)
	elif str(enemy.get("role", "")) == "boss" and not bool(enemy.get("phase_triggered", false)) and int(enemy["hp"]) <= int(enemy["max_hp"]) / 2:
		_trigger_boss_phase(enemy)


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
	if kill_heal_chance > 0.0 and player_hp < player_max_hp and rng.randf() < kill_heal_chance:
		player_hp = mini(player_hp + 1, player_max_hp)
		GameData.player_health = player_hp
		GameData.health_changed.emit(player_hp)
		_add_log("你借战后的喘息恢复 1 点生命。")

	if rng.randf() < 0.24:
		var drop_type := "potion" if rng.randf() < 0.36 else "coin"
		var item := _make_item(drop_type, dead_cell)
		items.append(item)
		item["node"] = _make_tile_sprite(str(item["texture"]), dead_cell, item_layer, 1)

	_refresh_exit()


func _tick_enemies(delta: float) -> void:
	for enemy in enemies.duplicate():
		if GameState.current_state != GameState.Playing:
			return
		if not enemies.has(enemy):
			continue

		enemy["move_cooldown"] = maxf(float(enemy.get("move_cooldown", 0.0)) - delta, 0.0)
		enemy["attack_cooldown"] = maxf(float(enemy.get("attack_cooldown", 0.0)) - delta, 0.0)

		var enemy_cell: Vector2i = enemy["cell"]
		var distance := _manhattan(enemy_cell, player_cell)
		if distance <= 1:
			if float(enemy.get("attack_cooldown", 0.0)) <= 0.0:
				_enemy_attack_player(enemy)
				enemy["attack_cooldown"] = float(enemy.get("attack_interval", 1.0))
			continue

		if _can_enemy_cast(enemy, distance):
			_enemy_ranged_attack_player(enemy)
			enemy["attack_cooldown"] = float(enemy.get("attack_interval", 1.0))
			enemy["move_cooldown"] = maxf(float(enemy.get("move_cooldown", 0.0)), 0.22)
			continue

		if float(enemy.get("move_cooldown", 0.0)) <= 0.0:
			_run_single_enemy(enemy)


func _run_single_enemy(enemy: Dictionary) -> void:
	var enemy_cell: Vector2i = enemy["cell"]
	var distance := _manhattan(enemy_cell, player_cell)
	var next_cell := enemy_cell
	if distance <= int(enemy["awareness"]):
		next_cell = _best_enemy_step(enemy)
	elif rng.randf() < 0.28:
		var direction: Vector2i = DIRECTIONS[rng.randi_range(0, DIRECTIONS.size() - 1)]
		var wander_cell := enemy_cell + direction
		if _can_enemy_enter(wander_cell, enemy):
			next_cell = wander_cell

	if next_cell != enemy_cell:
		enemy["cell"] = next_cell
		_tween_node_to_cell(enemy.get("node"), next_cell, ENEMY_MOVE_TWEEN_DURATION)

	enemy["move_cooldown"] = float(enemy.get("move_interval", 0.6))


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


func _can_enemy_cast(enemy: Dictionary, distance: int) -> bool:
	if str(enemy.get("role", "")) != "caster":
		return false
	if float(enemy.get("attack_cooldown", 0.0)) > 0.0:
		return false
	if distance > int(enemy.get("ranged_range", 5)):
		return false
	return _has_line_of_sight(enemy["cell"], player_cell)


func _enemy_ranged_attack_player(enemy: Dictionary) -> void:
	var damage := int(enemy.get("ranged_damage", 1))
	player_hp = maxi(player_hp - damage, 0)
	GameData.player_health = player_hp
	GameData.health_changed.emit(player_hp)
	AudioManager.play_sound("hurt")
	_draw_cast_line(enemy["cell"], player_cell)
	ParticleManager.play_hurt_effect(_cell_to_world(player_cell))
	_flash_enemy(enemy, Color(1.0, 0.78, 0.34, 1.0))
	_flash_node(player_node, Color(1.0, 0.36, 0.28, 1.0))
	_add_log(str(enemy["name"]) + "沿走廊灼烧你，造成 " + str(damage) + " 点伤害。")
	_refresh_hud()

	if player_hp <= 0:
		_game_over()


func _trigger_boss_phase(enemy: Dictionary) -> void:
	enemy["phase_triggered"] = true
	enemy["move_interval"] = float(enemy.get("phase_move_interval", enemy.get("move_interval", 0.6)))
	enemy["attack_interval"] = float(enemy.get("phase_attack_interval", enemy.get("attack_interval", 0.85)))
	enemy["move_cooldown"] = 0.05
	enemy["base_modulate"] = Color(1.0, 0.42, 0.32, 1.0)
	var sprite: Variant = enemy.get("sprite")
	if sprite != null and is_instance_valid(sprite):
		sprite.modulate = enemy["base_modulate"]

	_add_log("深井看守怒吼，井壁间涌出游魂。")
	var summon_count := int(enemy.get("summon_on_half_hp", 2))
	var boss_rules: Dictionary = LEVEL_DEFS[current_level_index].get("boss_rules", {})
	summon_count = int(boss_rules.get("summon_on_half_hp", summon_count))
	var spawn_cells := _find_spawn_cells_near(enemy["cell"], summon_count)
	for cell in spawn_cells:
		var ghost := _make_enemy("ghost", cell)
		ghost["name"] = "低血游魂"
		ghost["hp"] = 2
		ghost["max_hp"] = 2
		ghost["score"] = 18
		ghost["move_cooldown"] = 0.1
		enemies.append(ghost)
		ghost["node"] = _make_enemy_node(ghost)
		_flash_enemy(ghost, Color(0.82, 0.62, 1.0, 1.0))


func _collect_item_at(cell: Vector2i) -> void:
	var item: Variant = _item_at(cell)
	if item == null:
		return

	match str(item["type"]):
		"potion":
			var before := player_hp
			player_hp = mini(player_hp + potion_heal_amount, player_max_hp)
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
		"ember":
			ember_shards += 1
			GameData.add_score(35 + current_level_index * 5)
			_add_log("拾起余烬碎片（" + str(ember_shards) + "）。")
			AudioManager.play_sound("coin")
			if ember_shards % EMBER_RESONANCE_COUNT == 0:
				var before := player_hp
				player_hp = mini(player_hp + 1, player_max_hp)
				GameData.player_health = player_hp
				GameData.health_changed.emit(player_hp)
				dash_cooldown = maxf(dash_cooldown - 0.35, 0.0)
				_add_log("余烬共鸣，恢复 " + str(player_hp - before) + " 点生命并冷却冲刺。")
				ParticleManager.play_powerup_appear_effect(_cell_to_world(cell))

	ParticleManager.play_collect_effect(_cell_to_world(cell))
	var node: Variant = item.get("node")
	if node != null and is_instance_valid(node):
		node.queue_free()
	items.erase(item)


func _open_chest_at(cell: Vector2i) -> bool:
	var chest: Variant = _chest_at(cell)
	if chest == null or bool(chest.get("opened", false)):
		return false

	chest["opened"] = true
	var node: Variant = chest.get("node")
	if node != null and is_instance_valid(node):
		var chest_sprite := node as Sprite2D
		if chest_sprite != null:
			chest_sprite.texture = textures.get("chest_open")
		node.modulate = Color(0.54, 0.46, 0.34, 0.76)
	ParticleManager.play_collect_effect(_cell_to_world(cell))
	AudioManager.play_sound("gear")

	var roll := rng.randf()
	if roll < 0.42:
		var score_gain := 55 + current_level_index * 8
		GameData.add_score(score_gain)
		_add_log("打开宝箱，找到 " + str(score_gain) + " 分的旧金币。")
	elif roll < 0.72:
		var before := player_hp
		player_hp = mini(player_hp + potion_heal_amount, player_max_hp)
		GameData.player_health = player_hp
		GameData.health_changed.emit(player_hp)
		_add_log("宝箱里有药剂，恢复 " + str(player_hp - before) + " 点生命。")
	else:
		player_attack += 1
		_add_log("宝箱里的余烬刻印让攻击力 +1。")
	_refresh_hud()
	return true


func _use_fountain_at(cell: Vector2i) -> bool:
	var fountain: Variant = _fountain_at(cell)
	if fountain == null or bool(fountain.get("used", false)):
		return false

	fountain["used"] = true
	var before := player_hp
	player_hp = mini(player_hp + FOUNTAIN_HEAL_AMOUNT, player_max_hp)
	GameData.player_health = player_hp
	GameData.health_changed.emit(player_hp)
	var node: Variant = fountain.get("node")
	if node != null and is_instance_valid(node):
		node.modulate = Color(0.32, 0.42, 0.40, 0.72)
	ParticleManager.play_collect_effect(_cell_to_world(cell))
	AudioManager.play_sound("potion")
	_add_log("你饮下冷泉，恢复 " + str(player_hp - before) + " 点生命。")
	_refresh_hud()
	return true


func _trigger_trap_at(cell: Vector2i) -> bool:
	var trap: Variant = _trap_at(cell)
	if trap == null or bool(trap.get("triggered", false)):
		return false

	trap["triggered"] = true
	var node: Variant = trap.get("node")
	if node != null and is_instance_valid(node):
		node.modulate = Color(0.38, 0.28, 0.26, 0.55)
		node.scale = Vector2.ONE * 1.84

	player_hp = maxi(player_hp - TRAP_DAMAGE, 0)
	GameData.player_health = player_hp
	GameData.health_changed.emit(player_hp)
	AudioManager.play_sound("hurt")
	ParticleManager.play_hurt_effect(_cell_to_world(cell))
	_flash_node(player_node, Color(1.0, 0.32, 0.22, 1.0))
	_add_log("尖刺机关弹起，造成 " + str(TRAP_DAMAGE) + " 点伤害。")
	_refresh_hud()

	if player_hp <= 0:
		_game_over()
		return true
	return false


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
		_show_reward_choices()
		AudioManager.play_sound("stairs")


func _game_over() -> void:
	run_outcome = RunOutcome.GAME_OVER
	_save_high_score()
	_show_result("探险失败", "你倒在第 " + str(current_level_index + 1) + " 层。\n最终得分：" + str(GameData.score), "重新开始", "主菜单")
	AudioManager.play_sound("death")


func _show_result(title: String, body: String, primary_text: String, secondary_text: String) -> void:
	GameState.set_state(GameState.Completed)
	enemy_ai_enabled = false
	result_title_label.text = title
	result_body_label.text = body
	result_primary_button.text = primary_text
	result_secondary_button.text = secondary_text
	result_layer.visible = true
	if reward_layer != null:
		reward_layer.visible = false
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


func _show_reward_choices() -> void:
	GameState.set_state(GameState.Completed)
	enemy_ai_enabled = false
	reward_choices.clear()
	var available: Array = REWARD_POOL.duplicate()
	available.shuffle()
	var count := mini(3, int(LEVEL_DEFS[current_level_index].get("reward_count", 3)))
	for i in range(count):
		reward_choices.append(available[i])

	reward_title_label.text = "楼层祝福"
	reward_body_label.text = "第 " + str(current_level_index + 1) + " 层已清空。选择 1 个祝福，进入 " + str(LEVEL_DEFS[GameData.current_level_index]["title"]) + "。"
	for i in range(reward_buttons.size()):
		var button := reward_buttons[i]
		if i < reward_choices.size():
			button.visible = true
			button.disabled = false
			button.text = _format_reward_button_text(reward_choices[i])
		else:
			button.visible = false
			button.disabled = true

	result_layer.visible = false
	reward_layer.visible = true
	pause_layer.visible = false
	menu_layer.visible = false
	instructions_layer.visible = false
	_set_hud_visible(true)


func _on_reward_button_pressed(index: int) -> void:
	if index < 0 or index >= reward_choices.size():
		return
	_apply_reward(reward_choices[index])
	reward_layer.visible = false
	SaveManager.save_progress(GameData.current_level_index, GameData.completed_levels, GameData.hint_count, GameData.has_seen_tutorial)
	_load_level(GameData.current_level_index)


func _format_reward_button_text(reward: Dictionary) -> String:
	return str(reward["title"]) + "\n\n" + str(reward["description"])


func _apply_reward(reward: Dictionary) -> void:
	selected_rewards.append(str(reward["title"]))
	match str(reward["type"]):
		"attack":
			player_attack += int(reward["amount"])
			_add_log("祝福生效：攻击力 +" + str(reward["amount"]) + "。")
		"max_hp":
			var amount := int(reward["amount"])
			player_max_hp += amount
			player_hp = mini(player_hp + amount, player_max_hp)
			GameData.player_health = player_hp
			GameData.health_changed.emit(player_hp)
			_add_log("祝福生效：最大生命 +" + str(amount) + "。")
		"move_speed":
			player_step_interval = maxf(MIN_PLAYER_STEP_INTERVAL, player_step_interval - float(reward["amount"]))
			_add_log("祝福生效：步伐更轻了。")
		"potion_heal":
			potion_heal_amount += int(reward["amount"])
			_add_log("祝福生效：药水治疗 +" + str(reward["amount"]) + "。")
		"kill_heal":
			kill_heal_chance += float(reward["amount"])
			_add_log("祝福生效：击杀有概率回血。")
	AudioManager.play_sound("complete")


func _refresh_hud() -> void:
	var level_def: Dictionary = LEVEL_DEFS[current_level_index]
	title_label.text = str(level_def["title"])
	depth_label.text = "深度 " + str(current_level_index + 1) + " / " + str(LEVEL_DEFS.size())
	hp_label.text = "生命 " + str(player_hp) + " / " + str(player_max_hp)
	var low_health := player_hp <= maxi(2, int(ceil(player_max_hp * 0.35)))
	hp_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.18, 1.0) if low_health else Color(0.95, 0.46, 0.36, 1.0))
	attack_label.text = "攻击 " + str(player_attack) + " - " + str(player_attack + 1)
	dash_label.text = "冲刺 就绪" if dash_cooldown <= 0.0 else "冲刺 " + str(snappedf(dash_cooldown, 0.1)) + "s"
	dash_label.add_theme_color_override("font_color", Color(0.64, 0.96, 0.86, 1.0) if dash_cooldown <= 0.0 else Color(0.62, 0.72, 0.78, 1.0))
	score_label.text = "得分 " + str(GameData.score)
	enemies_label.text = "敌人 " + str(enemies.size())
	threat_label.text = "威胁摘要\n陷阱 " + str(_count_armed_traps()) + "  宝箱 " + str(_count_unopened_chests()) + "  喷泉 " + str(_count_unused_fountains()) + "\n余烬 " + str(ember_shards)
	goal_label.text = "目标\n" + str(level_def["goal"])
	var unopened_chests := _count_unopened_chests()
	var unused_fountains := _count_unused_fountains()
	var armed_traps := _count_armed_traps()
	var status_text := "出口已开启，踩上去继续。" if exit_open else "清理敌人开启出口。"
	if unopened_chests > 0:
		status_text += "\n宝箱 " + str(unopened_chests)
	if unused_fountains > 0:
		status_text += "  喷泉 " + str(unused_fountains)
	if armed_traps > 0:
		status_text += "  陷阱 " + str(armed_traps)
	status_label.text = status_text
	log_label.text = "\n".join(log_lines)
	_refresh_exit()
	_refresh_minimap()


func _refresh_exit() -> void:
	var was_open := exit_open
	exit_open = enemies.is_empty()
	if exit_node != null and is_instance_valid(exit_node):
		if exit_open:
			exit_node.modulate = Color(1.0, 0.92, 0.45, 1.0)
			if not was_open:
				_pulse_exit()
		else:
			exit_node.modulate = Color(0.42, 0.47, 0.49, 0.84)
			exit_node.scale = Vector2.ONE * 2.0


func _refresh_minimap() -> void:
	if minimap_root == null:
		return

	for child in minimap_root.get_children():
		child.queue_free()

	var tile_px := 4.0
	var map_pixel_size := Vector2(GRID_WIDTH * tile_px, GRID_HEIGHT * tile_px)
	var offset := Vector2((minimap_root.size.x - map_pixel_size.x) * 0.5, 4.0)

	var backing := ColorRect.new()
	backing.position = offset - Vector2(4, 4)
	backing.size = map_pixel_size + Vector2(8, 8)
	backing.color = Color(0.045, 0.055, 0.052, 0.95)
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_root.add_child(backing)

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var cell := Vector2i(x, y)
			if _tile_at(cell) == Tile.FLOOR:
				_add_minimap_rect(cell, Color(0.24, 0.30, 0.26, 1.0), tile_px, offset)

	for trap in traps:
		if not bool(trap.get("triggered", false)):
			_add_minimap_rect(trap["cell"], Color(0.92, 0.28, 0.20, 1.0), tile_px, offset, 0.82)

	for item in items:
		var item_type := str(item.get("type", ""))
		var item_color := Color(0.94, 0.78, 0.35, 1.0)
		if item_type == "potion":
			item_color = Color(0.54, 0.92, 0.72, 1.0)
		elif item_type == "ember":
			item_color = Color(1.0, 0.62, 0.25, 1.0)
		_add_minimap_rect(item["cell"], item_color, tile_px, offset, 0.82)

	for chest in chests:
		if not bool(chest.get("opened", false)):
			_add_minimap_rect(chest["cell"], Color(0.86, 0.60, 0.32, 1.0), tile_px, offset, 0.9)

	for fountain in fountains:
		if not bool(fountain.get("used", false)):
			_add_minimap_rect(fountain["cell"], Color(0.45, 0.95, 0.88, 1.0), tile_px, offset, 0.9)

	_add_minimap_rect(exit_cell, Color(1.0, 0.88, 0.32, 1.0) if exit_open else Color(0.50, 0.56, 0.58, 1.0), tile_px, offset, 1.12)

	for enemy in enemies:
		_add_minimap_rect(enemy["cell"], Color(0.92, 0.24, 0.20, 1.0), tile_px, offset, 0.92)

	_add_minimap_rect(player_cell, Color(1.0, 0.95, 0.46, 1.0), tile_px, offset, 1.25)


func _add_minimap_rect(cell: Vector2i, color: Color, tile_px: float, offset: Vector2, scale_value: float = 1.0) -> void:
	if minimap_root == null:
		return
	var rect := ColorRect.new()
	var inset := tile_px * (1.0 - scale_value) * 0.5
	rect.position = offset + Vector2(cell.x * tile_px + inset, cell.y * tile_px + inset)
	rect.size = Vector2(tile_px * scale_value, tile_px * scale_value)
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_root.add_child(rect)


func _add_log(message: String) -> void:
	log_lines.push_front(message)
	while log_lines.size() > 5:
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


func _get_held_direction() -> Vector2i:
	if last_input_direction != Vector2i.ZERO and _is_direction_pressed(last_input_direction):
		return last_input_direction

	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_H):
		last_input_direction = Vector2i(-1, 0)
		return last_input_direction
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_L):
		last_input_direction = Vector2i(1, 0)
		return last_input_direction
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_K):
		last_input_direction = Vector2i(0, -1)
		return last_input_direction
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_J):
		last_input_direction = Vector2i(0, 1)
		return last_input_direction

	last_input_direction = Vector2i.ZERO
	return Vector2i.ZERO


func _is_direction_pressed(direction: Vector2i) -> bool:
	if direction == Vector2i(-1, 0):
		return Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_H)
	if direction == Vector2i(1, 0):
		return Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_L)
	if direction == Vector2i(0, -1):
		return Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_K)
	if direction == Vector2i(0, 1):
		return Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_J)
	return false


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
	var move_interval := float(definition.get("move_interval", 0.6))
	var attack_interval := float(definition.get("attack_interval", 1.0))
	return {
		"type": enemy_type,
		"name": definition["name"],
		"hp": hp,
		"max_hp": hp,
		"attack": int(definition["attack"]),
		"score": int(definition["score"]),
		"texture": definition["texture"],
		"role": str(definition.get("role", "normal")),
		"awareness": int(definition["awareness"]),
		"move_interval": move_interval,
		"attack_interval": attack_interval,
		"phase_move_interval": float(definition.get("phase_move_interval", move_interval)),
		"phase_attack_interval": float(definition.get("phase_attack_interval", attack_interval)),
		"ranged_range": int(definition.get("ranged_range", 0)),
		"ranged_damage": int(definition.get("ranged_damage", 0)),
		"summon_on_half_hp": int(definition.get("summon_on_half_hp", 0)),
		"phase_triggered": false,
		"base_modulate": Color.WHITE,
		"move_cooldown": rng.randf_range(0.05, move_interval),
		"attack_cooldown": rng.randf_range(0.35, attack_interval),
		"cell": cell,
		"node": null,
		"sprite": null,
		"hp_fill": null,
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


func _make_chest(cell: Vector2i) -> Dictionary:
	return {
		"cell": cell,
		"opened": false,
		"node": null,
	}


func _make_fountain(cell: Vector2i) -> Dictionary:
	return {
		"cell": cell,
		"used": false,
		"node": null,
	}


func _make_trap(cell: Vector2i) -> Dictionary:
	return {
		"cell": cell,
		"triggered": false,
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
	enemy["sprite"] = sprite

	var hp_back := ColorRect.new()
	hp_back.position = Vector2(-14, -24)
	hp_back.size = Vector2(28, 4)
	hp_back.color = Color(0.05, 0.06, 0.05, 0.88)
	hp_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(hp_back)

	var hp_fill := ColorRect.new()
	hp_fill.position = Vector2(-13, -23)
	hp_fill.size = Vector2(26, 2)
	hp_fill.color = Color(0.88, 0.18, 0.16, 1.0)
	hp_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(hp_fill)
	enemy["hp_fill"] = hp_fill
	_update_enemy_health_bar(enemy)

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


func _find_spawn_cells_near(origin: Vector2i, count: int) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
		Vector2i(1, 1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(-1, -1),
		Vector2i(2, 0),
		Vector2i(-2, 0),
		Vector2i(0, 2),
		Vector2i(0, -2),
	]
	candidates.shuffle()
	var result: Array[Vector2i] = []
	for offset in candidates:
		var cell := origin + offset
		if _can_spawn_enemy_at(cell) and not result.has(cell):
			result.append(cell)
			if result.size() >= count:
				return result
	return result


func _has_line_of_sight(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	var step := Vector2i.ZERO
	if from_cell.x == to_cell.x:
		step.y = 1 if to_cell.y > from_cell.y else -1
	elif from_cell.y == to_cell.y:
		step.x = 1 if to_cell.x > from_cell.x else -1
	else:
		return false

	var cursor := from_cell + step
	while cursor != to_cell:
		if _tile_at(cursor) == Tile.WALL:
			return false
		if _enemy_at(cursor) != null:
			return false
		cursor += step

	return true


func _draw_cast_line(from_cell: Vector2i, to_cell: Vector2i) -> void:
	if fx_layer == null:
		return

	var from_position := _cell_to_world(from_cell)
	var to_position := _cell_to_world(to_cell)
	var beam := ColorRect.new()
	beam.color = Color(1.0, 0.54, 0.20, 0.74)
	beam.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if from_cell.x == to_cell.x:
		beam.position = Vector2(from_position.x - 3.0, minf(from_position.y, to_position.y))
		beam.size = Vector2(6.0, absf(to_position.y - from_position.y))
	else:
		beam.position = Vector2(minf(from_position.x, to_position.x), from_position.y - 3.0)
		beam.size = Vector2(absf(to_position.x - from_position.x), 6.0)
	fx_layer.add_child(beam)

	var tween := create_tween()
	tween.tween_property(beam, "modulate", Color(1, 1, 1, 0), 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(beam.queue_free)


func _can_spawn_enemy_at(cell: Vector2i) -> bool:
	if not _is_inside(cell):
		return false
	if _tile_at(cell) == Tile.WALL:
		return false
	if cell == player_cell or cell == exit_cell:
		return false
	if _enemy_at(cell) != null:
		return false
	if _item_at(cell) != null or _chest_at(cell) != null or _fountain_at(cell) != null or _trap_at(cell) != null:
		return false
	return true


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


func _chest_at(cell: Vector2i) -> Variant:
	for chest in chests:
		if chest["cell"] == cell:
			return chest
	return null


func _fountain_at(cell: Vector2i) -> Variant:
	for fountain in fountains:
		if fountain["cell"] == cell:
			return fountain
	return null


func _trap_at(cell: Vector2i) -> Variant:
	for trap in traps:
		if trap["cell"] == cell:
			return trap
	return null


func _count_unopened_chests() -> int:
	var count := 0
	for chest in chests:
		if not bool(chest.get("opened", false)):
			count += 1
	return count


func _count_unused_fountains() -> int:
	var count := 0
	for fountain in fountains:
		if not bool(fountain.get("used", false)):
			count += 1
	return count


func _count_armed_traps() -> int:
	var count := 0
	for trap in traps:
		if not bool(trap.get("triggered", false)):
			count += 1
	return count


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


func _flash_enemy(enemy: Dictionary, color: Color) -> void:
	var sprite: Variant = enemy.get("sprite")
	if sprite == null or not is_instance_valid(sprite):
		_flash_node(enemy.get("node"), color)
		return
	var base_color: Color = enemy.get("base_modulate", Color.WHITE)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", color, 0.04)
	tween.tween_property(sprite, "modulate", base_color, 0.12)


func _update_enemy_health_bar(enemy: Dictionary) -> void:
	var hp_fill: Variant = enemy.get("hp_fill")
	if hp_fill == null or not is_instance_valid(hp_fill):
		return
	var max_hp := maxf(float(enemy.get("max_hp", 1)), 1.0)
	var ratio := clampf(float(enemy.get("hp", 0)) / max_hp, 0.0, 1.0)
	hp_fill.size = Vector2(26.0 * ratio, 2)
	hp_fill.color = Color(0.86, 0.18, 0.16, 1.0) if ratio <= 0.35 else Color(0.95, 0.55, 0.20, 1.0)


func _pulse_exit() -> void:
	if exit_node == null or not is_instance_valid(exit_node):
		return
	if exit_pulse_tween != null and exit_pulse_tween.is_valid():
		exit_pulse_tween.kill()
	exit_node.scale = Vector2.ONE * 2.0
	exit_pulse_tween = create_tween()
	exit_pulse_tween.set_loops()
	exit_pulse_tween.tween_property(exit_node, "scale", Vector2.ONE * 2.22, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	exit_pulse_tween.tween_property(exit_node, "scale", Vector2.ONE * 2.0, 0.36).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


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
