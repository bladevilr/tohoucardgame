extends Control
class_name AdjacencyVisualizer

var _lines: Array[Line2D] = []

func clear_visuals() -> void:
	for line in _lines:
		if is_instance_valid(line):
			line.queue_free()
	_lines.clear()

func add_link(from_pos: Vector2, to_pos: Vector2, color: Color = Color(1.0, 0.85, 0.35), width: float = 2.0, dashed: bool = false) -> void:
	var line = Line2D.new()
	line.default_color = color
	line.width = width
	line.z_index = 50
	if dashed:
		line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.add_point(from_pos)
	line.add_point(to_pos)
	add_child(line)
	_lines.append(line)

func visualize_from_slots(slots: Array, source_idx: int, adjacent_indices: Array, pairing_indices: Array = []) -> void:
	clear_visuals()
	if source_idx < 0 or source_idx >= slots.size():
		return
	var source = slots[source_idx]
	if source == null:
		return
	var source_pos = source.global_position + source.size * 0.5
	for idx in adjacent_indices:
		if idx >= 0 and idx < slots.size() and slots[idx] != null:
			var to_pos = slots[idx].global_position + slots[idx].size * 0.5
			add_link(source_pos, to_pos, Color(1.0, 0.8, 0.3), 2.2, false)
	for idx in pairing_indices:
		if idx >= 0 and idx < slots.size() and slots[idx] != null:
			var p_pos = slots[idx].global_position + slots[idx].size * 0.5
			add_link(source_pos, p_pos, Color(0.45, 0.9, 0.45), 2.0, true)
