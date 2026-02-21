extends "res://ai/AIStrategy.gd"
## AIDefensive - 韧性流
func _init() -> void:
	super._init("defensive", ["def", "spi"])

func evaluate_item(item: Dictionary, player: RefCounted, round_number: int) -> float:
	var base := super.evaluate_item(item, player, round_number)
	var stats: Dictionary = item.get("stats", {})
	base += float(stats.get("def", 0)) * 8.0
	var effects: Array = item.get("effects", [])
	if "hitstun_resist_20" in effects or "high_hp_guard" in effects:
		base += 15.0
	if "kill_heal_8_percent" in effects or "phoenix_regen" in effects:
		base += 12.0
	return base
