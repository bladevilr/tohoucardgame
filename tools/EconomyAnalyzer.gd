## 经济曲线分析器 (Economy Analyzer)
##
## 模拟完整10天Run的经济变化:
## - 每天净资产 (金币 + 物品价值)
## - 关键转折点 (何时能买金卡/钻石卡)
## - 连胜/连败对经济影响
## - 商店刷新消耗
##
## 用法:
##   var analyzer = EconomyAnalyzer.new()
##   var report = analyzer.simulate_run()
##   print(analyzer.format_report(report))

extends RefCounted
class_name EconomyAnalyzer

const TOTAL_DAYS := 10
const SIM_RUNS := 100

## 物品价值估算 (by tier)
const ITEM_VALUE := {0: 2, 1: 4, 2: 6, 3: 9}

## ---------- 单次Run模拟 ----------
func _simulate_single_run(win_pattern: Array) -> Dictionary:
	## win_pattern: Array of bool, length=TOTAL_DAYS. true=赢, false=输
	var gold := GameConfig.STARTING_GOLD
	var streak := 0
	var inventory_value := 0
	var day_snapshots: Array = []
	var gold_card_day := -1  # 第几天能买金卡
	var diamond_card_day := -1

	# 模拟商店消费模式 (典型玩家行为)
	var refresh_count_per_day := 1  # 平均每天刷新1次

	for day in range(1, TOTAL_DAYS + 1):
		# 收入
		var income := GameConfig.GOLD_PER_DAY
		income += mini(day - 1, GameConfig.DAY_INCOME_BONUS_CAP)

		# 连胜/连败补贴
		if streak > 0:
			income += GameConfig.get_streak_bonus(streak)
		elif streak < 0:
			income += GameConfig.get_loss_streak_bonus(streak)

		# 胜利奖励
		var won = win_pattern[day - 1] if day - 1 < win_pattern.size() else (randf() > 0.5)
		if won:
			income += GameConfig.WIN_BONUS_GOLD
			streak = maxi(1, streak + 1) if streak >= 0 else 1
		else:
			streak = mini(-1, streak - 1) if streak <= 0 else -1

		gold += income

		# 消费: 买菜 + 刷新
		var tier_weights = GameConfig.get_tier_weights(day)
		var avg_cost := 0
		var total_weight := 0
		for t_val in tier_weights.values():
			total_weight += t_val
		for t_key in tier_weights:
			var weight = float(tier_weights[t_key]) / maxf(1.0, float(total_weight))
			avg_cost += roundi(ITEM_VALUE.get(t_key, 2) * weight)
		avg_cost = maxi(2, avg_cost)

		# 典型: 买2~3个菜品 + 刷新
		var spending = avg_cost * mini(3, maxi(1, gold / maxi(1, avg_cost)))
		spending += refresh_count_per_day * GameConfig.SHOP_REFRESH_COST
		spending = mini(spending, gold)
		gold -= spending

		# 物品价值增长
		inventory_value += spending

		# 检查里程碑
		if gold_card_day < 0 and gold >= 6:
			gold_card_day = day
		if diamond_card_day < 0 and gold >= 9:
			diamond_card_day = day

		day_snapshots.append({
			"day": day,
			"gold": gold,
			"income": income,
			"spending": spending,
			"net_worth": gold + inventory_value,
			"streak": streak,
		})

	return {
		"snapshots": day_snapshots,
		"gold_card_day": gold_card_day,
		"diamond_card_day": diamond_card_day,
		"final_net_worth": gold + inventory_value,
	}


## ---------- 批量模拟 ----------
func simulate_run(count: int = SIM_RUNS) -> Dictionary:
	# 模拟三种场景
	var scenarios := {
		"consistent_winner": [],   # 70%胜率
		"average_player": [],      # 50%胜率
		"struggling_player": [],   # 30%胜率
	}

	for _i in range(count):
		for scenario_name in scenarios:
			var wr = 0.5
			match scenario_name:
				"consistent_winner": wr = 0.7
				"average_player": wr = 0.5
				"struggling_player": wr = 0.3

			var pattern: Array = []
			for _d in range(TOTAL_DAYS):
				pattern.append(randf() < wr)

			scenarios[scenario_name].append(_simulate_single_run(pattern))

	# 汇总每种场景
	var summary: Dictionary = {}
	for scenario_name in scenarios:
		var runs = scenarios[scenario_name]
		var avg_nw_by_day: Array = []
		for d in range(TOTAL_DAYS):
			var total_nw := 0.0
			for run in runs:
				total_nw += run.snapshots[d].net_worth
			avg_nw_by_day.append(total_nw / count)

		var avg_gold_day := 0.0
		var avg_diamond_day := 0.0
		var gold_hit := 0
		var diamond_hit := 0
		for run in runs:
			if run.gold_card_day > 0:
				avg_gold_day += run.gold_card_day
				gold_hit += 1
			if run.diamond_card_day > 0:
				avg_diamond_day += run.diamond_card_day
				diamond_hit += 1

		summary[scenario_name] = {
			"avg_net_worth_curve": avg_nw_by_day,
			"avg_gold_card_day": avg_gold_day / maxf(1, gold_hit) if gold_hit > 0 else -1,
			"avg_diamond_card_day": avg_diamond_day / maxf(1, diamond_hit) if diamond_hit > 0 else -1,
			"gold_card_reachable_pct": float(gold_hit) / count * 100,
			"diamond_card_reachable_pct": float(diamond_hit) / count * 100,
		}

	return summary


## ---------- 格式化 ----------
func format_report(summary: Dictionary) -> String:
	var output := "=== 经济曲线分析报告 ===\n\n"

	for scenario in ["consistent_winner", "average_player", "struggling_player"]:
		if not summary.has(scenario):
			continue
		var data = summary[scenario]
		var label = ""
		match scenario:
			"consistent_winner": label = "强势玩家(70%胜率)"
			"average_player": label = "普通玩家(50%胜率)"
			"struggling_player": label = "弱势玩家(30%胜率)"

		output += "--- %s ---\n" % label
		output += "  净资产曲线: "
		for i in range(data.avg_net_worth_curve.size()):
			output += "Day%d=%d " % [i + 1, roundi(data.avg_net_worth_curve[i])]
		output += "\n"

		if data.avg_gold_card_day > 0:
			output += "  首次买得起金卡: Day %.1f (%.0f%%的Run能到)\n" % [data.avg_gold_card_day, data.gold_card_reachable_pct]
		else:
			output += "  首次买得起金卡: 从未达到 ⚠️\n"

		if data.avg_diamond_card_day > 0:
			output += "  首次买得起钻石卡: Day %.1f (%.0f%%的Run能到)\n" % [data.avg_diamond_card_day, data.diamond_card_reachable_pct]
		else:
			output += "  首次买得起钻石卡: 从未达到\n"

		output += "\n"

	# 健康度检查
	output += "--- 健康度检查 ---\n"
	if summary.has("average_player"):
		var avg = summary.average_player
		if avg.avg_gold_card_day < 0 or avg.avg_gold_card_day > 6:
			output += "  ⚠️ 普通玩家买金卡太晚 (Day %.1f), 建议增加收入\n" % avg.avg_gold_card_day
		else:
			output += "  ✅ 金卡可达性正常 (Day %.1f)\n" % avg.avg_gold_card_day

		if avg.gold_card_reachable_pct < 80:
			output += "  ⚠️ 仅 %.0f%% 的Run能买到金卡, 经济可能过紧\n" % avg.gold_card_reachable_pct
		else:
			output += "  ✅ %.0f%% 的Run能买到金卡\n" % avg.gold_card_reachable_pct

	return output
