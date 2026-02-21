## 单卡强度排名器 (Card Power Ranker)
##
## 把每张卡塞进1000场随机对战中，统计它出现时的胜率贡献。
## 标记超模卡 (>58%) 和废卡 (<42%)。
##
## 用法:
##   var ranker = CardPowerRanker.new()
##   var report = ranker.rank_all_cards(500)
##   print(ranker.format_report(report))

extends RefCounted
class_name CardPowerRanker

const SIMS_PER_CARD := 500
const OP_THRESHOLD := 0.58    # 超模阈值
const WEAK_THRESHOLD := 0.42  # 废卡阈值

var _simulator := HeadlessSimulator.new()

## ---------- 生成随机卡组 (包含指定卡) ----------
func _build_random_loadout_with(target_dish_id: String) -> Dictionary:
	var target = DishDatabase.get_dish(target_dish_id)
	if target.is_empty():
		return {}

	var dish_ids := [target_dish_id]
	var total_size := int(target.get("size", 1))

	# 随机填充其他菜品
	var all_dishes = DishDatabase.get_dishes()
	all_dishes.shuffle()
	for d in all_dishes:
		if total_size >= 8:
			break
		var did = d.get("id", "")
		if did == target_dish_id:
			continue
		var size = int(d.get("size", 1))
		if total_size + size <= 8:
			dish_ids.append(did)
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
	chefs.shuffle()
	var chef_id = chefs[0].get("id", "") if not chefs.is_empty() else ""

	# 随机工具
	var tools = ToolDatabase.get_all()
	tools.shuffle()
	var tool_ids: Array = []
	for i in range(mini(3, tools.size())):
		tool_ids.append(tools[i].get("id", ""))

	return {"chef_id": chef_id, "dish_ids": dish_ids, "tool_ids": tool_ids}

## ---------- 生成纯随机卡组 ----------
func _build_random_loadout() -> Dictionary:
	var all_dishes = DishDatabase.get_dishes()
	all_dishes.shuffle()

	var dish_ids: Array = []
	var total_size := 0
	for d in all_dishes:
		if total_size >= 8:
			break
		var size = int(d.get("size", 1))
		if total_size + size <= 8:
			dish_ids.append(d.get("id", ""))
			total_size += size

	var ingredients = DishDatabase.get_ingredients()
	ingredients.shuffle()
	for ing in ingredients:
		if total_size >= 10:
			break
		dish_ids.append(ing.get("id", ""))
		total_size += 1

	var chefs = ChefDatabase.get_all()
	chefs.shuffle()
	var chef_id = chefs[0].get("id", "") if not chefs.is_empty() else ""

	var tools = ToolDatabase.get_all()
	tools.shuffle()
	var tool_ids: Array = []
	for i in range(mini(3, tools.size())):
		tool_ids.append(tools[i].get("id", ""))

	return {"chef_id": chef_id, "dish_ids": dish_ids, "tool_ids": tool_ids}


## ---------- 排名所有菜品 ----------
func rank_all_cards(sims_per_card: int = SIMS_PER_CARD) -> Dictionary:
	var all_dishes = DishDatabase.get_dishes()
	var rankings: Array = []
	var op_cards: Array = []
	var weak_cards: Array = []
	for dish in all_dishes:
		var dish_id = dish.get("id", "")
		var dish_name = dish.get("name", dish_id)
		var wins := 0

		for _i in range(sims_per_card):
			var loadout_a = _build_random_loadout_with(dish_id)
			var loadout_b = _build_random_loadout()
			if loadout_a.is_empty():
				break
			var result = _simulator.simulate_once(loadout_a, loadout_b, _i * 7919)
			if result.winner == 0:
				wins += 1

		var win_rate = float(wins) / maxf(1, sims_per_card)
		var status := "OK"
		if win_rate > OP_THRESHOLD:
			status = "⚠️ 超模"
			op_cards.append({"id": dish_id, "name": dish_name, "win_rate": win_rate, "tier": dish.get("tier", 0)})
		elif win_rate < WEAK_THRESHOLD:
			status = "⚠️ 废卡"
			weak_cards.append({"id": dish_id, "name": dish_name, "win_rate": win_rate, "tier": dish.get("tier", 0)})

		rankings.append({
			"id": dish_id,
			"name": dish_name,
			"cuisine": dish.get("cuisine", ""),
			"tier": dish.get("tier", 0),
			"win_rate": win_rate,
			"status": status,
		})

	# 按胜率降序排列
	rankings.sort_custom(func(a, b): return a.win_rate > b.win_rate)

	return {
		"rankings": rankings,
		"op_cards": op_cards,
		"weak_cards": weak_cards,
		"total_cards": rankings.size(),
	}


## ---------- 格式化报告 ----------
func format_report(report: Dictionary) -> String:
	var output := "=== 单卡强度排名 (%d张菜品) ===\n\n" % report.total_cards

	# 超模卡警告
	if not report.op_cards.is_empty():
		output += "🔴 超模卡 (胜率 > %d%%):\n" % roundi(OP_THRESHOLD * 100)
		for c in report.op_cards:
			output += "  %s [%s] T%d — %.1f%%\n" % [c.name, c.id, c.tier, c.win_rate * 100]
		output += "\n"

	# 废卡警告
	if not report.weak_cards.is_empty():
		output += "🔵 废卡 (胜率 < %d%%):\n" % roundi(WEAK_THRESHOLD * 100)
		for c in report.weak_cards:
			output += "  %s [%s] T%d — %.1f%%\n" % [c.name, c.id, c.tier, c.win_rate * 100]
		output += "\n"

	# 完整排名
	output += "--- 完整排名 ---\n"
	output += "%-4s %-12s %-8s %-6s %-8s %s\n" % ["#", "名称", "菜系", "品阶", "胜率", "状态"]
	for i in range(report.rankings.size()):
		var r = report.rankings[i]
		var tier_label = ["铜", "银", "金", "钻"][mini(r.tier, 3)]
		output += "%-4d %-12s %-8s %-6s %5.1f%%   %s\n" % [
			i + 1, r.name, r.cuisine, tier_label, r.win_rate * 100, r.status]

	return output
