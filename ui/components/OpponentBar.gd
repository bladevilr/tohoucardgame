extends PanelContainer

## OpponentBar - 底部：8人体力状态条

var player_entries: Array = []


func update_opponents(players: Array, current_round: int) -> void:
	var container := get_node_or_null("HBox")
	if container == null:
		return

	# 清除旧的
	for child in container.get_children():
		child.queue_free()
	player_entries.clear()

	for p in players:
		var vbox := VBoxContainer.new()
		vbox.custom_minimum_size = Vector2(120, 60)
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label := Label.new()
		name_label.text = p.player_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if p.is_human:
			name_label.add_theme_color_override("font_color", GameConfig.COLOR_GOLD)
		elif not p.is_alive():
			name_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		name_label.add_theme_font_size_override("font_size", 14)

		var hp_bar := ProgressBar.new()
		hp_bar.max_value = GameConfig.STARTING_HP
		hp_bar.value = p.hp
		hp_bar.custom_minimum_size.y = 16
		hp_bar.show_percentage = false

		var hp_label := Label.new()
		hp_label.text = "体力 %d" % p.hp if p.is_alive() else "淘汰 #%d" % p.placement
		hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hp_label.add_theme_font_size_override("font_size", 12)

		vbox.add_child(name_label)
		vbox.add_child(hp_bar)
		vbox.add_child(hp_label)
		container.add_child(vbox)
		player_entries.append(vbox)
