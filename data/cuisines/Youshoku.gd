extends RefCounted
class_name YoushokuPool

## 洋食カード・プール (Western Cuisine)
## 使用者: 咲夜 / 妖梦 / アリス / パチュリー
## 設計方針: 濃郁摆盘流 — 卖相DoT壓制 / 摆盘閾値爆発 / rich標籤聯動
## キーワード生成: plating, knife_work, umami, aftertaste

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) — 摆盘引擎 =====
		{
			"id": "consomme", "name": "清汤", "name_cn": "清汤",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["soup", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层刀工；清除1层味觉疲劳", "effect": {"add_keyword": "knife_work", "keyword_stacks": 1, "clear_environment": "taste_fatigue", "clear_amount": 1}}
			],
			"on_activate": [],
			"description": "澄清透亮的法式清汤，滴滴皆是高汤精华。"
		},
		{
			"id": "quiche", "name": "法式咸派", "name_cn": "法式咸派",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["egg", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层摆盘；若相邻有洋食(浓郁)菜品，额外获得1层摆盘", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "if_adjacent_has_tag": "rich", "then_bonus": {"add_keyword": "plating", "keyword_stacks": 1}}}
			],
			"on_activate": [],
			"description": "奶香蛋液与馅料焗烤的法式咸派。"
		},
		{
			"id": "caesar_salad", "name": "凯撒沙拉", "name_cn": "凯撒沙拉",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["vegetable", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "卖相+3，获得1层摆盘；清除1层油腻", "effect": {"type": "stat_bonus", "presentation": 3, "add_keyword": "plating", "keyword_stacks": 1, "clear_environment": "greasy", "clear_amount": 1}}
			],
			"on_activate": [],
			"description": "帕马森芝士与面包丁点缀的经典沙拉。"
		},
		{
			"id": "bruschetta", "name": "意式烤面包", "name_cn": "意式烤面包",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["grilled", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层焦香；若在最左侧额外+5卖相", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "if_position": "leftmost", "then": {"type": "stat_bonus", "presentation": 5}, "else": {}}}
			],
			"on_activate": [],
			"description": "烤至焦脆的面包片佐番茄罗勒。"
		},
		{
			"id": "vichyssoise", "name": "冷土豆浓汤", "name_cn": "冷土豆浓汤",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 4.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["soup", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美和1层摆盘", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "plating", "keyword_stacks_2": 1}},
				{"event": "adjacent_activate", "effect": {"reduce_cooldown_self": 1.0}, "desc": "相邻菜品激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "冰凉丝滑的奶油土豆浓汤。"
		},
		{
			"id": "carpaccio", "name": "生牛肉薄片", "name_cn": "生牛肉薄片",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["meat", "raw", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层刀工和1层摆盘", "effect": {"add_keyword": "knife_work", "keyword_stacks": 1, "add_keyword_2": "plating", "keyword_stacks_2": 1}}
			],
			"on_activate": [],
			"description": "鲜红牛肉薄片淋上柠檬油醋汁。"
		},
		{
			"id": "croquettes", "name": "可乐饼", "name_cn": "可乐饼",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["meat", "fried", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层焦香；30%概率额外获得1层摆盘", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "random_chance": 0.3, "on_success": {"add_keyword": "plating", "keyword_stacks": 1}}},
				{"event": "friend_activate", "effect": {"reduce_cooldown_self": 1.0}, "desc": "己方其他菜品激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "外酥内软的奶油肉馅炸丸子。"
		},
		{
			"id": "onion_soup", "name": "洋葱汤", "name_cn": "洋葱汤",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["soup", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美；相邻CD-1秒", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "reduce_cooldown_adjacent": 1.0}}
			],
			"on_activate": [],
			"description": "焗烤芝士封顶的浓郁洋葱汤。"
		},

		# ===== SILVER (Tier 1) — 摆盘+条件 =====
		{
			"id": "gratin", "name": "焗烤", "name_cn": "焗烤",
			"cuisine": "youshoku", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["rich", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层焦香和1层摆盘；每3次爆发+30风味", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "add_keyword_2": "plating", "keyword_stacks_2": 1, "accumulate": {"counter_id": "gratin_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 30}}}}
			],
			"on_activate": [],
			"description": "奶油酱汁与芝士焗至金黄的烤菜。"
		},
		{
			"id": "coq_au_vin", "name": "红酒炖鸡", "name_cn": "红酒炖鸡",
			"cuisine": "youshoku", "tier": 1, "size": 2, "cooldown": 6.5,
			"flavor": 11, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美和1层回味；相邻CD-1秒", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1, "reduce_cooldown_adjacent": 1.0}}
			],
			"on_activate": [],
			"description": "红酒慢炖的嫩鸡，汤汁浓郁醇厚。"
		},
		{
			"id": "nicoise_salad", "name": "尼斯沙拉", "name_cn": "尼斯沙拉",
			"cuisine": "youshoku", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["seafood", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层摆盘，卖相+3；清除1层油腻", "effect": {"add_keyword": "plating", "keyword_stacks": 2, "type": "stat_bonus", "presentation": 3, "clear_environment": "greasy", "clear_amount": 1}}
			],
			"on_activate": [],
			"description": "金枪鱼与橄榄交织的南法风情沙拉。"
		},
		{
			"id": "risotto", "name": "意式烩饭", "name_cn": "意式烩饭",
			"cuisine": "youshoku", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["rice", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美和1层摆盘，风味×1.2", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "plating", "keyword_stacks_2": 1, "flavor_mult": 1.2}}
			],
			"on_activate": [],
			"description": "不断搅拌至绵密的意式奶油烩饭。"
		},
		{
			"id": "terrine", "name": "法式冻糕", "name_cn": "法式冻糕",
			"cuisine": "youshoku", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["meat", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活卖相+10，获得2层摆盘", "effect": {"type": "first_activate_bonus", "presentation": 10, "extra": {"add_keyword": "plating", "keyword_stacks": 2}}}
			],
			"on_activate": [],
			"description": "层层压制成型的冷切肉冻，精致优雅。"
		},
		{
			"id": "escargot", "name": "法式蜗牛", "name_cn": "法式蜗牛",
			"cuisine": "youshoku", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["meat", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层摆盘；若相邻有洋食(浓郁)菜品，额外卖相+5", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "if_adjacent_has_tag": "rich", "then_bonus": {"type": "stat_bonus", "presentation": 5}}}
			],
			"on_activate": [],
			"description": "蒜香黄油焗烤的法式蜗牛。"
		},
		{
			"id": "pasta_carbonara", "name": "培根蛋面", "name_cn": "培根蛋面",
			"cuisine": "youshoku", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 10, "mod_slots": 2,
			"tags": ["noodle", "egg", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美和1层摆盘；右邻也获得1层摆盘", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "plating", "keyword_stacks_2": 1, "chain_right": {"range": 1, "effect": {"add_keyword": "plating", "keyword_stacks": 1}}}}
			],
			"on_activate": [],
			"description": "蛋黄酱汁裹挟培根的经典意面。"
		},
		{
			"id": "chicken_fricassee", "name": "白汁炖鸡", "name_cn": "白汁炖鸡",
			"cuisine": "youshoku", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 9, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美，相邻CD-1秒", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "reduce_cooldown_adjacent": 1.0}},
				{"event": "adjacent_activate", "effect": {"add_keyword": "plating", "keyword_stacks": 1}, "desc": "相邻菜品激活时，获得1层摆盘"}
			],
			"on_activate": [],
			"description": "白酱炖煮的嫩鸡肉，奶香四溢。"
		},

		# ===== GOLD (Tier 2) — 卖相爆发 =====
		{
			"id": "beef_wellington", "name": "惠灵顿牛排", "name_cn": "惠灵顿牛排",
			"cuisine": "youshoku", "tier": 2, "size": 3, "cooldown": 8.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["meat", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+20、获得3层摆盘和2层刀工", "effect": {"type": "first_activate_bonus", "flavor": 20, "extra": {"add_keyword": "plating", "keyword_stacks": 3, "add_keyword_2": "knife_work", "keyword_stacks_2": 2}}},
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "plating", "stacks": 4}, "then": {"presentation_mult": 1.5}, "else": {}}, "desc": "摆盘≥4层时卖相×1.5"}
			],
			"on_activate": [],
			"description": "酥皮包裹的整块菲力牛排，华丽的主菜。"
		},
		{
			"id": "bouillabaisse", "name": "马赛鱼汤", "name_cn": "马赛鱼汤",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["seafood", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美和1层摆盘，风味×1.3", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "plating", "keyword_stacks_2": 1, "flavor_mult": 1.3}}
			],
			"on_activate": [],
			"description": "多种海鲜熬煮的普罗旺斯浓汤。"
		},
		{
			"id": "duck_confit", "name": "油封鸭", "name_cn": "油封鸭",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 15, "mod_slots": 2,
			"tags": ["meat", "rich", "stewed"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层回味和1层摆盘；回味≥3时风味×1.3", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 2, "add_keyword_2": "plating", "keyword_stacks_2": 1, "if_keyword_gte": {"keyword": "aftertaste", "stacks": 3}, "then": {"flavor_mult": 1.3}, "else": {}}}
			],
			"on_activate": [],
			"description": "低温油封后煎至酥脆的鸭腿。"
		},
		{
			"id": "lobster_thermidor", "name": "焗龙虾", "name_cn": "焗龙虾",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 7.5,
			"flavor": 16, "mod_slots": 2,
			"tags": ["seafood", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层摆盘；每3次爆发+40风味和卖相+15", "effect": {"add_keyword": "plating", "keyword_stacks": 2, "accumulate": {"counter_id": "lobster_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 40, "presentation": 15}}}}
			],
			"on_activate": [],
			"description": "奶油酱焗烤的半只龙虾，浓香扑鼻。"
		},
		{
			"id": "souffle", "name": "舒芙蕾", "name_cn": "舒芙蕾",
			"cuisine": "youshoku", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["egg", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+15、卖相+10；后续获得2层摆盘", "effect": {"type": "first_activate_bonus", "flavor": 15, "presentation": 10}},
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 2}, "desc": "获得2层摆盘"}
			],
			"on_activate": [],
			"description": "蓬松如云的烤蛋奶糕，转瞬即逝的美味。"
		},
		{
			"id": "rack_of_lamb", "name": "烤羊排", "name_cn": "烤羊排",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 15, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层焦香和1层摆盘；首次激活风味+15", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 2, "add_keyword_2": "plating", "keyword_stacks_2": 1, "type": "first_activate_bonus", "flavor": 15}}
			],
			"on_activate": [],
			"description": "香草面包糠包裹的法式烤羊排。"
		},
		{
			"id": "steak_frites", "name": "牛排薯条", "name_cn": "牛排薯条",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 14, "mod_slots": 2,
			"tags": ["meat", "grilled", "fried", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层焦香；每3次爆发+35风味；25%概率风味×1.5", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "accumulate": {"counter_id": "steak_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 35}}, "random_chance": 0.25, "on_success": {"flavor_mult": 1.5}}}
			],
			"on_activate": [],
			"description": "煎至完美熟度的牛排配金黄薯条。"
		},
		{
			"id": "afternoon_tea_set", "name": "下午茶套装", "name_cn": "下午茶套装",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 10, "mod_slots": 2,
			"tags": ["sweet", "tea", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活卖相+15、获得3层摆盘；清除1层味觉疲劳", "effect": {"type": "first_activate_bonus", "presentation": 15, "extra": {"add_keyword": "plating", "keyword_stacks": 3, "clear_environment": "taste_fatigue", "clear_amount": 1}}}
			],
			"on_activate": [],
			"description": "三层架上的精致点心与红茶。"
		},
		{
			"id": "osso_buco", "name": "炖小牛胫", "name_cn": "炖小牛胫",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 7.5,
			"flavor": 16, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美和1层回味；相邻CD-1秒", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1, "reduce_cooldown_adjacent": 1.0}}
			],
			"on_activate": [],
			"description": "慢炖至骨髓融化的小牛胫骨。"
		},

		# ===== DIAMOND (Tier 3) — 卖相终极引爆 =====
		{
			"id": "foie_gras_truffle", "name": "松露鹅肝", "name_cn": "松露鹅肝",
			"cuisine": "youshoku", "tier": 3, "size": 2, "cooldown": 9.0,
			"flavor": 22, "mod_slots": 2,
			"tags": ["meat", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+25、获得3层摆盘；摆盘≥5时卖相×1.8", "effect": {"type": "first_activate_bonus", "flavor": 25, "extra": {"add_keyword": "plating", "keyword_stacks": 3}}},
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "plating", "stacks": 5}, "then": {"presentation_mult": 1.8, "add_keyword": "plating", "keyword_stacks": 2}, "else": {"add_keyword": "plating", "keyword_stacks": 2}}, "desc": "摆盘≥5层时卖相×1.8并获得2层摆盘；否则获得2层摆盘"}
			],
			"on_activate": [],
			"description": "松露薄片覆盖的煎鹅肝，奢华至极。"
		},
		{
			"id": "full_course_francais", "name": "法式全席", "name_cn": "法式全席",
			"cuisine": "youshoku", "tier": 3, "size": 3, "cooldown": 12.0,
			"flavor": 20, "mod_slots": 2,
			"tags": ["mastered", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+30、卖相+20、获得3层摆盘和2层刀工；相邻加速2秒", "effect": {"type": "first_activate_bonus", "flavor": 30, "presentation": 20, "extra": {"add_keyword": "plating", "keyword_stacks": 3, "add_keyword_2": "knife_work", "keyword_stacks_2": 2, "haste_adjacent": 2.0, "haste_mult": 2.0}}}
			],
			"on_activate": [],
			"description": "从前菜到甜点的完整法式套餐。"
		},
		{
			"id": "grand_dessert_assiette", "name": "大甜品盘", "name_cn": "大甜品盘",
			"cuisine": "youshoku", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得3层摆盘和2层回味；摆盘≥5时卖相×1.5", "effect": {"add_keyword": "plating", "keyword_stacks": 3, "add_keyword_2": "aftertaste", "keyword_stacks_2": 2, "if_keyword_gte": {"keyword": "plating", "stacks": 5}, "then": {"presentation_mult": 1.5}, "else": {}}}
			],
			"on_activate": [],
			"description": "主厨精选甜品的华丽拼盘。"
		},
		{
			"id": "chateaubriand_rossini", "name": "罗西尼牛排", "name_cn": "罗西尼牛排",
			"cuisine": "youshoku", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 24, "mod_slots": 2,
			"tags": ["meat", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得3层刀工和2层焦香，风味×1.3；向两侧传2层摆盘", "effect": {"add_keyword": "knife_work", "keyword_stacks": 3, "add_keyword_2": "char_aroma", "keyword_stacks_2": 2, "flavor_mult": 1.3, "chain_right": {"range": 1, "effect": {"add_keyword": "plating", "keyword_stacks": 2}}, "chain_left": {"range": 1, "effect": {"add_keyword": "plating", "keyword_stacks": 2}}}}
			],
			"on_activate": [],
			"description": "鹅肝与松露加冕的顶级牛排。"
		},
	]
