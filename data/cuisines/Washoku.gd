extends RefCounted
class_name WashokuPool

## 和食カード・プール (Traditional Japanese)
## 使用者: ミスティア / 妖梦 / 霊夢
## 設計方針: 精進蓄力流 — 刀工=技法倍率引擎 / 大型菜高基数 / 位置敏感
## キーワード生成: knife_work, umami, plating, aftertaste

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) — 基本和食 =====
		{
			"id": "onigiri", "name": "饭团", "name_cn": "饭团",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["rice", "light", "staple"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层刀工；若在最左侧，额外+5风味并向右传1层鲜美", "effect": {"add_keyword": "knife_work", "keyword_stacks": 1, "if_position": "leftmost", "then": {"flavor": 5, "chain_right": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 1}}}, "else": {}}}
			],
			"on_activate": [],
			"description": "用海苔包裹的盐味米饭，简单而踏实。"
		},
		{
			"id": "miso_shiru", "name": "味噌汤", "name_cn": "味噌汤",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 4.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["soup", "umami_tag", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美；清除1层味觉疲劳", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "clear_environment": "taste_fatigue", "clear_amount": 1}}
			],
			"on_activate": [],
			"description": "以大豆发酵酱为底的鲜汤，暖胃解乏。"
		},
		{
			"id": "tamagoyaki", "name": "玉子烧", "name_cn": "玉子烧",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["egg", "light", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+8；若相邻有和食(清淡)，获得1层刀工", "effect": {"type": "first_activate_bonus", "flavor": 8, "extra": {"if_adjacent_has_tag": "light", "then_bonus": {"add_keyword": "knife_work", "keyword_stacks": 1}}}}
			],
			"on_activate": [],
			"description": "层层卷叠的甜味煎蛋，火候见真章。"
		},
		{
			"id": "tsukemono", "name": "渍物", "name_cn": "渍物",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["vegetable", "light", "fermented"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层回味；清除1层油腻", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "clear_environment": "greasy", "clear_amount": 1}}
			],
			"on_activate": [],
			"description": "时令蔬菜的盐渍小品，爽脆解腻。"
		},
		{
			"id": "edamame", "name": "毛豆", "name_cn": "毛豆",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 2.5,
			"flavor": 3, "mod_slots": 2,
			"tags": ["vegetable", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "风味+3；相邻CD-1秒", "effect": {"type": "stat_bonus", "flavor": 3, "reduce_cooldown_adjacent": 1.0}},
				{"event": "friend_activate", "effect": {"reduce_cooldown_self": 1.0}, "desc": "己方其他菜品激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "撒盐水煮的青大豆，佐酒良伴。"
		},
		{
			"id": "hiyayakko", "name": "冷豆腐", "name_cn": "冷豆腐",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 2.5,
			"flavor": 3, "mod_slots": 2,
			"tags": ["vegetable", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层刀工", "effect": {"add_keyword": "knife_work", "keyword_stacks": 1}},
				{"event": "adjacent_activate", "effect": {"reduce_cooldown_self": 1.0}, "desc": "相邻菜品激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "冰镇嫩豆腐佐姜葱，清凉素净。"
		},
		{
			"id": "yakitori", "name": "烤鸡肉串", "name_cn": "烤鸡肉串",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["meat", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层焦香；每3次爆发+25风味并相邻CD-1秒", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "accumulate": {"counter_id": "yakitori_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 25, "reduce_cooldown_adjacent": 1.0}}}}
			],
			"on_activate": [],
			"description": "炭火慢烤的鸡肉串，焦香四溢。"
		},

		# ===== SILVER (Tier 1) — 定番和食 =====
		{
			"id": "sashimi_moriawase", "name": "刺身拼盘", "name_cn": "刺身拼盘",
			"cuisine": "washoku", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 12, "mod_slots": 2,
			"tags": ["seafood", "raw", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层刀工，卖相+5；若刀工≥3，风味×1.3", "effect": {"add_keyword": "knife_work", "keyword_stacks": 2, "type": "stat_bonus", "presentation": 5, "if_keyword_gte": {"keyword": "knife_work", "stacks": 3}, "then": {"flavor_mult": 1.3}, "else": {}}}
			],
			"on_activate": [],
			"description": "严选鲜鱼薄切拼盘，刀工的极致展现。"
		},
		{
			"id": "chawanmushi", "name": "茶碗蒸", "name_cn": "茶碗蒸",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["egg", "steamed", "umami_tag", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美，右邻也获得1层鲜美", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "chain_right": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 1}}}},
				{"event": "adjacent_activate", "effect": {"add_keyword": "umami", "keyword_stacks": 1}, "desc": "相邻菜品激活时，获得1层鲜美"}
			],
			"on_activate": [],
			"description": "滑嫩如丝的蒸蛋羹，鲜味层层渗透。"
		},
		{
			"id": "yakizakana", "name": "烤鱼", "name_cn": "烤鱼",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 9, "mod_slots": 2,
			"tags": ["seafood", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层焦香和1层刀工；每3次爆发+30风味", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "add_keyword_2": "knife_work", "keyword_stacks_2": 1, "accumulate": {"counter_id": "yakizakana_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 30}}}}
			],
			"on_activate": [],
			"description": "盐烤整尾鲜鱼，皮脆肉嫩满口鲜。"
		},
		{
			"id": "nikujaga", "name": "肉土豆", "name_cn": "肉土豆",
			"cuisine": "washoku", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美和1层回味，相邻CD-1秒", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1, "reduce_cooldown_adjacent": 1.0}}
			],
			"on_activate": [],
			"description": "酱油炖煮的牛肉土豆，家庭料理的温柔。"
		},
		{
			"id": "tofu_dengaku", "name": "味噌烤豆腐", "name_cn": "味噌烤豆腐",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["vegetable", "grilled", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美；将油腻转化为鲜美", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "convert_keyword": {"from": "greasy", "to": "umami", "ratio": 1.0}}}
			],
			"on_activate": [],
			"description": "抹上味噌酱烤制的豆腐，甘香浓郁。"
		},
		{
			"id": "nimono", "name": "煮物", "name_cn": "煮物",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["vegetable", "stewed", "light", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美，相邻CD-1秒", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "reduce_cooldown_adjacent": 1.0}},
				{"event": "adjacent_activate", "condition": {"has_tag": "light"}, "effect": {"add_keyword": "umami", "keyword_stacks": 1}, "desc": "相邻和食(清淡)菜品激活时，获得1层鲜美"}
			],
			"on_activate": [],
			"description": "用高汤慢煮的时令蔬菜，清淡鲜醇。"
		},
		{
			"id": "kitsune_udon", "name": "狐狸乌冬", "name_cn": "狐狸乌冬",
			"cuisine": "washoku", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 9, "mod_slots": 2,
			"tags": ["noodle", "umami_tag", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "风味×1.3；获得1层鲜美", "effect": {"flavor_mult": 1.3, "add_keyword": "umami", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "盖着甜煮油豆腐的热汤乌冬，朴素满足。"
		},
		{
			"id": "agedashi_tofu", "name": "炸出汁豆腐", "name_cn": "炸出汁豆腐",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["vegetable", "fried", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美；若相邻有和食(清淡)，额外获得1层刀工", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "if_adjacent_has_tag": "light", "then_bonus": {"add_keyword": "knife_work", "keyword_stacks": 1}}}
			],
			"on_activate": [],
			"description": "外酥内嫩浸于出汁中的炸豆腐。"
		},
		{
			"id": "takoyaki", "name": "章鱼烧", "name_cn": "章鱼烧",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["seafood", "fried"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层摆盘；30%概率额外获得1层焦香和自身CD-1秒", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "random_chance": 0.3, "on_success": {"add_keyword": "char_aroma", "keyword_stacks": 1, "reduce_cooldown_self": 1.0}}}
			],
			"on_activate": [],
			"description": "外焦里嫩的圆形章鱼小丸子。"
		},

		# ===== GOLD (Tier 2) — 料亭級 =====
		{
			"id": "tempura_moriawase", "name": "天妇罗拼盘", "name_cn": "天妇罗拼盘",
			"cuisine": "washoku", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 14, "mod_slots": 2,
			"tags": ["seafood", "fried", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+15、卖相+10，获得2层刀工", "effect": {"type": "first_activate_bonus", "flavor": 15, "presentation": 10, "extra": {"add_keyword": "knife_work", "keyword_stacks": 2}}}
			],
			"on_activate": [],
			"description": "薄衣轻裹的炸物拼盘，酥而不腻。"
		},
		{
			"id": "unagi_kabayaki", "name": "蒲烧鳗鱼", "name_cn": "蒲烧鳗鱼",
			"cuisine": "washoku", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["seafood", "grilled", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美；每3次爆发+40风味并相邻加速1秒", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "accumulate": {"counter_id": "unagi_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 40, "haste_adjacent": 1.0, "haste_mult": 2.0}}}}
			],
			"on_activate": [],
			"description": "刷满蒲烧酱汁的烤鳗鱼，甘甜浓香。"
		},
		{
			"id": "sukiyaki", "name": "寿喜烧", "name_cn": "寿喜烧",
			"cuisine": "washoku", "tier": 2, "size": 3, "cooldown": 8.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美和1层回味；若鲜美≥3，风味×1.4", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1, "if_keyword_gte": {"keyword": "umami", "stacks": 3}, "then": {"flavor_mult": 1.4}, "else": {}}}
			],
			"on_activate": [],
			"description": "甜酱油汤底中涮煮的牛肉与蔬菜盛宴。"
		},
		{
			"id": "ochazuke", "name": "茶泡饭", "name_cn": "茶泡饭",
			"cuisine": "washoku", "tier": 2, "size": 1, "cooldown": 4.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["rice", "light", "tea"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "清除2层油腻→+10风味；清除1层味觉疲劳→获得回味", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "stat_bonus", "flavor": 10}, "clear_env_keyword_2": "taste_fatigue", "stacks_2": 1}}
			],
			"on_activate": [],
			"description": "热茶浇饭的素朴料理，解腻清口佳品。"
		},
		{
			"id": "soba_tsuyu", "name": "冷荞麦面", "name_cn": "冷荞麦面",
			"cuisine": "washoku", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["noodle", "light", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+12，获得2层刀工", "effect": {"type": "first_activate_bonus", "flavor": 12, "extra": {"add_keyword": "knife_work", "keyword_stacks": 2}}}
			],
			"on_activate": [],
			"description": "弹韧荞麦面配冰凉蘸汁，清爽利落。"
		},
		{
			"id": "kaisendon", "name": "海鲜盖饭", "name_cn": "海鲜盖饭",
			"cuisine": "washoku", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 13, "mod_slots": 2,
			"tags": ["seafood", "raw", "rice"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层刀工和卖相+5；若刀工≥4，额外风味×1.3", "effect": {"add_keyword": "knife_work", "keyword_stacks": 2, "type": "stat_bonus", "presentation": 5, "if_keyword_gte": {"keyword": "knife_work", "stacks": 4}, "then": {"flavor_mult": 1.3}, "else": {}}}
			],
			"on_activate": [],
			"description": "新鲜海产铺满白饭，色彩缤纷的丼物。"
		},
		{
			"id": "chanko_nabe", "name": "相扑火锅", "name_cn": "相扑火锅",
			"cuisine": "washoku", "tier": 2, "size": 3, "cooldown": 7.5,
			"flavor": 15, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美，风味×1.2；相邻CD-1秒", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "flavor_mult": 1.2, "reduce_cooldown_adjacent": 1.0}}
			],
			"on_activate": [],
			"description": "料足味浓的大锅炖煮，力士的能量之源。"
		},
		{
			"id": "katsudon", "name": "炸猪排盖饭", "name_cn": "炸猪排盖饭",
			"cuisine": "washoku", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["meat", "fried", "rice", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "刀工≥2：风味×1.5并获得2层鲜美；否则获得1层鲜美+1层油腻", "effect": {"if_keyword_gte": {"keyword": "knife_work", "stacks": 2}, "then": {"flavor_mult": 1.5, "add_keyword": "umami", "keyword_stacks": 2}, "else": {"add_keyword": "umami", "keyword_stacks": 1, "add_environment": "greasy", "environment_stacks": 1}}}
			],
			"on_activate": [],
			"description": "酥炸猪排裹蛋盖饭，外酥内嫩的满足感。"
		},

		# ===== DIAMOND (Tier 3) — 极致和食 =====
		{
			"id": "kaiseki_hassun", "name": "怀石八寸", "name_cn": "怀石八寸",
			"cuisine": "washoku", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 20, "mod_slots": 2,
			"tags": ["seasonal", "mastered", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活卖相+20，获得3层摆盘；后续每次获得2层摆盘和1层回味", "effect": {"type": "first_activate_bonus", "presentation": 20, "extra": {"add_keyword": "plating", "keyword_stacks": 3}}},
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1}, "desc": "获得2层摆盘和1层回味"}
			],
			"on_activate": [],
			"description": "以八寸方盘呈现的季节精华，怀石美学之巅。"
		},
		{
			"id": "fugu_course", "name": "河豚全席", "name_cn": "河豚全席",
			"cuisine": "washoku", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 22, "mod_slots": 2,
			"tags": ["seafood", "raw", "mastered", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+25、3层刀工；刀工≥5时风味×1.8", "effect": {"type": "first_activate_bonus", "flavor": 25, "extra": {"add_keyword": "knife_work", "keyword_stacks": 3}}},
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "knife_work", "stacks": 5}, "then": {"flavor_mult": 1.8}, "else": {"add_keyword": "knife_work", "keyword_stacks": 1}}, "desc": "刀工≥5层时风味×1.8；否则获得1层刀工"}
			],
			"on_activate": [],
			"description": "需要极致刀工的河豚全席，鲜美与危险并存。"
		},
		{
			"id": "tai_no_sugata", "name": "鲷鱼姿造", "name_cn": "鲷鱼姿造",
			"cuisine": "washoku", "tier": 3, "size": 3, "cooldown": 9.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["seafood", "raw", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得3层刀工，卖相+15；向两侧传递1层刀工", "effect": {"add_keyword": "knife_work", "keyword_stacks": 3, "type": "stat_bonus", "presentation": 15, "chain_right": {"range": 1, "effect": {"add_keyword": "knife_work", "keyword_stacks": 1}}, "chain_left": {"range": 1, "effect": {"add_keyword": "knife_work", "keyword_stacks": 1}}}}
			],
			"on_activate": [],
			"description": "整条鲷鱼的华丽姿造，刀工之艺术。"
		},
		{
			"id": "osechi_jubako", "name": "御节料理重箱", "name_cn": "御节料理重箱",
			"cuisine": "washoku", "tier": 3, "size": 3, "cooldown": 12.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["seasonal", "mastered", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美和2层摆盘；相邻菜品加速2秒", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "plating", "keyword_stacks_2": 2, "haste_adjacent": 2.0, "haste_mult": 1.5}}
			],
			"on_activate": [],
			"description": "层层叠放的正月料理，每道菜都有吉祥寓意。"
		},
		{
			"id": "matsutake_dobin", "name": "松茸土瓶蒸", "name_cn": "松茸土瓶蒸",
			"cuisine": "washoku", "tier": 3, "size": 2, "cooldown": 9.0,
			"flavor": 19, "mod_slots": 2,
			"tags": ["seasonal", "steamed", "umami_tag", "light", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得3层鲜美，风味×1.3；相邻CD-1秒", "effect": {"add_keyword": "umami", "keyword_stacks": 3, "flavor_mult": 1.3, "reduce_cooldown_adjacent": 1.0}}
			],
			"on_activate": [],
			"description": "松茸的清雅香气封存于土瓶之中，秋之极品。"
		},
	]
