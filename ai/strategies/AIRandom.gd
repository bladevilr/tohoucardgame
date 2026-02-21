extends "res://ai/AIStrategy.gd"
## AIRandom - 随机购买（最弱AI）
func _init() -> void:
	super._init("random", ["atk", "def", "spd", "spi"])

func evaluate_item(item: Dictionary, _player: RefCounted, _round_number: int) -> float:
	if item.is_empty():
		return 0.0
	return randf_range(3.0, 15.0)

func should_refresh(_player: RefCounted, _round_number: int) -> bool:
	return randf() < 0.2
