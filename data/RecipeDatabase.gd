extends Node

## RecipeDatabase - 配方数据库：食材组合 → 料理

# 配方格式: recipe_id → {result_dish, ingredients[], name}
# ingredients 是食材id列表，顺序无关
const RECIPES := {
	# === 小食 (snack) ===
	"recipe_rice_ball": {
		"result": "rice_ball",
		"ingredients": ["bamboo_shoot", "salt"],
		"name": "饭团",
	},
	"recipe_grilled_fish": {
		"result": "grilled_fish",
		"ingredients": ["crucian_carp", "salt"],
		"name": "烤鱼",
	},
	"recipe_dango": {
		"result": "dango",
		"ingredients": ["sugar", "moon_herb"],
		"name": "团子",
	},
	"recipe_senbei": {
		"result": "senbei",
		"ingredients": ["bamboo_shoot", "soy_sauce"],
		"name": "仙贝",
	},
	"recipe_grilled_bamboo_shoot": {
		"result": "grilled_bamboo_shoot",
		"ingredients": ["bamboo_shoot", "spice"],
		"name": "烤竹笋",
	},
	"recipe_spicy_stir_meat": {
		"result": "spicy_stir_meat",
		"ingredients": ["beast_meat", "chili"],
		"name": "辣炒肉",
	},
	"recipe_pumpkin_congee": {
		"result": "pumpkin_congee",
		"ingredients": ["pumpkin", "sugar"],
		"name": "南瓜粥",
	},
	"recipe_moon_herb_dango": {
		"result": "moon_herb_dango",
		"ingredients": ["moon_herb", "sugar"],
		"name": "月见草团子",
	},
	"recipe_honey_skewer": {
		"result": "honey_skewer",
		"ingredients": ["fairy_meat", "honey"],
		"name": "蜂蜜烤串",
	},

	# === 主食 (meal) ===
	"recipe_miso_soup": {
		"result": "miso_soup",
		"ingredients": ["crucian_carp", "miso"],
		"name": "味噌汤",
	},
	"recipe_bamboo_rice": {
		"result": "bamboo_rice",
		"ingredients": ["bamboo_shoot", "salt", "soy_sauce"],
		"name": "竹笋饭",
	},
	"recipe_mushroom_stew": {
		"result": "mushroom_stew",
		"ingredients": ["reishi", "salt", "miso"],
		"name": "蘑菇炖菜",
	},
	"recipe_tempura": {
		"result": "tempura",
		"ingredients": ["rainbow_trout", "spice"],
		"name": "天妇罗",
	},
	"recipe_eel_rice": {
		"result": "eel_rice",
		"ingredients": ["rainbow_trout", "soy_sauce", "sugar"],
		"name": "鳗鱼饭",
	},
	"recipe_herb_salad": {
		"result": "herb_salad",
		"ingredients": ["moon_herb", "impatiens"],
		"name": "草药沙拉",
	},
	"recipe_phoenix_roast_chicken": {
		"result": "phoenix_roast_chicken",
		"ingredients": ["beast_meat", "chili", "spice"],
		"name": "凤凰烤鸡",
	},
	"recipe_reishi_stew": {
		"result": "reishi_stew",
		"ingredients": ["reishi", "ginseng", "salt"],
		"name": "灵芝炖汤",
	},
	"recipe_bamboo_cold_noodles": {
		"result": "bamboo_cold_noodles",
		"ingredients": ["bamboo_shoot", "soy_sauce", "spice"],
		"name": "竹林冷面",
	},
	"recipe_moon_reishi_boil": {
		"result": "moon_reishi_boil",
		"ingredients": ["moon_herb", "reishi", "moon_dew"],
		"name": "月见灵茸煮",
	},
	"recipe_fairy_meat_pie": {
		"result": "fairy_meat_pie",
		"ingredients": ["fairy_meat", "chili", "salt"],
		"name": "妖精肉饼",
	},
	"recipe_ginseng_chicken_soup": {
		"result": "ginseng_chicken_soup",
		"ingredients": ["ginseng", "beast_meat", "salt"],
		"name": "人参鸡汤",
	},
	"recipe_spicy_beast_skewer": {
		"result": "spicy_beast_skewer",
		"ingredients": ["youkai_beast_meat", "chili", "spice"],
		"name": "辣味兽肉串",
	},
	"recipe_moon_herb_soup": {
		"result": "moon_herb_soup",
		"ingredients": ["moon_herb", "ginseng", "salt"],
		"name": "月见草汤",
	},

	# === 宴席 (feast) ===
	"recipe_pufferfish_sashimi": {
		"result": "pufferfish_sashimi",
		"ingredients": ["phantom_fish", "soy_sauce", "spice"],
		"name": "河豚刺身",
	},
	"recipe_mokou_yakitori": {
		"result": "mokou_yakitori",
		"ingredients": ["moon_fish", "chili", "soy_sauce"],
		"name": "妹红烤鸡",
	},
	"recipe_moon_viewing_dango": {
		"result": "moon_viewing_dango",
		"ingredients": ["moon_herb", "sugar", "moon_dew"],
		"name": "月见团子",
	},
	"recipe_phoenix_hotpot": {
		"result": "phoenix_hotpot",
		"ingredients": ["youkai_beast_meat", "chili", "reishi", "spice"],
		"name": "蓬莱火锅",
	},
	"recipe_hourai_hotpot": {
		"result": "hourai_hotpot",
		"ingredients": ["youkai_beast_meat", "fire_eggplant", "hourai_branch"],
		"name": "蓬莱火锅·极",
	},
	"recipe_eternal_night_banquet": {
		"result": "eternal_night_banquet",
		"ingredients": ["phantom_fish", "moon_herb", "moon_dew", "hourai_branch"],
		"name": "永夜宴",
	},
	"recipe_mokou_full_course": {
		"result": "mokou_full_course",
		"ingredients": ["youkai_beast_meat", "fire_eggplant", "chili", "spice"],
		"name": "妹红特制全席",
	},
	"recipe_kaguya_elixir_feast": {
		"result": "kaguya_elixir_feast",
		"ingredients": ["ginseng", "reishi", "moon_dew", "hourai_branch"],
		"name": "辉夜秘药膳",
	},
	"recipe_bamboo_taketori_feast": {
		"result": "bamboo_taketori_feast",
		"ingredients": ["bamboo_shoot", "rainbow_trout", "impatiens", "spice"],
		"name": "竹取盛宴",
	},

	# === 饮品 (drink) ===
	"recipe_green_tea": {
		"result": "green_tea",
		"ingredients": ["moon_herb"],
		"name": "绿茶",
	},
	"recipe_reishi_tea": {
		"result": "reishi_tea",
		"ingredients": ["reishi", "honey"],
		"name": "灵芝茶",
	},
	"recipe_bamboo_leaf_wine": {
		"result": "bamboo_leaf_wine",
		"ingredients": ["bamboo_shoot", "sugar"],
		"name": "竹叶酒",
	},
	"recipe_moon_herb_dew": {
		"result": "moon_herb_dew",
		"ingredients": ["moon_herb", "moon_dew"],
		"name": "月见草露",
	},
	"recipe_impatiens_tea": {
		"result": "impatiens_tea",
		"ingredients": ["impatiens", "honey"],
		"name": "凤仙花茶",
	},
	"recipe_ginseng_tonic": {
		"result": "ginseng_tonic",
		"ingredients": ["ginseng", "honey"],
		"name": "人参汤",
	},
	"recipe_chili_shochu": {
		"result": "chili_shochu",
		"ingredients": ["chili", "sugar", "spice"],
		"name": "辣椒烧酒",
	},
	"recipe_phantom_koi_broth": {
		"result": "phantom_koi_broth",
		"ingredients": ["phantom_fish", "salt", "moon_dew"],
		"name": "幻想鲤鱼汤",
	},
}


# --- 查询函数 ---

## 根据手中食材列表，返回可以制作的所有配方
static func get_available_recipes(held_ingredients: Array) -> Array:
	var available := []
	for recipe_id in RECIPES:
		var recipe: Dictionary = RECIPES[recipe_id]
		var needed: Array = recipe.get("ingredients", [])
		if _has_all_ingredients(held_ingredients, needed):
			available.append({
				"recipe_id": recipe_id,
				"result": recipe.get("result", ""),
				"name": recipe.get("name", ""),
				"ingredients": needed,
			})
	return available


## 检查是否拥有所有所需食材（考虑重复）
static func _has_all_ingredients(held: Array, needed: Array) -> bool:
	var held_copy: Array = held.duplicate()
	for ing in needed:
		var idx: int = held_copy.find(ing)
		if idx < 0:
			return false
		held_copy.remove_at(idx)
	return true


## 获取指定配方信息
static func get_recipe(recipe_id: String) -> Dictionary:
	return RECIPES.get(recipe_id, {})


## 根据成品料理id反查配方
static func find_recipe_for_dish(dish_id: String) -> Dictionary:
	for recipe_id in RECIPES:
		var recipe: Dictionary = RECIPES[recipe_id]
		if recipe.get("result", "") == dish_id:
			return recipe
	return {}


## 获取所有配方id
static func get_all_recipe_ids() -> Array:
	return RECIPES.keys()


## 获取指定料理的所需食材
static func get_ingredients_for_dish(dish_id: String) -> Array:
	var recipe: Dictionary = find_recipe_for_dish(dish_id)
	return recipe.get("ingredients", [])
