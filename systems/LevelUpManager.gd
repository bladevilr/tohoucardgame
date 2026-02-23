extends RefCounted
class_name LevelUpManager

## 升级奖励生成与执行
## Lv.2（第一次升级）：方向选择 — 技法 / 附魔小菜 / 技法
## Lv.3+：标准升级奖励 — 金币 / 食材 / 技法 / 升星

static func generate_choices(player: PlayerState) -> Array:
	if player.level == 2:
		return _generate_level1_choices()
	return _generate_standard_choices(player, player.level)

# ============================================================
#  Lv.2 — 方向选择（开局定向）
# ============================================================
static func _generate_level1_choices() -> Array:
	var choices: Array = []

	# 技法池
	var techs: Array = TechniqueDatabase.get_all().duplicate()
	techs.shuffle()

	# 小型菜品池（size == 1）
	var small_dishes: Array = []
	for d in DishDatabase.get_dishes():
		if int(d.get("size", 1)) == 1:
			small_dishes.append(d)
	small_dishes.shuffle()

	# 选项 A：技法
	if not techs.is_empty():
		var t: Dictionary = techs[0].duplicate(true)
		t["item_type"] = "technique"
		t["_reward_type"] = "technique"
		t["_reward_flavor"] = "全局被动：持续增益你的所有菜品"
		choices.append(t)

	# 选项 B：附魔小菜（随机选一个属性强化）
	if not small_dishes.is_empty():
		var d: Dictionary = small_dishes[0].duplicate(true)
		d["_reward_type"] = "dish"
		if not d.has("base_stats"):
			d["base_stats"] = {}
		var bonus_attrs: Array[String] = ["flavor", "presentation", "technique"]
		var bonus_attr: String = bonus_attrs[randi() % bonus_attrs.size()]
		d.base_stats[bonus_attr] = int(d.base_stats.get(bonus_attr, 0)) + 8
		var stat_name: String = str(GameConfig.STAT_NAMES.get(bonus_attr, bonus_attr))
		d["_enchanted_with"] = "+8 %s（已附魔）" % stat_name
		d["_reward_flavor"] = "开局定向菜品，已附魔强化"
		choices.append(d)

	# 选项 C：另一个技法（或食材作后备）
	if techs.size() >= 2:
		var t2: Dictionary = techs[1].duplicate(true)
		t2["item_type"] = "technique"
		t2["_reward_type"] = "technique"
		t2["_reward_flavor"] = "全局被动：持续增益你的所有菜品"
		choices.append(t2)
	else:
		var ings: Array = IngredientDatabase.get_by_tier(1)
		if ings.is_empty():
			ings = IngredientDatabase.get_all()
		ings = ings.duplicate()
		ings.shuffle()
		if not ings.is_empty():
			var ing: Dictionary = ings[0].duplicate(true)
			ing["_reward_type"] = "ingredient"
			ing["_reward_flavor"] = "银级食材，可附魔到菜品上"
			choices.append(ing)

	return choices

# ============================================================
#  Lv.3+ — 标准升级奖励
# ============================================================
static func _generate_standard_choices(player: PlayerState, level: int) -> Array:
	var pool: Array = []

	# 选项：金币
	var gold_amount: int = 4 + level
	pool.append({
		"_reward_type": "gold",
		"name": "%d 金币" % gold_amount,
		"name_cn": "%d 金币" % gold_amount,
		"description": "当下就是金钱，积累资本。",
		"_reward_flavor": "即时经济奖励",
		"amount": gold_amount,
		"item_type": "gold",
	})

	# 选项：食材（随等级提升品质）
	var tier: int = 2 if level < 6 else 3
	var ings: Array = IngredientDatabase.get_by_tier(tier)
	if ings.is_empty():
		ings = IngredientDatabase.get_all()
	ings = ings.duplicate()
	ings.shuffle()
	if not ings.is_empty():
		var ing: Dictionary = ings[0].duplicate(true)
		ing["_reward_type"] = "ingredient"
		ing["_reward_flavor"] = "高品质食材，附魔增强菜品属性"
		pool.append(ing)

	# 选项：技法
	var techs: Array = TechniqueDatabase.get_all().duplicate()
	techs.shuffle()
	if not techs.is_empty():
		var t: Dictionary = techs[0].duplicate(true)
		t["item_type"] = "technique"
		t["_reward_type"] = "technique"
		t["_reward_flavor"] = "全局被动效果"
		pool.append(t)

	# 选项：升星最弱菜品（若存在可升星的菜品）
	var board_items: Array = player.get_board_items()
	if not board_items.is_empty():
		board_items.sort_custom(func(a, b): return _dish_power(a.item) < _dish_power(b.item))
		var weakest: Dictionary = board_items[0].item
		if int(weakest.get("star_level", 1)) < 3:
			var dish_name: String = weakest.get("name_cn", weakest.get("name", "???"))
			pool.append({
				"_reward_type": "upgrade_weakest",
				"name": "升星：%s" % dish_name,
				"name_cn": "升星：%s" % dish_name,
				"description": "最弱菜品升一星，基础属性大幅增长。",
				"_reward_flavor": "强化现有阵容核心",
				"item_type": "upgrade",
			})

	pool.shuffle()
	return pool.slice(0, 3)

# ============================================================
#  奖励执行
# ============================================================
static func apply_reward(player: PlayerState, reward: Dictionary) -> void:
	match reward.get("_reward_type", ""):
		"gold":
			player.add_gold(int(reward.get("amount", 3)))
		"technique":
			if player.techniques.size() < player.max_techniques:
				player.techniques.append(reward)
			else:
				player.add_to_backpack(reward)
		"dish":
			var placed: int = BoardManager.auto_place_item(player, reward)
			if placed < 0:
				player.add_to_backpack(reward)
		"ingredient":
			player.add_to_backpack(reward)
		"upgrade_weakest":
			var board_items: Array = player.get_board_items()
			if not board_items.is_empty():
				board_items.sort_custom(func(a, b): return _dish_power(a.item) < _dish_power(b.item))
				var dish: Dictionary = board_items[0].item
				var star: int = int(dish.get("star_level", 1))
				if star < 3:
					dish["star_level"] = star + 1
					var mult: float = GameConfig.STAR2_MULTIPLIER if star + 1 == 2 else GameConfig.STAR3_MULTIPLIER
					for attr in dish.get("base_stats", {}).keys():
						dish.base_stats[attr] = float(dish.base_stats[attr]) * mult

static func _dish_power(dish: Dictionary) -> float:
	var stats: Dictionary = dish.get("base_stats", {})
	return float(stats.get("flavor", 0)) + float(stats.get("presentation", 0)) + float(stats.get("technique", 0))
