extends Node

# Keyword data: id -> {name, type, description, per_stack_effect}
var keywords: Dictionary = {}
func _ready():
	_init_keywords()

func _init_keywords():
	# === Score-Attack Engine Keywords (8 Core) ===

	_add("appetizing", "开胃", "mechanic",
		"酸辣的开胃前菜，让人胃口大开。激活时推进相邻菜品当前CD的15%，前菜区效果额外+50%。",
		{})

	_add("addictive", "上瘾", "mechanic",
		"重口味道让人越吃越上头。每次激活叠加2层上瘾，每层每秒产出1.5分。每5秒自然衰减10%层数。",
		{})

	_add("umami", "鲜美", "mechanic",
		"谷氨酸的魔力，让周围的一切都更好吃。同菜系≥2道时，标记右侧邻居下次激活得分×1.8。",
		{})

	_add("sizzling", "爆香", "mechanic",
		"猛火蓄热，一口气爆发出惊人锅气。烤/炒标签菜激活时积累热量，满4次后爆发，得分×3.0。",
		{})

	_add("crisp", "爽脆", "mechanic",
		"咔嚓咔嚓停不下来。油炸标签菜有25%概率双重激活，第2次得分衰减至70%。",
		{})

	_add("refreshing", "清口", "mechanic",
		"一口清茶，满血复活。清除当前油腻层数的50%，每清1层获得3分并全场CD加速0.3秒。",
		{})

	_add("greasy", "油腻", "mechanic",
		"好吃但太油，越吃越慢。同时拥有浓郁+油炸标签时叠加油腻，每层减慢全场CD 8%，最多20层。",
		{})

	_add("fermented", "发酵", "mechanic",
		"时间带来的深邃味道，越陈越香。首次激活得分×1.3，之后每次激活永久+1%（上限+30%）。",
		{})

	# === Culinary Tags (For Cookware / Synergies) ===
	_add("meat", "肉类", "tag", "肉类食材标签。", {})
	_add("seafood", "海鲜", "tag", "海鲜食材标签。", {})
	_add("vegetable", "素菜", "tag", "素菜食材标签。", {})
	_add("staple", "主食", "tag", "主食标签。", {})
	_add("sweet", "甜点", "tag", "甜食标签。", {})
	
	_add("grilled", "烤制", "tag", "高温烤制。", {})
	_add("fried", "炸制", "tag", "油炸制作。", {})
	_add("steamed", "蒸煮", "tag", "水流软化。", {})
	_add("raw", "生食", "tag", "原始风味。", {})

func _add(id: String, display_name: String, type: String, desc: String, effect: Dictionary):
	keywords[id] = {
		"id": id,
		"name": display_name,
		"type": type,
		"description": desc,
		"effect": effect
	}

func get_keyword(id: String) -> Dictionary:
	return keywords.get(id, {})

func get_keywords_by_type(type: String) -> Array:
	var result: Array = []
	for kw in keywords.values():
		if kw.type == type:
			result.append(kw)
	return result

func get_all() -> Array:
	return keywords.values()
