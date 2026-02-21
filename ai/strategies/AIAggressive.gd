extends "res://ai/AIStrategy.gd"
## AIAggressive - 力量流
func _init() -> void:
	super._init("aggressive", ["atk", "spd"])

func evaluate_item(item: Dictionary, player: RefCounted, round_number: int) -> float:
	var base := super.evaluate_item(item, player, round_number)
	var stats: Dictionary = item.get("stats", {})
	base += float(stats.get("atk", 0)) * 8.0
	# 追求ATK阈值
	var current_atk: int = player.total_stats.get("atk", 0)
	var item_atk: int = int(stats.get("atk", 0))
	for t in GameConfig.THRESHOLDS:
		if current_atk < t and current_atk + item_atk >= t:
			base += 20.0
	return base
