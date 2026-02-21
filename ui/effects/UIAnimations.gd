extends Node

func fade_in(node: CanvasItem, duration: float = 0.25, delay: float = 0.0) -> Tween:
	if node == null:
		return null
	node.modulate.a = 0.0
	var tween = node.create_tween()
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.tween_property(node, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween

func fade_out(node: CanvasItem, duration: float = 0.2) -> Tween:
	if node == null:
		return null
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return tween

func slide_in_from_bottom(control: Control, distance: float = 36.0, duration: float = 0.3, delay: float = 0.0) -> Tween:
	if control == null:
		return null
	control.modulate.a = 0.0
	var layout_managed = control.get_parent() is Container
	var tween = control.create_tween()
	if delay > 0.0:
		tween.tween_interval(delay)
	if layout_managed:
		control.pivot_offset = control.size * 0.5
		control.scale = Vector2(1.0, 0.96)
		tween.tween_property(control, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		var original: Vector2 = control.position
		control.position = original + Vector2(0.0, distance)
		tween.tween_property(control, "position", original, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(control, "modulate:a", 1.0, duration)
	return tween

func pop_in(control: Control, duration: float = 0.25, from_scale: Vector2 = Vector2(0.85, 0.85), delay: float = 0.0) -> Tween:
	if control == null:
		return null
	control.pivot_offset = control.size * 0.5
	control.scale = from_scale
	control.modulate.a = 0.0
	var tween = control.create_tween()
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.tween_property(control, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(control, "modulate:a", 1.0, duration)
	return tween

func hover_lift(control: Control, to_scale: float = 1.08, duration: float = 0.15) -> Tween:
	if control == null:
		return null
	control.pivot_offset = control.size * 0.5
	var tween = control.create_tween()
	tween.tween_property(control, "scale", Vector2(to_scale, to_scale), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween

func hover_reset(control: Control, duration: float = 0.12) -> Tween:
	if control == null:
		return null
	var tween = control.create_tween()
	tween.tween_property(control, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	return tween

func count_number(label: Label, from_value: float, to_value: float, duration: float = 0.3, prefix: String = "", suffix: String = "") -> Tween:
	if label == null:
		return null
	label.text = "%s%d%s" % [prefix, int(from_value), suffix]
	var tween = label.create_tween()
	tween.tween_method(
		Callable(self, "_apply_count_to_label").bind(label, prefix, suffix),
		from_value,
		to_value,
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	return tween

func _apply_count_to_label(value: float, label: Label, prefix: String, suffix: String) -> void:
	if label:
		label.text = "%s%d%s" % [prefix, int(round(value)), suffix]

func smooth_progress(bar: Range, to_value: float, duration: float = 0.3) -> Tween:
	if bar == null:
		return null
	var tween = bar.create_tween()
	tween.tween_property(bar, "value", to_value, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tween

func shake(control: Control, strength: float = 8.0, duration: float = 0.25) -> Tween:
	if control == null:
		return null
	var original: Vector2 = control.position
	var tween = control.create_tween()
	for i in range(6):
		var offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tween.tween_property(control, "position", original + offset, duration / 7.0)
	tween.tween_property(control, "position", original, duration / 7.0)
	return tween

func pulse(control: Control, intensity: float = 1.06, duration: float = 0.5) -> Tween:
	if control == null:
		return null
	control.pivot_offset = control.size * 0.5
	var tween = control.create_tween().set_loops()
	tween.tween_property(control, "scale", Vector2.ONE * intensity, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(control, "scale", Vector2.ONE, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween

func flip_reveal(control: Control, duration: float = 0.2, delay: float = 0.0) -> Tween:
	if control == null:
		return null
	control.pivot_offset = control.size * 0.5
	control.scale.x = 0.0
	var tween = control.create_tween()
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.tween_property(control, "scale:x", 1.0, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween

func fly_arc(parent: CanvasItem, from_pos: Vector2, to_pos: Vector2, label_text: String, duration: float = 0.4) -> Tween:
	if parent == null:
		return null
	var ghost = PanelContainer.new()
	ghost.custom_minimum_size = Vector2(80, 24)
	ghost.z_index = 50
	ghost.position = from_pos
	ghost.pivot_offset = Vector2(40, 12)
	ghost.scale = Vector2(0.7, 0.7)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.85)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	ghost.add_theme_stylebox_override("panel", style)
	var lbl = Label.new()
	lbl.text = label_text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ghost.add_child(lbl)
	parent.add_child(ghost)

	var mid = (from_pos + to_pos) * 0.5 + Vector2(0, -60)
	var tween = ghost.create_tween()
	tween.tween_method(
		func(t: float):
			var a = from_pos.lerp(mid, t)
			var b = mid.lerp(to_pos, t)
			ghost.position = a.lerp(b, t)
			ghost.scale = Vector2.ONE * lerpf(0.7, 1.0, t),
		0.0, 1.0, duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func():
		if is_instance_valid(ghost):
			ghost.queue_free()
	)
	return tween
