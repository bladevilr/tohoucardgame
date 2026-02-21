extends Node

func get_available_crafts(player: PlayerState) -> Array:
	"""Check what the player can craft from board + backpack items."""
	var available_items: Array = []
	for entry in player.get_board_items():
		available_items.append(entry.item)
	for item in player.backpack:
		available_items.append(item)

	var results: Array = []
	for recipe in CraftingDatabase.get_all_recipes():
		if recipe.get("is_star_upgrade", false):
			continue
		if DishDatabase.get_item(recipe.get("result_id", "")).is_empty():
			continue
		var ingredients_needed = recipe.get("ingredients", [])
		var can_craft = true
		var used_items: Array = []
		for ingredient_id in ingredients_needed:
			var found = false
			for item in available_items:
				if item.get("id", "") == ingredient_id and item not in used_items:
					used_items.append(item)
					found = true
					break
			if not found:
				can_craft = false
				break
		if can_craft:
			results.append({"recipe": recipe, "used_items": used_items})
	return results

func execute_craft(player: PlayerState, recipe: Dictionary) -> Dictionary:
	"""Execute a crafting recipe. Returns the result item or empty dict."""
	if recipe.get("is_star_upgrade", false):
		return {}

	var result_id = recipe.get("result_id", "")
	var result_template = DishDatabase.get_item(result_id)
	if result_template.is_empty():
		return {}

	var ingredients_needed = recipe.get("ingredients", [])
	var matched_sources: Array = []
	var used_board_slots: Dictionary = {}
	var used_bp_indices: Dictionary = {}

	for ingredient_id in ingredients_needed:
		var found = false
		for entry in player.get_board_items():
			if used_board_slots.has(entry.slot_idx):
				continue
			if entry.item.get("id", "") == ingredient_id:
				used_board_slots[entry.slot_idx] = true
				matched_sources.append({"source": "board", "slot_idx": entry.slot_idx, "item": entry.item})
				found = true
				break
		if found:
			continue
		for i in range(player.backpack.size()):
			if used_bp_indices.has(i):
				continue
			if player.backpack[i].get("id", "") == ingredient_id:
				used_bp_indices[i] = true
				matched_sources.append({"source": "backpack", "backpack_idx": i, "item": player.backpack[i]})
				found = true
				break
		if not found:
			return {}

	# Remove board items first, then backpack by descending index.
	for src in matched_sources:
		if src.get("source", "") == "board":
			player.remove_item(int(src.slot_idx))

	var bp_remove: Array = []
	for src in matched_sources:
		if src.get("source", "") == "backpack":
			bp_remove.append(int(src.backpack_idx))
	bp_remove.sort()
	bp_remove.reverse()
	for idx in bp_remove:
		player.backpack.remove_at(idx)

	var result_item = result_template.duplicate(true)

	var max_star = 1
	for src in matched_sources:
		max_star = maxi(max_star, int(src.item.get("star_level", 1)))
	result_item["star_level"] = max_star

	if recipe.get("result_name", "") != "":
		result_item["name"] = recipe.get("result_name", result_item.get("name", result_id))

	SignalBus.craft_completed.emit(player.player_idx, result_item)
	return result_item

func try_star_upgrade(player: PlayerState, item_ids_slots: Array) -> Dictionary:
	"""Try to upgrade 3 same items to next star. item_ids_slots is array of {item, source} dicts.
	Returns upgraded item or empty dict."""
	if item_ids_slots.size() != 3:
		return {}

	var base_id = item_ids_slots[0].item.get("id", "")
	var base_star = int(item_ids_slots[0].item.get("star_level", 1))
	for entry in item_ids_slots:
		if entry.item.get("id", "") != base_id:
			return {}
		if int(entry.item.get("star_level", 1)) != base_star:
			return {}

	if base_star >= 3:
		return {}

	# Remove selected items safely.
	var removed_board: Array = []
	var removed_backpack: Array = []
	var bp_indices: Array = []
	for entry in item_ids_slots:
		if entry.has("slot_idx"):
			removed_board.append({"slot_idx": int(entry.slot_idx), "item": player.remove_item(int(entry.slot_idx))})
		elif entry.has("backpack_idx"):
			bp_indices.append(int(entry.backpack_idx))

	bp_indices.sort()
	bp_indices.reverse()
	for idx in bp_indices:
		var removed = player.backpack.pop_at(idx)
		removed_backpack.append({"backpack_idx": idx, "item": removed})

	var new_item = DishDatabase.get_item(base_id)
	if new_item.is_empty():
		# Rollback on failure.
		for b in removed_board:
			if b.item != null:
				if not player.place_item(int(b.slot_idx), b.item):
					player.add_to_backpack(b.item)
		for b in removed_backpack:
			if b.item != null:
				player.add_to_backpack(b.item)
		return {}

	new_item = new_item.duplicate(true)
	var new_star = base_star + 1
	new_item["star_level"] = new_star

	var mult = GameConfig.STAR2_MULTIPLIER if new_star == 2 else GameConfig.STAR3_MULTIPLIER
	var stats = new_item.get("base_stats", {})
	for attr in stats:
		stats[attr] = float(stats[attr]) * mult

	var enchant = item_ids_slots[0].item.get("enchant", "")
	if enchant != "":
		new_item["enchant"] = enchant

	SignalBus.star_upgraded.emit(player.player_idx, new_item, new_star)
	return new_item
