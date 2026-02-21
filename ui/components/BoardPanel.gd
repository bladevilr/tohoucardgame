extends PanelContainer

## BoardPanel - 3个Buff槽 + 1饮品槽

signal slot_clicked(slot_index: int)
signal drink_clicked()
signal slot_sell_requested(slot_index: int)
signal drink_sell_requested()

var slot_buttons: Array = []
var drink_button: Button


func _ready() -> void:
	SignalBus.stats_changed.connect(_on_stats_changed)


func update_board(player: RefCounted) -> void:
	if player == null:
		return
	_update_slots(player)
	_update_drink(player)


func _update_slots(player: RefCounted) -> void:
	var container := get_node_or_null("VBox/SlotsHBox")
	if container == null:
		return

	# 清除旧的
	for child in container.get_children():
		child.queue_free()
	slot_buttons.clear()

	for i in range(GameConfig.BUFF_SLOT_COUNT):
		var slot: Dictionary = player.buff_slots[i]
		var dish_id: String = slot.get("dish_id", "")
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(200, 100)

		if dish_id.is_empty():
			btn.text = "[空槽 %d]" % (i + 1)
			btn.modulate = Color(0.5, 0.5, 0.5)
		else:
			var name_str: String = DishDatabase.get_dish(dish_id).get("name", dish_id)
			var stats: Dictionary = slot.get("stats", {})
			var stat_text := ""
			for key in GameConfig.STAT_KEYS:
				var val: int = int(stats.get(key, 0))
				if val > 0:
					stat_text += "%s%d " % [GameConfig.STAT_ICONS.get(key, key), val]
			btn.text = "%s\n%s" % [name_str, stat_text.strip_edges()]

			# 主属性颜色
			var profile: Dictionary = DishDatabase.get_dish(dish_id)
			var main_stat: String = profile.get("main_stat", "")
			var color: Color = GameConfig.STAT_COLORS.get(main_stat, Color.WHITE)
			btn.add_theme_color_override("font_color", color)

		var idx := i
		btn.pressed.connect(func(): slot_clicked.emit(idx))
		container.add_child(btn)
		slot_buttons.append(btn)


func _update_drink(player: RefCounted) -> void:
	var container := get_node_or_null("VBox/DrinkHBox")
	if container == null:
		return

	# 清除旧的
	for child in container.get_children():
		child.queue_free()

	var drink: Dictionary = player.drink_slot
	var drink_id: String = drink.get("dish_id", "")

	drink_button = Button.new()
	drink_button.custom_minimum_size = Vector2(200, 60)

	if drink_id.is_empty():
		drink_button.text = "[饮品槽 - 空]"
		drink_button.modulate = Color(0.5, 0.5, 0.5)
	else:
		var name_str: String = DishDatabase.get_dish(drink_id).get("name", drink_id)
		drink_button.text = "饮品: %s" % name_str
		drink_button.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))

	drink_button.pressed.connect(func(): drink_clicked.emit())
	container.add_child(drink_button)


func _on_stats_changed(player_index: int, _stats: Dictionary) -> void:
	if player_index != 0:
		return
	# 由 GameBoard 调用 update_board 刷新
