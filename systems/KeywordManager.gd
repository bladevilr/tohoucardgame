extends RefCounted
class_name KeywordManager

var _match_state: Object = null

func _init(match_state):
	_match_state = match_state

var _fusion_multipliers: Array = [{}, {}]

func reset_fusion_multipliers():
	_fusion_multipliers = [{}, {}]

func _ensure_player_multiplier(player_idx: int) -> void:
	while _fusion_multipliers.size() <= player_idx:
		_fusion_multipliers.append({})
	if not (_fusion_multipliers[player_idx] is Dictionary):
		_fusion_multipliers[player_idx] = {}

func set_fusion_multiplier(player_idx: int, keyword: String, mult: float):
	_ensure_player_multiplier(player_idx)
	var player_mults: Dictionary = _fusion_multipliers[player_idx]
	player_mults[keyword] = mult
	_fusion_multipliers[player_idx] = player_mults

func get_fusion_multiplier(player_idx: int, keyword: String) -> float:
	if player_idx < 0 or player_idx >= _fusion_multipliers.size():
		return 1.0
	var player_mults = _fusion_multipliers[player_idx]
	if not (player_mults is Dictionary):
		return 1.0
	return float((player_mults as Dictionary).get(keyword, 1.0))

func apply_keyword_modifiers(player_idx: int, base_scores: Dictionary) -> Dictionary:
	"""Apply keyword stack bonuses to base scores before serving."""
	var player = _match_state.get_player(player_idx)
	var modified = base_scores.duplicate()

	# Buff keywords
	var umami = player.get_keyword_stacks("umami")
	if umami > 0:
		modified["flavor"] = modified.get("flavor", 0) + umami * 3

	var char_aroma = player.get_keyword_stacks("char_aroma")
	if char_aroma > 0:
		modified["flavor"] = modified.get("flavor", 0) + char_aroma * 2

	var plating = player.get_keyword_stacks("plating")
	if plating > 0:
		modified["presentation"] = modified.get("presentation", 0) + plating * 3

	var knife_work = player.get_keyword_stacks("knife_work")
	if knife_work > 0:
		modified["technique"] = modified.get("technique", 0) + knife_work * 2

	# Aftertaste: +30% flavor per stack (boosted by kanmi synergy)
	var aftertaste = player.get_keyword_stacks("aftertaste")
	if aftertaste > 0:
		var mult = 0.30 * get_fusion_multiplier(player_idx, "aftertaste")
		modified["flavor"] = modified.get("flavor", 0) * (1.0 + aftertaste * mult)

	# Secret recipe: x1.5 per stack (consumed on use) (boosted by yakuzen synergy)
	var secret = player.get_keyword_stacks("secret_recipe")
	if secret > 0:
		var bonus = 0.50 * get_fusion_multiplier(player_idx, "secret_recipe")
		modified["flavor"] = modified.get("flavor", 0) * (1.0 + secret * bonus)
		player.consume_keyword("secret_recipe")

	# Environment debuffs (affect both players)
	var greasy = _match_state.environment_keywords.get("greasy", 0)
	if greasy > 0:
		modified["flavor"] = modified.get("flavor", 0) - greasy * 2

	var messy = _match_state.environment_keywords.get("messy", 0)
	if messy > 0:
		modified["presentation"] = modified.get("presentation", 0) - messy * 2

	var taste_fatigue = _match_state.environment_keywords.get("taste_fatigue", 0)
	if taste_fatigue > 0:
		modified["flavor"] = modified.get("flavor", 0) * maxf(0.1, 1.0 + taste_fatigue * (-0.15))

	# Ensure no negative scores
	for key in modified:
		modified[key] = maxf(0, modified[key])

	return modified

func apply_spotlight(player_idx: int, item_runtime: Dictionary):
	"""Apply spotlight CD reduction."""
	var player = _match_state.get_player(player_idx)
	var spotlight = player.get_keyword_stacks("spotlight")
	if spotlight > 0:
		var reduction = spotlight * 1.0
		item_runtime["current_cd"] = maxf(0.1, item_runtime.get("current_cd", 0) - reduction)
		player.consume_keyword("spotlight")

func get_environment_cd_penalty() -> float:
	"""Get CD penalty from dull environment keyword."""
	var dull = _match_state.environment_keywords.get("dull", 0)
	return dull * 0.3
