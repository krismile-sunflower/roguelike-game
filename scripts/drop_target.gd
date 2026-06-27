class_name DropTarget
extends Node2D

enum Mode {
	SINGLE,
	CATEGORY_BIN,
}

var target_id: String = ""
var label_text: String = ""
var size: Vector2 = Vector2(120.0, 120.0)
var accepted_item_ids: Array[String] = []
var accepted_category: String = ""
var slot_positions: Array[Vector2] = []
var mode: int = Mode.SINGLE
var base_color: Color = Color(0.85, 0.82, 0.75, 0.65)
var highlight_color: Color = Color(1.0, 0.95, 0.7, 0.95)

var _assigned_slots: Dictionary = {}
var _shadow: Polygon2D
var _visual: Polygon2D
var _accent: Polygon2D
var _slot_markers: Node2D
var _label: Label


func _ready() -> void:
	_build_visuals()
	_refresh_visuals()


func configure(data: Dictionary) -> void:
	target_id = str(data.get("id", ""))
	label_text = str(data.get("label", ""))
	size = data.get("size", Vector2(120.0, 120.0))
	accepted_category = str(data.get("accepted_category", ""))
	base_color = data.get("color", base_color)
	highlight_color = data.get("highlight_color", highlight_color)

	var mode_name := str(data.get("mode", "single"))
	mode = Mode.CATEGORY_BIN if mode_name == "category_bin" else Mode.SINGLE

	accepted_item_ids.clear()
	for value in data.get("accepted_item_ids", []):
		accepted_item_ids.append(str(value))

	slot_positions.clear()
	for value in data.get("slot_positions", []):
		slot_positions.append(value)

	if slot_positions.is_empty():
		slot_positions.append(Vector2.ZERO)

	position = data.get("position", position)

	if is_inside_tree():
		_build_visuals()
		_refresh_visuals()


func contains_point(point: Vector2) -> bool:
	var rect := Rect2(global_position - size * 0.5, size)
	return rect.has_point(point)


func can_accept(item: DraggableItem) -> bool:
	match mode:
		Mode.SINGLE:
			if not accepted_item_ids.has(item.item_id):
				return false
			return not _is_slot_taken_by_other(item, 0)
		Mode.CATEGORY_BIN:
			if item.category != accepted_category:
				return false
			return _find_available_slot(item) != -1
	return false


func assign_item(item: DraggableItem) -> Vector2:
	var slot_index := _find_available_slot(item)
	if slot_index == -1:
		return item.home_position

	_assigned_slots[item.item_id] = slot_index
	return global_position + slot_positions[slot_index]


func remove_item(item: DraggableItem) -> void:
	_assigned_slots.erase(item.item_id)


func reset_assignments() -> void:
	_assigned_slots.clear()


func pulse_hint() -> void:
	if _visual == null:
		return

	var tween := create_tween()
	tween.tween_property(_visual, "color", highlight_color, 0.12)
	tween.parallel().tween_property(_accent, "color", highlight_color.lightened(0.06), 0.12)
	tween.tween_property(_visual, "color", base_color, 0.18)
	tween.parallel().tween_property(_accent, "color", base_color.darkened(0.12), 0.18)


func _find_available_slot(item: DraggableItem) -> int:
	if _assigned_slots.has(item.item_id):
		return int(_assigned_slots[item.item_id])

	for index in range(slot_positions.size()):
		if not _is_slot_taken(index):
			return index
	return -1


func _is_slot_taken(slot_index: int) -> bool:
	for value in _assigned_slots.values():
		if int(value) == slot_index:
			return true
	return false


func _is_slot_taken_by_other(item: DraggableItem, slot_index: int) -> bool:
	for item_key in _assigned_slots.keys():
		if item_key != item.item_id and int(_assigned_slots[item_key]) == slot_index:
			return true
	return false


func _build_visuals() -> void:
	for child in get_children():
		child.queue_free()

	_shadow = _add_poly(_rounded_rect_points(size + Vector2(10.0, 10.0), 28.0), Color(0.26, 0.18, 0.12, 0.08), Vector2(0, 10))
	_visual = _add_poly(_rounded_rect_points(size, 28.0), base_color, Vector2.ZERO)
	_accent = _add_poly(_rounded_rect_points(size - Vector2(18.0, 18.0), 22.0), base_color.darkened(0.12), Vector2(0, 6))

	_slot_markers = Node2D.new()
	add_child(_slot_markers)
	_build_mode_visuals()

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.position = Vector2(-size.x * 0.5 + 12.0, size.y * 0.5 - 36.0)
	_label.size = Vector2(size.x - 24.0, 24.0)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color(0.24, 0.17, 0.12, 0.76))
	add_child(_label)


func _refresh_visuals() -> void:
	if _visual:
		_visual.color = base_color
	if _accent:
		_accent.color = base_color.darkened(0.12)
	if _label:
		_label.text = label_text


func _build_mode_visuals() -> void:
	if _slot_markers == null:
		return

	match mode:
		Mode.SINGLE:
			_build_single_target()
		Mode.CATEGORY_BIN:
			_build_bin_target()


func _build_single_target() -> void:
	var slot_outline := Polygon2D.new()
	slot_outline.color = Color(1, 1, 1, 0.22)
	slot_outline.polygon = _rounded_rect_points(size - Vector2(34.0, 34.0), 18.0)
	slot_outline.position = Vector2(0, -4)
	_slot_markers.add_child(slot_outline)

	if accepted_item_ids.size() > 0:
		var preview := Label.new()
		preview.text = _preview_name_for_item(accepted_item_ids[0])
		preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		preview.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		preview.position = Vector2(-size.x * 0.5 + 12.0, -12.0)
		preview.size = Vector2(size.x - 24.0, 24.0)
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.add_theme_font_size_override("font_size", 13)
		preview.add_theme_color_override("font_color", Color(0.32, 0.24, 0.18, 0.42))
		_slot_markers.add_child(preview)


func _build_bin_target() -> void:
	var lip := Polygon2D.new()
	lip.color = base_color.darkened(0.18)
	lip.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5 + 10.0, -size.y * 0.5 + 18.0),
		Vector2(size.x * 0.5 - 10.0, -size.y * 0.5 + 18.0),
		Vector2(size.x * 0.5 - 26.0, -size.y * 0.5 + 42.0),
		Vector2(-size.x * 0.5 + 26.0, -size.y * 0.5 + 42.0),
	])
	_slot_markers.add_child(lip)

	for slot_position in slot_positions:
		var marker := Polygon2D.new()
		marker.color = Color(1, 1, 1, 0.18)
		marker.position = slot_position + Vector2(0, 4)
		marker.polygon = _rounded_rect_points(Vector2(54, 40), 12.0)
		_slot_markers.add_child(marker)

	if label_text.to_lower().contains("basket"):
		for x in [-82.0, -40.0, 2.0, 44.0, 86.0]:
			var stripe := Polygon2D.new()
			stripe.color = Color(1, 1, 1, 0.12)
			stripe.position = Vector2(x, 4)
			stripe.polygon = _rect_points(Vector2(10, size.y - 40.0))
			_slot_markers.add_child(stripe)


func _preview_name_for_item(item_name: String) -> String:
	match item_name:
		"lamp":
			return "lamp"
		"book":
			return "notebook"
		"camera":
			return "camera"
		"book_short":
			return "short"
		"book_mid":
			return "medium"
		"book_tall":
			return "tall"
		_:
			return item_name


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


func _add_poly(points: PackedVector2Array, fill_color: Color, offset: Vector2) -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.polygon = points
	polygon.color = fill_color
	polygon.position = offset
	add_child(polygon)
	return polygon
