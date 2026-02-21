extends RefCounted
class_name MatchState

var players: Array[PlayerState] = []
var current_day: int = 1
var current_phase: int = 0  # GameConfig.Phase
var current_action: int = 0  # 1-6 within a day
var current_action_data: Dictionary = {}  # Current action metadata
var current_encounter: Dictionary = {}  # Current encounter/event data
var judges: Array = []  # 2 judge dicts for current day
var judge_pool_used: Array = []  # judge ids used this run

# 对战模式与对手信息
var game_mode: String = "casual"           # "ranked" / "casual"
var opponent_display_name: String = ""     # e.g. "八云紫#0001"
var opponent_rating: int = 1000

# Environment keywords (shared between both players)
var environment_keywords: Dictionary = {}  # keyword_id -> stacks

# Showdown state
var showdown_elapsed: float = 0.0
var showdown_scores: Array = [0.0, 0.0]  # player 0 and 1 total scores
var showdown_running: bool = false

func _init():
	players.append(PlayerState.new(0))
	players.append(PlayerState.new(1))

func get_player(idx: int) -> PlayerState:
	return players[idx]

func start_new_day():
	current_day += 1
	for p in players:
		p.free_refresh_used = false
		# Base income
		p.add_gold(GameConfig.GOLD_PER_DAY)
		# Day bonus: +1 per day, capped
		var day_bonus = mini(current_day - 1, GameConfig.DAY_INCOME_BONUS_CAP)
		p.add_gold(day_bonus)
		# Streak bonus
		if p.streak > 0:
			p.add_gold(GameConfig.get_streak_bonus(p.streak))
		elif p.streak < 0:
			p.add_gold(GameConfig.get_loss_streak_bonus(p.streak))

func pick_judges():
	var all_judges = JudgeDatabase.get_all()
	var available: Array = []
	for j in all_judges:
		if j.get("id", "") not in judge_pool_used:
			available.append(j)
	if available.size() < 2:
		judge_pool_used.clear()
		available = all_judges.duplicate()
	available.shuffle()
	judges = [available[0], available[1]]
	judge_pool_used.append(judges[0].get("id", ""))
	judge_pool_used.append(judges[1].get("id", ""))

func add_environment_keyword(keyword_id: String, stacks: int = 1):
	environment_keywords[keyword_id] = environment_keywords.get(keyword_id, 0) + stacks

func has_environment_keyword(keyword_id: String) -> bool:
	return environment_keywords.has(keyword_id) and environment_keywords[keyword_id] > 0

func get_environment_keyword_stacks(keyword_id: String) -> int:
	return environment_keywords.get(keyword_id, 0)

func clear_environment_keyword(keyword_id: String, amount: int = -1) -> int:
	var current = environment_keywords.get(keyword_id, 0)
	if current <= 0:
		return 0
	var to_clear = current if amount < 0 else mini(amount, current)
	environment_keywords[keyword_id] = current - to_clear
	if environment_keywords[keyword_id] <= 0:
		environment_keywords.erase(keyword_id)
	return to_clear

func reset_for_showdown():
	showdown_elapsed = 0.0
	showdown_scores = [0.0, 0.0]
	showdown_running = false
	environment_keywords.clear()
	for p in players:
		p.reset_for_showdown()

func apply_prestige_damage(loser_idx: int, score_diff: float):
	var damage = GameConfig.get_prestige_damage(score_diff)
	var player = players[loser_idx]
	# Check chef skill for damage reduction (e.g. future defensive skills)
	var chef = ChefDatabase.get_chef(player.chef_id)
	if not chef.is_empty():
		var skill_effect = chef.get("skill", {}).get("effect", {})
		if skill_effect.get("prestige_damage_reduction", 0.0) > 0:
			damage = maxi(1, int(damage * (1.0 - skill_effect.prestige_damage_reduction)))
	var old_prestige = player.prestige
	player.prestige = maxi(0, player.prestige - damage)
	SignalBus.prestige_changed.emit(loser_idx, old_prestige, player.prestige)
	if player.prestige <= 0:
		SignalBus.player_eliminated.emit(loser_idx)
