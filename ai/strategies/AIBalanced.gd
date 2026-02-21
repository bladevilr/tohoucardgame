extends "res://ai/AIStrategy.gd"
## AIBalanced - 均衡策略
func _init() -> void:
	super._init("balanced", ["atk", "def", "spd", "spi"])

func evaluate_item(item: Dictionary, player: RefCounted, round_number: int) -> float:
	var base := super.evaluate_item(item, player, round_number)
	# 补短板加分：属性最低的维度额外加权
	var stats: Dictionary = item.get("stats", {})
	var min_stat := "atk"
	var min_val := 999
	for key in GameConfig.STAT_KEYS:
		if player.total_stats.get(key, 0) < min_val:
			min_val = player.total_stats.get(key, 0)
			min_stat = key
	base += float(stats.get(min_stat, 0)) * 5.0
	return base
