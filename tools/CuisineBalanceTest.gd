## 菜系均衡分析 — 循环赛 (Round Robin)
##
## 为每个菜系自动生成"最优卡组"，然后做两两对战。
## 输出胜率矩阵，目标: 45%~55%。
##
## 用法:
##   var test = CuisineBalanceTest.new()
##   var matrix = test.run_round_robin(500)
##   test.print_matrix(matrix)

extends RefCounted
class_name CuisineBalanceTest

const CUISINES := ["chinese", "french", "japanese", "wild", "molecular", "dessert"]
const SIM_COUNT := 500

var _simulator := HeadlessSimulator.new()

## ---------- 为菜系生成最优卡组 ----------
func build_best_loadout(cuisine: String) -> Dictionary:
	var dishes = DishDatabase.get_dishes_by_cuisine(cuisine)
	# 按 tier 降序排列, 取最强的
	dishes.sort_custom(func(a, b): return int(a.get("tier", 0)) > int(b.get("tier", 0)))

	var dish_ids: Array = []
	var total_size := 0
	for d in dishes:
		var size = int(d.get("size", 1))
		if total_size + size <= 10:  # BOARD_SLOTS
			dish_ids.append(d.get("id", ""))
			total_size += size

	# 填充食材 (ingredient) 到剩余空间
	if total_size < 10:
		var ingredients = DishDatabase.get_ingredients()
		ingredients.sort_custom(func(a, b):
			var va = a.get("base_stats", {}).get("flavor", 0) + a.get("base_stats", {}).get("aroma", 0)
			var vb = b.get("base_stats", {}).get("flavor", 0) + b.get("base_stats", {}).get("aroma", 0)
			return va > vb)
		for ing in ingredients:
			if total_size >= 10:
				break
			dish_ids.append(ing.get("id", ""))
			total_size += 1

	# 选匹配的厨师
	var chef_id := ""
	var all_chefs = ChefDatabase.get_all()
	for chef in all_chefs:
		if cuisine in chef.get("cuisines", []):
			chef_id = chef.get("id", "")
			break
	if chef_id == "" and not all_chefs.is_empty():
		chef_id = all_chefs[0].get("id", "")

	# 选匹配的工具
	var tool_ids: Array = []
	var all_tools = ToolDatabase.get_all()
	for t in all_tools:
		if tool_ids.size() >= 3:
			break
		# 优先选有菜系相关 trigger 的工具
		var dominated = false
		for trigger in t.get("triggers", []):
			var cond = str(trigger.get("condition", ""))
			if cuisine in cond:
				dominated = true
				break
		if dominated:
			tool_ids.append(t.get("id", ""))

	# 不够3个就随机补
	for t in all_tools:
		if tool_ids.size() >= 3:
			break
		if t.get("id", "") not in tool_ids:
			tool_ids.append(t.get("id", ""))

	return {
		"chef_id": chef_id,
		"dish_ids": dish_ids,
		"tool_ids": tool_ids,
	}


## ---------- 循环赛 ----------
func run_round_robin(sims_per_match: int = SIM_COUNT) -> Dictionary:
	var loadouts: Dictionary = {}
	for c in CUISINES:
		loadouts[c] = build_best_loadout(c)

	var matrix: Dictionary = {}
	var imbalanced: Array = []
	for i in range(CUISINES.size()):
		var ca = CUISINES[i]
		matrix[ca] = {}
		for j in range(CUISINES.size()):
			var cb = CUISINES[j]
			if i == j:
				matrix[ca][cb] = {"win_rate": 0.5, "status": "—"}
				continue
			if j < i:
				# 已经打过了，取对称值
				matrix[ca][cb] = {
					"win_rate": 1.0 - matrix[cb][ca].win_rate,
					"status": matrix[cb][ca].get("status_mirror", "OK"),
				}
				continue

			var result = _simulator.run_batch(loadouts[ca], loadouts[cb], sims_per_match)
			var wr = result.win_rate_a
			var status = "OK"
			var status_mirror = "OK"
			if wr > 0.55:
				status = "⚠️ %s偏强" % ca
				status_mirror = "⚠️ %s偏弱" % cb
				imbalanced.append("%s vs %s: %.1f%%" % [ca, cb, wr * 100])
			elif wr < 0.45:
				status = "⚠️ %s偏弱" % ca
				status_mirror = "⚠️ %s偏强" % cb
				imbalanced.append("%s vs %s: %.1f%%" % [ca, cb, wr * 100])

			matrix[ca][cb] = {
				"win_rate": wr,
				"avg_score_a": result.avg_score_a,
				"avg_score_b": result.avg_score_b,
				"status": status,
				"status_mirror": status_mirror,
			}

	return {
		"matrix": matrix,
		"imbalanced_matchups": imbalanced,
		"loadouts_used": loadouts,
	}


## ---------- 打印矩阵 ----------
func print_matrix(result: Dictionary) -> String:
	var matrix = result.matrix
	var output := "=== 菜系均衡矩阵 ===\n"
	output += "         "
	for c in CUISINES:
		output += "%8s" % c.substr(0, 6)
	output += "\n"

	for ca in CUISINES:
		output += "%8s " % ca.substr(0, 6)
		for cb in CUISINES:
			var wr = matrix[ca][cb].win_rate
			if ca == cb:
				output += "    —   "
			else:
				output += " %5.1f%% " % (wr * 100)
		output += "\n"

	if not result.imbalanced_matchups.is_empty():
		output += "\n⚠️ 失衡对局:\n"
		for s in result.imbalanced_matchups:
			output += "  - %s\n" % s

	return output
