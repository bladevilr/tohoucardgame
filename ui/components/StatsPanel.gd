extends PanelContainer

## StatsPanel - 四维属性条 + 阈值指示

var stat_bars: Dictionary = {}
var stat_labels: Dictionary = {}
var threshold_labels: Dictionary = {}


func update_stats(player: RefCounted) -> void:
	if player == null:
		return

	var container := get_node_or_null("VBox")
	if container == null:
		return

	# 首次创建
	if stat_bars.is_empty():
		_create_stat_rows(container)

	for key in GameConfig.STAT_KEYS:
		var val: int = player.total_stats.get(key, 0)
		var bar: ProgressBar = stat_bars.get(key)
		var label: Label = stat_labels.get(key)

		if bar:
			bar.value = val
		if label:
			label.text = "%s %s: %d" % [GameConfig.STAT_ICONS.get(key, ""), GameConfig.STAT_NAMES.get(key, key), val]

		# 阈值指示
		var th_label: Label = threshold_labels.get(key)
		if th_label:
			var th_text := ""
			for threshold in GameConfig.THRESHOLDS:
				if player.has_threshold(key, threshold):
					var th_name: String = GameConfig.THRESHOLD_NAMES.get(key, {}).get(threshold, "")
					th_text += " [%s]" % th_name
			th_label.text = th_text


func _create_stat_rows(container: VBoxContainer) -> void:
	for key in GameConfig.STAT_KEYS:
		var hbox := HBoxContainer.new()
		hbox.custom_minimum_size.y = 28

		var label := Label.new()
		label.custom_minimum_size.x = 80
		label.text = "%s %s: 0" % [GameConfig.STAT_ICONS.get(key, ""), GameConfig.STAT_NAMES.get(key, key)]
		var color: Color = GameConfig.STAT_COLORS.get(key, Color.WHITE)
		label.add_theme_color_override("font_color", color)
		stat_labels[key] = label

		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(160, 20)
		bar.max_value = GameConfig.HARD_CAP
		bar.value = 0
		bar.show_percentage = false
		stat_bars[key] = bar

		var th_label := Label.new()
		th_label.custom_minimum_size.x = 200
		th_label.add_theme_font_size_override("font_size", 14)
		th_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		threshold_labels[key] = th_label

		hbox.add_child(label)
		hbox.add_child(bar)
		hbox.add_child(th_label)
		container.add_child(hbox)
