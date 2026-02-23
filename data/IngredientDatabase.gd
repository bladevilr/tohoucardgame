extends Node

var ingredients: Dictionary = {}

const STAT_TEXT := {
	"flavor": "美味度",
	"presentation": "卖相",
	"technique": "技法",
}

const CUISINE_TEXT := {
	"washoku": "和食",
	"chuuka": "中华",
	"youshoku": "洋食",
	"yatai": "夜市",
	"kanmi": "甜品",
	"yakuzen": "药膳",
}

const TAG_TEXT := {
	"rich": "浓郁",
	"spicy": "辛辣",
	"umami_tag": "鲜味",
	"light": "清淡",
	"sweet": "甜味",
	"sour": "酸味",
	"fermented": "发酵",
	"medicinal": "药用",
	"rare": "稀有",
	"numbing": "麻味",
	"egg": "蛋类",
	"divine": "神圣",
	"grilled": "烧烤",
	"greasy": "油腻",
}

const SPECIAL_EFFECT_TEXT := {
	"appetize_right_20": "右侧相邻菜品上菜时额外+20美味度",
	"clear_greasy_1": "开场清除1层油腻",
	"score_right_raw_30": "右侧生食菜品上菜时额外+30美味度",
	"fermented_growth_boost": "发酵类效果成长速度提升",
	"umami_on_3rd_activate": "每第3次上菜时额外获得1层提味",
	"dessert_zone_bonus": "甜品区菜品获得额外加成",
	"addiction_double_stack": "与上瘾类效果联动时叠层翻倍",
	"add_env_greasy_2": "首次上菜时给环境增加2层油腻",
	"first_activate_bonus_50": "首次上菜额外+50美味度",
	"clear_all_env_1": "开场各清除1层环境减益",
	"sizzle_threshold_minus_1": "爆香类爆发阈值-1",
	"all_scores_mult_1_5": "该菜品最终得分×1.5",
	"grant_secret_recipe": "开场获得1层秘方",
	"refreshing_full_clear": "开场清除全部沉闷与疲劳",
	"double_next_activate": "首次上菜美味度倍率翻倍",
	"grant_umami_3": "开场获得3层提味",
}

func _ready():
	_init_ingredients()

func can_apply_to(ingredient: Dictionary, dish: Dictionary) -> bool:
	var dish_tags: Array = dish.get("tags", [])
	for req in ingredient.get("requires_tags", []):
		if req not in dish_tags:
			return false
	for forbid in ingredient.get("forbidden_tags", []):
		if forbid in dish_tags:
			return false
	# 标签冲突：fried + steamed 互斥
	var added: Array = ingredient.get("added_tags", [])
	if "fried" in added and "steamed" in dish_tags:
		return false
	if "steamed" in added and "fried" in dish_tags:
		return false
	return true

func get_ingredient(id: String) -> Dictionary:
	return ingredients.get(id, {})

func get_all() -> Array:
	return ingredients.values()

func get_by_tier(tier: int) -> Array:
	var result: Array = []
	for t in ingredients.values():
		if int(t.tier) == tier:
			result.append(t)
	return result

func _add(id: String, display_name: String, tier: int, cost: int, stats: Dictionary, tags_mod: Dictionary, special_effect: String, cuisine: String):
	ingredients[id] = {
		"id": id,
		"name": display_name,
		"tier": tier,
		"cost": cost,
		"item_type": "ingredient",
		"stat_modifiers": stats,
		"added_tags": tags_mod.get("add", []),
		"removed_tags": tags_mod.get("remove", []),
		"requires_tags": tags_mod.get("require", []),
		"forbidden_tags": tags_mod.get("forbid", []),
		"special_effect": special_effect,
		"cuisine_affinity": cuisine,
		"affinity_bonus": 1.5,
		"description": _build_desc(stats, tags_mod, special_effect, cuisine)
	}

func _build_desc(stats: Dictionary, tags: Dictionary, effect: String, cuisine: String) -> String:
	var segments: Array[String] = []
	var stat_parts: Array[String] = []
	for key in ["flavor", "presentation", "technique"]:
		if not stats.has(key):
			continue
		var delta: float = float(stats.get(key, 0.0))
		if absf(delta) <= 0.001:
			continue
		var name: String = STAT_TEXT.get(key, key)
		if absf(delta - roundf(delta)) <= 0.001:
			stat_parts.append("%s%+d" % [name, int(roundf(delta))])
		else:
			stat_parts.append("%s%+.1f" % [name, delta])
	if not stat_parts.is_empty():
		segments.append("属性：" + "、".join(stat_parts))

	var add_tags: Array = tags.get("add", [])
	if not add_tags.is_empty():
		var names: Array[String] = []
		for tag in add_tags:
			names.append(_translate_tag(str(tag)))
		segments.append("附加标签：" + "、".join(names))

	var remove_tags: Array = tags.get("remove", [])
	if not remove_tags.is_empty():
		var names: Array[String] = []
		for tag in remove_tags:
			names.append(_translate_tag(str(tag)))
		segments.append("移除标签：" + "、".join(names))

	var require_tags: Array = tags.get("require", [])
	if not require_tags.is_empty():
		var names: Array[String] = []
		for tag in require_tags:
			names.append(_translate_tag(str(tag)))
		segments.append("使用条件：目标需包含" + "、".join(names))

	var forbid_tags: Array = tags.get("forbid", [])
	if not forbid_tags.is_empty():
		var names: Array[String] = []
		for tag in forbid_tags:
			names.append(_translate_tag(str(tag)))
		segments.append("禁用条件：目标不能包含" + "、".join(names))

	if cuisine != "" and cuisine != "无":
		var cuisine_name: String = CUISINE_TEXT.get(cuisine, cuisine)
		segments.append("菜系亲和：%s（数值×1.5）" % cuisine_name)

	if effect != "":
		segments.append("特效：" + SPECIAL_EFFECT_TEXT.get(effect, "触发特殊效果"))

	if segments.is_empty():
		return "可用于菜品附魔"
	return "；".join(segments)

func _translate_tag(tag: String) -> String:
	return TAG_TEXT.get(tag, tag)

func _init_ingredients():
	# ============================================================
	# Tier 0 (基础调味) — flavor+1, 只加1个标签
	# ============================================================
	_add("butter", "发酵黄油", 0, 1, {"flavor": 1}, {"add": ["rich"], "require": ["light"]}, "", "youshoku")
	_add("chili_flakes", "辣椒碎", 0, 1, {"flavor": 1}, {"add": ["spicy"]}, "", "")
	_add("garlic", "极品大蒜", 0, 1, {"flavor": 1}, {"add": ["umami_tag"]}, "", "")
	_add("green_onion", "九条葱", 0, 1, {"flavor": 1}, {"add": ["light"]}, "", "washoku")
	_add("mirin", "味醂", 0, 1, {"flavor": 1}, {"add": ["light"]}, "", "washoku")
	_add("salt", "博丽盐", 0, 1, {"flavor": 1}, {"add": ["umami_tag"]}, "", "")
	_add("sesame_oil", "麻油", 0, 1, {"flavor": 1}, {"add": ["rich"]}, "", "chuuka")
	_add("soy_sauce", "酱油", 0, 1, {"flavor": 1}, {"add": ["umami_tag"]}, "", "chuuka")
	_add("sugar", "和三盆糖", 0, 1, {"flavor": 1}, {"add": ["sweet"]}, "", "kanmi")
	_add("vinegar", "黑醋", 0, 1, {"flavor": 1}, {"add": ["sour"]}, "", "chuuka")

	# ============================================================
	# Tier 1 (优质食材) — flavor+2, 加1~2个标签 + 简单行为
	# ============================================================
	_add("bonito_flakes", "鰹節", 1, 2, {"flavor": 2}, {"add": ["umami_tag", "fermented"]}, "", "washoku")
	_add("chili_oil", "红油", 1, 2, {"flavor": 2}, {"add": ["spicy", "rich"]}, "appetize_right_20", "chuuka")
	_add("cream", "生奶油", 1, 2, {"flavor": 2}, {"add": ["rich", "sweet"]}, "", "youshoku")
	_add("dashi_kombu", "利尻昆布", 1, 2, {"flavor": 2}, {"add": ["umami_tag"]}, "", "washoku")
	_add("ginger", "老姜", 1, 2, {"flavor": 2}, {"remove": ["greasy"]}, "clear_greasy_1", "")
	_add("herb_mix", "普罗旺斯香草", 1, 2, {"flavor": 2}, {"add": ["light"]}, "", "youshoku")
	_add("medicinal_herb", "灵芝", 1, 2, {"flavor": 2}, {"add": ["medicinal"]}, "", "yakuzen")
	_add("miso_paste", "八丁味噌", 1, 2, {"flavor": 2}, {"add": ["fermented", "umami_tag", "rich"]}, "", "washoku")
	_add("saffron", "番红花", 1, 2, {"flavor": 2}, {"add": ["rare"]}, "", "youshoku")
	_add("sichuan_pepper", "花椒", 1, 2, {"flavor": 2}, {"add": ["spicy", "numbing"]}, "", "chuuka")
	_add("truffle_oil", "松露油", 1, 2, {"flavor": 2}, {"add": ["rich", "umami_tag"]}, "", "youshoku")
	_add("wasabi", "本山葵", 1, 2, {"flavor": 2}, {"add": ["spicy"]}, "score_right_raw_30", "washoku")

	# ============================================================
	# Tier 2 (稀有食材) — flavor+2, 加标签 + 强力行为
	# ============================================================
	_add("aged_sake", "百年古酒", 2, 2, {"flavor": 2}, {"add": ["fermented", "rich"]}, "fermented_growth_boost", "washoku")
	_add("black_truffle", "黑松露", 2, 2, {"flavor": 2}, {"add": ["rich", "rare", "umami_tag"]}, "umami_on_3rd_activate", "youshoku")
	_add("celestial_peach", "天人之桃", 2, 2, {"flavor": 2}, {"add": ["sweet", "rare"]}, "dessert_zone_bonus", "kanmi")
	_add("dragon_liver", "龙肝", 2, 2, {"flavor": 2}, {"add": ["rich", "rare"]}, "addiction_double_stack", "")
	_add("ghost_pepper", "灵界辣椒", 2, 2, {"flavor": 2}, {"add": ["spicy", "rare"]}, "add_env_greasy_2", "")
	_add("golden_egg", "凤凰卵", 2, 2, {"flavor": 2}, {"add": ["egg", "rare"]}, "first_activate_bonus_50", "")
	_add("moonlight_salt", "月光盐", 2, 2, {"flavor": 2}, {}, "clear_all_env_1", "")
	_add("youkai_mushroom", "妖怪茸", 2, 2, {"flavor": 2}, {"add": ["medicinal", "rare"]}, "sizzle_threshold_minus_1", "yakuzen")

	# ============================================================
	# Tier 3 (传说食材) — flavor+3, 独特行为（改变卡牌运作方式）
	# ============================================================
	_add("ambrosia", "神馔", 3, 2, {"flavor": 3}, {"add": ["rare", "divine"]}, "all_scores_mult_1_5", "")
	_add("hourai_elixir", "蓬莱之药", 3, 2, {"flavor": 3}, {"add": ["medicinal", "rare", "divine"]}, "grant_secret_recipe", "yakuzen")
	_add("lunar_dew", "月露", 3, 2, {"flavor": 3}, {"add": ["rare", "light", "divine"]}, "refreshing_full_clear", "")
	_add("void_essence", "虚空精华", 3, 2, {"flavor": 3}, {"add": ["rare"]}, "double_next_activate", "")
	_add("yatagarasu_flame", "八咫鸦之炎", 3, 2, {"flavor": 3}, {"add": ["spicy", "rare", "grilled"], "remove": ["light"]}, "grant_umami_3", "yatai")
