extends "res://ai/AIStrategy.gd"
## AISpiritRush - 灵力流
func _init() -> void:
	super._init("spirit_rush", ["spi", "def"])

func evaluate_item(item: Dictionary, player: RefCounted, round_number: int) -> float:
	var base := super.evaluate_item(item, player, round_number)
	var stats: Dictionary = item.get("stats", {})
	base += float(stats.get("spi", 0)) * 8.0
	var effects: Array = item.get("effects", [])
	if "spirit_charge_bonus" in effects or "spirit_pulse" in effects or "tracking_bullets" in effects:
		base += 15.0
	if "drink_focus" in effects:
		base += 10.0
	return base
