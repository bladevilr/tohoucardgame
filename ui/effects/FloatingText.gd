extends Label
class_name FloatingText

static func spawn(parent: Node, text: String, position: Vector2, color: Color = Color.WHITE, duration: float = 0.8, rise: float = 56.0, font_size: int = 20) -> FloatingText:
	if parent == null:
		return null
	var label = FloatingText.new()
	label.text = text
	label.position = position
	label.modulate = color
	label.z_index = 100
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(label)

	var tween = label.create_tween()
	tween.tween_property(label, "position", position + Vector2(0, -rise), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, duration)
	tween.finished.connect(func():
		if is_instance_valid(label):
			label.queue_free()
	)
	return label
