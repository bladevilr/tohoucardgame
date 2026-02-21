extends Node

## CombatManager - 战斗编排：配对、调用解算、扣血

var match_state: RefCounted  # MatchState引用


func set_match_state(state: RefCounted) -> void:
	match_state = state


## 执行一轮完整战斗
func execute_combat_round() -> Array:
	if match_state == null:
		return []

	var pairs = match_state.generate_pairings()
	var results: Array = []
	for pair in pairs:
		var idx_a: int = pair[0]
		var idx_b: int = pair[1]
		var player_a = match_state.get_player(idx_a)
		var player_b = match_state.get_player(idx_b)

		if player_a == null or player_b == null:
			continue

		SignalBus.combat_started.emit(idx_a, idx_b)

		# 解算战斗
		var CombatResolverScript = load("res://systems/CombatResolver.gd")
		var result = CombatResolverScript.resolve(player_a, player_b)

		# 应用结果
		var winner: int = result.get("winner", -1)
		var loser: int = result.get("loser", -1)
		var damage: int = result.get("damage", 0)

		if loser >= 0 and damage > 0:
			var loser_player = match_state.get_player(loser)
			if loser_player:
				loser_player.take_damage(damage)
				SignalBus.player_hp_changed.emit(loser, loser_player.hp)

				# 检查淘汰
				if not loser_player.is_alive():
					match_state.eliminate_player(loser)
					SignalBus.player_eliminated.emit(loser, loser_player.placement)

		# 记录战绩
		if winner >= 0:
			var winner_player = match_state.get_player(winner)
			if winner_player:
				winner_player.record_win()
		if loser >= 0:
			var loser_p = match_state.get_player(loser)
			if loser_p:
				loser_p.record_loss()

		# 平局双方都算败
		if winner < 0 and loser < 0:
			player_a.record_loss()
			player_b.record_loss()

		# 发送战斗结束信号
		SignalBus.combat_ended.emit(winner, loser, damage)

		# 记录到比赛日志
		result["pair"] = [idx_a, idx_b]
		match_state.add_combat_result(result)
		results.append(result)

	return results


## 获取上轮战斗摘要（用于UI显示）
func get_combat_summary() -> Array:
	if match_state == null:
		return []

	var summary: Array = []
	for result in match_state.combat_log:
		var pair: Array = result.get("pair", [])
		if pair.size() < 2:
			continue

		var pa: RefCounted = match_state.get_player(pair[0])
		var pb: RefCounted = match_state.get_player(pair[1])
		if pa == null or pb == null:
			continue

		var winner: int = result.get("winner", -1)
		var winner_name := ""
		if winner >= 0:
			var wp = match_state.get_player(winner)
			if wp:
				winner_name = wp.player_name

		summary.append({
			"player_a": pa.player_name,
			"player_b": pb.player_name,
			"winner": winner_name,
			"damage": result.get("damage", 0),
			"a_hp_remain": result.get("unit_a_hp", 0),
			"b_hp_remain": result.get("unit_b_hp", 0),
		})

	return summary
