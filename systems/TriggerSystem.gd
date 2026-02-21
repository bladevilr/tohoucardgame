extends RefCounted
class_name TriggerSystem

var _chain_depth: int = 0
var _max_chain_depth: int = 10
var _match_state: Object = null
var _event_log: Array = []

func _init(match_state):
	_match_state = match_state
	_max_chain_depth = GameConfig.MAX_CHAIN_DEPTH

func process_event(event_type: String, context: Dictionary):
	if _chain_depth >= _max_chain_depth:
		return
	_chain_depth += 1

	var player_idx = int(context.get("player_idx", 0))
	var source_idx = int(context.get("item_idx", -1))
	var player: PlayerState = _match_state.get_player(player_idx)

	for entry in player.get_board_items():
		var item = entry.item
		var slot_idx = entry.slot_idx
		for trigger in item.get("triggers", []):
			if trigger is Dictionary and _matches_event(trigger, event_type, slot_idx, source_idx, context, player):
				_execute_effect(trigger.get("effect", {}), player_idx, slot_idx, item, context)
				_process_keyword_effect(trigger, player_idx, slot_idx, context)

	for tool in player.tools:
		for trigger in tool.get("triggers", []):
			if trigger is Dictionary and _matches_event(trigger, event_type, -1, source_idx, context, player):
				# Handle first_only flag: skip if not first activation
				if trigger.get("first_only", false) and context.get("activate_count", 0) != 1:
					continue
				_execute_effect(trigger.get("effect", {}), player_idx, -1, tool, context)
				_process_keyword_effect(trigger, player_idx, -1, context)

	_chain_depth -= 1
	if _chain_depth == 0:
		_event_log.clear()

func _normalize_event(trigger_event: String) -> String:
	var ev = trigger_event.strip_edges().to_lower()
	match ev:
		# Legacy cuisine-pool data uses this event id for self activation.
		"item_activated":
			return "self_activate"
		"when_this_activates", "on_self_activate":
			return "self_activate"
		"when_any_friend_activates", "on_friend_activate":
			return "friend_activate"
		"when_adjacent_activates", "on_adjacent_activate":
			return "adjacent_activate"
		"when_left_neighbor_activates", "on_left_activate":
			return "left_activate"
		"when_right_neighbor_activates", "on_right_activate":
			return "right_activate"
		"when_any_left_activates", "on_any_left_activate":
			return "any_left_activate"
		"when_any_right_activates", "on_any_right_activate":
			return "any_right_activate"
		"when_keyword_gained":
			return "keyword_gained"
		"when_keyword_consumed":
			return "keyword_consumed"
		"when_environment_applied":
			return "environment_applied"
		"on_showdown_start":
			return "showdown_start"
		"on_showdown_end":
			return "showdown_end"
		"when_adjacent_has_tag":
			return "adjacent_has_tag"
		"on_tick":
			return "item_tick"
		"on_activate":
			return "any_activate"
		# --- New: first activate mappings ---
		"on_first_activate", "on_self_first_activate", "when_this_first_activates":
			return "self_first_activate"
		# --- New: keyword gain event (used by tools like porcelain_set, sous_vide_machine) ---
		"on_keyword_gain", "when_keyword_gained":
			return "keyword_gained"
	return ev

func _matches_event(trigger: Dictionary, event_type: String, listener_slot: int, source_slot: int, context: Dictionary, player: PlayerState) -> bool:
	var norm = _normalize_event(str(trigger.get("event", trigger.get("trigger", ""))))
	var is_activation = event_type == "item_activated"
	var ok = false

	match norm:
		"self_activate":
			ok = is_activation and listener_slot == source_slot
		"self_first_activate":
			ok = is_activation and listener_slot == source_slot and context.get("activate_count", 0) == 1
		"friend_activate":
			ok = is_activation and listener_slot != source_slot
		"adjacent_activate":
			if is_activation:
				var adj = player.get_adjacent(listener_slot)
				ok = context.get("item_data", {}) in adj
		"left_activate":
			if is_activation:
				var left = player.get_left_neighbor(listener_slot)
				ok = left != null and left == context.get("item_data")
		"right_activate":
			if is_activation:
				var right = player.get_right_neighbor(listener_slot)
				ok = right != null and right == context.get("item_data")
		"any_left_activate":
			ok = is_activation and context.get("item_data") in player.get_all_left(listener_slot)
		"any_right_activate":
			ok = is_activation and context.get("item_data") in player.get_all_right(listener_slot)
		"keyword_gained":
			ok = event_type == "keyword_gained"
		"keyword_consumed":
			ok = event_type == "keyword_consumed"
		"environment_applied":
			ok = event_type == "environment_applied"
		"showdown_start":
			ok = event_type == "showdown_start"
		"showdown_end":
			ok = event_type == "showdown_end"
		"adjacent_has_tag":
			ok = is_activation and listener_slot == source_slot
		"item_tick":
			ok = event_type == "item_tick" and listener_slot == source_slot
		"any_activate":
			ok = is_activation
		_:
			ok = false

	if not ok:
		return false

	if norm == "adjacent_has_tag":
		var required_tag = trigger.get("condition", {}).get("tag", "")
		for adj_item in player.get_adjacent(listener_slot):
			if required_tag in adj_item.get("tags", []):
				return true
		return false

	var condition = trigger.get("condition", "")
	if condition is String and not condition.is_empty():
		return _check_condition_string(condition, context, player, listener_slot)
	if condition is Dictionary and not condition.is_empty():
		return _check_condition(condition, context, player, listener_slot)
	return true

func _check_condition_string(condition: String, context: Dictionary, player: PlayerState, listener_slot: int) -> bool:
	var c = condition.strip_edges()
	if c == "always":
		return true
	if c == "self":
		return true
	var src = context.get("item_data", {})
	if c.begins_with("has_tag:"):
		var tag = c.trim_prefix("has_tag:")
		return tag in src.get("tags", [])
	if c.begins_with("cuisine:"):
		return src.get("cuisine", "") == c.trim_prefix("cuisine:")
	if c.begins_with("has_technique:"):
		return src.get("enchant", "") == c.trim_prefix("has_technique:")
	# Size condition: "size:N" matches items of that size
	if c.begins_with("size:"):
		var target_size = int(c.trim_prefix("size:"))
		return src.get("size", 1) == target_size
	# Keyword condition: "keyword:umami" matches when the gained keyword matches
	if c.begins_with("keyword:"):
		var kw_id = c.trim_prefix("keyword:")
		return context.get("keyword_id", "") == kw_id
	# Synergy condition: "cuisine_count:X:N" - handled at synergy level, pass through
	if c.begins_with("cuisine_count:"):
		return true
	# Legacy cuisine-pool condition, e.g. "adjacent_washoku".
	if c.begins_with("adjacent_"):
		var cuisine_id = c.trim_prefix("adjacent_")
		if cuisine_id.is_empty():
			return false
		for adj_item in player.get_adjacent(listener_slot):
			if str(adj_item.get("cuisine", "")) == cuisine_id:
				return true
		return false
	return true

func _check_condition(condition: Dictionary, context: Dictionary, player: PlayerState, slot_idx: int) -> bool:
	var source_item = context.get("item_data", {})

	if condition.has("tag") and condition.tag not in source_item.get("tags", []):
		return false
	if condition.has("has_tag") and condition.has_tag not in source_item.get("tags", []):
		return false
	# has_tag_any: match if source item has ANY of the listed tags
	if condition.has("has_tag_any"):
		var found_any = false
		for t in condition.has_tag_any:
			if t in source_item.get("tags", []):
				found_any = true
				break
		if not found_any:
			return false
	if condition.has("size") and source_item.get("size", 1) != condition.size:
		return false
	if condition.has("cuisine") and source_item.get("cuisine", "") != condition.cuisine:
		return false
	if condition.has("keyword_min"):
		var kw_id = condition.get("keyword_id", "")
		if player.get_keyword_stacks(kw_id) < int(condition.keyword_min):
			return false
	if condition.has("keyword_stacks_gte"):
		for kw in condition.keyword_stacks_gte:
			if player.get_keyword_stacks(kw) < int(condition.keyword_stacks_gte[kw]):
				return false

	# --- New: adjacent_has_all_tags ---
	# Checks that ALL listed tags are found across adjacent items (each tag must
	# appear on at least one adjacent item; different tags may be on different items).
	if condition.has("adjacent_has_all_tags"):
		var required_tags: Array = condition.adjacent_has_all_tags
		var adjacent_items = player.get_adjacent(slot_idx)
		for req_tag in required_tags:
			var found = false
			for adj_item in adjacent_items:
				if req_tag in adj_item.get("tags", []):
					found = true
					break
			if not found:
				return false

	# --- New: adjacent_has_id ---
	# Checks that at least one adjacent item has the specified item ID.
	if condition.has("adjacent_has_id"):
		var required_id = str(condition.adjacent_has_id)
		var adjacent_items = player.get_adjacent(slot_idx)
		var found = false
		for adj_item in adjacent_items:
			if str(adj_item.get("id", "")) == required_id:
				found = true
				break
		if not found:
			return false

	# --- New: for_each_size ---
	# Counts items on the board matching the given size value (1=small, 2=medium, 3=large).
	# Sets context["_for_each_count"] so the effect can scale by count.
	if condition.has("for_each_size"):
		var target_size = int(condition.for_each_size)
		var count = 0
		for entry in player.get_board_items():
			if entry.item.get("size", 1) == target_size:
				count += 1
		context["_for_each_count"] = count
		# Always passes (count may be 0, effect scaling handles the rest).

	# --- New: for_each_tag ---
	# Counts items on the board with the given tag. Sets context["_for_each_count"].
	if condition.has("for_each_tag"):
		var target_tag = str(condition.for_each_tag)
		var count = 0
		for entry in player.get_board_items():
			if target_tag in entry.item.get("tags", []):
				count += 1
		context["_for_each_count"] = count

	# --- New: for_each_left ---
	# Counts items to the LEFT of the listener that match the given criteria.
	# Example: {"for_each_left": {"size": "small"}} → count small items to the left
	if condition.has("for_each_left"):
		var criteria = condition.for_each_left
		var left_items = player.get_all_left(slot_idx)
		var count = 0
		for left_item in left_items:
			if criteria is Dictionary:
				if criteria.has("size"):
					var target_size_str = str(criteria.size)
					var target_size_val = 1
					match target_size_str:
						"small": target_size_val = 1
						"medium": target_size_val = 2
						"large": target_size_val = 3
						_: target_size_val = int(target_size_str)
					if left_item.get("size", 1) == target_size_val:
						count += 1
				elif criteria.has("tag"):
					if str(criteria.tag) in left_item.get("tags", []):
						count += 1
				else:
					count += 1
			else:
				count += 1
		context["_for_each_count"] = count

	# --- New: if_position ---
	# "leftmost" => the listener item must be in the leftmost occupied slot.
	# "rightmost" => the listener item must be in the rightmost occupied slot.
	if condition.has("if_position"):
		var pos_check = str(condition.if_position).to_lower()
		if pos_check == "leftmost":
			var leftmost_slot = -1
			for entry in player.get_board_items():
				if leftmost_slot < 0 or entry.slot_idx < leftmost_slot:
					leftmost_slot = entry.slot_idx
			if slot_idx != leftmost_slot:
				return false
		elif pos_check == "rightmost":
			var rightmost_slot = -1
			for entry in player.get_board_items():
				# The rightmost item is the one with the highest starting slot index.
				if entry.slot_idx > rightmost_slot:
					rightmost_slot = entry.slot_idx
			if slot_idx != rightmost_slot:
				return false

	# --- New: if_count_size ---
	# Checks if there are >= min_count items of the given size on the board.
	# Example: {"if_count_size": {"size": 2, "min_count": 3}}
	if condition.has("if_count_size"):
		var size_cond = condition.if_count_size
		if size_cond is Dictionary:
			var target_size = int(size_cond.get("size", 1))
			var min_count = int(size_cond.get("min_count", 1))
			var count = 0
			for entry in player.get_board_items():
				if entry.item.get("size", 1) == target_size:
					count += 1
			if count < min_count:
				return false

	if condition.has("condition") and condition.condition is Dictionary:
		return _check_condition(condition.condition, context, player, slot_idx)

	return true

func _add_scores_to_context(scores: Dictionary, context: Dictionary):
	if scores.is_empty():
		return
	if context.has("score_bonus"):
		var sink: Dictionary = context.get("score_bonus", {})
		for attr in scores:
			sink[attr] = sink.get(attr, 0.0) + float(scores[attr])
		context["score_bonus"] = sink

func _parse_effect_string(raw: String) -> Dictionary:
	var parsed: Dictionary = {}
	for part in raw.split(","):
		var token = part.strip_edges()
		if token.is_empty():
			continue
		var sign_idx = token.find("+")
		var sign = "+"
		if sign_idx < 0:
			sign_idx = token.find("-")
			sign = "-"
		if sign_idx <= 0:
			continue
		var attr = token.substr(0, sign_idx).strip_edges()
		var num_txt = token.substr(sign_idx + 1).strip_edges()
		var value = float(num_txt)
		if sign == "-":
			value = -value
		parsed[attr] = value
	return parsed

func _execute_effect(effect: Variant, player_idx: int, slot_idx: int, item: Dictionary, context: Dictionary):
	if effect == null:
		return
	var effect_dict: Dictionary = {}
	if effect is Dictionary:
		effect_dict = effect
	elif effect is String:
		effect_dict = _parse_effect_string(effect)
	else:
		return
	if effect_dict.is_empty():
		return

	var player = _match_state.get_player(player_idx)
	var scores: Dictionary = {}

	# Legacy alias compatibility for cuisine-pool effect payloads.
	if effect_dict.has("add_env_keyword"):
		effect_dict["add_environment"] = effect_dict.get("add_env_keyword", "")
		if effect_dict.has("env_stacks"):
			effect_dict["environment_stacks"] = int(effect_dict.get("env_stacks", 1))
		elif effect_dict.has("stacks"):
			effect_dict["environment_stacks"] = int(effect_dict.get("stacks", 1))
		else:
			effect_dict["environment_stacks"] = 1

	if effect_dict.has("clear_env_keyword"):
		effect_dict["clear_environment"] = effect_dict.get("clear_env_keyword", "")
		effect_dict["clear_amount"] = int(effect_dict.get("stacks", 1))

	if effect_dict.has("add_keyword_2"):
		var kw2 = str(effect_dict.get("add_keyword_2", ""))
		if kw2 != "":
			var stacks2 = int(effect_dict.get("keyword_stacks_2", 1))
			player.add_keyword(kw2, stacks2)
			SignalBus.keyword_gained.emit(player_idx, slot_idx, kw2, stacks2)
			process_event("keyword_gained", {"player_idx": player_idx, "item_idx": slot_idx, "keyword_id": kw2, "stacks": stacks2})

	if effect_dict.has("clear_env_keyword_2"):
		var clear2 = str(effect_dict.get("clear_env_keyword_2", ""))
		if clear2 != "":
			var clear2_amount = int(effect_dict.get("stacks_2", 1))
			var cleared2 = _match_state.clear_environment_keyword(clear2, clear2_amount)
			if cleared2 > 0:
				SignalBus.keyword_environment_cleared.emit(clear2, cleared2)

	# --- Compute per_count_bonus scaling if a for_each condition set _for_each_count ---
	var for_each_count = int(context.get("_for_each_count", 0))
	var per_count_bonus = effect_dict.get("per_count_bonus", {})
	if per_count_bonus is Dictionary and not per_count_bonus.is_empty() and for_each_count > 0:
		for attr in per_count_bonus:
			scores[attr] = scores.get(attr, 0.0) + float(per_count_bonus[attr]) * for_each_count
	elif for_each_count > 0:
		# No explicit per_count_bonus; multiply the flat effect stats by the count
		# (e.g., stat_bonus {presentation: 3} with for_each_left → presentation +3 * count)
		context["_for_each_multiplier"] = for_each_count
	# Clean up the transient key so it does not leak to other triggers.
	context.erase("_for_each_count")

	# New schema directly supported.
	if effect_dict.has("flavor"):
		scores["flavor"] = scores.get("flavor", 0.0) + float(effect_dict.flavor)
	if effect_dict.has("presentation"):
		scores["presentation"] = scores.get("presentation", 0.0) + float(effect_dict.presentation)
	if effect_dict.has("technique"):
		scores["technique"] = scores.get("technique", 0.0) + float(effect_dict.technique)
	if effect_dict.has("aroma"):
		scores["aroma"] = scores.get("aroma", 0.0) + float(effect_dict.aroma)

	# Legacy schema support via type.
	var effect_type = str(effect_dict.get("type", ""))
	match effect_type:
		"stat_bonus":
			var fe_mult = int(context.get("_for_each_multiplier", 1))
			context.erase("_for_each_multiplier")
			for k in ["flavor", "presentation", "technique", "aroma"]:
				if effect_dict.has(k):
					scores[k] = scores.get(k, 0.0) + float(effect_dict.get(k, 0.0)) * fe_mult
			# Handle nested "extra" effect (e.g., stat_bonus with extra gain_keyword)
			if effect_dict.has("extra"):
				var extra = effect_dict.get("extra", {})
				if extra is Dictionary and not extra.is_empty():
					_execute_effect(extra, player_idx, slot_idx, item, context)
		"stat_bonus_for_target":
			# Apply stat bonus to the activating item's score_bonus in context
			for k in ["flavor", "presentation", "technique", "aroma"]:
				if effect_dict.has(k):
					if context.has("score_bonus"):
						context["score_bonus"][k] = context["score_bonus"].get(k, 0.0) + float(effect_dict.get(k, 0.0))
		"gain_keyword":
			effect_dict["add_keyword"] = effect_dict.get("keyword", "")
			effect_dict["keyword_stacks"] = int(effect_dict.get("stacks", 1))
		"gain_keyword_for_target":
			# Give keyword to the player (affects the activating item contextually)
			var kw_id = str(effect_dict.get("keyword", ""))
			var kw_stacks = int(effect_dict.get("stacks", 1))
			if kw_id != "":
				player.add_keyword(kw_id, kw_stacks)
				SignalBus.keyword_gained.emit(player_idx, slot_idx, kw_id, kw_stacks)
				process_event("keyword_gained", {"player_idx": player_idx, "item_idx": slot_idx, "keyword_id": kw_id, "stacks": kw_stacks})
		"add_environment":
			effect_dict["add_environment"] = effect_dict.get("keyword", "")
			effect_dict["environment_stacks"] = int(effect_dict.get("stacks", 1))
		"clear_environment":
			effect_dict["clear_environment"] = effect_dict.get("keyword", "")
			effect_dict["clear_amount"] = int(effect_dict.get("stacks", 1))
			var bonus_on_clear = effect_dict.get("bonus_on_clear", {})
			if bonus_on_clear is Dictionary and bonus_on_clear.get("type", "") == "gain_keyword":
				effect_dict["on_clear_gain_keyword"] = bonus_on_clear.get("keyword", "")
		"consume_keyword":
			var kw = str(effect_dict.get("keyword", ""))
			var consumed = 0
			if bool(effect_dict.get("all_stacks", false)):
				consumed = player.consume_keyword(kw)
			else:
				consumed = player.consume_keyword(kw, int(effect_dict.get("stacks", 1)))
			if consumed > 0:
				process_event("keyword_consumed", {"player_idx": player_idx, "item_idx": slot_idx, "keyword_id": kw, "amount": consumed})
			var per_stack_bonus: Variant = effect_dict.get("per_stack_bonus", effect_dict.get("bonus", {}))
			if not (per_stack_bonus is Dictionary):
				per_stack_bonus = {}
			# Legacy flat per-stack fields from cuisine pools.
			if (per_stack_bonus as Dictionary).is_empty():
				var legacy_bonus: Dictionary = {}
				if effect_dict.has("per_stack_flavor_bonus"):
					legacy_bonus["flavor"] = float(effect_dict.get("per_stack_flavor_bonus", 0.0))
				if effect_dict.has("per_stack_presentation_bonus"):
					legacy_bonus["presentation"] = float(effect_dict.get("per_stack_presentation_bonus", 0.0))
				per_stack_bonus = legacy_bonus
			if per_stack_bonus is Dictionary:
				for attr in per_stack_bonus:
					scores[attr] = scores.get(attr, 0.0) + float(per_stack_bonus[attr]) * consumed
		"gain_keyword_per_adjacent":
			var cond = effect_dict.get("condition", {})
			var match_count = 0
			for adj in player.get_adjacent(slot_idx):
				if cond is Dictionary and cond.has("cuisine") and adj.get("cuisine", "") == cond.cuisine:
					match_count += 1
				elif cond is Dictionary and cond.has("has_tag") and cond.has_tag in adj.get("tags", []):
					match_count += 1
				elif cond.is_empty():
					match_count += 1
			if match_count > 0:
				effect_dict["add_keyword"] = effect_dict.get("keyword", "")
				effect_dict["keyword_stacks"] = int(effect_dict.get("stacks", 1)) * match_count
		"gain_keyword_scaling":
			var stacks = int(effect_dict.get("base_stacks", 1))
			var by_tag = str(effect_dict.get("per_tag", ""))
			if by_tag != "":
				for entry in player.get_board_items():
					if by_tag in entry.item.get("tags", []):
						stacks += int(effect_dict.get("per_tag_stacks", 1))
			effect_dict["add_keyword"] = effect_dict.get("keyword", "")
			effect_dict["keyword_stacks"] = stacks
		# --- New: flavor_mult effect type ---
		# Multiplies the running flavor score bonus in context by the given multiplier.
		"flavor_mult":
			var mult = float(effect_dict.get("value", effect_dict.get("mult", 1.0)))
			if context.has("score_bonus"):
				var current_flavor = float(context["score_bonus"].get("flavor", 0.0))
				var added = current_flavor * (mult - 1.0)
				scores["flavor"] = scores.get("flavor", 0.0) + added
			# If there are also flat scores accumulated above, multiply those too.
			if scores.has("flavor") and not context.has("score_bonus"):
				# No existing score_bonus yet; the flat flavor from this effect is simply added.
				pass
		# --- New: first_activate_bonus effect type ---
		# Only applies its stat bonuses when activate_count == 1 in context.
		"first_activate_bonus":
			if context.get("activate_count", 0) == 1:
				for k in ["flavor", "presentation", "technique", "aroma"]:
					if effect_dict.has(k):
						scores[k] = scores.get(k, 0.0) + float(effect_dict.get(k, 0.0))
				# Also handle flavor_mult for first_activate_bonus
				if effect_dict.has("flavor_mult"):
					var fmult = float(effect_dict.flavor_mult)
					if context.has("score_bonus"):
						var cur = float(context["score_bonus"].get("flavor", 0.0))
						scores["flavor"] = scores.get("flavor", 0.0) + cur * (fmult - 1.0)
		# --- New: presentation_mult effect type ---
		"presentation_mult":
			var pmult = float(effect_dict.get("value", effect_dict.get("mult", 1.0)))
			if context.has("score_bonus"):
				var cur_pres = float(context["score_bonus"].get("presentation", 0.0))
				scores["presentation"] = scores.get("presentation", 0.0) + cur_pres * (pmult - 1.0)

	# Legacy cuisine count scaling fields used by dish pools.
	if bool(effect_dict.get("washoku_count_bonus", false)):
		var add_flavor = float(effect_dict.get("per_washoku_flavor", 0.0))
		if add_flavor != 0.0:
			var count_washoku := 0
			for entry in player.get_board_items():
				if str(entry.item.get("cuisine", "")) == "washoku":
					count_washoku += 1
			scores["flavor"] = scores.get("flavor", 0.0) + add_flavor * count_washoku

	if bool(effect_dict.get("chuuka_count_bonus", false)):
		var add_chuuka_flavor = float(effect_dict.get("per_chuuka_flavor", 0.0))
		var add_chuuka_pres = float(effect_dict.get("per_chuuka_presentation", 0.0))
		if add_chuuka_flavor != 0.0 or add_chuuka_pres != 0.0:
			var count_chuuka := 0
			for entry in player.get_board_items():
				if str(entry.item.get("cuisine", "")) == "chuuka":
					count_chuuka += 1
			if add_chuuka_flavor != 0.0:
				scores["flavor"] = scores.get("flavor", 0.0) + add_chuuka_flavor * count_chuuka
			if add_chuuka_pres != 0.0:
				scores["presentation"] = scores.get("presentation", 0.0) + add_chuuka_pres * count_chuuka

	if not scores.is_empty():
		SignalBus.score_produced.emit(player_idx, slot_idx, scores)
		_add_scores_to_context(scores, context)

	if effect_dict.has("add_keyword"):
		var kw_id = str(effect_dict.add_keyword)
		if kw_id != "":
			var stacks = int(effect_dict.get("keyword_stacks", 1))
			player.add_keyword(kw_id, stacks)
			SignalBus.keyword_gained.emit(player_idx, slot_idx, kw_id, stacks)
			process_event("keyword_gained", {"player_idx": player_idx, "item_idx": slot_idx, "keyword_id": kw_id, "stacks": stacks})

	if effect_dict.has("add_environment"):
		var env_id = str(effect_dict.add_environment)
		if env_id != "":
			var env_stacks = int(effect_dict.get("environment_stacks", 1))
			_match_state.add_environment_keyword(env_id, env_stacks)
			SignalBus.keyword_environment_applied.emit(env_id, env_stacks, player_idx)
			process_event("environment_applied", {"player_idx": player_idx, "item_idx": slot_idx, "keyword_id": env_id, "stacks": env_stacks})

	if effect_dict.has("clear_environment"):
		var clear_id = str(effect_dict.clear_environment)
		if clear_id != "":
			var clear_amount = int(effect_dict.get("clear_amount", 1))
			var cleared = _match_state.clear_environment_keyword(clear_id, clear_amount)
			if cleared > 0:
				SignalBus.keyword_environment_cleared.emit(clear_id, cleared)
				if effect_dict.has("on_clear_gain_keyword"):
					var gain_kw = str(effect_dict.on_clear_gain_keyword)
					if gain_kw != "":
						player.add_keyword(gain_kw, cleared)
						SignalBus.keyword_gained.emit(player_idx, slot_idx, gain_kw, cleared)

	# ========== 新效果类型 ==========

	# 1. 延迟触发（delayed_trigger）
	if effect_dict.has("delayed_trigger"):
		var delayed = effect_dict.delayed_trigger
		if delayed is Dictionary:
			var delay_ticks = int(delayed.get("delay_ticks", 1))
			var delayed_effect = delayed.get("effect", {})
			if not delayed_effect.is_empty():
				_schedule_delayed_effect(player_idx, slot_idx, item, delayed_effect, delay_ticks, context)

	# 2. 连锁反应（chain_left / chain_right）
	if effect_dict.has("chain_left"):
		var chain = effect_dict.chain_left
		if chain is Dictionary:
			var range_val = int(chain.get("range", 1))
			var chain_effect = chain.get("effect", {})
			if not chain_effect.is_empty():
				_apply_chain_effect(player_idx, slot_idx, "left", range_val, chain_effect, context)

	if effect_dict.has("chain_right"):
		var chain = effect_dict.chain_right
		if chain is Dictionary:
			var range_val = int(chain.get("range", 1))
			var chain_effect = chain.get("effect", {})
			if not chain_effect.is_empty():
				_apply_chain_effect(player_idx, slot_idx, "right", range_val, chain_effect, context)

	# 3. 条件爆发（if_then_else）
	if effect_dict.has("if_keyword_gte"):
		var condition = effect_dict.if_keyword_gte
		if condition is Dictionary:
			var kw_id = str(condition.get("keyword", ""))
			var required_stacks = int(condition.get("stacks", 1))
			var current_stacks = player.get_keyword_stacks(kw_id)
			var then_effect = effect_dict.get("then", {})
			var else_effect = effect_dict.get("else", {})
			if current_stacks >= required_stacks and not then_effect.is_empty():
				_execute_effect(then_effect, player_idx, slot_idx, item, context)
			elif current_stacks < required_stacks and not else_effect.is_empty():
				_execute_effect(else_effect, player_idx, slot_idx, item, context)

	# 4. 位置依赖（if_position）
	if effect_dict.has("if_position"):
		var pos_check = str(effect_dict.if_position).to_lower()
		var matches_position = false
		var board_items = player.get_board_items()
		if pos_check == "leftmost":
			if not board_items.is_empty() and board_items[0].slot_idx == slot_idx:
				matches_position = true
		elif pos_check == "rightmost":
			if not board_items.is_empty() and board_items[-1].slot_idx == slot_idx:
				matches_position = true
		if matches_position:
			var then_effect = effect_dict.get("then", {})
			if not then_effect.is_empty():
				_execute_effect(then_effect, player_idx, slot_idx, item, context)
		else:
			var else_effect = effect_dict.get("else", {})
			if not else_effect.is_empty():
				_execute_effect(else_effect, player_idx, slot_idx, item, context)

	# 5. 累积充能（accumulate）
	if effect_dict.has("accumulate"):
		var accum = effect_dict.accumulate
		if accum is Dictionary:
			var counter_id = str(accum.get("counter_id", "default"))
			var increment = int(accum.get("increment", 1))
			var threshold = int(accum.get("threshold", 3))
			var on_threshold_effect = accum.get("on_threshold", {})
			var reset_on_threshold = bool(accum.get("reset_counter", false))
			_process_accumulate(player_idx, slot_idx, item, counter_id, increment, threshold, on_threshold_effect, reset_on_threshold, context)

	# 6. 相邻条件加成（if_adjacent_count_gte）
	if effect_dict.has("if_adjacent_count_gte"):
		var required_count = int(effect_dict.if_adjacent_count_gte)
		var adjacent_items = player.get_adjacent(slot_idx)
		var then_effect = effect_dict.get("then", {})
		var else_effect = effect_dict.get("else", {})
		if adjacent_items.size() >= required_count and not then_effect.is_empty():
			_execute_effect(then_effect, player_idx, slot_idx, item, context)
		elif adjacent_items.size() < required_count and not else_effect.is_empty():
			_execute_effect(else_effect, player_idx, slot_idx, item, context)

	# 7. 相邻标签条件加成（if_adjacent_has_tag + then_bonus）
	if effect_dict.has("if_adjacent_has_tag"):
		var required_tag = str(effect_dict.if_adjacent_has_tag)
		var has_tag = false
		for adj_item in player.get_adjacent(slot_idx):
			if required_tag in adj_item.get("tags", []):
				has_tag = true
				break
		if has_tag:
			var then_bonus = effect_dict.get("then_bonus", {})
			if not then_bonus.is_empty():
				_execute_effect(then_bonus, player_idx, slot_idx, item, context)

	# 8. 治疗声望（heal_prestige）
	if effect_dict.has("heal_prestige"):
		var heal_amount = int(effect_dict.heal_prestige)
		if heal_amount > 0:
			player.prestige = mini(20, player.prestige + heal_amount)
			SignalBus.prestige_changed.emit(player_idx, player.prestige)

	# 9. 获得金币（grant_gold）
	if effect_dict.has("grant_gold"):
		var gold_amount = int(effect_dict.grant_gold)
		if gold_amount > 0:
			player.add_gold(gold_amount)
			SignalBus.gold_changed.emit(player_idx, player.gold)

	# 10. CD 操控效果（写入 context，由 ShowdownResolver 统一消费）
	# 缩减自身冷却
	if effect_dict.has("reduce_cooldown_self"):
		var amt = float(effect_dict.reduce_cooldown_self)
		if amt > 0.0:
			context["cd_reduction_self"] = float(context.get("cd_reduction_self", 0.0)) + amt
	# 缩减相邻冷却
	if effect_dict.has("reduce_cooldown_adjacent"):
		var amt = float(effect_dict.reduce_cooldown_adjacent)
		if amt > 0.0:
			context["cd_reduction_adjacent"] = float(context.get("cd_reduction_adjacent", 0.0)) + amt
	# 加速自身（临时提高 CD 转速）
	if effect_dict.has("haste"):
		var dur  = float(effect_dict.get("haste", 1.0))
		var mult = float(effect_dict.get("haste_mult", 2.0))
		context["haste_self"] = {"duration": dur, "multiplier": mult}
	# 加速相邻
	if effect_dict.has("haste_adjacent"):
		var dur  = float(effect_dict.get("haste_adjacent", 1.0))
		var mult = float(effect_dict.get("haste_mult", 2.0))
		context["haste_adjacent"] = {"duration": dur, "multiplier": mult}
	# 减速（对手，默认全体）
	if effect_dict.has("slow"):
		var dur  = float(effect_dict.get("slow", 1.0))
		var mult = float(effect_dict.get("slow_mult", 0.5))
		context["slow_opponent"] = {"duration": dur, "multiplier": mult}

	# 11. 随机概率触发（random_chance）
	if effect_dict.has("random_chance"):
		var chance = float(effect_dict.random_chance)
		var on_success = effect_dict.get("on_success", {})
		if randf() < chance and not on_success.is_empty():
			_execute_effect(on_success, player_idx, slot_idx, item, context)

	# 12. 关键词转换（convert_keyword）
	if effect_dict.has("convert_keyword"):
		var convert = effect_dict.convert_keyword
		if convert is Dictionary:
			var from_kw = str(convert.get("from", ""))
			var to_kw = str(convert.get("to", ""))
			var ratio = float(convert.get("ratio", 1.0))
			if from_kw != "" and to_kw != "":
				# 检查是否是环境关键词
				var from_stacks = 0
				if _match_state.has_environment_keyword(from_kw):
					from_stacks = _match_state.get_environment_keyword_stacks(from_kw)
					if from_stacks > 0:
						var cleared = _match_state.clear_environment_keyword(from_kw, from_stacks)
						var to_stacks = int(float(cleared) * ratio)
						if to_stacks > 0:
							player.add_keyword(to_kw, to_stacks)
							SignalBus.keyword_gained.emit(player_idx, slot_idx, to_kw, to_stacks)
				else:
					# 玩家关键词转换
					from_stacks = player.get_keyword_stacks(from_kw)
					if from_stacks > 0:
						var consumed = player.consume_keyword(from_kw, from_stacks)
						var to_stacks = int(float(consumed) * ratio)
						if to_stacks > 0:
							player.add_keyword(to_kw, to_stacks)
							SignalBus.keyword_gained.emit(player_idx, slot_idx, to_kw, to_stacks)

	# 13. 复制相邻关键词（copy_adjacent_keyword）
	if effect_dict.has("copy_adjacent_keyword"):
		var copy = effect_dict.copy_adjacent_keyword
		if copy is Dictionary:
			var target = str(copy.get("target", "left"))
			var keyword = str(copy.get("keyword", "any"))
			var stacks = int(copy.get("stacks", 1))
			var adjacent_items = []
			if target == "left":
				var left = player.get_left_neighbor(slot_idx)
				if left != null:
					adjacent_items.append(left)
			elif target == "right":
				var right = player.get_right_neighbor(slot_idx)
				if right != null:
					adjacent_items.append(right)
			else:
				adjacent_items = player.get_adjacent(slot_idx)

			# 从相邻菜品复制关键词（这里简化为复制玩家的关键词）
			if keyword == "any":
				# 复制玩家当前拥有的第一个关键词
				var player_keywords = player.keyword_stacks
				if not player_keywords.is_empty():
					var first_kw = player_keywords.keys()[0]
					player.add_keyword(first_kw, stacks)
					SignalBus.keyword_gained.emit(player_idx, slot_idx, first_kw, stacks)
			else:
				player.add_keyword(keyword, stacks)
				SignalBus.keyword_gained.emit(player_idx, slot_idx, keyword, stacks)

func _process_keyword_effect(trigger: Dictionary, player_idx: int, slot_idx: int, context: Dictionary):
	"""Process the keyword_effect field from a trigger dictionary (used by tools)."""
	var kw_effect = trigger.get("keyword_effect", {})
	if not kw_effect is Dictionary or kw_effect.is_empty():
		return

	var player = _match_state.get_player(player_idx)
	var effect_type = str(kw_effect.get("type", ""))

	match effect_type:
		"gain_keyword":
			var kw_id = str(kw_effect.get("keyword", ""))
			var stacks = int(kw_effect.get("stacks", 1))
			if kw_id != "":
				player.add_keyword(kw_id, stacks)
				SignalBus.keyword_gained.emit(player_idx, slot_idx, kw_id, stacks)
				process_event("keyword_gained", {"player_idx": player_idx, "item_idx": slot_idx, "keyword_id": kw_id, "stacks": stacks})
		"add_environment":
			var env_id = str(kw_effect.get("keyword", ""))
			var stacks = int(kw_effect.get("stacks", 1))
			if env_id != "":
				_match_state.add_environment_keyword(env_id, stacks)
				SignalBus.keyword_environment_applied.emit(env_id, stacks, player_idx)
		"clear_environment":
			var clear_id = str(kw_effect.get("keyword", ""))
			var stacks = int(kw_effect.get("stacks", 1))
			if clear_id != "":
				_match_state.clear_environment_keyword(clear_id, stacks)

func get_event_log() -> Array:
	return _event_log

# ========== 新效果辅助函数 ==========

## 延迟触发效果调度
func _schedule_delayed_effect(player_idx: int, slot_idx: int, item: Dictionary, effect: Dictionary, delay_ticks: int, context: Dictionary):
	# 在 match_state 中存储延迟效果队列
	if not _match_state.has_meta("_delayed_effects"):
		_match_state.set_meta("_delayed_effects", [])
	var delayed_effects: Array = _match_state.get_meta("_delayed_effects")
	delayed_effects.append({
		"player_idx": player_idx,
		"slot_idx": slot_idx,
		"item": item,
		"effect": effect,
		"remaining_ticks": delay_ticks,
		"context": context.duplicate()
	})

## 处理延迟效果（每个 tick 调用）
func process_delayed_effects():
	if not _match_state.has_meta("_delayed_effects"):
		return
	var delayed_effects: Array = _match_state.get_meta("_delayed_effects")
	var to_remove: Array = []
	for i in range(delayed_effects.size()):
		var entry: Dictionary = delayed_effects[i]
		entry["remaining_ticks"] = int(entry.get("remaining_ticks", 0)) - 1
		if entry["remaining_ticks"] <= 0:
			# 触发延迟效果
			_execute_effect(
				entry.get("effect", {}),
				int(entry.get("player_idx", 0)),
				int(entry.get("slot_idx", -1)),
				entry.get("item", {}),
				entry.get("context", {})
			)
			to_remove.append(i)
	# 从后往前删除
	to_remove.reverse()
	for idx in to_remove:
		delayed_effects.remove_at(idx)

## 连锁效果传播
func _apply_chain_effect(player_idx: int, source_slot: int, direction: String, range_val: int, effect: Dictionary, context: Dictionary):
	var player = _match_state.get_player(player_idx)
	var board_items = player.get_board_items()
	var targets: Array = []# 找到目标槽位
	if direction == "left":
		for entry in board_items:
			if entry.slot_idx < source_slot:
				targets.append(entry)
		targets.reverse()  # 从近到远
	elif direction == "right":
		for entry in board_items:
			if entry.slot_idx > source_slot:
				targets.append(entry)

	# 应用效果到范围内的目标
	var count = 0
	for target_entry in targets:
		if count >= range_val:
			break
		_execute_effect(effect, player_idx, target_entry.slot_idx, target_entry.item, context)
		count += 1

## 累积充能处理
func _process_accumulate(player_idx: int, slot_idx: int, item: Dictionary, counter_id: String, increment: int, threshold: int, on_threshold_effect: Dictionary, reset_on_threshold: bool, context: Dictionary):
	# 在 item 上存储计数器
	var counter_key = "_counter_" + counter_id
	var current_count = int(item.get(counter_key, 0))
	current_count += increment
	item[counter_key] = current_count

	# 检查是否达到阈值
	if current_count >= threshold and not on_threshold_effect.is_empty():
		_execute_effect(on_threshold_effect, player_idx, slot_idx, item, context)
		if reset_on_threshold:
			item[counter_key] = 0
