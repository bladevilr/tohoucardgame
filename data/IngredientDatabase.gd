extends Node

var ingredients: Dictionary = {}

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
	var d = ""
	for k in stats:
		d += "%s+%s " % [k.capitalize(), stats[k]]
	if cuisine != "" and cuisine != "无":
		d += " | 对%s亲和" % cuisine
	return d

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
	_add("yatagarasu_flame", "八咫鸦之炎", 3, 2, {"flavor": 3}, {"add": ["spicy", "rare", "grilled"], "remove": ["light"]}, "grant_char_aroma_3", "yatai")
