extends Node

## 遭遇池系统 — 多维度商店设计
##
## 商店维度：
## 1. 规模：小型(3物品) / 中型(5物品) / 大型(7物品)
## 2. 菜系：中华/和食/夜市/洋食/甘味/药膳
## 3. 标签：提味/清淡/油腻/回味等
## 4. 类型：菜品/食材/技法/厨具/混合
## 5. 品阶：低级货摊/普通/高级
## 6. 价格：便宜(0.7x)/正常/昂贵(1.5x)
## 7. 特殊：英雄专属/稀有/黑市

# 厨师与主菜系映射
const CHEF_MAIN_CUISINE := {
	"mystia": "yatai",
	"youmu": "washoku",
	"sakuya": "youshoku",
	"meiling": "chuuka",
	"marisa": "yatai",
	"reimu": "washoku",
	"alice": "kanmi",
	"patchouli": "yakuzen",
	"reisen": "kanmi",
	"seija": "chuuka",
}

const ICON_FALLBACK_BY_ID: Dictionary = {
	"keine": "mystia",
	"ichirin": "patchouli",
	"yukari": "alice",
	"satori": "seija",
	"aya": "marisa",
	"tenshi": "youmu",
	"koishi": "alice",
	"nitori": "sakuya",
	"rinnosuke": "reimu",
	"cirno": "reimu",
}

# 角色专属商店池 — 每个角色只能刷出池内的商店/事件
const CHEF_SHOP_POOL := {
	"mystia": [
		# 主菜系: 夜市 (全尺寸)
		"small_yatai", "medium_yatai", "large_yatai",
		# 副菜系: 中华 (小/中)
		"small_chuuka", "medium_chuuka",
		# 标签: 提味
		"tag_umami",
		# 通用
		"shop_ingredient_small", "shop_ingredient_medium", "shop_tool",
		"shop_mixed_small", "shop_lowgrade",
		# 事件
		"event_shrine", "event_gamble", "event_training", "event_treasure",
	],
	"youmu": [
		# 主菜系: 和食 (全尺寸)
		"small_washoku", "medium_washoku", "large_washoku",
		# 副菜系: 洋食 (中)
		"medium_youshoku",
		# 标签: 清淡、提味
		"tag_light", "tag_umami",
		# 通用
		"shop_ingredient_small", "shop_ingredient_medium", "shop_technique",
		"shop_lowgrade",
		# 事件
		"event_shrine", "event_training", "event_treasure",
	],
	"sakuya": [
		# 主菜系: 洋食 (全尺寸)
		"small_youshoku", "medium_youshoku", "large_youshoku",
		# 副菜系: 甘味 (中)
		"medium_kanmi",
		# 标签: 提味
		"tag_umami",
		# 通用
		"shop_ingredient_medium", "shop_technique", "shop_tool",
		"shop_highgrade",
		# 事件
		"event_shrine", "event_training", "event_treasure",
	],
	"meiling": [
		# 主菜系: 中华 (全尺寸)
		"small_chuuka", "medium_chuuka", "large_chuuka",
		# 副菜系: 夜市 (小/中)
		"small_yatai", "medium_yatai",
		# 标签: 提味、提味
		"tag_umami", "tag_umami",
		# 通用
		"shop_ingredient_small", "shop_ingredient_medium", "shop_tool",
		"shop_mixed_small",
		# 事件
		"event_shrine", "event_training", "event_treasure",
	],
	"marisa": [
		# 主菜系: 夜市 (小/中)
		"small_yatai", "medium_yatai",
		# 副菜系: 和食 (小)
		"small_washoku",
		# 标签: 提味
		"tag_umami",
		# 通用 (强化食材和混合)
		"shop_ingredient_small", "shop_ingredient_medium",
		"shop_mixed_small", "shop_mixed_large",
		"shop_lowgrade", "shop_tool",
		# 事件
		"event_shrine", "event_gamble", "event_training", "event_treasure",
	],
	"reimu": [
		# 主菜系: 和食 (全尺寸)
		"small_washoku", "medium_washoku", "large_washoku",
		# 副菜系: 药膳 (中)
		"medium_yakuzen",
		# 标签: 清淡
		"tag_light",
		# 通用
		"shop_ingredient_small", "shop_ingredient_medium",
		"shop_technique", "shop_mixed_small",
		# 事件 (灵梦强化神社)
		"event_shrine", "event_gamble", "event_training", "event_treasure",
	],
	"alice": [
		# 主菜系: 甘味 (全尺寸)
		"small_kanmi", "medium_kanmi", "large_kanmi",
		# 副菜系: 洋食 (中)
		"medium_youshoku",
		# 标签: 甜蜜
		"tag_sweet",
		# 通用
		"shop_ingredient_medium", "shop_technique", "shop_tool",
		"shop_highgrade",
		# 事件
		"event_shrine", "event_training", "event_treasure",
	],
	"patchouli": [
		# 主菜系: 药膳 (全尺寸)
		"small_yakuzen", "medium_yakuzen", "large_yakuzen",
		# 副菜系: 甘味 (中)
		"medium_kanmi",
		# 标签: 清淡
		"tag_light",
		# 通用 (强化技法)
		"shop_ingredient_medium", "shop_technique",
		"shop_mixed_small", "shop_highgrade",
		# 事件
		"event_shrine", "event_training", "event_treasure",
	],
	"reisen": [
		# 主菜系: 甘味 (全尺寸)
		"small_kanmi", "medium_kanmi", "large_kanmi",
		# 副菜系: 药膳 (小/中)
		"small_yakuzen", "medium_yakuzen",
		# 标签: 甜蜜
		"tag_sweet",
		# 通用
		"shop_ingredient_small", "shop_ingredient_medium", "shop_tool",
		"shop_mixed_small",
		# 事件
		"event_shrine", "event_training", "event_treasure",
	],
	"seija": [
		# 主菜系: 中华 (全尺寸)
		"small_chuuka", "medium_chuuka", "large_chuuka",
		# 副菜系: 夜市 (小)
		"small_yatai",
		# 标签: 提味
		"tag_umami",
		# 通用 (强化黑市和混合)
		"shop_ingredient_small", "shop_mixed_small", "shop_mixed_large",
		"shop_lowgrade", "shop_blackmarket",
		# 事件
		"event_gamble", "event_training", "event_treasure",
	],
}

# 商店配置模板
var _shop_templates := {
	# === 小型商店（3物品，便宜，早期） ===
	"small_yatai": {
		"type": "shop",
		"size": "small",
		"slots": 3,
		"filter": {"cuisine": "yatai"},
		"name": "夜市小摊",
		"desc": "便宜的街边小吃\n3个物品·价格便宜",
		"icon": "keine",
		"weight_base": 80,
		"unlock_day": 1,
		"price_mult": 0.7,
		"tier_max_offset": 0,
	},
	"small_washoku": {
		"type": "shop",
		"size": "small",
		"slots": 3,
		"filter": {"cuisine": "washoku"},
		"name": "和食便当店",
		"desc": "简单的和食料理\n3个物品·价格便宜",
		"icon": "youmu",
		"weight_base": 80,
		"unlock_day": 1,
		"price_mult": 0.7,
		"tier_max_offset": 0,
	},
	"small_chuuka": {
		"type": "shop",
		"size": "small",
		"slots": 3,
		"filter": {"cuisine": "chuuka"},
		"name": "中华快餐",
		"desc": "家常中华菜\n3个物品·价格便宜",
		"icon": "meiling",
		"weight_base": 80,
		"unlock_day": 1,
		"price_mult": 0.7,
		"tier_max_offset": 0,
	},
	"small_youshoku": {
		"type": "shop",
		"size": "small",
		"slots": 3,
		"filter": {"cuisine": "youshoku"},
		"name": "洋食简餐",
		"desc": "简单的西式料理\n3个物品·价格便宜",
		"icon": "sakuya",
		"weight_base": 70,
		"unlock_day": 2,
		"price_mult": 0.7,
		"tier_max_offset": 0,
	},
	"small_kanmi": {
		"type": "shop",
		"size": "small",
		"slots": 3,
		"filter": {"cuisine": "kanmi"},
		"name": "甜品小铺",
		"desc": "小巧的甜品店\n3个物品·价格便宜",
		"icon": "reisen",
		"weight_base": 70,
		"unlock_day": 2,
		"price_mult": 0.7,
		"tier_max_offset": 0,
	},
	"small_yakuzen": {
		"type": "shop",
		"size": "small",
		"slots": 3,
		"filter": {"cuisine": "yakuzen"},
		"name": "草药小摊",
		"desc": "简单的药膳料理\n3个物品·价格便宜",
		"icon": "ichirin",
		"weight_base": 60,
		"unlock_day": 2,
		"price_mult": 0.7,
		"tier_max_offset": 0,
	},

	# === 中型商店（5物品，正常价格） ===
	"medium_yatai": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"cuisine": "yatai"},
		"name": "人间之里夜市",
		"desc": "热闹的夜市摊位\n5个物品·正常价格",
		"icon": "keine",
		"weight_base": 100,
		"unlock_day": 2,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},
	"medium_washoku": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"cuisine": "washoku"},
		"name": "白玉楼厨房",
		"desc": "妖梦的和食料理\n5个物品·正常价格",
		"icon": "youmu",
		"weight_base": 100,
		"unlock_day": 2,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},
	"medium_chuuka": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"cuisine": "chuuka"},
		"name": "中华菜馆",
		"desc": "美铃的中华菜\n5个物品·正常价格",
		"icon": "meiling",
		"weight_base": 100,
		"unlock_day": 2,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},
	"medium_youshoku": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"cuisine": "youshoku"},
		"name": "红魔馆餐厅",
		"desc": "咲夜的西式料理\n5个物品·正常价格",
		"icon": "sakuya",
		"weight_base": 90,
		"unlock_day": 3,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},
	"medium_kanmi": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"cuisine": "kanmi"},
		"name": "永远亭茶室",
		"desc": "铃仙的甜品店\n5个物品·正常价格",
		"icon": "reisen",
		"weight_base": 90,
		"unlock_day": 3,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},
	"medium_yakuzen": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"cuisine": "yakuzen"},
		"name": "命莲寺斋堂",
		"desc": "一轮的药膳料理\n5个物品·正常价格",
		"icon": "ichirin",
		"weight_base": 80,
		"unlock_day": 4,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},

	# === 大型商店（7物品，稍贵，后期） ===
	"large_youshoku": {
		"type": "shop",
		"size": "large",
		"slots": 7,
		"filter": {"cuisine": "youshoku"},
		"name": "红魔馆盛宴",
		"desc": "咲夜的豪华套餐\n7个物品·价格稍贵",
		"icon": "sakuya",
		"weight_base": 70,
		"unlock_day": 5,
		"price_mult": 1.2,
		"tier_max_offset": 1,
	},
	"large_kanmi": {
		"type": "shop",
		"size": "large",
		"slots": 7,
		"filter": {"cuisine": "kanmi"},
		"name": "永远亭甜品宴",
		"desc": "铃仙的甜品盛宴\n7个物品·价格稍贵",
		"icon": "reisen",
		"weight_base": 70,
		"unlock_day": 5,
		"price_mult": 1.2,
		"tier_max_offset": 1,
	},
	"large_yakuzen": {
		"type": "shop",
		"size": "large",
		"slots": 7,
		"filter": {"cuisine": "yakuzen"},
		"name": "命莲寺药膳宴",
		"desc": "一轮的高级药膳\n7个物品·价格稍贵",
		"icon": "ichirin",
		"weight_base": 60,
		"unlock_day": 6,
		"price_mult": 1.2,
		"tier_max_offset": 1,
	},
	"large_yatai": {
		"type": "shop",
		"size": "large",
		"slots": 7,
		"filter": {"cuisine": "yatai"},
		"name": "人间之里庙会",
		"desc": "盛大的夜市庙会\n7个物品·价格稍贵",
		"icon": "keine",
		"weight_base": 60,
		"unlock_day": 5,
		"price_mult": 1.2,
		"tier_max_offset": 1,
	},
	"large_washoku": {
		"type": "shop",
		"size": "large",
		"slots": 7,
		"filter": {"cuisine": "washoku"},
		"name": "白玉楼正宴",
		"desc": "妖梦的正式和食宴\n7个物品·价格稍贵",
		"icon": "youmu",
		"weight_base": 60,
		"unlock_day": 5,
		"price_mult": 1.2,
		"tier_max_offset": 1,
	},
	"large_chuuka": {
		"type": "shop",
		"size": "large",
		"slots": 7,
		"filter": {"cuisine": "chuuka"},
		"name": "红美铃的满汉全席",
		"desc": "美铃的中华大宴\n7个物品·价格稍贵",
		"icon": "meiling",
		"weight_base": 60,
		"unlock_day": 5,
		"price_mult": 1.2,
		"tier_max_offset": 1,
	},

	# === 标签商店（按关键词筛选） ===
	"tag_umami": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"tag": "umami"},
		"name": "提味专卖",
		"desc": "汤汁浓郁专家\n只卖提味菜品",
		"icon": "meiling",
		"weight_base": 60,
		"unlock_day": 3,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},
	"tag_light": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"tag": "light"},
		"name": "清淡专卖",
		"desc": "健康养生专家\n只卖清淡菜品",
		"icon": "youmu",
		"weight_base": 60,
		"unlock_day": 3,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},
	"tag_sweet": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"tag": "sweet"},
		"name": "甜蜜专卖",
		"desc": "甜品糕点专家\n只卖甜味菜品",
		"icon": "reisen",
		"weight_base": 60,
		"unlock_day": 3,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},

	# === 类型商店 ===
	"shop_ingredient_small": {
		"type": "shop",
		"size": "small",
		"slots": 3,
		"filter": {"item_type": "ingredient"},
		"name": "食材小摊",
		"desc": "基础调味料\n3个食材·便宜",
		"icon": "marisa",
		"weight_base": 100,
		"unlock_day": 1,
		"price_mult": 0.6,
		"tier_max_offset": 0,
	},
	"shop_ingredient_medium": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"item_type": "ingredient"},
		"name": "魔法森林采集",
		"desc": "魔理沙的食材店\n5个食材·正常价格",
		"icon": "marisa",
		"weight_base": 120,
		"unlock_day": 2,
		"price_mult": 0.8,
		"tier_max_offset": 0,
	},
	"shop_technique": {
		"type": "shop",
		"size": "small",
		"slots": 2,
		"filter": {"item_type": "technique"},
		"name": "图书馆秘籍",
		"desc": "帕秋莉的技法书\n2个技法·正常价格",
		"icon": "patchouli",
		"weight_base": 80,
		"unlock_day": 2,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},
	"shop_tool": {
		"type": "shop",
		"size": "small",
		"slots": 2,
		"filter": {"item_type": "tool"},
		"name": "河童工坊",
		"desc": "河城荷取的厨具\n2个厨具·正常价格",
		"icon": "nitori",
		"weight_base": 70,
		"unlock_day": 2,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},

	# === 混合商店 ===
	"shop_mixed_small": {
		"type": "shop",
		"size": "small",
		"slots": 3,
		"filter": {"mixed": true},
		"name": "杂货铺",
		"desc": "什么都卖一点\n3个随机物品·便宜",
		"icon": "rinnosuke",
		"weight_base": 90,
		"unlock_day": 1,
		"price_mult": 0.8,
		"tier_max_offset": 0,
	},
	"shop_mixed_large": {
		"type": "shop",
		"size": "large",
		"slots": 7,
		"filter": {"mixed": true},
		"name": "香霖堂大甩卖",
		"desc": "雾雨店的特价商品\n7个随机物品·正常价格",
		"icon": "rinnosuke",
		"weight_base": 70,
		"unlock_day": 4,
		"price_mult": 1.0,
		"tier_max_offset": 0,
	},

	# === 品阶商店 ===
	"shop_lowgrade": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"tier_range": [0, 1]},
		"name": "低级货摊",
		"desc": "便宜的铜银货\n5个物品·很便宜",
		"icon": "cirno",
		"weight_base": 100,
		"unlock_day": 1,
		"price_mult": 0.6,
		"tier_max_offset": -1,
	},
	"shop_highgrade": {
		"type": "shop",
		"size": "medium",
		"slots": 5,
		"filter": {"tier_range": [2, 3]},
		"name": "高级商店",
		"desc": "稀有的金钻货\n5个物品·很贵",
		"icon": "yukari",
		"weight_base": 50,
		"unlock_day": 6,
		"price_mult": 1.5,
		"tier_max_offset": 1,
	},

	# === 特殊商店 ===
	"shop_blackmarket": {
		"type": "shop",
		"size": "small",
		"slots": 3,
		"filter": {"blackmarket": true},
		"name": "地灵殿黑市",
		"desc": "觉的地下交易\n3个稀有物品·很贵",
		"icon": "satori",
		"weight_base": 30,
		"unlock_day": 6,
		"price_mult": 1.8,
		"tier_max_offset": 2,
		"requires_condition": "blackmarket_unlocked",
	},

	# === 随机事件 ===
	"event_shrine": {
		"type": "event",
		"event_id": "shrine_blessing",
		"name": "博丽神社",
		"desc": "灵梦的祈福服务\n随机增益·运气加成",
		"icon": "reimu",
		"weight_base": 120,
		"unlock_day": 1,
	},
	"event_gamble": {
		"type": "event",
		"event_id": "tengu_gamble",
		"name": "天狗赌场",
		"desc": "文文的赌局\n高风险高回报",
		"icon": "aya",
		"weight_base": 100,
		"unlock_day": 2,
	},
	"event_training": {
		"type": "event",
		"event_id": "chef_training",
		"name": "修行道场",
		"desc": "提升厨艺等级\n经验加成",
		"icon": "tenshi",
		"weight_base": 110,
		"unlock_day": 1,
	},
	"event_treasure": {
		"type": "event",
		"event_id": "treasure_hunt",
		"name": "宝物探索",
		"desc": "发现隐藏宝箱\n随机奖励",
		"icon": "koishi",
		"weight_base": 90,
		"unlock_day": 3,
	},
}

func generate_three_choices(player: PlayerState, day: int) -> Array:
	"""生成3个随机遭遇选项（按角色卡池筛选）"""
	var eligible: Array[Dictionary] = []
	if player == null:
		return _get_fallback_choices()
	var player_chef: String = str(player.chef_id)
	var pool: Array = CHEF_SHOP_POOL.get(player_chef, [])
	if pool.is_empty():
		# 未配置角色：允许全部模板
		pool = _shop_templates.keys()

	# 仅从角色卡池中筛选
	for key in pool:
		if not _shop_templates.has(key):
			continue
		var config: Dictionary = _shop_templates[key].duplicate(true)
		config["_key"] = key
		config["icon"] = _resolve_icon_id(str(config.get("icon", "reimu")))

		if not _is_encounter_available(config, player, day):
			continue

		config["_final_weight"] = float(config.get("weight_base", 50))
		eligible.append(config)

	if eligible.is_empty():
		push_error("EncounterPool: No eligible encounters!")
		return _get_fallback_choices()

	# 按权重随机抽取3个（不重复）
	var choices: Array[Dictionary] = []
	for i in range(3):
		if eligible.is_empty():
			break

		var selected: Dictionary = _weighted_random_pick(eligible)
		choices.append(selected)
		eligible.erase(selected)

	# 保底：确保至少有1个shop类型
	var has_shop := false
	for c in choices:
		if c.get("type", "") == "shop":
			has_shop = true
			break
	if not has_shop and not choices.is_empty():
		# 从eligible中找一个shop替换最后一个非shop选项
		var shop_candidate: Dictionary = {}
		for e in eligible:
			if e.get("type", "") == "shop":
				shop_candidate = e
				break
		if shop_candidate.is_empty():
			# eligible中也没有shop了，从角色池中取一个基础shop
			for key in pool:
				if not _shop_templates.has(key):
					continue
				var tmpl: Dictionary = _shop_templates[key]
				if tmpl.get("type", "") == "shop" and day >= tmpl.get("unlock_day", 1):
					shop_candidate = tmpl.duplicate(true)
					shop_candidate["_key"] = key
					shop_candidate["icon"] = _resolve_icon_id(str(shop_candidate.get("icon", "reimu")))
					break
		if not shop_candidate.is_empty():
			choices[choices.size() - 1] = shop_candidate

	return choices

func _weighted_random_pick(pool: Array) -> Dictionary:
	"""从池中按权重随机选择一个"""
	var total_weight := 0.0
	for item in pool:
		total_weight += item.get("_final_weight", 50)

	var roll := randf() * total_weight
	var cumulative := 0.0

	for item in pool:
		cumulative += item.get("_final_weight", 50)
		if roll <= cumulative:
			return item

	return pool[0] if not pool.is_empty() else {}

func _is_encounter_available(config: Dictionary, _player: PlayerState, day: int) -> bool:
	"""检查遭遇是否可用"""
	# 检查天数解锁
	if day < config.get("unlock_day", 1):
		return false

	# 检查特殊条件
	var condition: String = str(config.get("requires_condition", ""))
	if condition != "":
		if condition == "blackmarket_unlocked":
			if day < 6:
				return false
			var bm_chance: float = 0.15 + (day - 6) * 0.03
			return randf() < bm_chance

	return true

func _get_fallback_choices() -> Array:
	"""降级方案：返回3个基础商店"""
	return [
		_shop_templates.get("shop_ingredient_small", {}),
		_shop_templates.get("small_yatai", {}),
		_shop_templates.get("event_shrine", {}),
	]

func get_encounter_config(encounter_key: String) -> Dictionary:
	return _shop_templates.get(encounter_key, {})

func _resolve_icon_id(icon_id: String) -> String:
	var normalized: String = icon_id.strip_edges().to_lower()
	if normalized == "":
		return "reimu"
	if ArtDatabase.has_chef_portrait(normalized):
		return normalized
	if ResourceLoader.exists("res://assets/merchants/%s.png" % normalized):
		return normalized
	return str(ICON_FALLBACK_BY_ID.get(normalized, "reimu"))
