
import os

file_path = "e:/TouhouBazaar/systems/ShowdownResolver.gd"

with open(file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Keep lines 0 to 628 (which is index 628, since lines are 1-indexed in view_file, so index 0..627 are lines 1..628)
# view_file said line 629 is the first corrupted line.
# So we keep lines[0] to lines[627].
valid_lines = lines[:628]

new_code = """func _process_fusion_runtime_triggers(player_idx: int, runtime: Dictionary, context: Dictionary):
	var player = _match_state.get_player(player_idx)
	var item = runtime.item
	var tags = item.get("tags", [])
	var cuisine = item.get("cuisine", "")
	
	for f in _active_fusions[player_idx]:
		var bonuses = f.get("effect", {})
		if bonuses.is_empty(): bonuses = f.get("bonuses", {})
		
		# Mystia (Yatai + Washoku): Char Aroma -> Umami
		if bonuses.has("char_aroma_to_umami"):
			var ca = player.get_keyword_stacks("char_aroma")
			if ca >= 2:
				var convert = int(ca / 2)
				player.consume_keyword("char_aroma", convert * 2)
				player.add_keyword("umami", convert)
		
		# Reimu (Washoku + Yakuzen): Light -> Clear Env + Flavor
		if bonuses.has("env_clear_on_light") and "light" in tags:
			var cleared = false
			var debuffs = ["greasy", "messy", "taste_fatigue", "dull"]
			debuffs.shuffle()
			for d in debuffs:
				if _match_state.environment_keywords.get(d, 0) > 0:
					_match_state.clear_environment_keyword(d, 1)
					cleared = true
					break
			if cleared and bonuses.has("donation_flavor"):
				var bonus = float(bonuses.donation_flavor)
				var cur_bonus = context.get("score_bonus", {})
				cur_bonus["flavor"] = cur_bonus.get("flavor", 0.0) + bonus
				context["score_bonus"] = cur_bonus

		# Marisa (Yatai + Yakuzen): Random Bonus on Yatai
		if bonuses.has("random_bonus_on_grill") and cuisine == "yatai":
			if randf() < 0.20:
				var buffs = ["umami", "char_aroma", "plating", "knife_work"]
				var pick = buffs[randi() % buffs.size()]
				player.add_keyword(pick, 1)
		
		# Reisen (Kanmi + Yakuzen): Aftertaste -> Secret Scheme
		if bonuses.has("aftertaste_to_secret"):
			var at = player.get_keyword_stacks("aftertaste")
			var thresh = int(bonuses.get("conversion_threshold", 3))
			if at >= thresh:
				var count = int(at / thresh)
				player.consume_keyword("aftertaste", count * thresh)
				player.add_keyword("secret_recipe", count)
"""

with open(file_path, "w", encoding="utf-8") as f:
    f.writelines(valid_lines)
    f.write(new_code)

print("Fixed ShowdownResolver.gd")
