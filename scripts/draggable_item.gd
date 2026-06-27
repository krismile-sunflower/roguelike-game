class_name DraggableItem
extends Node2D

signal pickup_started(item: DraggableItem)
signal dropped(item: DraggableItem)

var item_id: String = ""
var category: String = ""
var label_text: String = ""
var size: Vector2 = Vector2(110.0, 80.0)
var color: Color = Color(0.95, 0.86, 0.62, 1.0)
var home_position: Vector2 = Vector2.ZERO
var solution_target_id: String = ""
var sort_key: int = 0

var current_target: DropTarget = null

var _shadow: Polygon2D
var _card: Polygon2D
var _icon_root: Node2D
var _label: Label
var _dragging: bool = false


func _ready() -> void:
	_build_visuals()
	global_position = home_position


func configure(data: Dictionary) -> void:
	item_id = str(data.get("id", ""))
	category = str(data.get("category", ""))
	label_text = str(data.get("label", ""))
	size = data.get("size", Vector2(110.0, 80.0))
	color = data.get("color", color)
	home_position = data.get("home_position", global_position)
	solution_target_id = str(data.get("target_id", ""))
	sort_key = int(data.get("sort_key", 0))
	position = home_position

	if is_inside_tree():
		_build_visuals()


func contains_point(point: Vector2) -> bool:
	var rect := Rect2(global_position - size * 0.5, size)
	return rect.has_point(point)


func pick_up() -> void:
	_dragging = true
	z_index = 100
	scale = Vector2.ONE * 1.03
	if _shadow:
		_shadow.color = Color(0, 0, 0, 0.2)
	pickup_started.emit(self)


func drag_to(point: Vector2) -> void:
	global_position = point


func drop() -> void:
	_dragging = false
	z_index = 1
	scale = Vector2.ONE
	if _shadow:
		_shadow.color = Color(0, 0, 0, 0.12)
	dropped.emit(self)


func snap_to_position(target_position: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_position, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func reset_to_home() -> void:
	current_target = null
	snap_to_position(home_position)


func is_correctly_placed() -> bool:
	return current_target != null and current_target.target_id == solution_target_id


func pulse_hint() -> void:
	if _card == null:
		return

	var tween := create_tween()
	tween.tween_property(_card, "color", color.lightened(0.18), 0.12)
	tween.tween_property(_card, "color", color, 0.18)


func _build_visuals() -> void:
	for child in get_children():
		child.queue_free()

	_shadow = _make_rounded_polygon(size + Vector2(4.0, 4.0), 20.0, Color(0, 0, 0, 0.12))
	_shadow.position = Vector2(6.0, 7.0)
	add_child(_shadow)

	_card = _make_rounded_polygon(size, 20.0, color)
	add_child(_card)

	var inner_panel := _make_rounded_polygon(size - Vector2(18.0, 18.0), 16.0, Color(1, 1, 1, 0.28))
	inner_panel.position = Vector2(0, -4)
	add_child(inner_panel)

	var shine := Polygon2D.new()
	shine.color = Color(1, 1, 1, 0.16)
	shine.position = Vector2(-size.x * 0.32, -size.y * 0.3)
	shine.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(size.x * 0.34, -6),
		Vector2(size.x * 0.24, 16),
		Vector2(-6, 18),
	])
	add_child(shine)

	_icon_root = Node2D.new()
	_icon_root.position = Vector2(0, -10)
	add_child(_icon_root)
	_build_icon()

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.position = Vector2(-size.x * 0.5 + 10.0, size.y * 0.5 - 32.0)
	_label.size = Vector2(size.x - 20.0, 22.0)
	_label.text = label_text
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color(0.24, 0.17, 0.12, 0.82))
	add_child(_label)


func _build_icon() -> void:
	match item_id:
		"lamp":
			_draw_lamp()
		"book":
			_draw_notebook()
		"camera":
			_draw_camera()
		"book_short":
			_draw_book_spine(Vector2(54, 64), Color(0.55, 0.71, 0.93, 1.0), "I")
		"book_mid":
			_draw_book_spine(Vector2(54, 96), Color(0.66, 0.82, 0.62, 1.0), "II")
		"book_tall":
			_draw_book_spine(Vector2(54, 128), Color(0.95, 0.73, 0.56, 1.0), "III")
		"mug":
			_draw_mug()
		"spoon":
			_draw_spoon()
		"tea_tin":
			_draw_tin()
		"brush":
			_draw_brush()
		"paint":
			_draw_paint_tubes()
		"scissors":
			_draw_scissors()
		_:
			_draw_generic_token()


func _draw_lamp() -> void:
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(-16, 26), Vector2(14, 26), Vector2(28, 8), Vector2(-28, 8)
	]), Color(0.98, 0.86, 0.48, 1.0), Vector2(0, -8))
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(-8, 0), Vector2(6, 0), Vector2(24, -30), Vector2(10, -34)
	]), Color(0.57, 0.49, 0.37, 1.0), Vector2(0, 6))
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(-18, 24), Vector2(18, 24), Vector2(28, 34), Vector2(-28, 34)
	]), Color(0.64, 0.53, 0.39, 1.0), Vector2(0, 20))
	_add_dot(_icon_root, Vector2(18, 2), 4.5, Color(1.0, 0.97, 0.72, 0.85))


func _draw_notebook() -> void:
	_add_poly(_icon_root, _rect_points(Vector2(66, 50)), Color(0.73, 0.86, 0.95, 1.0), Vector2(0, 4))
	_add_poly(_icon_root, _rect_points(Vector2(54, 50)), Color(0.9, 0.96, 0.98, 1.0), Vector2(4, 4))
	_add_poly(_icon_root, _rect_points(Vector2(8, 52)), Color(0.48, 0.64, 0.75, 1.0), Vector2(-25, 4))
	for y in [-14.0, -4.0, 6.0, 16.0]:
		_add_poly(_icon_root, _rect_points(Vector2(34, 2)), Color(0.71, 0.8, 0.89, 1.0), Vector2(8, y))


func _draw_camera() -> void:
	_add_poly(_icon_root, _rect_points(Vector2(72, 42)), Color(0.34, 0.29, 0.28, 1.0), Vector2(0, 6))
	_add_poly(_icon_root, _rect_points(Vector2(22, 10)), Color(0.45, 0.39, 0.36, 1.0), Vector2(-18, -20))
	_add_dot(_icon_root, Vector2(0, 6), 15.0, Color(0.89, 0.91, 0.95, 1.0))
	_add_dot(_icon_root, Vector2(0, 6), 8.0, Color(0.42, 0.51, 0.64, 1.0))
	_add_dot(_icon_root, Vector2(24, 0), 4.0, Color(0.97, 0.73, 0.67, 1.0))


func _draw_book_spine(book_size: Vector2, book_color: Color, marker: String) -> void:
	_add_poly(_icon_root, _rect_points(book_size), book_color, Vector2(0, 12))
	_add_poly(_icon_root, _rect_points(Vector2(book_size.x - 12.0, book_size.y - 10.0)), book_color.lightened(0.12), Vector2(0, 12))
	_add_poly(_icon_root, _rect_points(Vector2(8, book_size.y)), book_color.darkened(0.14), Vector2(-book_size.x * 0.34, 12))
	var marker_label := Label.new()
	marker_label.text = marker
	marker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker_label.position = Vector2(-16, 4)
	marker_label.size = Vector2(32, 24)
	marker_label.add_theme_font_size_override("font_size", 14)
	marker_label.add_theme_color_override("font_color", Color(0.22, 0.17, 0.14, 0.72))
	_icon_root.add_child(marker_label)


func _draw_mug() -> void:
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(-22, -18), Vector2(10, -18), Vector2(16, 20), Vector2(-18, 20)
	]), Color(0.98, 0.91, 0.77, 1.0), Vector2(0, 10))
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(0, -14), Vector2(24, -6), Vector2(24, 14), Vector2(2, 10)
	]), Color(0.9, 0.75, 0.58, 1.0), Vector2(14, 8))
	_add_poly(_icon_root, _rect_points(Vector2(36, 4)), Color(0.84, 0.67, 0.54, 1.0), Vector2(-2, -12))


func _draw_spoon() -> void:
	_add_dot(_icon_root, Vector2(-18, 0), 13.0, Color(0.86, 0.72, 0.56, 1.0))
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(-6, -4), Vector2(34, -4), Vector2(34, 4), Vector2(-6, 4)
	]), Color(0.72, 0.57, 0.41, 1.0), Vector2(6, 10))


func _draw_tin() -> void:
	_add_poly(_icon_root, _rect_points(Vector2(50, 56)), Color(0.76, 0.89, 0.67, 1.0), Vector2(0, 8))
	_add_poly(_icon_root, _rect_points(Vector2(56, 10)), Color(0.6, 0.74, 0.52, 1.0), Vector2(0, -18))
	_add_poly(_icon_root, _rect_points(Vector2(30, 22)), Color(0.93, 0.97, 0.88, 1.0), Vector2(0, 8))


func _draw_brush() -> void:
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(-26, -3), Vector2(16, -3), Vector2(16, 3), Vector2(-26, 3)
	]), Color(0.77, 0.61, 0.4, 1.0), Vector2(-2, 12))
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(0, -8), Vector2(16, -6), Vector2(16, 6), Vector2(0, 8)
	]), Color(0.89, 0.77, 0.61, 1.0), Vector2(12, 12))
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(0, -10), Vector2(18, 0), Vector2(0, 10), Vector2(-8, 0)
	]), Color(0.95, 0.56, 0.44, 1.0), Vector2(30, 12))


func _draw_paint_tubes() -> void:
	_add_poly(_icon_root, _rect_points(Vector2(18, 42)), Color(0.97, 0.78, 0.43, 1.0), Vector2(-18, 8))
	_add_poly(_icon_root, _rect_points(Vector2(18, 42)), Color(0.72, 0.77, 0.97, 1.0), Vector2(6, 8))
	_add_poly(_icon_root, _rect_points(Vector2(18, 42)), Color(0.94, 0.57, 0.65, 1.0), Vector2(30, 8))
	for x in [-18.0, 6.0, 30.0]:
		_add_poly(_icon_root, _rect_points(Vector2(12, 8)), Color(0.92, 0.92, 0.95, 1.0), Vector2(x, -18))


func _draw_scissors() -> void:
	_add_dot(_icon_root, Vector2(-10, 16), 11.0, Color(0.91, 0.67, 0.67, 1.0))
	_add_dot(_icon_root, Vector2(12, 16), 11.0, Color(0.77, 0.84, 0.95, 1.0))
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(-2, -24), Vector2(4, -24), Vector2(-4, 10), Vector2(-10, 10)
	]), Color(0.73, 0.74, 0.78, 1.0), Vector2(0, 0))
	_add_poly(_icon_root, PackedVector2Array([
		Vector2(-4, -24), Vector2(2, -24), Vector2(10, 10), Vector2(4, 10)
	]), Color(0.73, 0.74, 0.78, 1.0), Vector2(0, 0))
	_add_dot(_icon_root, Vector2(0, 8), 3.0, Color(0.52, 0.53, 0.58, 1.0))


func _draw_generic_token() -> void:
	_add_dot(_icon_root, Vector2(0, 8), 20.0, color.darkened(0.1))
	_add_dot(_icon_root, Vector2(0, 8), 10.0, Color(1, 1, 1, 0.35))


func _make_rounded_polygon(panel_size: Vector2, radius: float, fill_color: Color) -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.color = fill_color
	polygon.polygon = _rounded_rect_points(panel_size, radius)
	return polygon


func _rounded_rect_points(panel_size: Vector2, radius: float) -> PackedVector2Array:
	var half := panel_size * 0.5
	var r := minf(radius, minf(half.x, half.y))
	return PackedVector2Array([
		Vector2(-half.x + r, -half.y),
		Vector2(half.x - r, -half.y),
		Vector2(half.x, -half.y + r),
		Vector2(half.x, half.y - r),
		Vector2(half.x - r, half.y),
		Vector2(-half.x + r, half.y),
		Vector2(-half.x, half.y - r),
		Vector2(-half.x, -half.y + r),
	])


func _rect_points(rect_size: Vector2) -> PackedVector2Array:
	var half := rect_size * 0.5
	return PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y),
	])


func _add_poly(parent: Node, points: PackedVector2Array, fill_color: Color, offset: Vector2 = Vector2.ZERO) -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.polygon = points
	polygon.color = fill_color
	polygon.position = offset
	parent.add_child(polygon)
	return polygon


func _add_dot(parent: Node, center: Vector2, radius: float, fill_color: Color) -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.position = center
	polygon.color = fill_color
	var points := PackedVector2Array()
	var steps := 16
	for index in range(steps):
		var angle := TAU * float(index) / float(steps)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	polygon.polygon = points
	parent.add_child(polygon)
	return polygon
