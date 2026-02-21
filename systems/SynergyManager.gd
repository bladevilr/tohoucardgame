extends Node

var _active_synergies: Dictionary = {}  # player_idx -> [synergy_ids]

func check_synergies(player: PlayerState) -> Array:
	"""Check all synergies for a player. Returns array of active synergy dicts."""
	var active: Array = []
	var board_items = player.get_board_items()
	
	# Count cuisines
	var cuisine_counts: Dictionary = {}
	var tag_counts: Dictionary = {}
	var flavor_counts: Dictionary = {}
	var method_counts: Dictionary = {}
	var total_items := board_items.size()
	var small_count := 0
	var large_count := 0
	var all_enchanted := total_items > 0
	var cuisine_set: Dictionary = {}
	for entry in board_items:
		var item = entry.item
		var cuisine = item.get("cuisine", "")
		if cuisine != "":
			cuisine_counts[cuisine] = cuisine_counts.get(cuisine, 0) + 1
			cuisine_set[cuisine] = true
		
		for tag in item.get("tags", []):
			tag_counts[tag] = tag_counts.get(tag, 0) + 1
		
		if item.get("size", 1) == 1:
			small_count += 1
		elif item.get("size", 1) == 3:
			large_count += 1
		
		if item.get("enchant", "") == "":
			all_enchanted = false
	
	# Cuisine synergies (3+)
	for cuisine in cuisine_counts:
		if cuisine_counts[cuisine] >= 3:
			var syn = CuisineDatabase.check_synergy(cuisine, cuisine_counts[cuisine])
			if not syn.is_empty():
				active.append(syn)
	
	# Fusion artist (3+ fusion tags)
	if tag_counts.get("fusion", 0) >= 3:
		active.append({"id": "fusion_artist", "name": "融合艺术家", "effect": {"flavor_mult": 1.10, "presentation_mult": 1.15}, "keyword_trigger": {"on_serve_fusion": {"add_keyword": "plating", "keyword_stacks": 1}}})
	
	# Mastered (3+ mastered tags)
	if tag_counts.get("mastered", 0) >= 3:
		active.append({"id": "master_craft", "name": "匠心独运", "effect": {"technique_mult": 1.30}, "keyword_trigger": {"on_serve_mastered": {"add_keyword": "knife_work", "keyword_stacks": 1}}})
	
	# All enchanted
	if all_enchanted and total_items > 0:
		active.append({"id": "fully_armed", "name": "全副武装", "effect": {"flavor_mult": 1.10}, "keyword_trigger": {"on_serve_any": {"add_keyword": "secret_recipe", "keyword_stacks": 1, "cooldown": 10.0}}})
	
	# 4+ different cuisines
	if cuisine_set.size() >= 4:
		active.append({"id": "world_cuisine", "name": "万国料理博览", "effect": {"presentation_add_pct": 0.25}})
	
	# Small army (5+ small)
	if small_count >= 5:
		active.append({"id": "small_army", "name": "小菜军团", "effect": {"small_cd_mult": 0.85}, "keyword_trigger": {"on_serve_small": {"add_keyword": "spotlight", "keyword_stacks": 1, "target": "random_adjacent"}}})
	
	# Double large (2+ large)
	if large_count >= 2:
		active.append({"id": "double_large", "name": "压轴双雄", "effect": {"large_flavor_mult": 1.20}, "keyword_trigger": {"on_serve_large": {"consume_all_keywords": true, "effect_mult": 1.2}}})
	
	# Taste layers (rich + light both present)
	if tag_counts.get("rich", 0) > 0 and tag_counts.get("light", 0) > 0:
		active.append({"id": "taste_layers", "name": "味觉层次", "effect": {"presentation_add_pct": 0.15}, "keyword_trigger": {"on_serve_any": {"add_keyword": "plating", "keyword_stacks": 1}}})
	
	# Fusion combos
	var fusion_combos = CuisineDatabase.get_all_fusions()
	for combo in fusion_combos:
		var cuisines_needed = combo.get("required_cuisines", combo.get("cuisines", []))
		var all_present = true
		for c in cuisines_needed:
			if cuisine_counts.get(c, 0) == 0:
				all_present = false
				break
		if all_present:
			active.append(combo)
	
	# Same flavor x3
	for flavor_tag in ["spicy", "umami_tag", "sweet", "sour"]:
		if tag_counts.get(flavor_tag, 0) >= 3:
			active.append({"id": "flavor_storm_" + flavor_tag, "name": "风味风暴·" + flavor_tag, "effect": {"flavor_add_pct": 0.25}})
	
	# Same method x3
	for method_tag in ["grilled", "stewed", "fried", "raw", "steamed", "stir_fried"]:
		if tag_counts.get(method_tag, 0) >= 3:
			active.append({"id": "cooking_master_" + method_tag, "name": "烹饪大师·" + method_tag, "effect": {"technique_add_pct": 0.20}, "keyword_trigger": {"on_serve_method": {"add_keyword": "knife_work", "keyword_stacks": 1}}})
	
	# Update active synergies tracking
	var p_idx = player.player_idx
	var old_synergies = _active_synergies.get(p_idx, [])
	var new_ids = []
	for s in active:
		new_ids.append(s.get("id", ""))
	
	# Emit signals for newly activated/deactivated
	for s_id in new_ids:
		if s_id not in old_synergies:
			SignalBus.synergy_activated.emit(p_idx, s_id)
	for s_id in old_synergies:
		if s_id not in new_ids:
			SignalBus.synergy_deactivated.emit(p_idx, s_id)
	
	_active_synergies[p_idx] = new_ids
	return active

func get_active_synergies(player_idx: int) -> Array:
	return _active_synergies.get(player_idx, [])
