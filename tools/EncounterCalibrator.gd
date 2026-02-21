## PvE 打野校准器 (Encounter Calibrator)
##
## 模拟玩家在 Day 1~10 面对不同难度 NPC 的胜率。
## 根据天数自动推算玩家的典型卡组实力。
## 输出推荐的 NPC 数值和奖励金额。
##
## 用法:
##   var cal = EncounterCalibrator.new()
##   var report = cal.calibrate()
##   print(cal.format_report(report))

extends RefCounted
class_name EncounterCalibrator

const DAYS := [1, 3, 5, 7, 10]
const SIMS_PER_CHECK := 200

## 目标胜率曲线: Day -> 目标胜率
const TARGET_WIN_RATES := {
	1: 0.85,
	3: 0.70,
	5: 0.55,
	7: 0.45,
	10: 0.35,
}

var _simulator := HeadlessSimulator.new()

## ---------- 按天数推算玩家"典型卡组" ----------
func _build_player_loadout_for_day(day: int) -> Dictionary:
	var tier_weights = GameConfig.get_tier_weights(day)

	# 按概率选菜品: 模拟玩家在该天拥有的平均品质卡组
	var all_dishes = DishDatabase.get_dishes()
	var available: Array = []
	for d in all_dishes:
		var t = int(d.get("tier", 0))
		if t <= _max_tier_for_day(day):
			available.append(d)

	# 按权重排序, 高tier优先
	available.sort_custom(func(a, b): return int(a.get("tier", 0)) > int(b.get("tier", 0)))

	var dish_ids: Array = []
	var total_size := 0
	for d in available:
		if total_size >= 8:  # 留2格给食材
			break
		var size = int(d.get("size", 1))
		if total_size + size <= 8:
			dish_ids.append(d.get("id", ""))
			total_size += size

	# 补食材
	var ingredients = DishDatabase.get_ingredients()
	ingredients.shuffle()
	for ing in ingredients:
		if total_size >= 10:
			break
		dish_ids.append(ing.get("id", ""))
		total_size += 1

	# 随机厨师
	var chefs = ChefDatabase.get_all()
	var chef_id = ""
	if not chefs.is_empty():
		chefs.shuffle()
		chef_id = chefs[0].get("id", "")

	return {"chef_id": chef_id, "dish_ids": dish_ids, "tool_ids": []}

func _max_tier_for_day(day: int) -> int:
	if day <= 2: return 1
	if day <= 5: return 2
	return 3

## ---------- 为 NPC 生成卡组 ----------
func _build_npc_loadout(difficulty: int) -> Dictionary:
	var all_dishes = DishDatabase.get_dishes()
	all_dishes.sort_custom(func(a, b): return int(a.get("tier", 0)) > int(b.get("tier", 0)))

	var max_tier = mini(difficulty, 3)
	var filtered: Array = []
	for d in all_dishes:
		if int(d.get("tier", 0)) <= max_tier:
			filtered.append(d)

	# NPC 选更强的卡
	var dish_ids: Array = []
	var total_size := 0
	for d in filtered:
		if total_size >= 10:
			break
		var size = int(d.get("size", 1))
		if total_size + size <= 10:
			dish_ids.append(d.get("id", ""))
			total_size += size

	return {"chef_id": "", "dish_ids": dish_ids, "tool_ids": []}


## ---------- 校准 ----------
func calibrate() -> Dictionary:
	var report: Dictionary = {}
	for day in DAYS:
		var player_loadout = _build_player_loadout_for_day(day)
		var results_by_difficulty: Array = []
		for diff in [1, 2, 3]:
			var npc_loadout = _build_npc_loadout(diff)
			var batch = _simulator.run_batch(player_loadout, npc_loadout, SIMS_PER_CHECK)
			var target_wr = TARGET_WIN_RATES.get(day, 0.5)
			var actual_wr = batch.win_rate_a
			var delta = actual_wr - target_wr

			var suggestion := "OK"
			if delta > 0.10:
				suggestion = "NPC太弱, 建议增强"
			elif delta < -0.10:
				suggestion = "NPC太强, 建议削弱"

			results_by_difficulty.append({
				"difficulty": diff,
				"player_win_rate": actual_wr,
				"target_win_rate": target_wr,
				"delta": delta,
				"suggestion": suggestion,
				"avg_player_score": batch.avg_score_a,
				"avg_npc_score": batch.avg_score_b,
			})

		# 推荐奖励金额: 风险越高, 奖励越高
		var recommended_rewards: Dictionary = {}
		for r in results_by_difficulty:
			var base_gold = 3
			if r.player_win_rate < 0.5:
				base_gold = ceili(5 + (1.0 - r.player_win_rate) * 10)
			elif r.player_win_rate < 0.7:
				base_gold = 5
			recommended_rewards[r.difficulty] = base_gold

		report[day] = {
			"results": results_by_difficulty,
			"recommended_rewards": recommended_rewards,
		}

	return report

## ---------- 格式化报告 ----------
func format_report(report: Dictionary) -> String:
	var output := "=== PvE 打野校准报告 ===\n\n"

	for day in DAYS:
		if not report.has(day):
			continue
		var day_data = report[day]
		output += "--- Day %d ---\n" % day

		for r in day_data.results:
			output += "  难度 %d: 胜率 %.1f%% (目标 %.1f%%) " % [
				r.difficulty, r.player_win_rate * 100, r.target_win_rate * 100]
			if r.suggestion != "OK":
				output += "⚠️ %s" % r.suggestion
			output += "\n"

		output += "  推荐奖励: %s\n\n" % str(day_data.recommended_rewards)

	return output
