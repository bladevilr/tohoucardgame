extends Node2D

var _start_pos: Vector2
var _target_pos: Vector2
var _flavor: float = 0.0
var _duration: float = 0.6

@onready var visual: Node2D = $Visual
@onready var glow: ColorRect = $Visual/Glow
@onready var icon_label: Label = $Visual/Icon
@onready var trail: Line2D = $Trail

func launch(start_pos: Vector2, target_pos: Vector2, flavor: float, item_data: Dictionary = {}, duration: float = 0.6) -> void:
	_start_pos = start_pos
	_target_pos = target_pos
	_flavor = flavor
	_duration = duration
	global_position = start_pos

	var scale_factor = 0.8 + min(flavor / 50.0, 1.5)
	visual.scale = Vector2(scale_factor, scale_factor)

	var color := Color(1.0, 0.9, 0.6)
	if flavor > 30.0:
		color = Color(1.0, 0.4, 0.2)
	elif flavor < 10.0:
		color = Color(0.6, 0.8, 1.0)

	glow.color = color
	trail.default_color = color * Color(1, 1, 1, 0.5)
	trail.clear_points()
	trail.top_level = true
	trail.add_point(_start_pos)

	icon_label.text = _pick_emoji(item_data)
	icon_label.add_theme_font_size_override("font_size", 34)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.position = Vector2(-20, -20)
	icon_label.custom_minimum_size = Vector2(40, 40)
	icon_label.modulate = Color(1, 1, 1, 0.95)

	_animate_flight()

func _animate_flight() -> void:
	var start: Vector2 = _start_pos
	var mid_y: float = minf(start.y, _target_pos.y) - 100.0 - randf() * 50.0
	var peak_pos: Vector2 = (start + _target_pos) * 0.5
	peak_pos.y = mid_y

	var tween: Tween = create_tween()
	tween.tween_method(func(t: float):
		var q0 = start.lerp(peak_pos, t)
		var q1 = peak_pos.lerp(_target_pos, t)
		var pos = q0.lerp(q1, t)
		global_position = pos
		trail.add_point(pos)
		if trail.get_point_count() > 14:
			trail.remove_point(0)
		visual.rotation += 0.2
	, 0.0, 1.0, _duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(_on_impact)

func _on_impact() -> void:
	var particle_factory = get_node_or_null("/root/ParticleFactory")
	if particle_factory and particle_factory.has_method("spawn_score_burst"):
		particle_factory.call("spawn_score_burst", self, global_position, _flavor > 30.0)

	if _flavor > 20.0:
		var sfx = get_node_or_null("/root/ScreenFX")
		if sfx:
			sfx.call("shake", _flavor * 0.1, 0.15)

	trail.top_level = false
	queue_free()

func _pick_emoji(item_data: Dictionary) -> String:
	var tags: Array = item_data.get("tags", [])
	var cuisine := str(item_data.get("cuisine", ""))

	if _has_any(tags, ["meat", "beef", "pork", "poultry"]):
		return "🥩"
	if _has_any(tags, ["vegetable", "mushroom", "tofu", "fruit"]):
		return "🥬"
	if _has_any(tags, ["seafood", "fish"]):
		return "🐟"
	if _has_any(tags, ["dessert", "sweet", "kanmi"]) or cuisine == "kanmi":
		return "🍰"
	if _has_any(tags, ["soup", "stew"]) or cuisine == "yakuzen":
		return "🍲"
	if _has_any(tags, ["noodle", "staple", "rice"]):
		return "🍜"
	return "🍽️"

func _has_any(tags: Array, candidates: Array) -> bool:
	for c in candidates:
		if c in tags:
			return true
	return false
