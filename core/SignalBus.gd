extends Node

# === Item Events ===
signal item_activated(player_idx: int, item_idx: int, item_data: Dictionary)
signal item_placed(player_idx: int, item_idx: int, item_data: Dictionary)
signal item_removed(player_idx: int, item_idx: int, item_data: Dictionary)
signal item_sold(player_idx: int, item_data: Dictionary)

# === Keyword Events ===
signal keyword_gained(player_idx: int, item_idx: int, keyword_id: String, stacks: int)
signal keyword_consumed(player_idx: int, keyword_id: String, amount: int)
signal keyword_environment_applied(keyword_id: String, stacks: int, source_player: int)
signal keyword_environment_cleared(keyword_id: String, amount: int)

# === Score Events ===
signal score_produced(player_idx: int, item_idx: int, scores: Dictionary)
signal dot_tick(player_idx: int, dot_amount: float)

# === Trigger Events ===
signal trigger_fired(player_idx: int, item_idx: int, trigger_type: String)

# === Technique Events ===
signal technique_applied(player_idx: int, item_idx: int, technique_id: String)
signal technique_removed(player_idx: int, item_idx: int, old_technique_id: String)

# === Showdown Events ===
signal showdown_started()
signal showdown_tick(elapsed: float)
signal showdown_ended()
signal showdown_item_served(player_idx: int, item_idx: int, score_result: Dictionary)

# === Game Flow Events ===
signal phase_changed(new_phase: int)  # GameConfig.Phase enum
signal day_started(day_number: int)
signal day_ended(day_number: int)

# === Shop Events ===
signal shop_refreshed(player_idx: int)
signal item_purchased(player_idx: int, item_data: Dictionary)

# === UI Events ===
signal item_hovered(item_data: Dictionary)
signal item_unhovered()
signal item_clicked(item_data: Dictionary)
signal board_slot_clicked(slot_idx: int)

# === Ingredient Events ===
signal ingredient_applied(player_idx: int, dish_data: Dictionary, ingredient_data: Dictionary)
signal ingredient_failed(player_idx: int, reason: String)

# === Crafting Events ===
signal craft_completed(player_idx: int, result_item: Dictionary)
signal star_upgraded(player_idx: int, item_data: Dictionary, new_star: int)
signal showdown_skill_activated(player: String, tool_id: String, name: String)

# === Synergy Events ===
signal synergy_activated(player_idx: int, synergy_id: String)
signal synergy_deactivated(player_idx: int, synergy_id: String)

# === Encounter Events ===
signal encounter_started(encounter_data: Dictionary)
signal encounter_completed(result: Dictionary)

# === Match Events ===
signal prestige_changed(player_idx: int, old_val: int, new_val: int)
signal player_eliminated(player_idx: int)
signal match_ended(winner_idx: int)

# === Level Events ===
signal player_leveled_up(player_idx: int, new_level: int)
signal xp_gained(player_idx: int, new_xp: int, xp_max: int)
