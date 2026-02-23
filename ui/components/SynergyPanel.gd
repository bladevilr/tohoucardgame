extends PanelContainer

@onready var title_label: Label = $VBox/TitleLabel
@onready var list_container: VBoxContainer = $VBox/ListContainer

func _ready() -> void:
	title_label.text = "羁绊"
	# Removed hardcoded stylebox to allow transparency from TSCN


func update_synergies(active_synergies: Array) -> void:
	if title_label == null or list_container == null:
		return

	for child in list_container.get_children():
		child.queue_free()

	for syn in active_synergies:
		var is_active: bool = syn.get("active", true)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var icon_label := Label.new()
		icon_label.text = "✦"
		icon_label.add_theme_font_size_override("font_size", 14)
		icon_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0) if is_active else Color(0.5, 0.5, 0.5, 1.0))
		icon_label.add_theme_color_override("font_outline_color", Color.BLACK)
		icon_label.add_theme_constant_override("outline_size", 3)
		row.add_child(icon_label)

		var name_label := Label.new()
		name_label.text = syn.get("name", "???")
		name_label.add_theme_font_size_override("font_size", 14)
		name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1) if is_active else Color(0.6, 0.6, 0.6, 1.0))
		name_label.add_theme_color_override("font_outline_color", Color.BLACK)
		name_label.add_theme_constant_override("outline_size", 3)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		var effect_label := Label.new()
		effect_label.text = _build_effect_text(syn)
		effect_label.add_theme_font_size_override("font_size", 13)
		effect_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5, 1.0) if is_active else Color(0.45, 0.45, 0.45, 1.0))
		effect_label.add_theme_color_override("font_outline_color", Color.BLACK)
		effect_label.add_theme_constant_override("outline_size", 3)
		effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(effect_label)

		list_container.add_child(row)

func _build_effect_text(syn: Dictionary) -> String:
	var effect: Dictionary = syn.get("effect", {})
	if effect.is_empty():
		return ""

	var parts: Array[String] = []
	for key in effect.keys():
		var value = effect[key]
		match key:
			"flavor_mult":
				parts.append("美味度x%s" % str(value))
			"presentation_add_pct":
				parts.append("卖相+%d%%" % int(float(value) * 100.0))
			"technique_mult":
				parts.append("技法x%s" % str(value))
			"small_cd_mult":
				parts.append("小型CDx%s" % str(value))
			"large_flavor_mult":
				parts.append("大型美味度x%s" % str(value))
			_:
				parts.append("%s:%s" % [key, str(value)])

	return " ".join(parts)
