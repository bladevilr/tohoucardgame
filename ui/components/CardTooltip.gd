extends PanelContainer

## CardTooltip - 悬停提示

@onready var title_label: Label = $VBox/TitleLabel
@onready var stats_label: Label = $VBox/StatsLabel
@onready var effects_label: Label = $VBox/EffectsLabel
@onready var tier_label: Label = $VBox/TierLabel


func _ready() -> void:
	visible = false
	SignalBus.tooltip_show.connect(_on_show)
	SignalBus.tooltip_hide.connect(_on_hide)


func _on_show(data: Dictionary, pos: Vector2) -> void:
	var dish_id: String = data.get("dish_id", "")
	if dish_id.is_empty():
		return

	title_label.text = DishDatabase.get_dish(dish_id).get("name", dish_id)
	var stats: Dictionary = DishDatabase.get_dish(dish_id).get("base_stats", {})
	var stat_text := ""
	for key in GameConfig.STAT_KEYS:
		var val: int = int(stats.get(key, 0))
		if val > 0:
			stat_text += "%s %s: +%d  " % [GameConfig.STAT_ICONS.get(key, ""), GameConfig.STAT_NAMES.get(key, key), val]
	stats_label.text = stat_text

	var effects: Array = DishDatabase.get_dish(dish_id).get("effects", [])
	var eff_text := ""
	for eff_id in effects:
		eff_text += "· %s\n" % KeywordDatabase.get_keyword(eff_id).get("description", eff_id)
	effects_label.text = eff_text if not eff_text.is_empty() else "无特殊效果"

	tier_label.text = "档次: %s" % str(DishDatabase.get_dish(dish_id).get("tier", ""))

	global_position = pos
	visible = true


func _on_hide() -> void:
	visible = false
