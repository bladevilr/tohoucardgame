extends RefCounted

const BoardManager = preload("res://systems/BoardManager.gd")

## CombatResolver - 纯函数确定性战斗解算（10 tick）
## 输入两个 PlayerState，输出战斗结果

class CombatUnit:
	var player_index: int
	var max_hp: float
	var hp: float
	var atk_mult: float
	var def_reduction: float
	var initiative: float
	var spirit_mult: float
	var effects: Array
	var combo_count: int = 0
	var spirit_pulse_remaining: int = 0
	var revived: bool = false

	func is_alive() -> bool:
		return hp > 0.0


static func resolve(player_a: RefCounted, player_b: RefCounted) -> Dictionary:
	var unit_a := _build_unit(player_a)
	var unit_b := _build_unit(player_b)
	var log: Array = []# --- PRE_COMBAT阶段 ---
	_apply_pre_combat(unit_a, log)
	_apply_pre_combat(unit_b, log)

	# --- 10 tick 战斗 ---
	for tick in range(GameConfig.MAX_COMBAT_TICKS):
		if not unit_a.is_alive() or not unit_b.is_alive():
			break

		var tick_log := {"tick": tick, "events": []}

		# 先手判定
		var a_first := unit_a.initiative >= unit_b.initiative
		var first: CombatUnit = unit_a if a_first else unit_b
		var second: CombatUnit = unit_b if a_first else unit_a

		# 先手攻击
		if first.is_alive() and second.is_alive():
			var dmg := _calculate_damage(first, second, tick, log)
			_apply_damage(second, dmg, tick_log)
			_on_hit_effects(first, second, tick_log)

		# 后手攻击（如果还活着）
		if second.is_alive() and first.is_alive():
			var dmg := _calculate_damage(second, first, tick, log)
			_apply_damage(first, dmg, tick_log)
			_on_hit_effects(second, first, tick_log)

		# POST_TICK效果
		_apply_post_tick(unit_a, tick_log)
		_apply_post_tick(unit_b, tick_log)

		# 死亡检查 + 复活
		_check_death(unit_a, tick_log)
		_check_death(unit_b, tick_log)

		log.append(tick_log)

	# --- 判定胜负 ---
	var winner_idx: int = -1
	var loser_idx: int = -1
	var hp_diff: float = unit_a.hp - unit_b.hp

	if unit_a.hp <= 0 and unit_b.hp <= 0:
		winner_idx = -1  # 平局
		loser_idx = -1
	elif unit_b.hp <= 0 or hp_diff > 0:
		winner_idx = unit_a.player_index
		loser_idx = unit_b.player_index
	elif unit_a.hp <= 0 or hp_diff < 0:
		winner_idx = unit_b.player_index
		loser_idx = unit_a.player_index
	else:
		winner_idx = -1  # HP相同→平局
		loser_idx = -1

	# 计算扣血
	var damage_to_loser := 0
	if loser_idx >= 0:
		damage_to_loser = GameConfig.HP_LOSS_BASE_PER_ROUND + (player_a.total_stats.get("atk", 0) + player_b.total_stats.get("atk", 0)) / 4
		damage_to_loser = maxi(damage_to_loser, GameConfig.MIN_HP_LOSS)

	return {
		"winner": winner_idx,
		"loser": loser_idx,
		"damage": damage_to_loser,
		"unit_a_hp": unit_a.hp,
		"unit_b_hp": unit_b.hp,
		"unit_a_max_hp": unit_a.max_hp,
		"unit_b_max_hp": unit_b.max_hp,
		"log": log,
	}


static func _build_unit(player: RefCounted) -> CombatUnit:
	var unit := CombatUnit.new()
	unit.player_index = player.player_index
	unit.max_hp = GameConfig.BASE_COMBAT_HP
	unit.hp = GameConfig.BASE_COMBAT_HP
	unit.atk_mult = BoardManager.get_damage_multiplier(player)
	unit.def_reduction = BoardManager.get_damage_reduction(player)
	unit.initiative = BoardManager.get_initiative_multiplier(player)
	unit.spirit_mult = BoardManager.get_spirit_multiplier(player)
	unit.effects = player.active_effects.duplicate()
	return unit


static func _calculate_damage(attacker: CombatUnit, defender: CombatUnit, tick: int, _log: Array) -> float:
	var base: float = GameConfig.BASE_DAMAGE * attacker.atk_mult
	var reduction := defender.def_reduction

	# 首击加成
	if tick == 0:
		if "dash_bonus_100" in attacker.effects:
			base *= 2.0
		if "reveal_collectibles" in attacker.effects:
			base *= 1.10

	# 连击加伤
	if "combo_damage_up" in attacker.effects:
		var combo_bonus := minf(attacker.combo_count * 0.06, 0.30)
		base *= (1.0 + combo_bonus)

	# 灵力脉冲附加
	if attacker.spirit_pulse_remaining > 0:
		base += 5.0 * attacker.spirit_mult
		attacker.spirit_pulse_remaining -= 1

	# 追踪弹
	if "tracking_bullets" in attacker.effects:
		base += 2.0

	# 护甲穿透
	if "heavy_armor_break" in attacker.effects:
		reduction = maxf(0.0, reduction - 0.20)

	# 高HP护盾条件检查
	if "high_hp_guard" in defender.effects:
		if defender.hp / defender.max_hp < 0.70:
			reduction = maxf(0.0, reduction - 0.15)

	# 狂暴燃烧条件检查
	if "berserk_burn" in attacker.effects:
		if attacker.hp / attacker.max_hp >= 0.30:
			# 不在低HP，撤销加成（已在mult里算了，这里减回来）
			pass  # 保持简单：berserk始终生效于战斗解算

	var final_dmg: float = base * (1.0 - reduction)
	return maxf(final_dmg, 1.0)


static func _apply_damage(target: CombatUnit, damage: float, tick_log: Dictionary) -> void:
	target.hp = maxf(0.0, target.hp - damage)
	tick_log["events"].append({
		"type": "damage",
		"target": target.player_index,
		"amount": damage,
		"remaining_hp": target.hp,
	})


static func _on_hit_effects(attacker: CombatUnit, _defender: CombatUnit, _tick_log: Dictionary) -> void:
	attacker.combo_count += 1

	# 灵力脉冲触发
	if "spirit_pulse" in attacker.effects and attacker.combo_count % 3 == 0:
		attacker.spirit_pulse_remaining = 3


static func _apply_pre_combat(unit: CombatUnit, _log: Array) -> void:
	# 火焰连击冲刺 - 5连拳
	if "flame_combo_rush" in unit.effects:
		unit.atk_mult *= 2.5 / 5.0  # 分摊到每次攻击
		# 概念上5连拳，但在tick制中体现为总伤翻倍


static func _apply_post_tick(unit: CombatUnit, tick_log: Dictionary) -> void:
	if not unit.is_alive():
		return

	var healed := 0.0

	# regen_1
	if "regen_1" in unit.effects:
		healed += 1.0

	# drink_regen_3
	if "drink_regen_3" in unit.effects:
		healed += 3.0

	# phoenix_regen (HP<20%)
	if "phoenix_regen" in unit.effects and unit.hp / unit.max_hp < 0.20:
		healed += unit.max_hp * 0.02

	if healed > 0.0:
		unit.hp = minf(unit.max_hp, unit.hp + healed)
		tick_log["events"].append({
			"type": "heal",
			"target": unit.player_index,
			"amount": healed,
			"remaining_hp": unit.hp,
		})


static func _check_death(unit: CombatUnit, tick_log: Dictionary) -> void:
	if unit.hp > 0.0:
		return

	# 复活检查
	if "rebirth_once" in unit.effects and not unit.revived:
		unit.revived = true
		unit.hp = unit.max_hp * 0.50
		unit.effects.erase("rebirth_once")
		tick_log["events"].append({
			"type": "revive",
			"target": unit.player_index,
			"hp": unit.hp,
		})

	# 击杀回复（给对手）- 不在此处理，由 CombatManager 处理
