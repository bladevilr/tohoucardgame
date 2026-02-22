extends Node

## 东方料理对决 — 核心游戏循环管理器
## 每日6行动结构：清晨奇遇→早市传闻→午间PvE→下午茶歇→黄昏暗盘→深夜PvP
## 每个事件节点之间回到商店界面让玩家操作

const AIControllerScript = preload("res://ai/AIController.gd")

var match_state: MatchState = null
var current_phase: int = 0
var current_action: int = 0  # 1-6 within a day
var ai_controller: Node = null
var _is_pve_showdown: bool = false  # Tracks if current showdown originated from PvE
var _pending_level_ups: int = 0     # Level-ups awaiting UI resolution
var game_mode: String = "casual"    # "ranked" / "casual"
var _match_save_done: bool = false  # 防止重复存档
var _cached_online_shadow: Dictionary = {}  # 从服务器预取的对手阵容

# Day action sequence
# Each action has: phase type, name, description
const DAY_ACTIONS := [
	{"action": 1, "phase": "SHOP", "id": "morning_event",
	 "name": "清晨奇遇", "name_en": "Dawn Encounter",
	 "desc": "晨雾未散，幻想乡的一天从意想不到的邂逅开始……"},
	{"action": 2, "phase": "SHOP", "id": "market_rumor",
	 "name": "早市传闻", "name_en": "Market Rumor",
	 "desc": "人里的早市熙熙攘攘，各种消息在摊贩间流传……"},
	{"action": 3, "phase": "PVE_BATTLE", "id": "noon_trial",
	 "name": "午间试营业", "name_en": "Noon Trial",
	 "desc": "正午的阳光下，是时候检验你的料理阵容了。"},
	{"action": 4, "phase": "SHOP", "id": "afternoon_tea",
	 "name": "下午茶歇", "name_en": "Afternoon Tea",
	 "desc": "午后的闲暇时光，总会有些有趣的事情发生……"},
	{"action": 5, "phase": "SHOP", "id": "dusk_market",
	 "name": "黄昏暗盘", "name_en": "Dusk Black Market",
	 "desc": "夕阳西下，暗巷深处传来神秘的叫卖声……"},
	{"action": 6, "phase": "PVP_BATTLE", "id": "midnight_showdown",
	 "name": "深夜料理对决", "name_en": "Midnight Showdown",
	 "desc": "月光下的终极对决，胜者为王，败者扣除声望。"},
]

func _ready():
	OnlineManager.shadow_fetched.connect(_on_shadow_fetched)

func _on_shadow_fetched(data: Dictionary) -> void:
	if data.get("ok", false):
		_cached_online_shadow = data.get("shadow", {})

func start_new_game(chef_id: String, opponent_chef_id: String = "", mode: String = "casual", opponent_profile: Dictionary = {}):
	match_state = MatchState.new()
	match_state.players[0].chef_id = chef_id
	match_state.players[0].prestige = GameConfig.STARTING_PRESTIGE
	match_state.players[0].gold = GameConfig.STARTING_GOLD
	_apply_chef_passive(match_state.players[0])
	game_mode = mode
	match_state.game_mode = mode
	match_state.opponent_display_name = opponent_profile.get("display_name", "AI对手")
	match_state.opponent_rating = int(opponent_profile.get("rating", 1000))
	_match_save_done = false

	# AI opponent
	if opponent_chef_id.is_empty():
		var chefs = ChefDatabase.get_all()
		chefs.shuffle()
		for c in chefs:
			if c.get("id", "") != chef_id:
				opponent_chef_id = c.get("id", "")
				break
	match_state.players[1].chef_id = opponent_chef_id
	match_state.players[1].prestige = GameConfig.STARTING_PRESTIGE
	match_state.players[1].gold = GameConfig.STARTING_GOLD
	_apply_chef_passive(match_state.players[1])

	ai_controller = AIControllerScript.new()
	ai_controller.setup(match_state)

	start_day()

func _apply_chef_passive(player: PlayerState):
	var chef = ChefDatabase.get_chef(player.chef_id)
	if chef.is_empty():
		return
	var skill_effect = chef.get("skill", {}).get("effect", {})
	player.max_tools = chef.get("tool_slots", 3)
	if skill_effect.get("yatai_cd_reduction", 0.0) > 0:
		player.yatai_cd_reduction = skill_effect.yatai_cd_reduction
	player.chef_skill_effect = skill_effect

func start_day():
	current_action = 0
	_cached_online_shadow = {}
	match_state.pick_judges()
	ShopManager.generate_shop(match_state.players[0], match_state.current_day)
	if ai_controller != null:
		ai_controller.do_shop_phase()
	# 预取服务器上其他玩家的阵容快照，供 PvP 使用
	OnlineManager.fetch_random_shadow()
	SignalBus.day_started.emit(match_state.current_day)
	_advance_to_next_action()

func change_phase(phase: int):
	current_phase = phase
	match_state.current_phase = phase
	if phase == GameConfig.Phase.PREP and ai_controller != null:
		ai_controller.do_prep_phase()
	SignalBus.phase_changed.emit(phase)

func advance_phase():
	"""Called by UI when player finishes current phase.
	Progresses through the 6-action day structure."""
	match current_phase:
		GameConfig.Phase.SHOP:
			# From shop, advance to next action
			_advance_to_next_action()
		GameConfig.Phase.PVE_CHOICE:
			# Player chose PvE difficulty; set up AI with chosen opponent and proceed to battle
			if ai_controller != null:
				var difficulty: int = clampi(int(match_state.current_encounter.get("difficulty", 1)), 1, 3)
				ai_controller.setup_pve_opponent(difficulty, match_state.current_day)
			_is_pve_showdown = true
			change_phase(GameConfig.Phase.PVE_BATTLE)
		GameConfig.Phase.PVE_BATTLE:
			# PvE now goes through full showdown: PVE_BATTLE → PREP → SHOWDOWN
			_is_pve_showdown = true
			change_phase(GameConfig.Phase.PREP)
		GameConfig.Phase.PREP:
			# From prep, go to showdown
			change_phase(GameConfig.Phase.SHOWDOWN)
		GameConfig.Phase.SHOWDOWN:
			# After showdown, check if this was PvE or PvP
			if _is_pve_showdown:
				_is_pve_showdown = false
				# Award PvE XP based on chosen difficulty
				var pve_diff: int = clampi(int(match_state.current_encounter.get("difficulty", 1)), 1, 3)
				_award_player_xp(GameConfig.XP_PER_PVE_BY_DIFF[pve_diff])
				# Save player board as shadow for future PvP opponents
				_save_player_shadow()
				change_phase(GameConfig.Phase.SHOP)
			else:
				# PvP：无论胜负都给经验，胜利额外+1
				var scores: Array = match_state.showdown_scores
				var pvp_xp: int = GameConfig.XP_PER_ACTION
				if scores.size() >= 2 and float(scores[0]) > float(scores[1]):
					pvp_xp += 1
				_award_player_xp(pvp_xp)
				_end_day()
		GameConfig.Phase.PVP_BATTLE:
			# PvP goes through prep first
			change_phase(GameConfig.Phase.PREP)

func _advance_to_next_action():
	"""Move to the next action in the day sequence."""
	current_action += 1
	if current_action > 6:
		_end_day()
		return

	var action = DAY_ACTIONS[current_action - 1]
	match_state.current_action = current_action
	match_state.current_action_data = action

	match action.phase:
		"SHOP":
			# 完成商店行动获得经验
			_award_player_xp(GameConfig.XP_PER_ACTION)
			# 重置商店状态，重新生成三选一气泡（免费）
			ShopManager.generate_shop(match_state.players[0], match_state.current_day)
			change_phase(GameConfig.Phase.SHOP)
		"PVE_BATTLE":
			# Generate 3 difficulty choices for player selection, then show PVE_CHOICE phase
			var pve_choices: Array = EncounterManager.generate_pve_choices(match_state.current_day)
			match_state.set_meta("pve_choices", pve_choices)
			# Default current_encounter to easiest option
			if not pve_choices.is_empty():
				match_state.current_encounter = pve_choices[0]
			change_phase(GameConfig.Phase.PVE_CHOICE)
		"PVP_BATTLE":
			# PvP showdown - try online shadow → local shadow → AI fallback
			var shadow: Dictionary = {}
			if not _cached_online_shadow.is_empty():
				# 使用服务器上的真实玩家阵容
				shadow = _cached_online_shadow.get("snapshot", {})
				shadow["chef_id"] = _cached_online_shadow.get("chef_id", "")
				shadow["display_name"] = _cached_online_shadow.get("nickname", "")
				_cached_online_shadow = {}
			else:
				shadow = SaveManager.get_random_shadow()
			if ai_controller != null:
				if not shadow.is_empty():
					ai_controller.setup_shadow_opponent(shadow)
					var opp_name: String = str(shadow.get("display_name", shadow.get("nickname", "")))
					if opp_name != "":
						match_state.opponent_display_name = opp_name
				else:
					ai_controller.do_shop_phase()
			change_phase(GameConfig.Phase.PREP)

func skip_to_showdown():
	"""Shortcut: skip remaining events and go straight to PvP prep."""
	current_action = 5  # Will advance to 6 (PvP)
	_advance_to_next_action()

func _end_day():
	SignalBus.day_ended.emit(match_state.current_day)

	# 每日工资
	match_state.players[0].add_gold(GameConfig.DAILY_BASE_INCOME)

	# Check elimination
	for i in range(2):
		if match_state.players[i].prestige <= 0:
			_save_match_result(1 - i)
			SignalBus.match_ended.emit(1 - i)
			return
	# Check win condition
	for i in range(2):
		if match_state.players[i].wins >= GameConfig.WINS_TO_CLEAR:
			_save_match_result(i)
			SignalBus.match_ended.emit(i)
			return
	# Next day
	match_state.start_new_day()
	start_day()

func _save_match_result(winner_idx: int) -> void:
	if _match_save_done:
		return
	_match_save_done = true
	var player: PlayerState = match_state.players[0]
	var result: String = "win" if winner_idx == 0 else "loss"
	SaveManager.record_match(game_mode, result, player.chef_id, player.prestige, match_state.current_day)
	# Online leaderboard submission
	var p_score: float = float(match_state.showdown_scores[0]) if match_state.showdown_scores.size() > 0 else 0.0
	var o_score: float = float(match_state.showdown_scores[1]) if match_state.showdown_scores.size() > 1 else 0.0
	OnlineManager.submit_match(game_mode, result, player.chef_id, player.prestige, match_state.current_day, p_score, o_score)

func get_current_action_data() -> Dictionary:
	"""Get the current action's metadata for UI display."""
	if current_action >= 1 and current_action <= 6:
		return DAY_ACTIONS[current_action - 1]
	return {}

func get_day_progress() -> Dictionary:
	"""Get day progress info for UI."""
	return {
		"day": match_state.current_day if match_state else 1,
		"action": current_action,
		"total_actions": 6,
		"action_name": get_current_action_data().get("name", ""),
		"action_desc": get_current_action_data().get("desc", ""),
	}

func get_match_state() -> MatchState:
	return match_state

func get_player(idx: int = 0) -> PlayerState:
	if match_state:
		return match_state.get_player(idx)
	return null

func pop_pending_level_up() -> bool:
	"""Consume one pending level-up. Returns true if one was pending."""
	if _pending_level_ups > 0:
		_pending_level_ups -= 1
		return true
	return false

func _save_player_shadow() -> void:
	"""Save the current player board as a shadow snapshot for future PvP opponents."""
	if match_state == null:
		return
	var player: PlayerState = match_state.players[0]
	var board_items: Array = []
	for i in range(player.board_size):
		if player.board[i] != null and player.board[i] is Dictionary:
			board_items.append(player.board[i].duplicate(true))
		else:
			board_items.append(null)
	var snapshot: Dictionary = {
		"chef_id": player.chef_id,
		"board": board_items,
		"tools": player.tools.duplicate(true),
		"techniques": player.techniques.duplicate(true),
		"day": match_state.current_day,
		"prestige": player.prestige,
		"display_name": SaveManager.get_nickname(),
	}
	SaveManager.save_shadow(snapshot)
	OnlineManager.upload_shadow(snapshot)

func _award_player_xp(amount: int) -> void:
	"""Award XP to player 0, track level-ups, emit signals."""
	if match_state == null:
		return
	var player: PlayerState = match_state.players[0]
	var levelups: int = player.add_xp(amount)
	if levelups > 0:
		_pending_level_ups += levelups
		SignalBus.player_leveled_up.emit(0, player.level)
	SignalBus.xp_gained.emit(0, player.xp, GameConfig.XP_PER_LEVEL)
