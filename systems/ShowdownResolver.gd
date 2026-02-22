extends RefCounted
class_name ShowdownResolver

# Simulates showdown ticks, score production, and post-battle analysis payloads.
var _match_state: MatchState = null
var _trigger_system: TriggerSystem = null
var _keyword_manager: KeywordManager = null

# Runtime item states: player_idx -> [{item, slot_idx, current_cd, base_cd, activate_count, tick_accum}]
var _item_runtimes: Array = [[], []]
var _scores: Array = [0.0, 0.0]
var _presentation_totals: Array = [0.0, 0.0]
var _technique_mults: Array = [1.0, 1.0]
var _aroma_reductions: Array = [0.0, 0.0]
var _dot_totals: Array = [0.0, 0.0]

var _elapsed: float = 0.0
var _duration: float = 30.0
var _tick_interval: float = 0.1
var _running: bool = false

var _serve_log: Array = []

# === 战斗播报系统 ===
var _broadcast_log: Array = []  # [{time, type, text, player_idx}]
var _highlight_moments: Array = []  # 高光时刻标记

# Per-cuisine flavor scores for clash mechanic: [{cuisine: float}, {cuisine: float}]
var _cuisine_scores: Array = [{}, {}]

# Cached active synergies per player for keyword_trigger checks
var _player_synergies: Array = [[], []]

# Cumulative item score by slot: player_idx -> {slot_idx: float}
var _item_cumulative_scores: Array = [{}, {}]
# Clash penalty records: [{cuisine, loser_idx, penalty}]
var _clash_penalties: Array = []

# Fusion / Synergy state
var _active_fusions: Array = [[], []]
var _fusion_presentation_mults: Array = [1.0, 1.0]
var _fusion_all_attr_bonus: Array = [0.0, 0.0]

func _init(match_state: MatchState):
	_match_state = match_state
	_trigger_system = TriggerSystem.new(match_state)
	_keyword_manager = KeywordManager.new(match_state)
	_duration = GameConfig.SHOWDOWN_DURATION
	_tick_interval = GameConfig.TICK_INTERVAL

func setup():
	_match_state.reset_for_showdown()
	_scores = [0.0, 0.0]
	_elapsed = 0.0
	_serve_log.clear()
	_broadcast_log.clear()
	_highlight_moments.clear()
	_cuisine_scores = [{}, {}]
	_player_synergies = [[], []]
	_item_cumulative_scores = [{}, {}]
	_clash_penalties = []
	_dot_totals = [0.0, 0.0]

	_active_fusions = [[], []]
	_fusion_presentation_mults = [1.0, 1.0]
	_fusion_all_attr_bonus = [0.0, 0.0]
	_keyword_manager.reset_fusion_multipliers()

	for p_idx in range(2):
		_item_runtimes[p_idx].clear()
		var player = _match_state.get_player(p_idx)
		var board_items = player.get_board_items()

		# Identify cuisines and fusion combos
		var cuisine_counts = {}
		for entry in board_items:
			var c = entry.item.get("cuisine", "")
			if c != "":
				cuisine_counts[c] = cuisine_counts.get(c, 0) + 1
		
		# Check synergy (3+ of same cuisine)
		for c in cuisine_counts:
			if cuisine_counts[c] >= 3:
				var syn = CuisineDatabase.cuisines.get(c, {}).get("synergy", {})
				if not syn.is_empty():
					_active_fusions[p_idx].append(syn)
		
		# Check fusion combos (2+ distinct cuisines or special combos)
		var active_c_list = cuisine_counts.keys()
		# For fusion combos defined in CuisineDatabase
		for fid in CuisineDatabase.fusion_combos:
			var combo = CuisineDatabase.fusion_combos[fid]
			var reqs = combo.get("required_cuisines", [])
			if reqs.is_empty(): # Special case like World Expo
				pass # TODO: Implement World Expo logic (4+ cuisines)
			else:
				var match_all = true
				for r in reqs:
					if not cuisine_counts.has(r) or cuisine_counts[r] < 1:
						match_all = false
						break
				if match_all:
					_active_fusions[p_idx].append(combo)

		# World Expo check
		if cuisine_counts.size() >= 4:
			var we = CuisineDatabase.fusion_combos.get("world_expo", {})
			if not we.is_empty():
				_active_fusions[p_idx].append(we)

		# Cache active synergies for keyword_trigger checks during showdown
		_player_synergies[p_idx] = SynergyManager.check_synergies(player)

		for entry in board_items:
			var item = entry.item
			var base_cd = float(item.get("cooldown", 5.0))

			# NEW: Apply global technique CD modifiers (relic system)
			var tech_cd_mod = TechniqueManager.get_cd_modifier(player, item)
			base_cd += tech_cd_mod

			# Legacy per-item enchant CD modifier (backward compat)
			var tech_id = item.get("enchant", "")
			if tech_id != "":
				var tech = TechniqueDatabase.get_technique(tech_id)
				if not tech.is_empty():
					base_cd += float(tech.get("cd_modifier", 0.0))

			var chef = ChefDatabase.get_chef(player.chef_id)
			if not chef.is_empty() and chef.get("id", "") == "sakuya":
				base_cd = maxf(1.0, base_cd - 1.0)
			base_cd = maxf(1.0, base_cd)

			var runtime = {
				"item": item,
				"slot_idx": entry.slot_idx,
				"base_cd": base_cd,
				"current_cd": base_cd,
				"activate_count": 0,
				"tick_accum": {},
				# 加速/减速计时器（秒）和倍率
				"haste_time": 0.0,
				"haste_mult": 1.0,
				"slow_time": 0.0,
				"slow_mult": 1.0,
			}
			_item_runtimes[p_idx].append(runtime)

		_presentation_totals[p_idx] = _calc_presentation_total(p_idx)

		var tech_total = player.get_total_attr("technique")
		_technique_mults[p_idx] = GameConfig.get_technique_multiplier(tech_total)

		var aroma_total = player.get_total_attr("aroma")
		_aroma_reductions[p_idx] = GameConfig.get_aroma_cd_reduction(aroma_total)

		# Apply static fusion/synergy bonuses
		for f in _active_fusions[p_idx]:
			var bonuses = f.get("effect", {})
			if bonuses.is_empty(): bonuses = f.get("bonuses", {}) # Synergy uses 'effect', Fusion uses 'bonuses'
			
			# CD Reduction (e.g. Chuuka Synergy)
			if bonuses.has("chuuka_cd_reduction"):
				var reduction = float(bonuses.chuuka_cd_reduction)
				for rt in _item_runtimes[p_idx]:
					if rt.item.get("cuisine", "") == "chuuka":
						rt.base_cd *= (1.0 - reduction)
						rt.current_cd = rt.base_cd # Apply to initial CD too? Usually yes

			# Presentation Bonus (e.g. Youshoku Synergy or World Expo)
			if bonuses.has("presentation_output_bonus"):
				_fusion_presentation_mults[p_idx] += float(bonuses.presentation_output_bonus)
			
			if bonuses.has("board_presentation"):
				# World Expo: +20% presentation
				_fusion_presentation_mults[p_idx] += float(bonuses.board_presentation)
			
			# All Stats (e.g. 5-Element Library)
			if bonuses.has("all_attr_bonus"):
				var boost = float(bonuses.all_attr_bonus)
				_fusion_all_attr_bonus[p_idx] += boost

			# Keyword Multipliers (Kanmi/Yakuzen)
			if bonuses.has("aftertaste_bonus_mult"):
				_keyword_manager.set_fusion_multiplier(p_idx, "aftertaste", float(bonuses.aftertaste_bonus_mult))
			if bonuses.has("secret_recipe_bonus"):
				_keyword_manager.set_fusion_multiplier(p_idx, "secret_recipe", 1.0 + float(bonuses.secret_recipe_bonus))

	_trigger_system.process_event("showdown_start", {"player_idx": 0})
	_trigger_system.process_event("showdown_start", {"player_idx": 1})

	SignalBus.showdown_started.emit()
	_running = true

func tick(delta: float):
	if not _running:
		return

	_elapsed += delta
	_match_state.showdown_elapsed = _elapsed

	if _elapsed >= _duration:
		_finish()
		return

	for p_idx in range(2):
		var env_cd_penalty = _keyword_manager.get_environment_cd_penalty()
		for runtime in _item_runtimes[p_idx]:
			_keyword_manager.apply_spotlight(p_idx, runtime)
			_process_item_tick_triggers(p_idx, runtime, delta)

			var cd_reduction_mult = 1.0 - _aroma_reductions[p_idx]
			var effective_tick = delta / maxf(0.1, cd_reduction_mult)

			# 加速/减速倍率（互相独立，加速优先级更高）
			var rate_mult := 1.0
			if runtime.haste_time > 0.0:
				rate_mult *= runtime.haste_mult
				runtime.haste_time -= delta
				if runtime.haste_time < 0.0:
					runtime.haste_time = 0.0
					runtime.haste_mult = 1.0
			if runtime.slow_time > 0.0:
				rate_mult *= runtime.slow_mult
				runtime.slow_time -= delta
				if runtime.slow_time < 0.0:
					runtime.slow_time = 0.0
					runtime.slow_mult = 1.0
			runtime.current_cd -= effective_tick * rate_mult

			if runtime.current_cd <= 0:
				_activate_item(p_idx, runtime)
				var new_cd = runtime.base_cd * (1.0 - _aroma_reductions[p_idx]) + env_cd_penalty
				runtime.current_cd = maxf(1.0, new_cd)

	_apply_presentation_dot(delta)
	_match_state.showdown_scores = _scores.duplicate()
	SignalBus.showdown_tick.emit(_elapsed)

func _process_item_tick_triggers(player_idx: int, runtime: Dictionary, delta: float):
	var item = runtime.item
	var slot_idx = int(runtime.slot_idx)
	var triggers = item.get("triggers", [])
	if triggers.is_empty():
		return

	var tick_accum: Dictionary = runtime.get("tick_accum", {})
	for i in range(triggers.size()):
		var trigger = triggers[i]
		if not (trigger is Dictionary):
			continue
		var ev = str(trigger.get("event", "")).to_lower()
		if ev != "on_tick":
			continue

		var interval = maxf(0.1, float(trigger.get("interval", 1.0)))
		var acc = float(tick_accum.get(i, 0.0)) + delta
		while acc >= interval:
			acc -= interval
			var context = {
				"player_idx": player_idx,
				"item_idx": slot_idx,
				"item_data": item,
				"score_bonus": {},
			}
			_trigger_system._execute_effect(trigger.get("effect", {}), player_idx, slot_idx, item, context)
			var bonus = context.get("score_bonus", {})
			if bonus.has("flavor"):
				_scores[player_idx] += float(bonus["flavor"])
		tick_accum[i] = acc

	runtime["tick_accum"] = tick_accum

func _activate_item(player_idx: int, runtime: Dictionary):
	var item = runtime.item
	var slot_idx = int(runtime.slot_idx)
	var player = _match_state.get_player(player_idx)
	runtime.activate_count += 1

	var base_scores = item.get("base_stats", {}).duplicate()

	# --- NEW: Apply global technique relic modifiers ---
	base_scores = TechniqueManager.apply_global_modifiers_to_stats(player, item, base_scores)

	# --- Chef skill modifiers (data-driven) ---
	var chef = ChefDatabase.get_chef(player.chef_id)
	var skill_effect = {} if chef.is_empty() else chef.get("skill", {}).get("effect", {})

	# Meiling: char_aroma bonus
	if skill_effect.get("char_aroma_bonus_mult", 0.0) > 0:
		var aroma_stacks = player.get_keyword_stacks("char_aroma")
		if aroma_stacks > 0:
			var bonus = aroma_stacks * skill_effect.char_aroma_bonus_mult
			base_scores["flavor"] = float(base_scores.get("flavor", 0)) * (1.0 + bonus * 0.1)

	# Alice: plating bonus
	if skill_effect.get("plating_output_bonus", 0.0) > 0:
		base_scores["presentation"] = float(base_scores.get("presentation", 0)) * (1.0 + skill_effect.plating_output_bonus)

	# Seija: swap lowest and highest attribute values
	if skill_effect.get("swap_min_max_attrs", false):
		var attr_keys = ["flavor", "presentation", "technique", "aroma"]
		var min_attr := ""
		var max_attr := ""
		var min_val := INF
		var max_val := -INF
		for attr_key in attr_keys:
			var val = float(base_scores.get(attr_key, 0.0))
			if val < min_val:
				min_val = val
				min_attr = attr_key
			if val > max_val:
				max_val = val
				max_attr = attr_key
		if min_attr != "" and max_attr != "" and min_attr != max_attr:
			base_scores[min_attr] = max_val
			base_scores[max_attr] = min_val

	var tech_id = item.get("enchant", "")
	if tech_id != "":
		var tech = TechniqueDatabase.get_technique(tech_id)
		if not tech.is_empty():
			var mods = tech.get("modifiers", {})
			for attr in mods:
				base_scores[attr] = base_scores.get(attr, 0.0) * (1.0 + float(mods[attr]))

	# --- Fusion Global Attribute Bonus ---
	if _fusion_all_attr_bonus[player_idx] > 0:
		var bonus = _fusion_all_attr_bonus[player_idx]
		for k in base_scores:
			base_scores[k] = base_scores.get(k, 0.0) * (1.0 + bonus)

	# --- Fusion Triggers (Activation) ---
	for f in _active_fusions[player_idx]:
		var bonuses = f.get("effect", {})
		if bonuses.is_empty(): bonuses = f.get("bonuses", {})
		
		# Yatai Synergy: First activation bonus
		if bonuses.has("first_activate_flavor_mult"):
			if runtime.activate_count == 1: # This is the first activation
				var mult = float(bonuses.first_activate_flavor_mult)
				base_scores["flavor"] = base_scores.get("flavor", 0.0) * mult


	# --- Tracking: base flavor before keyword modifiers ---
	var _pre_kw_flavor = float(base_scores.get("flavor", 0.0))

	var modified_scores = _keyword_manager.apply_keyword_modifiers(player_idx, base_scores)

	var _post_kw_flavor = float(modified_scores.get("flavor", 0.0))

	# --- Rich/Light keyword active effects (tag-based) ---
	var _pre_tag_flavor = float(modified_scores.get("flavor", 0.0))
	var tags = item.get("tags", [])
	if "rich" in tags:
		_match_state.add_environment_keyword("greasy", 2)
		modified_scores["flavor"] = modified_scores.get("flavor", 0.0) * 1.2
	if "light" in tags:
		_match_state.clear_environment_keyword("greasy", 1)
		_match_state.clear_environment_keyword("taste_fatigue", 1)
	var _tag_flavor_delta = float(modified_scores.get("flavor", 0.0)) - _pre_tag_flavor

	var context = {
		"player_idx": player_idx,
		"item_idx": slot_idx,
		"item_data": item,
		"score_bonus": {},
		"activate_count": runtime.activate_count,
	}

	SignalBus.item_activated.emit(player_idx, slot_idx, item)
	_trigger_system.process_event("item_activated", context)

	for effect in item.get("on_activate", []):
		if effect is Dictionary:
			_trigger_system._execute_effect(effect, player_idx, slot_idx, item, context)

	# --- Synergy keyword_trigger effects ---
	_process_synergy_keyword_triggers(player_idx, item, slot_idx, context)

	# --- Fusion Runtime Triggers ---
	_process_fusion_runtime_triggers(player_idx, runtime, context)

	var score_bonus: Dictionary = context.get("score_bonus", {})
	for attr in score_bonus:
		modified_scores[attr] = modified_scores.get(attr, 0.0) + float(score_bonus[attr])
	var _trigger_flavor = float(score_bonus.get("flavor", 0.0))

	# --- 消费 context 里的 CD 操控效果 ---
	# 缩减自身
	var cd_self := float(context.get("cd_reduction_self", 0.0))
	if cd_self > 0.0:
		runtime.current_cd = maxf(1.0, runtime.current_cd - cd_self)
	# 缩减相邻
	var cd_adj := float(context.get("cd_reduction_adjacent", 0.0))
	if cd_adj > 0.0:
		for other in _item_runtimes[player_idx]:
			if abs(int(other.slot_idx) - slot_idx) == 1:
				other.current_cd = maxf(1.0, other.current_cd - cd_adj)
	# 增加自身冷却
	var cd_inc := float(context.get("cd_increase_self", 0.0))
	if cd_inc > 0.0:
		runtime.current_cd += cd_inc
	# 加速自身
	if context.has("haste_self"):
		var h = context["haste_self"]
		runtime.haste_time  = maxf(runtime.haste_time, float(h.get("duration", 1.0)))
		runtime.haste_mult  = float(h.get("multiplier", 2.0))
	# 加速相邻
	if context.has("haste_adjacent"):
		var h = context["haste_adjacent"]
		for other in _item_runtimes[player_idx]:
			if abs(int(other.slot_idx) - slot_idx) == 1:
				other.haste_time = maxf(other.haste_time, float(h.get("duration", 1.0)))
				other.haste_mult = float(h.get("multiplier", 2.0))
	# 减速对手相邻（最近的那个）
	if context.has("slow_opponent"):
		var s = context["slow_opponent"]
		var opp_idx = 1 - player_idx
		for other in _item_runtimes[opp_idx]:
			other.slow_time = maxf(other.slow_time, float(s.get("duration", 1.0)))
			other.slow_mult = float(s.get("multiplier", 0.5))

	var flavor = float(modified_scores.get("flavor", 0.0))
	flavor *= _technique_mults[player_idx]

	# --- Tracking: combined judge flavor multiplier ---
	var _judge_flavor_mult = 1.0
	for judge in _match_state.judges:
		var scoring = judge.get("scoring_modifiers", {})
		if scoring.has("flavor_mult"):
			_judge_flavor_mult *= float(scoring.flavor_mult)
	flavor *= _judge_flavor_mult

	# --- Youmu passive ---
	var _youmu_doubled = false
	if not chef.is_empty() and chef.get("id", "") == "youmu" and item.get("size", 1) == 1:
		if randf() < 0.3:
			flavor *= 2.0
			_youmu_doubled = true

	var _clamped_flavor = maxf(0.0, flavor)
	_scores[player_idx] += _clamped_flavor
	_presentation_totals[player_idx] = _calc_presentation_total(player_idx)

	# --- Accumulate per-item score contribution ---
	_item_cumulative_scores[player_idx][slot_idx] = _item_cumulative_scores[player_idx].get(slot_idx, 0.0) + _clamped_flavor

	# --- Track per-cuisine flavor scores for clash mechanic ---
	var cuisine = item.get("cuisine", "")
	var item_tags = item.get("tags", [])
	if cuisine != "" and not ("fusion" in item_tags):
		_cuisine_scores[player_idx][cuisine] = _cuisine_scores[player_idx].get(cuisine, 0.0) + _clamped_flavor

	var log_entry = {
		"time": _elapsed,
		"player_idx": player_idx,
		"item_name": item.get("name", "???"),
		"flavor_produced": flavor,
		"activate_count": runtime.activate_count,
	}
	_serve_log.append(log_entry)

	# === 战斗播报生成 ===
	_generate_serve_broadcast(player_idx, item, _clamped_flavor, runtime.activate_count, _youmu_doubled)

	SignalBus.showdown_item_served.emit(player_idx, slot_idx, {
		"flavor": flavor,
		"item": item,
		"base_flavor": _pre_kw_flavor,
		"keyword_bonus": _post_kw_flavor - _pre_kw_flavor,
		"tag_bonus": _tag_flavor_delta,
		"trigger_bonus": _trigger_flavor,
		"technique_mult": _technique_mults[player_idx],
		"judge_mult": _judge_flavor_mult,
		"youmu_doubled": _youmu_doubled,
	})

func _apply_presentation_dot(delta: float):
	var diff = _presentation_totals[0] - _presentation_totals[1]
	if absf(diff) < 0.01:
		return

	var dot_coeff = GameConfig.PRESENTATION_DOT_COEFF
	for judge in _match_state.judges:
		var scoring = judge.get("scoring_modifiers", {})
		if scoring.has("dot_mult"):
			dot_coeff *= float(scoring.dot_mult)

	if diff > 0:
		var dot = diff * dot_coeff * _technique_mults[0] * delta
		_scores[0] += dot
		_dot_totals[0] += dot
		SignalBus.dot_tick.emit(0, dot)
	else:
		var dot = absf(diff) * dot_coeff * _technique_mults[1] * delta
		_scores[1] += dot
		_dot_totals[1] += dot
		SignalBus.dot_tick.emit(1, dot)

func _calc_presentation_total(player_idx: int) -> float:
	var player = _match_state.get_player(player_idx)
	var total = player.get_total_attr("presentation")
	total += player.get_keyword_stacks("plating") * 3.0
	var messy = _match_state.environment_keywords.get("messy", 0)
	total -= messy * 2.0
	
	# Apply Fusion Modifiers
	total *= _fusion_presentation_mults[player_idx]
	
	return maxf(0.0, total)

func _finish():
	_running = false
	_trigger_system.process_event("showdown_end", {"player_idx": 0})
	_trigger_system.process_event("showdown_end", {"player_idx": 1})

	# --- Clash mechanic: penalize loser of each shared cuisine ---
	_apply_cuisine_clash()

	for judge in _match_state.judges:
		if judge.get("id") == "eiki":
			var total = _scores[0] + _scores[1]
			if total > 0:
				var diff_ratio = absf(_scores[0] - _scores[1]) / (total / 2.0)
				if diff_ratio < 0.10:
					_scores[0] *= 1.3
					_scores[1] *= 1.3

	_match_state.showdown_scores = _scores.duplicate()
	_match_state.showdown_running = false
	_generate_finish_broadcast()
	SignalBus.showdown_ended.emit()

func _apply_cuisine_clash():
	"""Clash mechanic: for each shared cuisine, the player with lower
	cuisine-specific flavor gets their cuisine items' total score multiplied
	by CLASH_LOSER_SCORE_MULT. Fusion items are exempt."""
	# Gather which cuisines each player has (excluding fusion-tagged items)
	var cuisine_items: Array = [{}, {}]  # player_idx -> {cuisine: [item_refs]}
	for p_idx in range(2):
		for runtime in _item_runtimes[p_idx]:
			var item = runtime.item
			var item_tags = item.get("tags", [])
			if "fusion" in item_tags:
				continue  # fusion items exempt from clash
			var cuisine = item.get("cuisine", "")
			if cuisine == "":
				continue
			if not cuisine_items[p_idx].has(cuisine):
				cuisine_items[p_idx][cuisine] = true

	# Find shared cuisines and apply penalty to loser
	for cuisine in _cuisine_scores[0]:
		if not _cuisine_scores[1].has(cuisine):
			continue
		# Both players have items of this cuisine -- check if non-fusion items exist
		if not cuisine_items[0].has(cuisine) or not cuisine_items[1].has(cuisine):
			continue
		var score_0 = _cuisine_scores[0].get(cuisine, 0.0)
		var score_1 = _cuisine_scores[1].get(cuisine, 0.0)
		if absf(score_0 - score_1) < 0.001:
			continue  # tie, no penalty
		var loser_idx = 0 if score_0 < score_1 else 1
		var loser_cuisine_score = _cuisine_scores[loser_idx].get(cuisine, 0.0)
		var penalty = loser_cuisine_score * (1.0 - GameConfig.CLASH_LOSER_SCORE_MULT)
		_scores[loser_idx] -= penalty
		_clash_penalties.append({"cuisine": cuisine, "loser_idx": loser_idx, "penalty": penalty})

func _process_synergy_keyword_triggers(player_idx: int, item: Dictionary, slot_idx: int, context: Dictionary):
	"""Check active synergies for keyword_trigger effects that match this item."""
	var synergies = _player_synergies[player_idx]
	var item_tags = item.get("tags", [])
	var item_size = item.get("size", 1)
	var item_cuisine = item.get("cuisine", "")
	var player = _match_state.get_player(player_idx)

	for synergy in synergies:
		var kw_triggers = synergy.get("keyword_trigger", {})
		if kw_triggers.is_empty():
			continue

		for trigger_key in kw_triggers:
			var trigger_data = kw_triggers[trigger_key]
			if not _does_trigger_match(trigger_key, item, item_tags, item_size, item_cuisine):
				continue

			# Execute the trigger effect
			if trigger_data.has("add_keyword"):
				var kw_id = str(trigger_data["add_keyword"])
				var stacks = int(trigger_data.get("keyword_stacks", 1))
				var target = str(trigger_data.get("target", "self"))

				if target == "random_adjacent":
					# Pick a random adjacent item runtime and give it spotlight
					var adjacent_runtimes = _get_adjacent_runtimes(player_idx, slot_idx)
					if not adjacent_runtimes.is_empty():
						var picked = adjacent_runtimes[randi() % adjacent_runtimes.size()]
						# Spotlight is applied to the player, not item-specific
						player.add_keyword(kw_id, stacks)
				else:
					player.add_keyword(kw_id, stacks)

			if trigger_data.has("consume_all_keywords") and trigger_data["consume_all_keywords"]:
				# Consume all buff keywords and apply multiplier
				var effect_mult = float(trigger_data.get("effect_mult", 1.0))
				var total_consumed := 0
				for buff_kw in GameConfig.KEYWORD_TYPES.get("buff", []):
					total_consumed += player.consume_keyword(buff_kw)
				if total_consumed > 0:
					var bonus_flavor = float(context.get("score_bonus", {}).get("flavor", 0.0))
					context["score_bonus"]["flavor"] = bonus_flavor + total_consumed * effect_mult

func _does_trigger_match(trigger_key: String, item: Dictionary, item_tags: Array, item_size: int, item_cuisine: String) -> bool:
	"""Check if a synergy keyword_trigger key matches the current item."""
	match trigger_key:
		"on_serve_any":
			return true
		"on_serve_small":
			return item_size == 1
		"on_serve_large":
			return item_size == 3
		"on_serve_fusion":
			return "fusion" in item_tags
		"on_serve_mastered":
			return "mastered" in item_tags
		"on_serve_method":
			# Matches if item has any cooking method tag
			var methods = ["grilled", "stewed", "fried", "raw", "steamed", "stir_fried"]
			for m in methods:
				if m in item_tags:
					return true
			return false
		_:
			# Check cuisine-based triggers like "on_serve_chinese"
			if trigger_key.begins_with("on_serve_"):
				var cuisine_key = trigger_key.substr(9)  # strip "on_serve_"
				return item_cuisine == cuisine_key or cuisine_key in item_tags
			return false

func _get_adjacent_runtimes(player_idx: int, slot_idx: int) -> Array:
	"""Get runtime entries for items adjacent to the given slot."""
	var player = _match_state.get_player(player_idx)
	var adj_items = player.get_adjacent(slot_idx)
	var result: Array = []
	for runtime in _item_runtimes[player_idx]:
		for adj_item in adj_items:
			if runtime.item == adj_item:
				result.append(runtime)
				break
	return result

func get_scores() -> Array:
	return _scores

func get_serve_log() -> Array:
	return _serve_log

func get_elapsed() -> float:
	return _elapsed

func is_running() -> bool:
	return _running

func get_item_runtimes(player_idx: int) -> Array:
	return _item_runtimes[player_idx]

func get_technique_mults() -> Array:
	return _technique_mults

func get_aroma_reductions() -> Array:
	return _aroma_reductions

func get_presentation_totals() -> Array:
	return _presentation_totals

func get_player_synergies() -> Array:
	return _player_synergies

func get_analysis_data() -> Dictionary:
	# Structured data consumed by ResultScreen for post-battle explanation UI.
	var item_contributions: Array = [{}, {}]
	for p_idx in range(2):
		for slot_idx in _item_cumulative_scores[p_idx]:
			var score = _item_cumulative_scores[p_idx][slot_idx]
			var item_name = "???"
			for runtime in _item_runtimes[p_idx]:
				if int(runtime.slot_idx) == int(slot_idx):
					item_name = runtime.item.get("name", "???")
					break
			item_contributions[p_idx][int(slot_idx)] = {
				"name": item_name,
				"total_score": score,
			}
	return {
		"scores": _scores.duplicate(),
		"technique_mults": _technique_mults.duplicate(),
		"aroma_reductions": _aroma_reductions.duplicate(),
		"presentation_totals": _presentation_totals.duplicate(),
		"dot_totals": _dot_totals.duplicate(),
		"item_contributions": item_contributions,
		"clash_penalties": _clash_penalties.duplicate(),
		"player_synergies": _player_synergies.duplicate(),
		"serve_log": _serve_log.duplicate(),
	}

func _process_fusion_runtime_triggers(player_idx: int, runtime: Dictionary, context: Dictionary):
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
				_add_broadcast(player_idx, "keyword", "焦香化为鲜美！%d层焦香转化为%d层鲜美。" % [convert * 2, convert])

		# Reimu (Washoku + Yakuzen): Light -> Clear Env + Flavor
		if bonuses.has("env_clear_on_light") and "light" in tags:
			var cleared = false
			var debuffs = ["greasy", "messy", "taste_fatigue", "dull"]
			debuffs.shuffle()
			for d in debuffs:
				if _match_state.environment_keywords.get(d, 0) > 0:
					_match_state.clear_environment_keyword(d, 1)
					cleared = true
					_add_broadcast(player_idx, "synergy", "清淡之风吹散了%s！" % _get_env_name(d))
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
				_add_broadcast(player_idx, "keyword", "魔法实验成功！随机获得1层%s！" % _get_keyword_name(pick))

		# Reisen (Kanmi + Yakuzen): Aftertaste -> Secret Scheme
		if bonuses.has("aftertaste_to_secret"):
			var at = player.get_keyword_stacks("aftertaste")
			var thresh = int(bonuses.get("conversion_threshold", 3))
			if at >= thresh:
				var count = int(at / thresh)
				player.consume_keyword("aftertaste", count * thresh)
				player.add_keyword("secret_recipe", count)
				_add_broadcast(player_idx, "keyword", "回味凝聚为秘方！%d层回味转化为%d层秘方！" % [count * thresh, count])

# ============================================================
#  战斗播报系统
# ============================================================
func _generate_serve_broadcast(player_idx: int, item: Dictionary, score: float, activate_count: int, youmu_doubled: bool):
	var name = item.get("name", "???")
	var cuisine_names = {"chuuka": "中华", "washoku": "和食", "youshoku": "洋食", "yatai": "夜市", "kanmi": "甜品", "yakuzen": "药膳"}
	var cuisine = cuisine_names.get(item.get("cuisine", ""), "")

	# 基础上菜播报
	if score >= 100:
		_add_broadcast(player_idx, "serve_epic", "【%s】华丽上桌！评委们惊叹不已——%.0f分！" % [name, score])
		_highlight_moments.append({"time": _elapsed, "type": "epic_serve", "player": player_idx, "score": score, "item": name})
	elif score >= 50:
		_add_broadcast(player_idx, "serve_great", "【%s】完美呈现！%.0f分！" % [name, score])
	elif score >= 20:
		_add_broadcast(player_idx, "serve", "【%s】上菜——%.0f分。" % [name, score])
	else:
		_add_broadcast(player_idx, "serve_weak", "【%s】勉强端上……%.0f分。" % [name, score])

	# 妖梦二刀流
	if youmu_doubled:
		_add_broadcast(player_idx, "chef_skill", "妖梦的二刀流发动！【%s】双重触发！" % name)
		_highlight_moments.append({"time": _elapsed, "type": "youmu_double", "player": player_idx, "item": name})

	# 连击播报
	if activate_count == 3:
		_add_broadcast(player_idx, "combo", "【%s】三连击！节奏越来越快！" % name)
	elif activate_count == 5:
		_add_broadcast(player_idx, "combo", "【%s】五连击！势不可挡！" % name)
		_highlight_moments.append({"time": _elapsed, "type": "combo_5", "player": player_idx, "item": name})
	elif activate_count >= 8:
		_add_broadcast(player_idx, "combo", "【%s】%d连击！！这已经是传说级的表现了！" % [name, activate_count])

	# 分差播报（逆转/碾压）
	var my_score = _scores[player_idx]
	var opp_score = _scores[1 - player_idx]
	if my_score > opp_score and my_score - opp_score > 200 and opp_score > 100:
		if not _has_recent_broadcast("lead", player_idx, 3.0):
			_add_broadcast(player_idx, "lead", "大幅领先！分差已超过%.0f分！" % (my_score - opp_score))
	elif opp_score > my_score * 1.5 and my_score > 50 and score > 30:
		if not _has_recent_broadcast("comeback", player_idx, 5.0):
			_add_broadcast(player_idx, "comeback", "绝地反击的气息……还没有放弃！")

func _generate_finish_broadcast():
	"""Generate end-of-battle narrative."""
	var diff = absf(_scores[0] - _scores[1])
	var winner = 0 if _scores[0] > _scores[1] else 1
	var loser = 1 - winner

	if diff < 10:
		_add_broadcast(-1, "result", "势均力敌！双方几乎打成平手！最终比分：%.0f vs %.0f" % [_scores[0], _scores[1]])
		_highlight_moments.append({"time": _elapsed, "type": "photo_finish"})
	elif diff < 50:
		_add_broadcast(-1, "result", "险胜！最终比分：%.0f vs %.0f，仅差%.0f分！" % [_scores[0], _scores[1], diff])
	elif diff > 500:
		_add_broadcast(-1, "result", "碾压性胜利！%.0f vs %.0f！" % [_scores[0], _scores[1]])
		_highlight_moments.append({"time": _elapsed, "type": "domination", "winner": winner})
	else:
		_add_broadcast(-1, "result", "对决结束！最终比分：%.0f vs %.0f。" % [_scores[0], _scores[1]])

	# Clash penalties
	for clash in _clash_penalties:
		var cuisine_names = {"chuuka": "中华", "washoku": "和食", "youshoku": "洋食", "yatai": "夜市", "kanmi": "甜品", "yakuzen": "药膳"}
		var c_name = cuisine_names.get(clash.get("cuisine", ""), clash.get("cuisine", ""))
		_add_broadcast(-1, "clash", "撞菜惩罚！%s料理对决中落败方扣除%.0f分。" % [c_name, clash.get("penalty", 0)])

func _add_broadcast(player_idx: int, type: String, text: String):
	_broadcast_log.append({
		"time": _elapsed,
		"player_idx": player_idx,
		"type": type,
		"text": text,
	})

func _has_recent_broadcast(type: String, player_idx: int, within_seconds: float) -> bool:
	for entry in _broadcast_log:
		if entry.type == type and entry.player_idx == player_idx and (_elapsed - entry.time) < within_seconds:
			return true
	return false

func _get_env_name(env_id: String) -> String:
	match env_id:
		"greasy": return "油腻"
		"messy": return "杂乱"
		"taste_fatigue": return "味觉疲劳"
		"dull": return "沉闷"
	return env_id

func _get_keyword_name(kw_id: String) -> String:
	match kw_id:
		"umami": return "鲜美"
		"char_aroma": return "焦香"
		"plating": return "摆盘"
		"knife_work": return "刀工"
		"spotlight": return "瞩目"
		"aftertaste": return "回味"
		"secret_recipe": return "秘方"
	return kw_id

func get_broadcast_log() -> Array:
	return _broadcast_log

func get_highlight_moments() -> Array:
	return _highlight_moments
