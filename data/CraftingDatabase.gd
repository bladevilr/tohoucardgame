extends Node

var recipes: Array = []
var _recipe_index: Dictionary = {}# key: sorted ingredient string -> recipe

func _ready():
	_init_recipes()
	_build_index()

func _init_recipes():
	# =====================
	# Basic Sauce Crafting
	# =====================
	_add(["sugar", "vinegar"], "sweet_sour_sauce", "糖醋酱")
	_add(["soy_sauce", "garlic_paste"], "garlic_soy_sauce", "蒜蓉酱油")
	_add(["miso", "mirin"], "miso_glaze", "味噌釉")
	_add(["butter", "lemon"], "lemon_butter_sauce", "柠檬黄油酱")
	_add(["cream", "white_wine"], "cream_sauce", "奶油白酱")
	_add(["chili", "garlic_paste"], "chili_garlic_sauce", "蒜蓉辣酱")
	_add(["sesame_paste", "vinegar"], "sesame_vinaigrette", "麻酱醋汁")
	_add(["dashi", "soy_sauce"], "tentsuyu", "天汁")
	_add(["olive_oil", "basil"], "basil_oil", "罗勒油")
	_add(["cream", "chocolate"], "chocolate_ganache", "巧克力甘纳许")
	_add(["sugar", "cream"], "caramel_sauce", "焦糖酱")
	_add(["truffle", "olive_oil"], "truffle_oil", "松露油")

	# =====================
	# Dish Crafting - Chinese
	# =====================
	_add(["sweet_sour_sauce", "pork_ribs"], "sweet_sour_ribs", "糖醋排骨")
	_add(["garlic_soy_sauce", "chicken"], "soy_sauce_chicken", "酱油鸡")
	_add(["chili_garlic_sauce", "prawns"], "chili_garlic_prawns", "蒜蓉辣虾")
	_add(["doubanjiang", "tofu", "pork_mince"], "mapo_tofu", "麻婆豆腐")
	_add(["chicken", "peanuts", "chili"], "kung_pao_chicken", "宫保鸡丁")
	_add(["pork_belly", "soy_sauce", "sugar"], "dongpo_pork", "东坡肉")
	_add(["duck", "maltose", "five_spice"], "peking_duck", "北京烤鸭")
	_add(["crab", "ginger", "vinegar"], "steamed_hairy_crab", "清蒸大闸蟹")

	# =====================
	# Dish Crafting - French
	# =====================
	_add(["cream_sauce", "salmon"], "salmon_cream", "奶油三文鱼")
	_add(["lemon_butter_sauce", "lobster"], "lobster_thermidor", "龙虾瑟米多")
	_add(["foie_gras", "brioche", "truffle_oil"], "foie_gras_toast", "鹅肝吐司")
	_add(["beef_tenderloin", "red_wine", "butter"], "beef_bourguignon", "勃艮第红酒牛肉")
	_add(["duck_leg", "duck_fat", "garlic_paste"], "duck_confit", "油封鸭腿")
	_add(["onion", "butter", "cream"], "french_onion_soup", "法式洋葱汤")

	# =====================
	# Dish Crafting - Japanese
	# =====================
	_add(["tentsuyu", "prawns"], "tempura_prawns", "天妇罗虾")
	_add(["miso_glaze", "cod"], "miso_cod", "西京烧鳕鱼")
	_add(["salmon", "rice", "nori"], "salmon_sushi", "三文鱼寿司")
	_add(["tuna", "soy_sauce", "wasabi"], "tuna_sashimi", "金枪鱼刺身")
	_add(["dashi", "tofu", "wakame"], "miso_soup", "味噌汤")
	_add(["wagyu", "salt", "pepper"], "wagyu_steak", "和牛牛排")

	# =====================
	# Dish Crafting - Wild
	# =====================
	_add(["venison", "juniper", "red_wine"], "grilled_venison", "炭烤鹿肉")
	_add(["wild_boar", "honey", "rosemary"], "wild_boar_roast", "蜜烤野猪")
	_add(["river_fish", "salt", "lemon"], "grilled_river_fish", "炭烤河鱼")

	# =====================
	# Dish Crafting - Molecular
	# =====================
	_add(["mango", "sodium_alginate", "calcium_chloride"], "mango_caviar", "芒果鱼子酱")
	_add(["basil_oil", "agar"], "basil_gel", "罗勒凝胶")
	_add(["chocolate_ganache", "liquid_nitrogen_ingredient"], "frozen_chocolate_sphere", "液氮巧克力球")

	# =====================
	# Dish Crafting - Dessert
	# =====================
	_add(["caramel_sauce", "apple", "pastry"], "tarte_tatin", "翻转苹果塔")
	_add(["chocolate_ganache", "cream", "eggs"], "chocolate_fondant", "熔岩巧克力")
	_add(["matcha", "cream", "sugar"], "matcha_parfait", "抹茶芭菲")
	_add(["strawberry", "cream", "sponge_cake"], "strawberry_shortcake", "草莓蛋糕")

	# =====================
	# Variant Crafting - Buddha Jumps Wall
	# =====================
	_add(["abalone", "sea_cucumber", "shark_fin"], "buddha_jumps_wall_classic", "佛跳墙·经典", "经典")
	_add(["matsutake", "bamboo_fungus", "veg_abalone"], "buddha_jumps_wall_vegetarian", "佛跳墙·素斋", "素斋")
	_add(["truffle", "foie_gras", "abalone"], "buddha_jumps_wall_luxury", "佛跳墙·奢华", "奢华")

	# =====================
	# Variant Crafting - Sushi Platter
	# =====================
	_add(["salmon_sushi", "tuna_sashimi", "prawns"], "sushi_platter_deluxe", "豪华寿司拼盘", "豪华")
	_add(["tofu", "avocado", "rice"], "sushi_platter_veggie", "素食寿司拼盘", "素食")

	# =====================
	# Variant Crafting - French Dessert Tower
	# =====================
	_add(["chocolate_fondant", "caramel_sauce", "gold_leaf"], "dessert_tower_grand", "法式甜品塔·华丽", "华丽")
	_add(["matcha_parfait", "strawberry_shortcake", "mango_caviar"], "dessert_tower_fusion", "法式甜品塔·融合", "融合")

	# =====================
	# Star Upgrade Recipes
	# =====================
	_add_star_upgrade(2)
	_add_star_upgrade(3)

func _add(ingredients: Array, result_id: String, result_name: String, variant: String = ""):
	var recipe := {
		"ingredients": ingredients,
		"result_id": result_id,
		"result_name": result_name,
		"result_variant": variant
	}
	recipes.append(recipe)

func _add_star_upgrade(target_star: int):
	var source_star = target_star - 1
	var recipe := {
		"ingredients": ["__same_item_x3"],
		"result_id": "__star_upgrade",
		"result_name": "星级升级",
		"result_variant": "",
		"is_star_upgrade": true,
		"source_star": source_star,
		"target_star": target_star,
		"required_count": 3
	}
	recipes.append(recipe)

func _build_index():
	for i in range(recipes.size()):
		var r = recipes[i]
		if r.has("is_star_upgrade") and r.is_star_upgrade:
			continue
		var key = _make_key(r.ingredients)
		_recipe_index[key] = i

func _make_key(ingredients: Array) -> String:
	var sorted = ingredients.duplicate()
	sorted.sort()
	return ",".join(sorted)

func find_recipe(ingredient_ids: Array) -> Dictionary:
	var key = _make_key(ingredient_ids)
	if _recipe_index.has(key):
		return recipes[_recipe_index[key]]
	return {}

func can_craft(ingredient_ids: Array) -> bool:
	return not find_recipe(ingredient_ids).is_empty()

func get_all_recipes() -> Array:
	return recipes

func get_star_upgrade_recipe(current_star: int) -> Dictionary:
	for r in recipes:
		if r.has("is_star_upgrade") and r.is_star_upgrade and r.source_star == current_star:
			return r
	return {}

func can_star_upgrade(item_id: String, current_star: int, inventory_count: int) -> bool:
	var upgrade = get_star_upgrade_recipe(current_star)
	if upgrade.is_empty():
		return false
	return inventory_count >= upgrade.required_count

func get_recipes_using(ingredient_id: String) -> Array:
	var result: Array = []
	for r in recipes:
		if r.has("is_star_upgrade") and r.is_star_upgrade:
			continue
		if ingredient_id in r.ingredients:
			result.append(r)
	return result

func get_recipes_producing(result_id: String) -> Array:
	var result: Array = []
	for r in recipes:
		if r.result_id == result_id:
			result.append(r)
	return result

func get_variants(base_name: String) -> Array:
	var result: Array = []
	for r in recipes:
		if r.result_name.begins_with(base_name) and r.result_variant != "":
			result.append(r)
	return result
