extends PanelContainer

## ShopPanel - 商店面板

signal item_clicked(shop_index: int)
signal refresh_clicked()

var shop_items: Array = []
var item_buttons: Array = []


func _ready() -> void:
	SignalBus.shop_refreshed.connect(_on_shop_refreshed)


func display_shop(items: Array) -> void:
	shop_items = items
	_rebuild_ui()


func _rebuild_ui() -> void:
	# 清除旧按钮
	for btn in item_buttons:
		if is_instance_valid(btn):
			btn.queue_free()
	item_buttons.clear()

	var container := get_node_or_null("VBox/ItemsHBox")
	if container == null:
		return

	for i in range(shop_items.size()):
		var item: Dictionary = shop_items[i]
		if item.is_empty():
			continue

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(180, 120)

		var name_str: String = item.get("name", "???")
		var cost: int = item.get("cost", 0)
		var quality: int = item.get("quality", 0)
		var q_name: String = GameConfig.QUALITY_NAME.get(quality, "普通")
		var tier: String = item.get("tier", "")

		var stats: Dictionary = item.get("stats", {})
		var stat_text := ""
		for key in GameConfig.STAT_KEYS:
			var val: int = int(stats.get(key, 0))
			if val > 0:
				stat_text += "%s%d " % [GameConfig.STAT_ICONS.get(key, key), val]

		btn.text = "[%s] %s\n%s\n%s金" % [q_name, name_str, stat_text.strip_edges(), cost]
		btn.tooltip_text = _build_tooltip(item)

		var idx := i
		btn.pressed.connect(func(): item_clicked.emit(idx))

		# 品质颜色
		var q_color: Color = GameConfig.QUALITY_COLOR.get(quality, Color.WHITE)
		btn.add_theme_color_override("font_color", q_color)

		container.add_child(btn)
		item_buttons.append(btn)


func _build_tooltip(item: Dictionary) -> String:
	var text: String = item.get("name", "???")
	var effects: Array = item.get("effects", [])
	for eff_id in effects:
		text += "\n· " + KeywordDatabase.get_keyword(eff_id).get("description", str(eff_id))
	return text


func _on_shop_refreshed(_player_index: int) -> void:
	pass  # GameBoard will call display_shop
