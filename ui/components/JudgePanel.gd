extends HBoxContainer

var _judge_boxes: Array = []

func update_judges(judges: Array) -> void:
	if judges == null:
		return

	# Clear existing children
	for child in get_children():
		child.queue_free()
	_judge_boxes.clear()

	# Create a box for each judge (up to 2)
	var count = mini(judges.size(), 2)
	var avatar_colors := [Color(0.6, 0.3, 0.7), Color(0.3, 0.6, 0.7)]

	for i in range(count):
		var judge = judges[i]
		if judge == null:
			continue

		# --- PanelContainer (outer wrapper) ---
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Use a distinct style for the judge card
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.12, 0.2, 0.6)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.5, 0.45, 0.6, 0.5)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_bottom_left = 8
		style.content_margin_left = 8
		style.content_margin_top = 8
		style.content_margin_right = 8
		style.content_margin_bottom = 8
		panel.add_theme_stylebox_override("panel", style)

		# --- HBoxContainer (avatar + text side by side) ---
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 6)

		# Avatar
		var avatar := TextureRect.new()
		avatar.custom_minimum_size = Vector2(100, 100)
		avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		
		var judge_id = judge.get("id", "")
		var tex = ArtDatabase.get_judge_portrait(judge_id)
		if tex:
			avatar.texture = tex
		else:
			# Placeholder if no art found
			var placeholder = ColorRect.new()
			placeholder.color = avatar_colors[i % avatar_colors.size()]
			placeholder.set_anchors_preset(Control.PRESET_FULL_RECT)
			avatar.add_child(placeholder)
			
		hbox.add_child(avatar)

		# --- VBoxContainer (name / effect / special) ---
		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)

		# Name label
		var name_label := Label.new()
		name_label.text = judge.get("name", "???")
		name_label.add_theme_color_override("font_color", Color.WHITE)
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.uppercase = false
		# Bold is set via theme or font variation; apply LabelSettings for bold
		var name_settings := LabelSettings.new()
		name_settings.font_size = 16
		name_settings.font_color = Color.WHITE
		name_label.label_settings = name_settings
		vbox.add_child(name_label)

		# Effect label — built from scoring_modifiers
		var effect_label := Label.new()
		effect_label.text = _build_effect_text(judge)
		effect_label.add_theme_color_override("font_color", Color(0.72, 0.62, 0.82))
		effect_label.add_theme_font_size_override("font_size", 14)
		vbox.add_child(effect_label)

		# Special label
		var special_label := Label.new()
		var special: Dictionary = judge.get("special", {})
		var special_name: String = special.get("name", "")
		var desc: String = judge.get("description", "")
		if desc.length() > 30:
			desc = desc.substr(0, 30)
		special_label.text = special_name + " - " + desc
		special_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		special_label.add_theme_font_size_override("font_size", 13)
		vbox.add_child(special_label)

		hbox.add_child(vbox)
		panel.add_child(hbox)
		add_child(panel)
		_judge_boxes.append(panel)


func _build_effect_text(judge: Dictionary) -> String:
	var mods: Dictionary = judge.get("scoring_modifiers", {})
	if mods == null or mods.is_empty():
		return ""

	var parts: Array[String] = []
	var key_map := {
		"flavor_mult": "味道",
		"dot_mult": "卖相压制",
		"technique_mult": "技法",
		"aroma_cap": "香气上限",
	}

	for key in mods.keys():
		if key_map.has(key):
			var label: String = key_map[key]
			var value = mods[key]
			if key == "aroma_cap":
				parts.append(label + str(value))
			else:
				parts.append(label + "\u00d7" + str(value))

	return " ".join(parts)
