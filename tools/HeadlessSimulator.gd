## 无头对战模拟器 (Headless Battle Simulator)
##
## 复用 ShowdownResolver 逻辑，跳过所有UI/信号/渲染。
## 用于自动化平衡性测试。
##
## 用法:
##   var sim = HeadlessSimulator.new()
##   var result = sim.run_batch(loadout_a, loadout_b, 1000)
##   print(result.win_rate_a)  # 0.52

extends RefCounted
class_name HeadlessSimulator

## ---------- Loadout 数据结构 ----------
## {
##   "chef_id": "reimu",
##   "dish_ids": ["peking_duck", "kung_pao_chicken", ...],
##   "tool_ids": ["santoku", "cast_iron_pot"],
##   "technique_assignments": {"peking_duck": "charcoal_grill"},  # optional
## }

const TICK_DT := 0.1
const SHOWDOWN_DURATION := 30.0

## ---------- 单场模拟 ----------
func simulate_once(loadout_a: Dictionary, loadout_b: Dictionary, rng_seed: int = -1) -> Dictionary:
	if rng_seed >= 0:
		seed(rng_seed)

	var match_state = MatchState.new()
	match_state.reset_for_showdown()

	# Setup players
	var players_data = [loadout_a, loadout_b]
	for i in range(2):
		var player: PlayerState = match_state.get_player(i)
		player.chef_id = players_data[i].get("chef_id", "")
		_populate_board(player, players_data[i])
		_equip_tools(player, players_data[i])

	# Pick random judges
	var all_judges = JudgeDatabase.get_all()
	if all_judges.size() >= 2:
		all_judges.shuffle()
		match_state.judges = [all_judges[0], all_judges[1]]

	# Run simulation
	var scores := [0.0, 0.0]
	var keyword_counts := [{}, {}]
	var env_stacks_total: Dictionary = {}
	var activation_counts := [{}, {}]

	# Build runtime items
	var runtimes := [[], []]
	for pi in range(2):
		var player: PlayerState = match_state.get_player(pi)
		for entry in player.get_board_items():
			var rt := {
				"item": entry.item,
				"slot_idx": entry.slot_idx,
				"cd_remaining": 0.0,
				"base_cd": float(entry.item.get("cooldown", 3.0)),
				"activate_count": 0,
			}
			runtimes[pi].append(rt)

	var trigger_system = TriggerSystem.new(match_state)
	var elapsed := 0.0

	while elapsed < SHOWDOWN_DURATION:
		elapsed += TICK_DT

		for pi in range(2):
			var player: PlayerState = match_state.get_player(pi)

			# Aroma CD reduction
			var aroma_total := player.get_total_attr("aroma")
			var cd_reduction := GameConfig.get_aroma_cd_reduction(aroma_total)

			for rt in runtimes[pi]:
				rt.cd_remaining -= TICK_DT
				if rt.cd_remaining <= 0.0:
					rt.activate_count += 1
					var item = rt.item
					var slot_idx = rt.slot_idx

					# Track activations
					var item_id = str(item.get("id", "unknown"))
					activation_counts[pi][item_id] = activation_counts[pi].get(item_id, 0) + 1

					# Execute on_activate effects
					var context := {
						"player_idx": pi,
						"item_idx": slot_idx,
						"item_data": item,
						"activate_count": rt.activate_count,
						"score_bonus": {"flavor": 0.0, "presentation": 0.0, "technique": 0.0, "aroma": 0.0},
					}

					for effect in item.get("on_activate", []):
						trigger_system._execute_effect(effect, pi, slot_idx, item, context)

					# Process triggers
					trigger_system.process_event("item_activated", context)

					# Calculate score from base_stats + bonuses
					var base = item.get("base_stats", {})
					var bonus = context.get("score_bonus", {})
					var flavor = float(base.get("flavor", 0)) + float(bonus.get("flavor", 0))
					var technique_val = float(base.get("technique", 0)) + float(bonus.get("technique", 0))
					var tech_mult = GameConfig.get_technique_multiplier(technique_val)

					# Apply judge modifiers
					for judge in match_state.judges:
						var mods = judge.get("scoring_modifiers", {})
						if mods.has("flavor_mult"):
							flavor *= float(mods.flavor_mult)

					var item_score = flavor * tech_mult
					scores[pi] += maxf(0.0, item_score)

					# Track keywords
					for kw in player.keyword_stacks:
						keyword_counts[pi][kw] = keyword_counts[pi].get(kw, 0) + player.keyword_stacks[kw]

					# Reset CD
					var effective_cd = rt.base_cd * (1.0 - cd_reduction)
					rt.cd_remaining = effective_cd

		# Tick-based triggers
		for pi in range(2):
			for rt in runtimes[pi]:
				trigger_system.process_event("item_tick", {
					"player_idx": pi,
					"item_idx": rt.slot_idx,
					"item_data": rt.item,
				})

		# Track environment
		for env_kw in match_state.environment_keywords:
			env_stacks_total[env_kw] = env_stacks_total.get(env_kw, 0) + match_state.environment_keywords[env_kw]

	# Presentation DoT
	var pres := [0.0, 0.0]
	for pi in range(2):
		pres[pi] = match_state.get_player(pi).get_total_attr("presentation")
	var pres_diff = pres[0] - pres[1]
	if pres_diff > 0:
		var dot_total = pres_diff * GameConfig.PRESENTATION_DOT_COEFF * SHOWDOWN_DURATION
		scores[0] += dot_total
	elif pres_diff < 0:
		var dot_total = absf(pres_diff) * GameConfig.PRESENTATION_DOT_COEFF * SHOWDOWN_DURATION
		scores[1] += dot_total

	# Result
	var winner := -1
	if scores[0] > scores[1]:
		winner = 0
	elif scores[1] > scores[0]:
		winner = 1

	return {
		"winner": winner,
		"scores": scores,
		"keyword_counts": keyword_counts,
		"env_stacks_total": env_stacks_total,
		"activation_counts": activation_counts,
	}


## ---------- 批量模拟 ----------
func run_batch(loadout_a: Dictionary, loadout_b: Dictionary, count: int = 1000) -> Dictionary:
	var wins := [0, 0, 0]  # [A, B, draw]
	var total_scores := [0.0, 0.0]
	var keyword_totals := [{}, {}]
	var env_totals: Dictionary = {}
	for i in range(count):
		var result = simulate_once(loadout_a, loadout_b, i * 31337)
		match result.winner:
			0: wins[0] += 1
			1: wins[1] += 1
			_: wins[2] += 1

		total_scores[0] += result.scores[0]
		total_scores[1] += result.scores[1]

		for pi in range(2):
			for kw in result.keyword_counts[pi]:
				keyword_totals[pi][kw] = keyword_totals[pi].get(kw, 0) + result.keyword_counts[pi][kw]
		for env_kw in result.env_stacks_total:
			env_totals[env_kw] = env_totals.get(env_kw, 0) + result.env_stacks_total[env_kw]

	return {
		"count": count,
		"win_rate_a": float(wins[0]) / count,
		"win_rate_b": float(wins[1]) / count,
		"draw_rate": float(wins[2]) / count,
		"avg_score_a": total_scores[0] / count,
		"avg_score_b": total_scores[1] / count,
		"keyword_usage": keyword_totals,
		"environment_stats": env_totals,
	}


## ---------- 内部工具 ----------
func _populate_board(player: PlayerState, loadout: Dictionary):
	var dish_ids: Array = loadout.get("dish_ids", [])
	var technique_map: Dictionary = loadout.get("technique_assignments", {})
	var slot := 0
	for dish_id in dish_ids:
		var dish = DishDatabase.get_dish(str(dish_id))
		if dish.is_empty():
			continue
		var item = dish.duplicate(true)

		# Apply technique if assigned
		if technique_map.has(dish_id):
			var tech = TechniqueDatabase.get_technique(str(technique_map[dish_id]))
			if not tech.is_empty():
				item["enchant"] = tech.id
				for mod_key in tech.get("modifiers", {}):
					var base_val = float(item.get("base_stats", {}).get(mod_key, 0))
					item["base_stats"][mod_key] = base_val * (1.0 + float(tech.modifiers[mod_key]))
				item["cooldown"] = float(item.get("cooldown", 3.0)) + float(tech.get("cd_modifier", 0.0))
				for tag in tech.get("added_tags", []):
					if tag not in item.get("tags", []):
						item["tags"].append(tag)

		var size = int(item.get("size", 1))
		while slot + size > player.board_size:
			size -= 1
			if size <= 0:
				break
		if size <= 0:
			break
		player.place_item(slot, item)
		slot += int(item.get("size", 1))

func _equip_tools(player: PlayerState, loadout: Dictionary):
	var tool_ids: Array = loadout.get("tool_ids", [])
	for tool_id in tool_ids:
		if player.tools.size() >= player.max_tools:
			break
		var tool_data = ToolDatabase.get_tool(str(tool_id))
		if not tool_data.is_empty():
			player.tools.append(tool_data.duplicate(true))
