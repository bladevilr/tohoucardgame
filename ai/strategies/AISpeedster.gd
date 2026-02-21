extends "res://ai/AIStrategy.gd"
## AISpeedster - 速度流
func _init() -> void:
	super._init("speedster", ["spd", "atk"])

func evaluate_item(item: Dictionary, player: RefCounted, round_number: int) -> float:
	var base := super.evaluate_item(item, player, round_number)
	var stats: Dictionary = item.get("stats", {})
	base += float(stats.get("spd", 0)) * 8.0
	var effects: Array = item.get("effects", [])
	if "afterimage_step" in effects or "dash_bonus_100" in effects or "dash_distance_15" in effects:
		base += 15.0
	return base
