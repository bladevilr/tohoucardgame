extends RefCounted
class_name ShowdownResolverV2

## V2 混合引擎 — 实时 Tick + 评委状态机 + 8 大引擎机制
## 标签驱动的引擎行为：菜品标签自动触发对应机制，无需手动填写 triggers
## 评委系统（饱腹度、心情、需求、口味阈值）提供自然的反馈与制衡

# ===== 评委状态 =====
var _states: Array[JudgeStateV2] = []

# ===== 运行时状态 =====
var _match_state: MatchState = null
var _trigger_system: TriggerSystem = null
var _runtimes: Array = []            # [player0_runtimes, player1_runtimes]
var _elapsed: float = 0.0
var _finished: bool = false
var _timeline: Array = []
var _scores: Array = [0.0, 0.0]

# ===== 引擎机制状态 =====
var _addiction_stacks: Array = [0, 0]
var _addiction_timer: float = 0.0
var _addiction_decay_timer: float = 0.0      # 上瘾衰减计时
var _sizzle_counters: Array = [{}, {}]
var _greasy_stacks: Array = [0, 0]
var _umami_primed: Array = [{}, {}]
var _fermented_growth: Array = [{}, {}]      # 发酵成长型：slot_idx -> 累计成长%

# ===== 需求触发器/满足器标签集合 =====
const THIRST_TRIGGERS := ["spicy", "grilled", "roasted", "numbing"]
const THIRST_SATISFIERS := ["soup", "tea", "light"]
const GREASY_TRIGGERS := ["rich", "fried"]
const GREASY_SATISFIERS := ["light", "sour", "tea", "vegetable"]
const STAPLE_SATISFIERS := ["noodle", "rice", "staple"]
const FLAVOR_TAGS := ["spicy", "sweet", "rich", "umami_tag", "sour", "light", "grilled", "fried", "stewed", "raw", "steamed"]

# ============================================================
#  setup — 初始化评委 + 运行时 + 引擎状态
# ============================================================

func setup(match_state: MatchState, judge_ids: Array) -> void:
	_match_state = match_state
	_states.clear()

	# 评委初始化
	for judge_id in judge_ids:
		var judge_config: Dictionary = JudgeDatabase.get_judge_v2(judge_id)
		_states.append(JudgeStateV2.new(judge_config))

	if _states.size() == 1:
		var judge_config: Dictionary = JudgeDatabase.get_judge_v2("eiki")
		_states.append(JudgeStateV2.new(judge_config))

	# 从 PlayerState 提取板面物品，创建运行时
	_runtimes = [[], []]
	for p_idx in range(2):
		var player: PlayerState = match_state.players[p_idx]
		var runtimes: Array = []
		for entry in player.get_board_items():
			runtimes.append({
				"item": entry.item,
				"slot_idx": entry.slot_idx,
				"base_cd": float(entry.item.get("cooldown", 3.0)),
				"current_cd": float(entry.item.get("cooldown", 3.0)),
				"activate_count": 0,
			})
		_runtimes[p_idx] = runtimes

	# 初始化 TriggerSystem（用于工具触发器）
	_trigger_system = TriggerSystem.new(match_state)

	# 初始化引擎状态
	_sizzle_counters = [{}, {}]
	_umami_primed = [{}, {}]
	_fermented_growth = [{}, {}]
	_addiction_stacks = [0, 0]
	_addiction_timer = 0.0
	_addiction_decay_timer = 0.0
	_greasy_stacks = [0, 0]
	_scores = [0.0, 0.0]
	_elapsed = 0.0
	_timeline = []
	_finished = false

# ============================================================
#  tick — 核心循环（每 0.1s 调用一次）
# ============================================================

func tick(delta: float) -> void:
	if _finished:
		return

	# 全局油腻减速 — 双方独立
	for p_idx in range(2):
		var greasy_slow: float = 1.0 + _greasy_stacks[p_idx] * GameConfig.GREASY_SLOW_PER_STACK
		var effective_delta: float = delta / greasy_slow

		for runtime in _runtimes[p_idx]:
			runtime.current_cd -= effective_delta
			if runtime.current_cd <= 0.0:
				_activate_item(p_idx, runtime, 0)

	# 上瘾 DoT 全局计时（每 1 秒触发一次）
	_addiction_timer += delta
	while _addiction_timer >= 1.0:
		_addiction_timer -= 1.0
		for p_idx in range(2):
			if _addiction_stacks[p_idx] > 0:
				var dot_score: float = _addiction_stacks[p_idx] * GameConfig.ADDICTION_SCORE_PER_STACK
				_scores[p_idx] += dot_score
				SignalBus.dot_tick.emit(p_idx, dot_score)

	# 上瘾自然衰减（每5秒衰减10%层数）
	_addiction_decay_timer += delta
	while _addiction_decay_timer >= GameConfig.ADDICTION_DECAY_INTERVAL:
		_addiction_decay_timer -= GameConfig.ADDICTION_DECAY_INTERVAL
		for p_idx in range(2):
			if _addiction_stacks[p_idx] > 0:
				var decay: int = maxi(1, int(_addiction_stacks[p_idx] * GameConfig.ADDICTION_DECAY_PERCENT))
				_addiction_stacks[p_idx] = maxi(0, _addiction_stacks[p_idx] - decay)

	# TriggerSystem 延迟效果处理
	_trigger_system.process_delayed_effects()

	# 时间推进
	_elapsed += delta
	SignalBus.showdown_tick.emit(_elapsed)

	# 30 秒时限检查
	if _elapsed >= GameConfig.V2_SHOWDOWN_DURATION:
		_finished = true

# ============================================================
#  _activate_item — 激活管线（8 大机制 + 评委评分）
# ============================================================

func _activate_item(p_idx: int, runtime: Dictionary, _multicast_depth: int = 0) -> void:
	var item: Dictionary = runtime.item
	runtime.activate_count += 1
	var tags: Array = item.get("tags", [])
	var board_size: int = _match_state.players[p_idx].board_size

	# ---- 区域 & 位置判定 ----
	var slot: int = runtime.slot_idx
	var zone: String = _get_zone(slot, board_size)
	var is_leftmost: bool = _is_leftmost(slot, p_idx)
	var is_rightmost: bool = _is_rightmost(slot, p_idx)

	# ---- 阶段1: V2 评委评分 ----
	var score: float = _score_dish_dual(item, p_idx)

	# 主菜区加成：基础风味+10%
	if zone == "main":
		score *= (1.0 + GameConfig.ZONE_MAIN_BONUS)

	# 甜品区加成：首次激活得分+25%
	if zone == "dessert" and runtime.activate_count == 1:
		score *= (1.0 + GameConfig.ZONE_DESSERT_BONUS)

	# 最右位加成：得分+20%
	if is_rightmost:
		score *= (1.0 + GameConfig.EDGE_RIGHT_SCORE_BONUS)

	for state in _states:
		_post_serve(item, score, state)

	# ---- 阶段2: 发酵（成长型）----
	if "fermented" in tags:
		# 首次加成
		if runtime.activate_count == 1:
			score *= GameConfig.FERMENTED_FIRST_BONUS
		# 成长型：每次激活永久+1%，上限+30%
		var growth: float = _fermented_growth[p_idx].get(runtime.slot_idx, 0.0)
		if growth < GameConfig.FERMENTED_GROWTH_CAP:
			growth = minf(growth + GameConfig.FERMENTED_GROWTH_PER_ACT, GameConfig.FERMENTED_GROWTH_CAP)
			_fermented_growth[p_idx][runtime.slot_idx] = growth
		score *= (1.0 + growth)

	# ---- 阶段3: 提鲜倍率检查（改为作用于本slot，由右邻触发标记）----
	if _umami_primed[p_idx].get(runtime.slot_idx, false):
		score *= GameConfig.UMAMI_PRIME_MULT
		_umami_primed[p_idx].erase(runtime.slot_idx)

	# ---- 阶段4: 工具触发器（TriggerSystem）----
	var context: Dictionary = {
		"player_idx": p_idx,
		"item_idx": runtime.slot_idx,
		"item_data": item,
		"activate_count": runtime.activate_count,
		"score_bonus": {"flavor": 0, "technique": 0, "presentation": 0, "aroma": 0},
	}
	_trigger_system.process_event("item_activated", context)
	var trigger_bonus: float = 0.0
	for k in context.score_bonus:
		trigger_bonus += float(context.score_bonus[k])
	score += trigger_bonus

	# ---- 阶段4.5: 关键词高层乘算 ----
	var player: PlayerState = _match_state.players[p_idx]
	var umami_stacks: int = player.get_keyword_stacks("umami")
	if umami_stacks >= GameConfig.KEYWORD_MULT_THRESHOLD:
		score *= (1.0 + umami_stacks * GameConfig.UMAMI_HIGH_SCORE_MULT)
	var plating_stacks: int = player.get_keyword_stacks("plating")
	if plating_stacks >= GameConfig.KEYWORD_MULT_THRESHOLD:
		score *= (1.0 + plating_stacks * GameConfig.PLATING_HIGH_SCORE_MULT)

	# ---- 阶段5: 标签驱动的引擎机制 ----

	# 标签冲突检测
	var has_spicy_sour: bool = "spicy" in tags or "sour" in tags
	var has_rich_staple: bool = "rich" in tags and "staple" in tags
	var has_light_tea: bool = "light" in tags or "tea" in tags
	var has_rich_fried: bool = "rich" in tags and "fried" in tags

	# 开胃：辣/酸 → 百分比推进相邻CD（被 rich+staple 压制）
	if has_spicy_sour and not has_rich_staple:
		var adj_items: Array = _match_state.players[p_idx].get_adjacent(runtime.slot_idx)
		var appetizer_mult: float = 1.0
		if zone == "appetizer":
			appetizer_mult += GameConfig.ZONE_APPETIZER_BONUS
		for rt in _runtimes[p_idx]:
			if rt == runtime:
				continue
			if rt.item in adj_items:
				var cd_reduction: float = rt.current_cd * GameConfig.APPETIZING_CD_PERCENT * appetizer_mult
				rt.current_cd = maxf(0.0, rt.current_cd - cd_reduction)

	# 上瘾：浓郁/鲜味 → 叠加上瘾层数
	if "rich" in tags or "umami_tag" in tags:
		_addiction_stacks[p_idx] = mini(
			_addiction_stacks[p_idx] + GameConfig.ADDICTION_STACKS_PER_ACTIVATE,
			GameConfig.ADDICTION_MAX_STACKS
		)
		SignalBus.keyword_gained.emit(p_idx, runtime.slot_idx, "addictive", _addiction_stacks[p_idx])

	# 爆香：烤/炒 → 积累热量，阈值到达后对基础分乘算爆发
	if "grilled" in tags or "stir_fried" in tags:
		var key: int = runtime.slot_idx
		_sizzle_counters[p_idx][key] = _sizzle_counters[p_idx].get(key, 0) + 1
		# 锅气高层减少爆香阈值
		var char_stacks: int = player.get_keyword_stacks("char_aroma")
		var effective_threshold: int = GameConfig.SIZZLE_THRESHOLD
		if char_stacks >= GameConfig.KEYWORD_MULT_THRESHOLD:
			effective_threshold = maxi(2, effective_threshold - GameConfig.CHAR_AROMA_SIZZLE_REDUCTION)
		if _sizzle_counters[p_idx][key] >= effective_threshold:
			var burst_score: float = score * GameConfig.SIZZLE_BURST_MULT
			score += burst_score
			_sizzle_counters[p_idx][key] = 0
			SignalBus.keyword_gained.emit(p_idx, runtime.slot_idx, "sizzling", 0)

	# 油腻：同时有 rich+fried → 叠加油腻（清口同时存在时不叠）
	if has_rich_fried and not has_light_tea:
		_greasy_stacks[p_idx] = mini(
			_greasy_stacks[p_idx] + 1,
			GameConfig.GREASY_MAX_STACKS
		)
		SignalBus.keyword_gained.emit(p_idx, runtime.slot_idx, "greasy", _greasy_stacks[p_idx])

	# 清口：清淡/茶 → 引爆式清除油腻（50%），转化为分数+全场CD推进
	if has_light_tea:
		var clear_amount: int = maxi(
			GameConfig.REFRESHING_CLEAR_MIN,
			int(_greasy_stacks[p_idx] * GameConfig.REFRESHING_CLEAR_PERCENT)
		)
		var cleared: int = mini(_greasy_stacks[p_idx], clear_amount)
		if cleared > 0:
			_greasy_stacks[p_idx] -= cleared
			# 分数回馈
			var refresh_score: float = cleared * GameConfig.REFRESHING_SCORE_PER_STACK
			score += refresh_score
			# CD加速回馈
			var speed_bonus: float = cleared * GameConfig.REFRESHING_SPEED_PER_STACK
			for rt in _runtimes[p_idx]:
				rt.current_cd = maxf(0.0, rt.current_cd - speed_bonus)
			SignalBus.keyword_consumed.emit(p_idx, "greasy", cleared)

	# 提鲜：umami_tag + 同菜系 >= 2 → 标记右侧邻居下次×1.8
	if "umami_tag" in tags:
		var cuisine: String = item.get("cuisine", "")
		if cuisine != "":
			var cuisine_count: int = 0
			for rt in _runtimes[p_idx]:
				if rt.item.get("cuisine", "") == cuisine:
					cuisine_count += 1
			if cuisine_count >= GameConfig.UMAMI_CUISINE_THRESHOLD:
				# 标记右侧邻居
				var right_neighbor = _match_state.players[p_idx].get_right_neighbor(runtime.slot_idx)
				if right_neighbor != null:
					var right_slot: int = -1
					for rt in _runtimes[p_idx]:
						if rt.item == right_neighbor:
							right_slot = rt.slot_idx
							break
					if right_slot >= 0:
						_umami_primed[p_idx][right_slot] = true
						SignalBus.keyword_gained.emit(p_idx, right_slot, "umami", 1)

	# ---- 阶段5.5: 刀工高层CD减少 ----
	var kw_stacks: int = player.get_keyword_stacks("knife_work")
	if kw_stacks >= GameConfig.KEYWORD_MULT_THRESHOLD:
		var kw_cd_reduction: float = runtime.base_cd * kw_stacks * GameConfig.KNIFE_WORK_HIGH_CD_PERCENT
		runtime.current_cd = maxf(0.0, runtime.current_cd - kw_cd_reduction)

	# ---- 阶段6: 爽脆多播（fried 标签，概率双重激活，衰减得分）----
	if "fried" in tags and _multicast_depth < GameConfig.MAX_MULTICAST_DEPTH:
		if randf() < GameConfig.CRISP_MULTICAST_CHANCE:
			# 记录当前得分，然后递归（递归的得分会衰减）
			score *= GameConfig.CRISP_SCORE_DECAY if _multicast_depth > 0 else 1.0
			_scores[p_idx] += score
			runtime.current_cd = maxf(GameConfig.MIN_CD_FLOOR, runtime.base_cd)
			# 最左位CD加成
			if is_leftmost:
				runtime.current_cd *= (1.0 - GameConfig.EDGE_LEFT_CD_BONUS)
			_timeline.append({
				"time": _elapsed, "player": p_idx, "dish": item,
				"slot_idx": runtime.slot_idx, "score": score,
			})
			SignalBus.showdown_item_served.emit(p_idx, runtime.slot_idx, {
				"score": score, "dish": item,
				"satiety": int(_states[0].satiety) if _states.size() > 0 else 0,
				"mood": int(_states[0].mood) if _states.size() > 0 else 0,
				"needs": _states[0].needs.duplicate() if _states.size() > 0 else [],
			})
			_activate_item(p_idx, runtime, _multicast_depth + 1)
			return

	# 爽脆衰减（非首次多播）
	if _multicast_depth > 0:
		score *= GameConfig.CRISP_SCORE_DECAY

	# ---- 阶段7: 记录和发送信号 ----
	_scores[p_idx] += score

	# 重置 CD（应用最低 CD 保底 + 尽头加成）
	runtime.current_cd = maxf(GameConfig.MIN_CD_FLOOR, runtime.base_cd)
	# 最左位CD加成：基础CD-15%
	if is_leftmost:
		runtime.current_cd *= (1.0 - GameConfig.EDGE_LEFT_CD_BONUS)

	# 记录时间线
	_timeline.append({
		"time": _elapsed,
		"player": p_idx,
		"dish": item,
		"slot_idx": runtime.slot_idx,
		"score": score,
	})

	# 发送上菜信号
	SignalBus.showdown_item_served.emit(p_idx, runtime.slot_idx, {
		"score": score,
		"dish": item,
		"satiety": int(_states[0].satiety) if _states.size() > 0 else 0,
		"mood": int(_states[0].mood) if _states.size() > 0 else 0,
		"needs": _states[0].needs.duplicate() if _states.size() > 0 else [],
	})

# ============================================================
#  双评委打分：取平均值
# ============================================================

func _score_dish_dual(dish: Dictionary, _p_idx: int = 0) -> float:
	var total_score: float = 0.0
	for state in _states:
		total_score += _score_dish(dish, state)
	return total_score / float(_states.size())

# ============================================================
#  核心公式：scoreDish (从 sim2.js 移植)
#  使用 tick 模式调参常量以适配更高激活频率
# ============================================================

func _score_dish(dish: Dictionary, s: JudgeStateV2) -> float:
	var j: Dictionary = s.judge_config

	# 基础分 = 风味 × 技法乘区
	var bs: Dictionary = dish.get("base_stats", {})
	var flavor: float = float(dish.get("flavor", bs.get("flavor", 0)))
	var technique: float = float(dish.get("technique", bs.get("technique", 0)))
	var presentation: float = float(dish.get("presentation", bs.get("presentation", 0)))

	var tech_mult: float = GameConfig.V2_TECH_MULT_BASE + technique * GameConfig.V2_TECH_MULT_PER_POINT
	var score: float = flavor * tech_mult

	# 疲劳曲线（tick 模式使用降低的疲劳率）
	var fatigue: float = maxf(GameConfig.V2_FATIGUE_FLOOR, 1.0 - s.dish_count * GameConfig.V2_TICK_FATIGUE_PER_DISH)
	score *= fatigue

	# 大小归一化
	var d_size: int = int(dish.get("size", 2))
	if d_size >= 2:
		score = score / pow(d_size, GameConfig.V2_SIZE_EXPONENT) * GameConfig.V2_SIZE_COMPENSATION

	# 味觉阈值
	var f_tags: Array = _get_flavor_tags(dish)
	var th_mult: float = 1.0
	for ft in f_tags:
		th_mult *= _threshold_decay(s.threshold.get(ft, 0.0))
	score *= th_mult

	# 需求满足（flat bonus）
	var need_bonus: float = 0.0
	var needs_met: int = 0
	var reward_mult: float = s.get_need_reward_mult()
	var tags: Array = dish.get("tags", [])
	var cuisine: String = dish.get("cuisine", "")

	if s.has_need("thirst") and _has_any_tag(dish, THIRST_SATISFIERS):
		need_bonus += GameConfig.V2_NEED_BONUS_THIRST * reward_mult
		s.satisfy_need("thirst")
		needs_met += 1

	if s.has_need("greasy") and _has_any_tag(dish, GREASY_SATISFIERS):
		need_bonus += GameConfig.V2_NEED_BONUS_GREASY * reward_mult
		s.satisfy_need("greasy")
		needs_met += 1

	if s.has_need("want_staple") and _has_any_tag(dish, STAPLE_SATISFIERS):
		need_bonus += GameConfig.V2_NEED_BONUS_STAPLE * reward_mult
		s.satisfy_need("want_staple")
		needs_met += 1

	if s.has_need("sweet_stomach") and tags.has("sweet"):
		need_bonus += GameConfig.V2_NEED_BONUS_SWEET * reward_mult
		s.satisfy_need("sweet_stomach")
		needs_met += 1

	if s.has_need("novelty") and not s.cuisines_seen.has(cuisine):
		need_bonus += GameConfig.V2_NEED_BONUS_NOVELTY * reward_mult
		s.satisfy_need("novelty")
		needs_met += 1

	if s.has_need("afterglow"):
		need_bonus += GameConfig.V2_NEED_BONUS_AFTERGLOW * reward_mult
		s.satisfy_need("afterglow")
		needs_met += 1

	if s.has_need("addiction"):
		var add_tag: String = s.cons_flavor.tag
		if add_tag != "" and tags.has(add_tag):
			need_bonus += GameConfig.V2_NEED_BONUS_ADDICTION * reward_mult
			s.satisfy_need("addiction")
			needs_met += 1

	# 需求奖励递减
	var dim: float = maxf(GameConfig.V2_NEED_DIMINISH_FLOOR, 1.0 - s._total_needs_met * GameConfig.V2_NEED_DIMINISH_RATE)
	score += need_bonus * GameConfig.V2_NEED_FLAT_MULT * dim
	s._total_needs_met += needs_met

	# 工具菜底线
	if needs_met > 0 and flavor <= 6:
		score = maxf(score, GameConfig.V2_UTILITY_FLOOR_BASE + needs_met * GameConfig.V2_UTILITY_FLOOR_PER_NEED)

	# 未满足需求惩罚
	var unmet_mult: float = s.get_unmet_penalty_mult()
	if s.needs.size() > 0:
		score *= maxf(GameConfig.V2_UNMET_PENALTY_FLOOR, 1.0 - s.needs.size() * GameConfig.V2_UNMET_PENALTY_RATE * unmet_mult)

	# 心情
	score *= maxf(GameConfig.V2_MOOD_FLOOR, 1.0 + s.mood * GameConfig.V2_MOOD_MULT_PER_POINT)

	# 评委偏好
	var pref: float = 0.0
	for pt in s.get_pref_tags():
		if tags.has(pt):
			pref += GameConfig.V2_PREF_BONUS
	for ht in s.get_hate_tags():
		if tags.has(ht):
			pref -= GameConfig.V2_HATE_PENALTY
	score *= (1.0 + pref)

	# yukari: 忽略前N道小菜
	if s.get_ignore_small_first() > 0 and d_size == 1 and s.small_dish_count < s.get_ignore_small_first():
		score *= 0.15

	# aya: 重复菜系惩罚
	if s.get_repeat_penalty() > 1.0 and s.cuisines_seen.has(cuisine):
		score *= (1.0 / s.get_repeat_penalty())

	# 菜系多样性奖励 (iku, miko)
	if s.get_cuisine_diversity_bonus() > 0.0:
		score *= (1.0 + s.cuisines_seen.size() * s.get_cuisine_diversity_bonus())

	# 卖相惊喜
	var surprise_base: float = GameConfig.V2_SURPRISE_BASE + s.dish_count * GameConfig.V2_SURPRISE_PER_DISH
	if presentation > surprise_base:
		var pres_mult: float = GameConfig.V2_SURPRISE_YOUSHOKU_KANMI_MULT if (cuisine == "youshoku" or cuisine == "kanmi") else GameConfig.V2_SURPRISE_DEFAULT_MULT
		score *= 1.0 + (presentation - surprise_base) * pres_mult

	# youshoku 套餐奖励
	if cuisine == "youshoku":
		var y_count: int = s._cuisine_count.get("youshoku", 0)
		if y_count >= GameConfig.V2_YOUSHOKU_COURSE_MIN_COUNT:
			score *= 1.0 + (y_count - 1) * GameConfig.V2_YOUSHOKU_COURSE_BONUS

	# 饱腹度惩罚
	var sat_pct: float = s.satiety / s.get_satiety_cap()
	if sat_pct > GameConfig.V2_SATIETY_THRESHOLD:
		var over: float = (sat_pct - GameConfig.V2_SATIETY_THRESHOLD) / (1.0 - GameConfig.V2_SATIETY_THRESHOLD)
		var sat_mult: float = GameConfig.V2_SATIETY_BASE_MULT - over * GameConfig.V2_SATIETY_PENALTY_RATE
		if tags.has("sweet") and s.has_need("sweet_stomach"):
			score *= maxf(GameConfig.V2_SATIETY_SWEET_FLOOR, sat_mult)
		else:
			score *= maxf(GameConfig.V2_SATIETY_FLOOR, sat_mult)

	# 菜系纯度奖励
	s._cuisine_count[cuisine] = s._cuisine_count.get(cuisine, 0) + 1
	var cc: int = s._cuisine_count[cuisine]
	if cc >= GameConfig.V2_CUISINE_PURITY_MIN_COUNT:
		score *= 1.0 + (cc - 2) * GameConfig.V2_CUISINE_PURITY_BONUS

	# 风味连贯性奖励
	if s.dish_count >= GameConfig.V2_COHERENCE_MIN_DISHES:
		var total_th: float = 0.0
		for v in s.threshold.values():
			total_th += v
		if total_th > 0:
			var match_weight: float = 0.0
			for ft in f_tags:
				var th: float = s.threshold.get(ft, 0.0)
				match_weight += th / total_th
			score *= 1.0 + match_weight * GameConfig.V2_COHERENCE_BONUS_MAX

	# yakuzen/tea/soup 清洗奖励
	if cuisine == "yakuzen" or tags.has("tea") or tags.has("soup"):
		var total_threshold: float = 0.0
		for v in s.threshold.values():
			total_threshold += v
		if total_threshold > 2:
			var cleanse_value: float = minf(total_threshold * GameConfig.V2_CLEANSE_THRESHOLD_MULT, GameConfig.V2_CLEANSE_CAP)
			score += cleanse_value

	# yakuzen 菜系奖励
	if cuisine == "yakuzen":
		score *= GameConfig.V2_YAKUZEN_MULT

	# kanmi 卖相奖励
	if cuisine == "kanmi" and presentation >= GameConfig.V2_KANMI_PRES_THRESHOLD:
		score *= 1.0 + (presentation - GameConfig.V2_KANMI_PRES_THRESHOLD) * GameConfig.V2_KANMI_PRES_BONUS_PER_POINT

	# 烤物连击
	if tags.has("grilled"):
		s._grill_streak += 1
		if s._grill_streak >= 2:
			score *= 1.0 + (s._grill_streak - 1) * GameConfig.V2_GRILL_STREAK_BONUS
	else:
		s._grill_streak = 0

	# 辛辣连击
	if tags.has("spicy"):
		s._spicy_streak += 1
		if s._spicy_streak >= 2:
			score *= 1.0 + mini(s._spicy_streak - 1, GameConfig.V2_SPICY_STREAK_CAP) * GameConfig.V2_SPICY_STREAK_BONUS
	else:
		s._spicy_streak = 0

	# 可预测性惩罚
	s._size_history.append(d_size)
	if s._size_history.size() >= 4:
		var h: Array = s._size_history
		var l: int = h.size()
		if h[l-1] == h[l-3] and h[l-2] == h[l-4] and h[l-1] != h[l-2]:
			s._predict_count += 1
			if s._predict_count >= 2:
				score *= maxf(GameConfig.V2_PREDICTABILITY_FLOOR, 1.0 - s._predict_count * GameConfig.V2_PREDICTABILITY_PENALTY)
		else:
			s._predict_count = maxi(0, s._predict_count - 1)

	# raiko 节奏奖励
	if s.has_rhythm_bonus() and needs_met > 0:
		score *= (1.0 + needs_met * 0.06)

	# 小菜饱和惩罚
	if d_size == 1 and s.small_dish_count >= GameConfig.V2_SMALL_DISH_SATURATION_THRESHOLD:
		var over_small: int = s.small_dish_count - (GameConfig.V2_SMALL_DISH_SATURATION_THRESHOLD - 1)
		score *= maxf(GameConfig.V2_SMALL_DISH_SATURATION_FLOOR, 1.0 - over_small * GameConfig.V2_SMALL_DISH_SATURATION_RATE)

	return maxf(0.0, roundf(score * 10.0) / 10.0)

# ============================================================
#  上菜后状态更新 (从 sim2.js 移植)
#  使用 tick 模式调参：降低饱腹增长和阈值增速
# ============================================================

func _post_serve(dish: Dictionary, dish_score: float, s: JudgeStateV2) -> void:
	var j: Dictionary = s.judge_config
	s.dish_count += 1
	var d_size: int = int(dish.get("size", 2))
	if d_size == 1:
		s.small_dish_count += 1
	var cuisine: String = dish.get("cuisine", "")
	s.cuisines_seen[cuisine] = true

	# 条件饱腹度（使用 tick 模式的降低基数）
	var base_sat: int = GameConfig.V2_TICK_SAT_BASE[d_size] if d_size < GameConfig.V2_TICK_SAT_BASE.size() else 5
	var avg_exp: float = 7.0 + s.dish_count * 1.2
	var tastiness: float = minf(dish_score / maxf(1.0, avg_exp), 2.5)
	var sat_mult: float = GameConfig.V2_SAT_TASTINESS_MULTS[0]
	for i in range(GameConfig.V2_SAT_TASTINESS_THRESHOLDS.size()):
		if tastiness >= GameConfig.V2_SAT_TASTINESS_THRESHOLDS[i]:
			sat_mult = GameConfig.V2_SAT_TASTINESS_MULTS[i + 1]
	var sat_gain: float = base_sat * sat_mult * s.get_gluttony()

	# 偏好匹配 → 吃更多
	var has_pref: bool = false
	var tags: Array = dish.get("tags", [])
	for pt in s.get_pref_tags():
		if tags.has(pt):
			has_pref = true
			break
	if has_pref:
		sat_gain *= GameConfig.V2_SAT_PREF_MULT

	s.satiety = minf(s.satiety + sat_gain, s.get_satiety_cap())

	# 味觉阈值更新（使用 tick 模式的降低增速）
	var f_tags: Array = _get_flavor_tags(dish)
	for ft in f_tags:
		var inc: float = GameConfig.V2_TICK_THRESHOLD_LIGHT_SWEET_INC if (ft == "sweet" or ft == "light") else GameConfig.V2_TICK_THRESHOLD_NORMAL_INC
		s.threshold[ft] = s.threshold.get(ft, 0.0) + inc

	# light/tea 清洗
	if tags.has("light") or tags.has("tea"):
		var cleanse_str: float = GameConfig.V2_YAKUZEN_CLEANSE if cuisine == "yakuzen" else GameConfig.V2_BASE_CLEANSE
		for k in s.threshold.keys():
			if k != "light" and k != "tea":
				s.threshold[k] = maxf(0.0, s.threshold[k] - cleanse_str)

	# 生成需求
	if _has_any_tag(dish, THIRST_TRIGGERS):
		var sens: float = s.get_need_sensitivity("thirst")
		if sens > 0:
			s.add_need("thirst", ceili(GameConfig.V2_NEED_TTL_THIRST * sens))

	if _has_any_tag(dish, GREASY_TRIGGERS):
		var sens: float = s.get_need_sensitivity("greasy")
		if sens > 0:
			s.add_need("greasy", ceili(GameConfig.V2_NEED_TTL_GREASY * sens))

	if d_size == 1 and not _has_any_tag(dish, STAPLE_SATISFIERS):
		s._small_streak += 1
		if s._small_streak >= GameConfig.V2_SMALL_STREAK_THRESHOLD:
			s.add_need("want_staple", GameConfig.V2_NEED_TTL_STAPLE)
	else:
		s._small_streak = 0

	if s.satiety / s.get_satiety_cap() > GameConfig.V2_SATIETY_SWEET_TRIGGER and tags.has("rich"):
		s.add_need("sweet_stomach", GameConfig.V2_NEED_TTL_SWEET)

	if cuisine != s._last_cuisine:
		var sens: float = s.get_need_sensitivity("novelty")
		if sens > 0.5:
			s.add_need("novelty", ceili(GameConfig.V2_NEED_TTL_NOVELTY * sens))
	s._last_cuisine = cuisine

	var avg_exp2: float = 7.0 + s.dish_count * 1.2
	if dish_score > avg_exp2 * GameConfig.V2_AFTERGLOW_MULT:
		var dur_mult: float = s.get_afterglow_duration_mult()
		s.add_need("afterglow", int(GameConfig.V2_NEED_TTL_AFTERGLOW * dur_mult))

	# 上瘾追踪
	var dom_flavor: String = ""
	for ft in f_tags:
		if ft != "light" and ft != "steamed":
			dom_flavor = ft
			break
	if dom_flavor != "" and dom_flavor == s.cons_flavor.tag:
		s.cons_flavor.count += 1
		var add_sens: float = s.get_need_sensitivity("addiction")
		var threshold: int = maxi(1, roundi(GameConfig.V2_ADDICTION_BASE_THRESHOLD / add_sens))
		if s.cons_flavor.count >= threshold:
			s.add_need("addiction", GameConfig.V2_NEED_TTL_ADDICTION)
	elif dom_flavor != "":
		s.cons_flavor = {"tag": dom_flavor, "count": 1}

	# 心情更新
	var has_pref2: bool = false
	for pt in s.get_pref_tags():
		if tags.has(pt):
			has_pref2 = true
			break
	if has_pref2:
		var swing: float = s.get_mood_swing_mult()
		s.mood = minf(5.0, s.mood + 1.0 * swing)

	var has_hate: bool = false
	for ht in s.get_hate_tags():
		if tags.has(ht):
			has_hate = true
			break
	if has_hate:
		var swing: float = s.get_mood_swing_mult()
		s.mood = maxf(-5.0, s.mood - 1.0 * swing)

	s.tick_needs()
	s.last_score = dish_score

# ============================================================
#  公共接口
# ============================================================

func is_finished() -> bool:
	return _finished

func get_item_runtimes(p_idx: int) -> Array:
	return _runtimes[p_idx] if p_idx < _runtimes.size() else []

func get_result() -> Dictionary:
	var winner: String = "TIE"
	if _scores[0] > _scores[1]:
		winner = "A"
	elif _scores[1] > _scores[0]:
		winner = "B"

	return {
		"score_a": _scores[0],
		"score_b": _scores[1],
		"winner": winner,
		"elapsed": _elapsed,
		"timeline": _timeline,
		"addiction_stacks": _addiction_stacks.duplicate(),
		"greasy_stacks": _greasy_stacks.duplicate(),
	}

func get_engine_state(p_idx: int) -> Dictionary:
	return {
		"addiction": _addiction_stacks[p_idx] if p_idx < _addiction_stacks.size() else 0,
		"greasy": _greasy_stacks[p_idx] if p_idx < _greasy_stacks.size() else 0,
		"sizzle": _sizzle_counters[p_idx].duplicate() if p_idx < _sizzle_counters.size() else {},
		"umami_primed": _umami_primed[p_idx].duplicate() if p_idx < _umami_primed.size() else {},
		"fermented_growth": _fermented_growth[p_idx].duplicate() if p_idx < _fermented_growth.size() else {},
	}

# ============================================================
#  区域 & 位置辅助函数
# ============================================================

# 根据棋盘大小和slot位置判断区域
func _get_zone(slot_idx: int, board_size: int) -> String:
	# 区域划分：前菜区(~30%) | 主菜区(~40%) | 甜品区(~30%)
	var appetizer_end: int
	var dessert_start: int
	match board_size:
		4:
			appetizer_end = 2   # [0,1]
			dessert_start = 3   # [3]
		6:
			appetizer_end = 2   # [0,1]
			dessert_start = 4   # [4,5]
		8:
			appetizer_end = 3   # [0,1,2]
			dessert_start = 5   # [5,6,7]
		_:  # 10 or other
			appetizer_end = 3   # [0,1,2]
			dessert_start = 7   # [7,8,9]
	if slot_idx < appetizer_end:
		return "appetizer"
	elif slot_idx >= dessert_start:
		return "dessert"
	else:
		return "main"

# 判断是否为最左位（有实际卡牌的最小slot）
func _is_leftmost(slot_idx: int, p_idx: int) -> bool:
	for rt in _runtimes[p_idx]:
		if rt.slot_idx < slot_idx:
			return false
	return true

# 判断是否为最右位（有实际卡牌的最大slot）
func _is_rightmost(slot_idx: int, p_idx: int) -> bool:
	for rt in _runtimes[p_idx]:
		if rt.slot_idx > slot_idx:
			return false
	return true

# ============================================================
#  辅助函数
# ============================================================

func _threshold_decay(count: float) -> float:
	if count >= GameConfig.V2_ADDICTION_REVERSAL_START:
		return 1.0 + (count - GameConfig.V2_ADDICTION_REVERSAL_START + 1) * GameConfig.V2_ADDICTION_REVERSAL_RATE
	return maxf(GameConfig.V2_THRESHOLD_FLOOR, 1.0 - count * GameConfig.V2_THRESHOLD_DECAY_PER_COUNT)

func _get_flavor_tags(dish: Dictionary) -> Array:
	var result: Array = []
	var tags: Array = dish.get("tags", [])
	for t in tags:
		if FLAVOR_TAGS.has(t):
			result.append(t)
	return result

func _has_any_tag(dish: Dictionary, tag_set: Array) -> bool:
	var tags: Array = dish.get("tags", [])
	for t in tags:
		if tag_set.has(t):
			return true
	return false
