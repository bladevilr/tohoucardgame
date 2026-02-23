extends Node

## Ingredient enchantment system
## Handles applying consumable ingredients to board dishes for permanent stat/tag modification.

signal ingredient_applied(player_idx: int, slot_idx: int, ingredient: Dictionary, dish: Dictionary)
signal ingredient_failed(player_idx: int, reason: String)

func apply_ingredient(player: PlayerState, ingredient: Dictionary, target_slot: int) -> bool:
	"""Apply an ingredient to a dish on the board. Returns true on success."""
	var dish = player.get_item_at(target_slot)
	if dish == null:
		ingredient_failed.emit(player.player_idx, "目标格子没有菜品")
		return false
	
	# Check if it's actually a dish (not a reference slot or tool)
	if dish.has("_ref_to"):
		ingredient_failed.emit(player.player_idx, "不能对引用格子使用食材")
		return false
	if dish.get("item_type", "") == "tool":
		ingredient_failed.emit(player.player_idx, "不能对厨具使用食材")
		return false
	
	# Check restrictions
	if not IngredientDatabase.can_apply_to(ingredient, dish):
		var req = ingredient.get("requires_tags", [])
		var forbid = ingredient.get("forbidden_tags", [])
		if not req.is_empty():
			ingredient_failed.emit(player.player_idx, "菜品缺少必要标签：%s" % str(req))
		else:
			ingredient_failed.emit(player.player_idx, "菜品含有冲突标签：%s" % str(forbid))
		return false
	
	# Apply stat modifiers
	var stat_mods = ingredient.get("stat_modifiers", {})
	var cuisine_affinity = ingredient.get("cuisine_affinity", "")
	var dish_cuisine = dish.get("cuisine", "")
	var affinity_mult = 1.0
	if cuisine_affinity != "" and cuisine_affinity == dish_cuisine:
		affinity_mult = float(ingredient.get("affinity_bonus", 1.5))
	
	var base_stats = dish.get("base_stats", {})
	for attr in stat_mods:
		var bonus = float(stat_mods[attr]) * affinity_mult
		base_stats[attr] = base_stats.get(attr, 0.0) + bonus
	dish["base_stats"] = base_stats
	
	# Apply tag additions
	var add_tags = ingredient.get("added_tags", [])
	var dish_tags: Array = dish.get("tags", [])
	for tag in add_tags:
		if tag not in dish_tags:
			dish_tags.append(tag)
	
	# Apply tag removals
	var remove_tags = ingredient.get("removed_tags", [])
	for tag in remove_tags:
		dish_tags.erase(tag)
	dish["tags"] = dish_tags
	
	# Track enchantment history on the dish
	var enchant_history: Array = dish.get("_ingredient_history", [])
	var ingredient_name: String = str(ingredient.get("name_cn", ingredient.get("name", "")))
	enchant_history.append({
		"id": ingredient.get("id", ""),
		"name": ingredient_name,
		"stat_mods": stat_mods.duplicate(),
		"affinity_mult": affinity_mult,
	})
	dish["_ingredient_history"] = enchant_history
	
	# Process special effects
	_process_special_effect(player, ingredient, dish, target_slot)
	
	# Emit success signal
	ingredient_applied.emit(player.player_idx, target_slot, ingredient, dish)
	SignalBus.item_activated.emit(player.player_idx, target_slot, dish)
	
	return true

func apply_from_backpack(player: PlayerState, backpack_idx: int, target_slot: int) -> bool:
	"""Apply ingredient from backpack to board dish."""
	if backpack_idx < 0 or backpack_idx >= player.backpack.size():
		ingredient_failed.emit(player.player_idx, "背包索引无效")
		return false
	
	var ingredient = player.backpack[backpack_idx]
	if ingredient.get("item_type", "") != "ingredient":
		ingredient_failed.emit(player.player_idx, "该物品不是食材")
		return false
	
	if apply_ingredient(player, ingredient, target_slot):
		player.backpack.remove_at(backpack_idx)
		return true
	return false

func _process_special_effect(player: PlayerState, ingredient: Dictionary, dish: Dictionary, slot_idx: int):
	"""Handle special ingredient effects beyond stat/tag modification."""
	var effect = ingredient.get("special_effect", "")
	if effect.is_empty():
		return
	
	match effect:
		"clear_greasy_1":
			# Ginger: clears 1 greasy from environment at showdown start
			var triggers = dish.get("triggers", [])
			triggers.append({
				"event": "on_showdown_start",
				"effect": {"clear_env_keyword": "greasy", "stacks": 1}
			})
			dish["triggers"] = triggers
		
		"add_env_greasy_2":
			# Ghost Pepper: adds 2 greasy when dish first activates
			var triggers = dish.get("triggers", [])
			triggers.append({
				"event": "on_self_first_activate",
				"effect": {"add_env_keyword": "greasy", "env_stacks": 2}
			})
			dish["triggers"] = triggers
		
		"clear_all_env_1":
			# Moonlight Salt: clears 1 of each env debuff at showdown start
			var triggers = dish.get("triggers", [])
			for debuff in ["greasy", "messy", "taste_fatigue", "dull"]:
				triggers.append({
					"event": "on_showdown_start",
					"effect": {"clear_env_keyword": debuff, "stacks": 1}
				})
			dish["triggers"] = triggers
		
		"double_next_activate":
			# Void Essence: first activation produces double score
			var triggers = dish.get("triggers", [])
			triggers.append({
				"event": "on_self_first_activate",
				"effect": {"type": "flavor_mult", "value": 2.0}
			})
			dish["triggers"] = triggers
		
		"grant_secret_recipe":
			# Hourai Elixir: grants 1 secret_recipe keyword at showdown start
			var triggers = dish.get("triggers", [])
			triggers.append({
				"event": "on_showdown_start",
				"effect": {"type": "gain_keyword", "keyword": "secret_recipe", "stacks": 1}
			})
			dish["triggers"] = triggers
		
		"grant_umami_6":
			# Yatagarasu Flame: grants 6 umami at showdown start
			var triggers = dish.get("triggers", [])
			triggers.append({
				"event": "on_showdown_start",
				"effect": {"type": "gain_keyword", "keyword": "umami", "stacks": 6}
			})
			dish["triggers"] = triggers

func get_enchant_summary(dish: Dictionary) -> String:
	"""Get a human-readable summary of all ingredients applied to a dish."""
	var history = dish.get("_ingredient_history", [])
	if history.is_empty():
		return ""
	var parts: Array = []
	for entry in history:
		var name = entry.get("name", "???")
		var mult = entry.get("affinity_mult", 1.0)
		if mult > 1.0:
			parts.append("%s (亲和×%.1f)" % [name, mult])
		else:
			parts.append(name)
	return "已调味：" + "、".join(parts)

func get_stat_preview(ingredient: Dictionary, dish: Dictionary) -> Dictionary:
	"""Preview what stats would change if ingredient is applied to dish."""
	var preview: Dictionary = {}
	var stat_mods = ingredient.get("stat_modifiers", {})
	var cuisine_affinity = ingredient.get("cuisine_affinity", "")
	var dish_cuisine = dish.get("cuisine", "")
	var affinity_mult = 1.0
	if cuisine_affinity != "" and cuisine_affinity == dish_cuisine:
		affinity_mult = float(ingredient.get("affinity_bonus", 1.5))
	
	var base_stats = dish.get("base_stats", {})
	for attr in stat_mods:
		var bonus = float(stat_mods[attr]) * affinity_mult
		preview[attr] = {
			"before": base_stats.get(attr, 0.0),
			"after": base_stats.get(attr, 0.0) + bonus,
			"delta": bonus,
			"affinity": affinity_mult > 1.0,
		}
	return preview

func describe_special_effect(effect_id: String) -> String:
	match effect_id:
		"appetize_right_20":
			return "右侧相邻菜品上菜时额外+20风味"
		"clear_greasy_1":
			return "开场清除1层油腻"
		"score_right_raw_30":
			return "右侧生食菜品上菜时额外+30风味"
		"fermented_growth_boost":
			return "发酵类效果成长速度提升"
		"umami_on_3rd_activate":
			return "每第3次上菜时额外获得1层提味"
		"dessert_zone_bonus":
			return "甜品区菜品获得额外加成"
		"addiction_double_stack":
			return "与上瘾类效果联动时叠层翻倍"
		"add_env_greasy_2":
			return "首次上菜时给环境增加2层油腻"
		"first_activate_bonus_50":
			return "首次上菜额外+50风味"
		"clear_all_env_1":
			return "开场各清除1层环境减益"
		"sizzle_threshold_minus_1":
			return "爆香类爆发阈值-1"
		"all_scores_mult_1_5":
			return "该菜品最终得分×1.5"
		"double_next_activate":
			return "首次上菜风味倍率翻倍"
		"grant_secret_recipe":
			return "开场获得1层秘方"
		"refreshing_full_clear":
			return "开场清除全部沉闷与疲劳"
		"grant_umami_6":
			return "开场获得6层提味"
		_:
			return "无特殊效果" if effect_id == "" else "特殊效果"
