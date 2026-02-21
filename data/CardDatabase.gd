extends Node

## CardDatabase - 料理/菜品数据库（移植自 CookingDatabase）

# 料理名称（中文显示用）
const DISH_NAMES := {
	"rice_ball": "饭团",
	"grilled_fish": "烤鱼",
	"miso_soup": "味噌汤",
	"bamboo_rice": "竹笋饭",
	"mushroom_stew": "蘑菇炖菜",
	"dango": "团子",
	"senbei": "仙贝",
	"tempura": "天妇罗",
	"green_tea": "绿茶",
	"eel_rice": "鳗鱼饭",
	"herb_salad": "草药沙拉",
	"grilled_bamboo_shoot": "烤竹笋",
	"spicy_stir_meat": "辣炒肉",
	"pumpkin_congee": "南瓜粥",
	"moon_herb_dango": "月见草团子",
	"honey_skewer": "蜂蜜烤串",
	"phoenix_roast_chicken": "凤凰烤鸡",
	"reishi_stew": "灵芝炖汤",
	"bamboo_cold_noodles": "竹林冷面",
	"moon_reishi_boil": "月见灵茸煮",
	"fairy_meat_pie": "妖精肉饼",
	"ginseng_chicken_soup": "人参鸡汤",
	"spicy_beast_skewer": "辣味兽肉串",
	"moon_herb_soup": "月见草汤",
	"pufferfish_sashimi": "河豚刺身",
	"mokou_yakitori": "妹红烤鸡",
	"moon_viewing_dango": "月见团子",
	"phoenix_hotpot": "蓬莱火锅",
	"hourai_hotpot": "蓬莱火锅·极",
	"eternal_night_banquet": "永夜宴",
	"mokou_full_course": "妹红特制全席",
	"kaguya_elixir_feast": "辉夜秘药膳",
	"bamboo_taketori_feast": "竹取盛宴",
	"reishi_tea": "灵芝茶",
	"bamboo_leaf_wine": "竹叶酒",
	"moon_herb_dew": "月见草露",
	"impatiens_tea": "凤仙花茶",
	"ginseng_tonic": "人参汤",
	"chili_shochu": "辣椒烧酒",
	"phantom_koi_broth": "幻想鲤鱼汤",
}

# 料理战斗档案（完整移植自 CookingDatabase.DISH_COMBAT_PROFILES）
const DISH_COMBAT_PROFILES: Dictionary = {
	"rice_ball": {
		"stats": {"atk": 0, "def": 1, "spd": 1, "spi": 0},
		"main_stat": "spd",
		"tier": "snack",
		"special_effects": [],
	},
	"grilled_fish": {
		"stats": {"atk": 1, "def": 1, "spd": 0, "spi": 0},
		"main_stat": "atk",
		"tier": "snack",
		"special_effects": ["regen_1"],
	},
	"miso_soup": {
		"stats": {"atk": 0, "def": 2, "spd": 0, "spi": 1},
		"main_stat": "def",
		"tier": "meal",
		"special_effects": [],
	},
	"bamboo_rice": {
		"stats": {"atk": 0, "def": 1, "spd": 3, "spi": 0},
		"main_stat": "spd",
		"tier": "meal",
		"special_effects": [],
	},
	"mushroom_stew": {
		"stats": {"atk": 0, "def": 2, "spd": 0, "spi": 2},
		"main_stat": "spi",
		"tier": "meal",
		"special_effects": [],
	},
	"dango": {
		"stats": {"atk": 0, "def": 0, "spd": 1, "spi": 1},
		"main_stat": "spi",
		"tier": "snack",
		"special_effects": [],
	},
	"senbei": {
		"stats": {"atk": 1, "def": 0, "spd": 1, "spi": 0},
		"main_stat": "atk",
		"tier": "snack",
		"special_effects": [],
	},
	"tempura": {
		"stats": {"atk": 3, "def": 0, "spd": 1, "spi": 0},
		"main_stat": "atk",
		"tier": "meal",
		"special_effects": [],
	},
	"green_tea": {
		"stats": {"atk": 0, "def": 0, "spd": 0, "spi": 1},
		"main_stat": "spi",
		"tier": "drink",
		"special_effects": ["drink_focus"],
		"drink_effects": [],
	},
	"eel_rice": {
		"stats": {"atk": 3, "def": 1, "spd": 1, "spi": 0},
		"main_stat": "atk",
		"tier": "meal",
		"special_effects": [],
	},
	"herb_salad": {
		"stats": {"atk": 0, "def": 1, "spd": 1, "spi": 2},
		"main_stat": "spi",
		"tier": "meal",
		"special_effects": [],
	},
	"grilled_bamboo_shoot": {
		"stats": {"atk": 0, "def": 1, "spd": 3, "spi": 0},
		"main_stat": "spd",
		"tier": "snack",
		"special_effects": ["dash_distance_15"],
	},
	"spicy_stir_meat": {
		"stats": {"atk": 4, "def": 1, "spd": 0, "spi": 0},
		"main_stat": "atk",
		"tier": "snack",
		"special_effects": ["light_shockwave"],
	},
	"pumpkin_congee": {
		"stats": {"atk": 0, "def": 3, "spd": 0, "spi": 0},
		"main_stat": "def",
		"tier": "snack",
		"special_effects": ["hitstun_resist_20"],
	},
	"moon_herb_dango": {
		"stats": {"atk": 0, "def": 0, "spd": 1, "spi": 3},
		"main_stat": "spi",
		"tier": "snack",
		"special_effects": ["spirit_charge_bonus"],
	},
	"honey_skewer": {
		"stats": {"atk": 2, "def": 1, "spd": 0, "spi": 0},
		"main_stat": "atk",
		"tier": "snack",
		"special_effects": ["kill_heal_3_percent"],
	},
	"phoenix_roast_chicken": {
		"stats": {"atk": 5, "def": 0, "spd": 2, "spi": 1},
		"main_stat": "atk",
		"tier": "meal",
		"special_effects": ["combo_damage_up"],
	},
	"reishi_stew": {
		"stats": {"atk": 0, "def": 5, "spd": 0, "spi": 2},
		"main_stat": "def",
		"tier": "meal",
		"special_effects": ["kill_heal_8_percent"],
	},
	"bamboo_cold_noodles": {
		"stats": {"atk": 1, "def": 0, "spd": 5, "spi": 1},
		"main_stat": "spd",
		"tier": "meal",
		"special_effects": ["afterimage_step"],
	},
	"moon_reishi_boil": {
		"stats": {"atk": 0, "def": 2, "spd": 0, "spi": 6},
		"main_stat": "spi",
		"tier": "meal",
		"special_effects": ["spirit_pulse"],
	},
	"fairy_meat_pie": {
		"stats": {"atk": 5, "def": 1, "spd": 1, "spi": 0},
		"main_stat": "atk",
		"tier": "meal",
		"special_effects": ["heavy_armor_break"],
	},
	"ginseng_chicken_soup": {
		"stats": {"atk": 1, "def": 5, "spd": 0, "spi": 1},
		"main_stat": "def",
		"tier": "meal",
		"special_effects": ["high_hp_guard"],
	},
	"spicy_beast_skewer": {
		"stats": {"atk": 5, "def": 0, "spd": 1, "spi": 0},
		"main_stat": "atk",
		"tier": "meal",
		"special_effects": [],
	},
	"moon_herb_soup": {
		"stats": {"atk": 0, "def": 1, "spd": 0, "spi": 5},
		"main_stat": "spi",
		"tier": "meal",
		"special_effects": [],
	},
	"pufferfish_sashimi": {
		"stats": {"atk": 4, "def": 0, "spd": 2, "spi": 1},
		"main_stat": "atk",
		"tier": "feast",
		"special_effects": [],
	},
	"mokou_yakitori": {
		"stats": {"atk": 4, "def": 1, "spd": 2, "spi": 1},
		"main_stat": "atk",
		"tier": "feast",
		"special_effects": ["flame_fist_bonus"],
	},
	"moon_viewing_dango": {
		"stats": {"atk": 0, "def": 1, "spd": 1, "spi": 4},
		"main_stat": "spi",
		"tier": "feast",
		"special_effects": ["spirit_charge_bonus"],
	},
	"phoenix_hotpot": {
		"stats": {"atk": 4, "def": 3, "spd": 1, "spi": 3},
		"main_stat": "atk",
		"tier": "feast",
		"special_effects": ["phoenix_regen"],
	},
	"hourai_hotpot": {
		"stats": {"atk": 4, "def": 3, "spd": 0, "spi": 3},
		"main_stat": "atk",
		"tier": "feast",
		"special_effects": ["berserk_burn"],
	},
	"eternal_night_banquet": {
		"stats": {"atk": 0, "def": 2, "spd": 3, "spi": 6},
		"main_stat": "spi",
		"tier": "feast",
		"special_effects": ["tracking_bullets"],
	},
	"mokou_full_course": {
		"stats": {"atk": 8, "def": 0, "spd": 2, "spi": 1},
		"main_stat": "atk",
		"tier": "feast",
		"special_effects": ["flame_combo_rush"],
	},
	"kaguya_elixir_feast": {
		"stats": {"atk": 1, "def": 4, "spd": 1, "spi": 5},
		"main_stat": "spi",
		"tier": "feast",
		"special_effects": ["rebirth_once"],
	},
	"bamboo_taketori_feast": {
		"stats": {"atk": 3, "def": 2, "spd": 4, "spi": 1},
		"main_stat": "spd",
		"tier": "feast",
		"special_effects": ["dash_bonus_100"],
	},
	"reishi_tea": {
		"stats": {"atk": 0, "def": 0, "spd": 0, "spi": 2},
		"main_stat": "spi",
		"tier": "drink",
		"special_effects": ["spirit_charge_bonus"],
		"drink_effects": [],
	},
	"bamboo_leaf_wine": {
		"stats": {"atk": 0, "def": 0, "spd": 0, "spi": 0},
		"main_stat": "atk",
		"tier": "drink",
		"special_effects": [],
		"drink_effects": ["attack_up_10", "risk_taken_up_10"],
	},
	"moon_herb_dew": {
		"stats": {"atk": 0, "def": 0, "spd": 0, "spi": 0},
		"main_stat": "spi",
		"tier": "drink",
		"special_effects": ["night_vision"],
		"drink_effects": [],
	},
	"impatiens_tea": {
		"stats": {"atk": 0, "def": 0, "spd": 1, "spi": 0},
		"main_stat": "spd",
		"tier": "drink",
		"special_effects": ["jump_boost_20"],
		"drink_effects": ["speed_up_8"],
	},
	"ginseng_tonic": {
		"stats": {"atk": 0, "def": 0, "spd": 0, "spi": 0},
		"main_stat": "def",
		"tier": "drink",
		"special_effects": ["drink_regen_3"],
		"drink_effects": [],
	},
	"chili_shochu": {
		"stats": {"atk": 3, "def": 0, "spd": 0, "spi": 0},
		"main_stat": "atk",
		"tier": "drink",
		"special_effects": ["fire_trail_visual"],
		"drink_effects": [],
	},
	"phantom_koi_broth": {
		"stats": {"atk": 0, "def": 0, "spd": 0, "spi": 1},
		"main_stat": "spi",
		"tier": "drink",
		"special_effects": ["reveal_collectibles"],
		"drink_effects": [],
	},
}

# --- 查询函数 ---

static func get_dish_name(dish_id: String) -> String:
	return DISH_NAMES.get(dish_id, dish_id)

static func get_dish_profile(dish_id: String) -> Dictionary:
	return DISH_COMBAT_PROFILES.get(dish_id, {})

static func get_dish_stats(dish_id: String) -> Dictionary:
	var profile := get_dish_profile(dish_id)
	return profile.get("stats", {"atk": 0, "def": 0, "spd": 0, "spi": 0})

static func get_dish_tier(dish_id: String) -> String:
	var profile := get_dish_profile(dish_id)
	return profile.get("tier", "snack")

static func get_dish_main_stat(dish_id: String) -> String:
	var profile := get_dish_profile(dish_id)
	return profile.get("main_stat", "atk")

static func get_dish_effects(dish_id: String) -> Array:
	var profile := get_dish_profile(dish_id)
	var effects := Array(profile.get("special_effects", []))
	effects.append_array(profile.get("drink_effects", []))
	return effects

static func is_drink(dish_id: String) -> bool:
	return get_dish_tier(dish_id) == "drink"

static func get_all_dish_ids() -> Array:
	return DISH_COMBAT_PROFILES.keys()

static func get_dishes_by_tier(tier: String) -> Array:
	var result := []
	for dish_id in DISH_COMBAT_PROFILES:
		if DISH_COMBAT_PROFILES[dish_id].get("tier", "") == tier:
			result.append(dish_id)
	return result

static func get_dish_total_stats(dish_id: String) -> int:
	var stats := get_dish_stats(dish_id)
	return int(stats.get("atk", 0)) + int(stats.get("def", 0)) + int(stats.get("spd", 0)) + int(stats.get("spi", 0))
