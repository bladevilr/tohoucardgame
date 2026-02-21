extends RefCounted
class_name YoushokuPool

## 洋食カード・プール (Western Cuisine)
## 使用者: 咲夜 / 妖梦 / アリス / パチュリー
## キーワード生成: plating, rich, knife_work

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) =====
		{
			"id": "consomme", "name": "清汤", "name_cn": "清汤",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["soup", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层刀工",
				 "effect": {"add_keyword": "knife_work", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "清汤。"
		},
		{
			"id": "quiche", "name": "法式咸派", "name_cn": "法式咸派",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["egg", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层摆盘",
				 "effect": {"add_keyword": "plating", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "法式咸派。"
		},
		{
			"id": "caesar_salad", "name": "凯撒沙拉", "name_cn": "凯撒沙拉",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["vegetable", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "卖相+3",
				 "effect": {"type": "stat_bonus", "presentation": 3}}
			],
			"on_activate": [],
			"description": "凯撒沙拉。"
		},
		{
			"id": "bruschetta", "name": "意式烤面包", "name_cn": "意式烤面包",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["grilled", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层焦香",
				 "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "意式烤面包。"
		},
		{
			"id": "vichyssoise", "name": "冷土豆浓汤", "name_cn": "冷土豆浓汤",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 4.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["soup", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "风味+3",
				 "effect": {"type": "stat_bonus", "flavor": 3}}
			],
			"on_activate": [],
			"description": "冷土豆浓汤。"
		},
		{
			"id": "carpaccio", "name": "生牛肉薄片", "name_cn": "生牛肉薄片",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["meat", "raw", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层刀工",
				 "effect": {"add_keyword": "knife_work", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "生牛肉薄片。"
		},
		{
			"id": "croquettes", "name": "可乐饼", "name_cn": "可乐饼",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["meat", "fried", "rich"],
			"triggers": [],
			"on_activate": [],
			"description": "可乐饼。"
		},
		{
			"id": "onion_soup", "name": "洋葱汤", "name_cn": "洋葱汤",
			"cuisine": "youshoku", "tier": 0, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["soup", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美",
				 "effect": {"add_keyword": "umami", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "洋葱汤。"
		},

		# ===== SILVER (Tier 1) =====
		{
			"id": "gratin", "name": "焗烤", "name_cn": "焗烤",
			"cuisine": "youshoku", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["rich", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层焦香，每3次激活爆发风味+30",
				 "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1,
				  "accumulate": {"counter_id": "gratin_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 30}}}}
			],
			"on_activate": [],
			"description": "焗烤。"
		},
		{
			"id": "coq_au_vin", "name": "红酒炖鸡", "name_cn": "红酒炖鸡",
			"cuisine": "youshoku", "tier": 1, "size": 2, "cooldown": 6.5,
			"flavor": 11, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美、1层回味",
				 "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1}}
			],
			"on_activate": [],
			"description": "红酒炖鸡。"
		},
		{
			"id": "nicoise_salad", "name": "尼斯沙拉", "name_cn": "尼斯沙拉",
			"cuisine": "youshoku", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["seafood", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层摆盘，卖相+3",
				 "effect": {"add_keyword": "plating", "keyword_stacks": 1, "type": "stat_bonus", "presentation": 3}}
			],
			"on_activate": [],
			"description": "尼斯沙拉。"
		},
		{
			"id": "risotto", "name": "意式烩饭", "name_cn": "意式烩饭",
			"cuisine": "youshoku", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["rice", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美，风味x1.2",
				 "effect": {"add_keyword": "umami", "keyword_stacks": 1, "type": "flavor_mult", "value": 1.2}}
			],
			"on_activate": [],
			"description": "意式烩饭。"
		},
		{
			"id": "terrine", "name": "法式冻糕", "name_cn": "法式冻糕",
			"cuisine": "youshoku", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["meat", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活卖相+10",
				 "effect": {"type": "first_activate_bonus", "presentation": 10}}
			],
			"on_activate": [],
			"description": "法式冻糕。"
		},
		{
			"id": "escargot", "name": "法式蜗牛", "name_cn": "法式蜗牛",
			"cuisine": "youshoku", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["meat", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层摆盘",
				 "effect": {"add_keyword": "plating", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "法式蜗牛。"
		},
		{
			"id": "pasta_carbonara", "name": "培根蛋面", "name_cn": "培根蛋面",
			"cuisine": "youshoku", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 10, "mod_slots": 2,
			"tags": ["noodle", "egg", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美、1层摆盘",
				 "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "plating", "keyword_stacks_2": 1}}
			],
			"on_activate": [],
			"description": "培根蛋面。"
		},
		{
			"id": "chicken_fricassee", "name": "白汁炖鸡", "name_cn": "白汁炖鸡",
			"cuisine": "youshoku", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 9, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美，相邻CD-0.3秒",
				 "effect": {"add_keyword": "umami", "keyword_stacks": 1, "reduce_cooldown_adjacent": 0.3}}
			],
			"on_activate": [],
			"description": "白汁炖鸡。"
		},

		# ===== GOLD (Tier 2) =====
		{
			"id": "beef_wellington", "name": "惠灵顿牛排", "name_cn": "惠灵顿牛排",
			"cuisine": "youshoku", "tier": 2, "size": 3, "cooldown": 8.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["meat", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+20，获得2层摆盘",
				 "effect": {"type": "first_activate_bonus", "flavor": 20, "extra": {"add_keyword": "plating", "keyword_stacks": 2}}}
			],
			"on_activate": [],
			"description": "惠灵顿牛排。"
		},
		{
			"id": "bouillabaisse", "name": "马赛鱼汤", "name_cn": "马赛鱼汤",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["seafood", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美，风味x1.3",
				 "effect": {"add_keyword": "umami", "keyword_stacks": 2, "type": "flavor_mult", "value": 1.3}}
			],
			"on_activate": [],
			"description": "马赛鱼汤。"
		},
		{
			"id": "duck_confit", "name": "油封鸭", "name_cn": "油封鸭",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 15, "mod_slots": 2,
			"tags": ["meat", "rich", "stewed"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层回味",
				 "effect": {"add_keyword": "aftertaste", "keyword_stacks": 2}}
			],
			"on_activate": [],
			"description": "油封鸭。"
		},
		{
			"id": "lobster_thermidor", "name": "焗龙虾", "name_cn": "焗龙虾",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 7.5,
			"flavor": 16, "mod_slots": 2,
			"tags": ["seafood", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层摆盘，每3次激活爆发风味+40",
				 "effect": {"add_keyword": "plating", "keyword_stacks": 2,
				  "accumulate": {"counter_id": "lobster_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 40}}}}
			],
			"on_activate": [],
			"description": "焗龙虾。"
		},
		{
			"id": "souffle", "name": "舒芙蕾", "name_cn": "舒芙蕾",
			"cuisine": "youshoku", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["egg", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+15、卖相+10",
				 "effect": {"type": "first_activate_bonus", "flavor": 15, "presentation": 10}}
			],
			"on_activate": [],
			"description": "舒芙蕾。"
		},
		{
			"id": "rack_of_lamb", "name": "烤羊排", "name_cn": "烤羊排",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 15, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层焦香，首次激活风味+15",
				 "effect": {"add_keyword": "char_aroma", "keyword_stacks": 2, "type": "first_activate_bonus", "flavor": 15}}
			],
			"on_activate": [],
			"description": "烤羊排。"
		},
		{
			"id": "steak_frites", "name": "牛排薯条", "name_cn": "牛排薯条",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 14, "mod_slots": 2,
			"tags": ["meat", "grilled", "fried", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "每3次激活爆发风味+35，20%概率风味x1.5",
				 "effect": {"accumulate": {"counter_id": "steak_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 35}},
				  "random_chance": 0.2, "on_success": {"type": "flavor_mult", "value": 1.5}}}
			],
			"on_activate": [],
			"description": "牛排薯条。"
		},
		{
			"id": "afternoon_tea_set", "name": "下午茶套装", "name_cn": "下午茶套装",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 10, "mod_slots": 2,
			"tags": ["sweet", "tea", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活卖相+15，获得2层摆盘",
				 "effect": {"type": "first_activate_bonus", "presentation": 15, "extra": {"add_keyword": "plating", "keyword_stacks": 2}}}
			],
			"on_activate": [],
			"description": "下午茶套装。"
		},
		{
			"id": "osso_buco", "name": "炖小牛胫", "name_cn": "炖小牛胫",
			"cuisine": "youshoku", "tier": 2, "size": 2, "cooldown": 7.5,
			"flavor": 16, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美、1层回味",
				 "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1}}
			],
			"on_activate": [],
			"description": "炖小牛胫。"
		},

		# ===== DIAMOND (Tier 3) =====
		{
			"id": "foie_gras_truffle", "name": "松露鹅肝", "name_cn": "松露鹅肝",
			"cuisine": "youshoku", "tier": 3, "size": 2, "cooldown": 9.0,
			"flavor": 22, "mod_slots": 2,
			"tags": ["meat", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得3层摆盘，首次激活风味+25",
				 "effect": {"add_keyword": "plating", "keyword_stacks": 3, "type": "first_activate_bonus", "flavor": 25}}
			],
			"on_activate": [],
			"description": "松露鹅肝。"
		},
		{
			"id": "full_course_francais", "name": "法式全席", "name_cn": "法式全席",
			"cuisine": "youshoku", "tier": 3, "size": 3, "cooldown": 12.0,
			"flavor": 20, "mod_slots": 2,
			"tags": ["mastered", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+30、卖相+20",
				 "effect": {"type": "first_activate_bonus", "flavor": 30, "presentation": 20}}
			],
			"on_activate": [],
			"description": "法式全席。"
		},
		{
			"id": "grand_dessert_assiette", "name": "大甜品盘", "name_cn": "大甜品盘",
			"cuisine": "youshoku", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得3层摆盘、2层回味",
				 "effect": {"add_keyword": "plating", "keyword_stacks": 3, "add_keyword_2": "aftertaste", "keyword_stacks_2": 2}}
			],
			"on_activate": [],
			"description": "大甜品盘。"
		},
		{
			"id": "chateaubriand_rossini", "name": "罗西尼牛排", "name_cn": "罗西尼牛排",
			"cuisine": "youshoku", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 24, "mod_slots": 2,
			"tags": ["meat", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得3层刀工、2层焦香，风味x1.3",
				 "effect": {"add_keyword": "knife_work", "keyword_stacks": 3, "add_keyword_2": "char_aroma", "keyword_stacks_2": 2, "type": "flavor_mult", "value": 1.3}}
			],
			"on_activate": [],
			"description": "罗西尼牛排。"
		},
	]
