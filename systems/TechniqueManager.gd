extends Node

## Technique Relic System
## Techniques are global passive relics that affect all dishes during showdown.
## They do NOT occupy board slots - they sit in a separate relic bar.

const MAX_TECHNIQUE_SLOTS := 4

signal technique_equipped(player_idx: int, technique: Dictionary)
signal technique_unequipped(player_idx: int, technique: Dictionary)
signal technique_slot_full(player_idx: int)

const TECHNIQUE_TO_DISH_CUISINE := {
	"chinese": "chuuka",
	"japanese": "washoku",
	"french": "youshoku",
	"wild": "yatai",
	"dessert": "kanmi",
	"molecular": "yakuzen",
}

func _normalize_cuisine(cuisine: String) -> String:
	return str(TECHNIQUE_TO_DISH_CUISINE.get(cuisine, cuisine))

func equip_technique(player: PlayerState, technique: Dictionary) -> bool:
	"""Equip a technique to the player's relic bar. Returns success."""
	var techniques = player.techniques
	if techniques.size() >= MAX_TECHNIQUE_SLOTS:
		technique_slot_full.emit(player.player_idx)
		return false
	
	# Check for duplicate
	var tech_id = technique.get("id", "")
	for existing in techniques:
		if existing.get("id", "") == tech_id:
			return false  # Already equipped
	
	technique["item_type"] = "technique"
	techniques.append(technique)
	technique_equipped.emit(player.player_idx, technique)
	return true

func unequip_technique(player: PlayerState, index: int) -> Dictionary:
	"""Remove a technique from the relic bar. Returns the removed technique."""
	if index < 0 or index >= player.techniques.size():
		return {}
	var removed = player.techniques.pop_at(index)
	technique_unequipped.emit(player.player_idx, removed)
	return removed

func get_global_modifiers(player: PlayerState, dish: Dictionary) -> Dictionary:
	"""Calculate combined technique modifiers for a specific dish.
	Returns {flavor_mult, presentation_mult, technique_mult, aroma_mult, cd_modifier, extra_tags}."""
	var result := {
		"flavor_mult": 1.0,
		"presentation_mult": 1.0,
		"technique_mult": 1.0,
		"aroma_mult": 1.0,
		"cd_modifier": 0.0,
		"extra_tags": [],
	}
	
	var dish_cuisine = dish.get("cuisine", "")
	var dish_tags = dish.get("tags", [])
	
	# Chef passive: Meiling chinese technique boost
	var chef = ChefDatabase.get_chef(player.chef_id)
	var chef_enhance = 1.0
	if not chef.is_empty() and chef.get("id", "") == "meiling":
		chef_enhance = 1.25
	
	for tech in player.techniques:
		var tech_cuisine_raw = str(tech.get("cuisine", ""))
		var tech_cuisine = _normalize_cuisine(tech_cuisine_raw)
		
		# Check if technique applies to this dish
		var applies = false
		if tech_cuisine == "" or tech_cuisine == dish_cuisine:
			applies = true
		# Check tag restrictions
		var restrictions = tech.get("restrictions", [])
		if not restrictions.is_empty():
			var has_match = false
			for r in restrictions:
				if r in dish_tags:
					has_match = true
					break
			if not has_match:
				applies = false
		
		if not applies:
			continue
		
		# Apply modifiers
		var mods = tech.get("modifiers", {})
		var enhance = chef_enhance if (tech_cuisine_raw == "chinese" or tech_cuisine == "chuuka") else 1.0
		
		for attr in mods:
			var mod_val = float(mods[attr]) * enhance
			match attr:
				"flavor":
					result.flavor_mult += mod_val
				"presentation":
					result.presentation_mult += mod_val
				"technique":
					result.technique_mult += mod_val
				"aroma":
					result.aroma_mult += mod_val
		
		# CD modifier
		result.cd_modifier += float(tech.get("cd_modifier", 0.0))
		
		# Extra tags from technique
		for tag in tech.get("added_tags", []):
			if tag not in result.extra_tags:
				result.extra_tags.append(tag)
		
		# Determine fusion/mastered status
		if tech_cuisine != "" and tech_cuisine != dish_cuisine and tech_cuisine != "":
			if "fusion" not in result.extra_tags:
				result.extra_tags.append("fusion")
		elif tech_cuisine != "" and tech_cuisine == dish_cuisine:
			if "mastered" not in result.extra_tags:
				result.extra_tags.append("mastered")
	
	return result

func apply_global_modifiers_to_stats(player: PlayerState, dish: Dictionary, base_stats: Dictionary) -> Dictionary:
	"""Apply all equipped technique modifiers to a dish's base stats."""
	var mods = get_global_modifiers(player, dish)
	var modified = base_stats.duplicate()
	
	modified["flavor"] = modified.get("flavor", 0.0) * mods.flavor_mult
	modified["presentation"] = modified.get("presentation", 0.0) * mods.presentation_mult
	modified["technique"] = modified.get("technique", 0.0) * mods.technique_mult
	modified["aroma"] = modified.get("aroma", 0.0) * mods.aroma_mult
	
	return modified

func get_cd_modifier(player: PlayerState, dish: Dictionary) -> float:
	"""Get total CD modifier from all applicable techniques for a dish."""
	var mods = get_global_modifiers(player, dish)
	return mods.cd_modifier

func get_extra_tags(player: PlayerState, dish: Dictionary) -> Array:
	"""Get extra tags granted by techniques for a dish."""
	var mods = get_global_modifiers(player, dish)
	return mods.extra_tags

func get_technique_summary(player: PlayerState) -> Array:
	"""Get summary of all equipped techniques for UI display."""
	var summaries: Array = []
	for tech in player.techniques:
		summaries.append({
			"id": tech.get("id", ""),
			"name": tech.get("name", ""),
			"cuisine": tech.get("cuisine", ""),
			"description": tech.get("description", ""),
			"modifiers": tech.get("modifiers", {}),
		})
	return summaries
