extends "res://ai/AIStrategy.gd"
## AIEconomic - 存钱后期爆发
func _init() -> void:
	super._init("economic", ["atk", "spi"])

var save_until_round := 5

func evaluate_item(item: Dictionary, player: RefCounted, round_number: int) -> float:
	# 前期只买便宜货
	if round_number < save_until_round:
		var cost: int = item.get("cost", 999)
		if cost > 3:
			return 0.0
	var base := super.evaluate_item(item, player, round_number)
	# 后期偏好高档料理
	if round_number >= save_until_round:
		var tier: String = item.get("tier", "")
		if tier == "feast":
			base += 20.0
		elif tier == "meal":
			base += 10.0
	return base

func should_refresh(player: RefCounted, round_number: int) -> bool:
	if round_number < save_until_round:
		return false
	return player.gold > 10
