## 事件系统 (Event System)
##
## 大巴扎式三选一事件:
##   - 商人: 卖菜品/工具
##   - 奇遇: 治疗/金币/临时Buff
##   - 休息: 回复声望
##   - 黑市: 可买到其他英雄的菜品
##
## 游戏循环:
##   每天 = 6时辰
##   时辰1: 事件三选一
##   时辰2: 事件三选一
##   时辰3: PvE 打野 (必出)
##   时辰4: 事件三选一
##   时辰5: 事件三选一
##   时辰6: PvP 对决 (必出)

extends Node
class_name EventSystem

signal event_choices_ready(choices: Array)
signal event_resolved(result: Dictionary)

const HOURS_PER_DAY := 6
const PVE_HOUR := 3
const PVP_HOUR := 6

## 事件类型
enum EventType {
	MERCHANT,      # 商人 — 买菜品/工具
	ADVENTURE,     # 奇遇 — 金币/物品/临时Buff
	REST,          # 休息 — 回声望
	BLACK_MARKET,  # 黑市 — 跨英雄卡池
	PVE_BATTLE,    # PvE 打野
	PVP_BATTLE,    # PvP 对决
}

## ==================== 生成三选一 ====================
func generate_choices(day: int, hour: int, chef_id: String) -> Array:
	if hour == PVE_HOUR:
		return [_generate_pve(day)]
	if hour == PVP_HOUR:
		return [_generate_pvp(day)]

	# 三选一: 保证至少一个商人、一个奇遇
	var pool: Array = []
	pool.append(_generate_merchant(day, chef_id))
	pool.append(_generate_adventure(day))

	# 第三个: 按概率选
	var roll := randf()
	if roll < 0.15:
		pool.append(_generate_black_market(day, chef_id))
	elif roll < 0.40:
		pool.append(_generate_rest(day))
	else:
		pool.append(_generate_adventure(day))

	pool.shuffle()
	event_choices_ready.emit(pool)
	return pool


## ==================== 解析选择 ====================
func resolve_event(event: Dictionary, player: PlayerState) -> Dictionary:
	var result := {"type": event.get("event_type", -1), "message": ""}

	match event.get("event_type", -1):
		EventType.MERCHANT:
			result.message = "商人到来: %s" % event.get("name", "")
			# 商店物品在 event.items 里, UI 层处理购买
			result["items"] = event.get("items", [])

		EventType.ADVENTURE:
			var effect = event.get("effect", "")
			match effect:
				"gold":
					var amount = int(event.get("amount", 3))
					player.add_gold(amount)
					result.message = "获得 %d 金币" % amount
				"heal":
					var amount = int(event.get("amount", 2))
					player.prestige = mini(20, player.prestige + amount)
					result.message = "回复 %d 声望" % amount
				"item":
					result.message = "获得物品: %s" % event.get("item_name", "")
					result["item"] = event.get("item_data", {})
				"buff":
					result.message = "获得临时增益: %s" % event.get("buff_name", "")
					result["buff"] = event.get("buff_data", {})

		EventType.REST:
			var heal = int(event.get("heal_amount", 2))
			player.prestige = mini(20, player.prestige + heal)
			result.message = "休息回复 %d 声望" % heal

		EventType.BLACK_MARKET:
			result.message = "黑市商人: 可购买其他英雄的菜品"
			result["items"] = event.get("items", [])

	event_resolved.emit(result)
	return result


## ==================== 事件工厂 ====================
func _generate_merchant(day: int, chef_id: String) -> Dictionary:
	var items: Array = []
	var hero_dishes = DishDatabase.get_hero_pool(chef_id)

	# 按 day 过滤可用 tier
	var max_tier = _max_tier_for_day(day)
	var available: Array = []
	for d in hero_dishes:
		if int(d.get("tier", 0)) <= max_tier:
			available.append(d)

	available.shuffle()
	var num_items = mini(3, available.size())
	for i in range(num_items):
		items.append(available[i])

	# 也提供 1~2 个通用食材
	var ingredients = DishDatabase.get_ingredients()
	ingredients.shuffle()
	for i in range(mini(2, ingredients.size())):
		items.append(ingredients[i])

	return {
		"event_type": EventType.MERCHANT,
		"name": "旅行商人",
		"description": "出售 %s 风格的菜品" % chef_id,
		"items": items,
	}

func _generate_adventure(day: int) -> Dictionary:
	var adventures := [
		{"name": "路边宝箱", "effect": "gold", "amount": 3 + day},
		{"name": "神社祈愿", "effect": "heal", "amount": 2},
		{"name": "食材发现", "effect": "gold", "amount": 2 + randi() % 3},
		{"name": "品鉴大赛", "effect": "gold", "amount": 4 + day / 2},
	]
	adventures.shuffle()
	var chosen = adventures[0]
	chosen["event_type"] = EventType.ADVENTURE
	chosen["description"] = "一次意外的冒险"
	return chosen

func _generate_rest(day: int) -> Dictionary:
	return {
		"event_type": EventType.REST,
		"name": "温泉休憩",
		"description": "在温泉旁休息, 恢复声望",
		"heal_amount": 2 + (1 if day >= 5 else 0),
	}

func _generate_black_market(day: int, chef_id: String) -> Dictionary:
	# 从其他英雄的卡池里随机选 2~3 张
	var items: Array = []
	var all_pool_keys = DishDatabase.hero_pools.keys()
	var other_pools: Array = []
	for k in all_pool_keys:
		if k != chef_id:
			other_pools.append(k)

	other_pools.shuffle()
	for pool_key in other_pools:
		if items.size() >= 3:
			break
		var pool = DishDatabase.get_hero_pool(pool_key)
		pool.shuffle()
		for d in pool:
			if int(d.get("tier", 0)) <= _max_tier_for_day(day):
				items.append(d)
				break

	return {
		"event_type": EventType.BLACK_MARKET,
		"name": "黑市商人",
		"description": "出售其他厨师的独门菜品, 价格翻倍",
		"items": items,
		"price_multiplier": 2.0,
	}

func _generate_pve(day: int) -> Dictionary:
	return {
		"event_type": EventType.PVE_BATTLE,
		"name": "PvE: 打野",
		"description": "击败野怪获得金币和物品",
		"difficulty": mini(day, 10),
	}

func _generate_pvp(day: int) -> Dictionary:
	return {
		"event_type": EventType.PVP_BATTLE,
		"name": "PvP: 对决",
		"description": "与其他玩家的镜像对决",
		"prestige_loss_on_defeat": day,
	}

func _max_tier_for_day(day: int) -> int:
	if day <= 2: return 1
	if day <= 5: return 2
	return 3
