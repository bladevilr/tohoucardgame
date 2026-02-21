extends Node

# Keyword data: id -> {name, type, description, per_stack_effect}
var keywords: Dictionary = {}
func _ready():
	_init_keywords()

func _init_keywords():
	# === Score-Attack Engine Keywords (8 Core) ===
	
	_add("appetizing", "开胃", "mechanic",
		"酸辣的开胃前菜，让人等不及想吃下一道。触发时，使相邻菜品的冷却时间立即减少。",
		{}) # Handled by TriggerSystem/Resolver
	
	_add("addictive", "上瘾", "mechanic",
		"重口的味道让人越吃越想吃，停不下来。给评委施加【上瘾】层数，每秒按总层数自动产生分数，永不衰减。",
		{}) # Global Ticker
	
	_add("umami", "提鲜", "mechanic",
		"本身不提供分数，但能把味道放大数倍。触发时，将评委身上的【上瘾】层数或下一次得分翻倍。",
		{}) # Handled by Resolver
		
	_add("sizzling", "爆香", "mechanic",
		"猛火爆炒积累热量，一口气爆发出惊人的香气。触发时不计分，而是积累热量层数，到达阈值时产生计分大爆炸。",
		{}) # Handled by Resolver
		
	_add("crisp", "爽脆", "mechanic",
		"咔嚓咔嚓吃紧不费力。自身基础冷却极短，且有概率连击（双口并作一口）。",
		{}) # Base CD reduction & Chance to multicast
		
	_add("refreshing", "清口", "mechanic",
		"吃腻了喝口绿茶，满血复活。触发时，清除评委的【油腻】层数，并转化为额外得分与全场加速。",
		{}) # Trigger System
		
	_add("greasy", "顶饱", "mechanic",
		"好吃但热量高，吃几口就塞不下了。激活时赋予评委【油腻】，使全场菜品冷却延长。",
		{}) # Debuff
		
	_add("fermented", "发酵", "mechanic",
		"时间带来的深邃味道，越陈越香。经历一次对决后，基础得分永久提升。",
		{}) # Meta-progression

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
