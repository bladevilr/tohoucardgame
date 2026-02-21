extends RefCounted

## AIStrategy - AI策略基类

var strategy_name: String = "base"
var priority_stats: Array = []  # 优先购买的属性方向


func _init(name: String = "base", priorities: Array = []) -> void:
	strategy_name = name
	priority_stats = priorities


## 评估商品对该策略的价值（0-100分）
func evaluate_item(item: Dictionary, player: RefCounted, _round_number: int) -> float:
	if item.is_empty():
		return 0.0

	var score := 0.0
	var stats: Dictionary = item.get("stats", {})

	# 基础：按优先属性加分
	for i in range(priority_stats.size()):
		var key: String = priority_stats[i]
		var stat_val := float(stats.get(key, 0))
		var weight := 10.0 - i * 2.0  # 第一优先10分，第二8分...
		score += stat_val * weight

	# 品质加分
	var quality: int = item.get("quality", 0)
	score += quality * 5.0

	# 特效加分
	var effects: Array = item.get("effects", [])
	score += effects.size() * 8.0

	# 性价比
	var cost: int = item.get("cost", 1)
	if cost > 0:
		score = score / float(cost) * 3.0

	return score


## 决定是否购买（返回商品索引，-1表示不买）
func decide_purchase(shop: Array, player: RefCounted, round_number: int) -> int:
	var best_idx := -1
	var best_score := 5.0  # 最低购买阈值

	for i in range(shop.size()):
		var item: Dictionary = shop[i]
		if item.is_empty():
			continue
		var cost: int = item.get("cost", 999)
		if cost > player.gold:
			continue

		var score := evaluate_item(item, player, round_number)
		if score > best_score:
			best_score = score
			best_idx = i

	return best_idx


## 决定是否刷新商店
func should_refresh(player: RefCounted, round_number: int) -> bool:
	# 基础策略：金币>8且回合>=3时考虑刷新
	return player.gold > 8 and round_number >= 3
