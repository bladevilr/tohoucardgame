extends Node

# Owns the active ShowdownResolver lifecycle and persists showdown outcomes.

var _resolver: ShowdownResolver = null
var _resolver_v2: ShowdownResolverV2 = null
var _timer: float = 0.0
var _active: bool = false

func start_showdown(match_state: MatchState):
	if GameConfig.BATTLE_SYSTEM_V2:
		_start_showdown_v2(match_state)
	else:
		_start_showdown_v1(match_state)

func _start_showdown_v1(match_state: MatchState):
	_resolver = ShowdownResolver.new(match_state)
	_resolver.setup()
	_active = true
	_timer = 0.0

func _start_showdown_v2(match_state: MatchState):
	# 获取两位评委
	var judge_ids: Array = []
	if match_state.judges.size() >= 2:
		for j in match_state.judges:
			if j is Dictionary:
				judge_ids.append(str(j.get("id", "eiki")))
			else:
				judge_ids.append(str(j))
	else:
		judge_ids = ["eiki", "yuyuko"]

	_resolver_v2 = ShowdownResolverV2.new()
	_resolver_v2.setup(match_state, judge_ids)
	_active = true
	_timer = 0.0
	SignalBus.showdown_started.emit()

func _on_showdown_v2_finished():
	var result: Dictionary = _resolver_v2.get_result()
	var match_state: MatchState = GameManager.get_match_state()
	if match_state == null:
		return

	# 存储分析数据（供 ResultScreen 使用）
	match_state.set_meta("showdown_analysis_v2", result)
	# 写入分数供 ResultScreen 和 ScoreBar 读取
	match_state.showdown_scores = [result.score_a, result.score_b]

	# 从V2真实数据构建 showdown_analysis
	var item_contributions: Array = [{}, {}]
	for p_idx in range(2):
		var runtimes: Array = _resolver_v2.get_item_runtimes(p_idx)
		for rt in runtimes:
			var slot_idx: int = int(rt.get("slot_idx", 0))
			var item: Dictionary = rt.get("item", {})
			item_contributions[p_idx][slot_idx] = {
				"name": str(item.get("name", "???")),
				"total_score": 0.0,
				"trigger_count": int(rt.get("activate_count", 0)),
				"base_flavor": float(item.get("flavor", 0)),
			}

	# 从 timeline 汇总每个(player, slot_idx)的累计得分
	for entry in result.timeline:
		var p_idx: int = int(entry.get("player", 0))
		var slot_idx: int = int(entry.get("slot_idx", 0))
		var score: float = float(entry.get("score", 0.0))
		if item_contributions[p_idx].has(slot_idx):
			item_contributions[p_idx][slot_idx]["total_score"] += score

	match_state.set_meta("showdown_analysis", {
		"technique_mults": [1.0, 1.0],
		"dot_totals": [0.0, 0.0],
		"item_contributions": item_contributions,
		"clash_penalties": [],
	})

	var is_pve: bool = str(match_state.current_action_data.get("phase", "")) == "PVE_BATTLE"
	var scores: Array = [result.score_a, result.score_b]

	# 判定胜负
	var winner: int = -1
	var score_diff: float = 0.0
	if result.winner == "A":
		winner = 0
		score_diff = result.score_a - result.score_b
	elif result.winner == "B":
		winner = 1
		score_diff = result.score_b - result.score_a

	if winner >= 0:
		var loser: int = 1 - winner
		if is_pve:
			if winner == 0:
				var reward_gold: int = match_state.current_encounter.get("reward_gold", 3)
				match_state.players[0].add_gold(reward_gold)
		else:
			match_state.apply_prestige_damage(loser, score_diff)
			match_state.players[winner].wins += 1
			match_state.players[winner].streak = maxi(1, match_state.players[winner].streak + 1) if match_state.players[winner].streak > 0 else 1
			match_state.players[loser].losses += 1
			match_state.players[loser].streak = mini(-1, match_state.players[loser].streak - 1) if match_state.players[loser].streak < 0 else -1
			match_state.players[winner].add_gold(GameConfig.WIN_BONUS_GOLD)

	SignalBus.showdown_ended.emit()
	_active = false

func _process(delta: float):
	if not _active:
		return

	if _resolver_v2:
		_timer += delta
		while _timer >= 0.1:
			_resolver_v2.tick(0.1)
			_timer -= 0.1
			if _resolver_v2.is_finished():
				_active = false
				_on_showdown_v2_finished()
				return
	elif _resolver:
		_timer += delta
		while _timer >= 0.1:
			_resolver.tick(0.1)
			_timer -= 0.1

			if not _resolver.is_running():
				_active = false
				_on_showdown_finished()
				return

func _on_showdown_finished():
	var scores = _resolver.get_scores()
	var match_state = GameManager.get_match_state()
	if match_state == null:
		return

	# 写入分数供 ResultScreen 读取
	match_state.showdown_scores = [scores[0], scores[1]]

	# ResultScreen reads this payload to render the battle analysis panel.
	match_state.set_meta("showdown_analysis", _resolver.get_analysis_data())

	# Detect if this is a PvE showdown.
	var is_pve: bool = str(match_state.current_action_data.get("phase", "")) == "PVE_BATTLE"

	# Determine winner
	var winner = -1
	var score_diff = 0.0
	if scores[0] > scores[1]:
		winner = 0
		score_diff = scores[0] - scores[1]
	elif scores[1] > scores[0]:
		winner = 1
		score_diff = scores[1] - scores[0]

	if winner >= 0:
		var loser = 1 - winner
		if is_pve:
			if winner == 0:
				var reward_gold = match_state.current_encounter.get("reward_gold", 3)
				match_state.players[0].add_gold(reward_gold)
		else:
			match_state.apply_prestige_damage(loser, score_diff)
			match_state.players[winner].wins += 1
			match_state.players[winner].streak = maxi(1, match_state.players[winner].streak + 1) if match_state.players[winner].streak > 0 else 1
			match_state.players[loser].losses += 1
			match_state.players[loser].streak = mini(-1, match_state.players[loser].streak - 1) if match_state.players[loser].streak < 0 else -1
			match_state.players[winner].add_gold(GameConfig.WIN_BONUS_GOLD)

	SignalBus.showdown_ended.emit()

func get_resolver() -> ShowdownResolver:
	return _resolver

func get_resolver_v2() -> ShowdownResolverV2:
	return _resolver_v2

func is_active() -> bool:
	return _active

func skip_showdown():
	"""For testing: instantly finish."""
	if _resolver and _active:
		while _resolver.is_running():
			_resolver.tick(1.0)
		_active = false
		_on_showdown_finished()
