extends RefCounted
class_name ChuukaPool

## 中華カード・プール (Chinese Cuisine)
## 使用者: 妖梦 / 美鈴 / パチュリー
## キーワード生成: char_aroma, umami, rich

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) =====
		{
			"id": "chahan", "name": "蛋炒饭", "name_cn": "蛋炒饭",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["rice", "stir_fried", "egg"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1}, "desc": "获得1层焦香"}],
			"on_activate": [],
			"description": "蛋炒饭。"
		},
		{
			"id": "gyoza", "name": "煎饺", "name_cn": "煎饺",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["meat", "fried", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"random_chance": 0.2, "on_success": {"flavor_mult": 2.0}}, "desc": "20%概率风味翻倍"}],
			"on_activate": [],
			"description": "煎饺。"
		},
		{
			"id": "mapo_tofu", "name": "麻婆豆腐", "name_cn": "麻婆豆腐",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 4.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["vegetable", "spicy", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "reduce_cooldown_adjacent": 0.3}, "desc": "获得1层鲜美，相邻CD-0.3秒"}],
			"on_activate": [],
			"description": "麻婆豆腐。"
		},
		{
			"id": "xiaolongbao", "name": "小笼包", "name_cn": "小笼包",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 6, "mod_slots": 2,
			"tags": ["meat", "steamed", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 8}, "desc": "首次激活风味+8"}],
			"on_activate": [],
			"description": "小笼包。"
		},
		{
			"id": "congee", "name": "白粥", "name_cn": "白粥",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["rice", "light", "staple"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "stat_bonus", "flavor": 3}, "desc": "风味+3"}],
			"on_activate": [],
			"description": "白粥。"
		},
		{
			"id": "baozi", "name": "肉包子", "name_cn": "肉包子",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["meat", "steamed"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1}, "desc": "获得1层鲜美"}],
			"on_activate": [],
			"description": "肉包子。"
		},
		{
			"id": "hotpot_base", "name": "火锅底料", "name_cn": "火锅底料",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 6, "mod_slots": 2,
			"tags": ["spicy", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "reduce_cooldown_adjacent": 0.3}, "desc": "获得1层焦香，相邻CD-0.3秒"}],
			"on_activate": [],
			"description": "火锅底料。"
		},
		{
			"id": "scallion_pancake", "name": "葱油饼", "name_cn": "葱油饼",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["fried", "staple", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"random_chance": 0.2, "on_success": {"flavor_mult": 2.0}}, "desc": "20%概率风味翻倍"}],
			"on_activate": [],
			"description": "葱油饼。"
		},
		{
			"id": "wonton_soup", "name": "馄饨汤", "name_cn": "馄饨汤",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 6, "mod_slots": 2,
			"tags": ["meat", "soup", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1}, "desc": "获得1层鲜美"}],
			"on_activate": [],
			"description": "馄饨汤。"
		},
		{
			"id": "youtiao", "name": "油条", "name_cn": "油条",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 2.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["fried", "staple", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "stat_bonus", "flavor": 3}, "desc": "风味+3"}],
			"on_activate": [],
			"description": "油条。"
		},

		# ===== SILVER (Tier 1) =====
		{
			"id": "kung_pao_chicken", "name": "宫保鸡丁", "name_cn": "宫保鸡丁",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["meat", "stir_fried", "spicy"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "accumulate": {"counter_id": "kungpao_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 30}}}, "desc": "获得1层焦香，每3次激活爆发风味+30"}],
			"on_activate": [],
			"description": "宫保鸡丁。"
		},
		{
			"id": "sweet_sour_pork", "name": "糖醋排骨", "name_cn": "糖醋排骨",
			"cuisine": "chuuka", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["meat", "fried", "sweet", "sour", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "random_chance": 0.25, "on_success": {"flavor_mult": 1.5}}, "desc": "获得1层摆盘，25%概率风味x1.5"}],
			"on_activate": [],
			"description": "糖醋排骨。"
		},
		{
			"id": "dan_dan_noodles", "name": "担担面", "name_cn": "担担面",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 9, "mod_slots": 2,
			"tags": ["noodle", "spicy", "rich", "umami_tag"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "char_aroma", "keyword_stacks_2": 1}, "desc": "获得1层鲜美、1层焦香"}],
			"on_activate": [],
			"description": "担担面。"
		},
		{
			"id": "char_siu", "name": "叉烧", "name_cn": "叉烧",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 5.5,
			"flavor": 10, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"accumulate": {"counter_id": "charsiu_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 35}}}, "desc": "每3次激活爆发风味+35"}],
			"on_activate": [],
			"description": "叉烧。"
		},
		{
			"id": "spring_rolls", "name": "春卷", "name_cn": "春卷",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["vegetable", "fried"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"random_chance": 0.3, "on_success": {"add_keyword": "plating", "keyword_stacks": 2}}, "desc": "30%概率获得2层摆盘"}],
			"on_activate": [],
			"description": "春卷。"
		},
		{
			"id": "niurou_mian", "name": "台式牛肉面", "name_cn": "台式牛肉面",
			"cuisine": "chuuka", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 10, "mod_slots": 2,
			"tags": ["noodle", "meat", "stewed", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "flavor_mult": 1.2}, "desc": "获得1层鲜美，风味x1.2"}],
			"on_activate": [],
			"description": "台式牛肉面。"
		},
		{
			"id": "maoxuewang", "name": "毛血旺", "name_cn": "毛血旺",
			"cuisine": "chuuka", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["meat", "spicy", "rich", "stewed"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 2}, "desc": "获得2层焦香"}],
			"on_activate": [],
			"description": "毛血旺。"
		},
		{
			"id": "xo_sauce_noodle", "name": "XO酱炒面", "name_cn": "XO酱炒面",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 8, "mod_slots": 2,
			"tags": ["noodle", "stir_fried", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "chain_right": {"range": 1, "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1}}}, "desc": "获得1层焦香，右邻也获得1层"}],
			"on_activate": [],
			"description": "XO酱炒面。"
		},
		{
			"id": "twice_cooked_pork", "name": "回锅肉", "name_cn": "回锅肉",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["meat", "stir_fried", "rich", "spicy"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "accumulate": {"counter_id": "huiguo_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 30}}}, "desc": "获得1层焦香，每3次激活爆发风味+30"}],
			"on_activate": [],
			"description": "回锅肉。"
		},

		# ===== GOLD (Tier 2) =====
		{
			"id": "peking_duck", "name": "北京烤鸭", "name_cn": "北京烤鸭",
			"cuisine": "chuuka", "tier": 2, "size": 3, "cooldown": 8.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 2, "type": "first_activate_bonus", "flavor": 20}, "desc": "获得2层焦香，首次激活风味+20"}],
			"on_activate": [],
			"description": "北京烤鸭。"
		},
		{
			"id": "dongpo_pork", "name": "东坡肉", "name_cn": "东坡肉",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "flavor_mult": 1.3}, "desc": "获得2层鲜美，风味x1.3"}],
			"on_activate": [],
			"description": "东坡肉。"
		},
		{
			"id": "wuxing_chaohe", "name": "五行干炒河粉", "name_cn": "五行干炒河粉",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["noodle", "stir_fried", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 2, "chain_right": {"range": 2, "effect": {"type": "stat_bonus", "flavor": 5}}}, "desc": "获得2层焦香，右侧2格各+5风味"}],
			"on_activate": [],
			"description": "五行干炒河粉。"
		},
		{
			"id": "steamed_fish", "name": "清蒸鲈鱼", "name_cn": "清蒸鲈鱼",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 13, "mod_slots": 2,
			"tags": ["seafood", "steamed", "light", "umami_tag"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "knife_work", "keyword_stacks_2": 1}, "desc": "获得2层鲜美、1层刀工"}],
			"on_activate": [],
			"description": "清蒸鲈鱼。"
		},
		{
			"id": "dim_sum_platter", "name": "点心拼盘", "name_cn": "点心拼盘",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 12, "mod_slots": 2,
			"tags": ["steamed", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 15, "presentation": 10}, "desc": "首次激活风味+15、卖相+10"}],
			"on_activate": [],
			"description": "点心拼盘。"
		},
		{
			"id": "shuizhu_yu", "name": "水煮鱼", "name_cn": "水煮鱼",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 15, "mod_slots": 2,
			"tags": ["seafood", "spicy", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 2, "reduce_cooldown_adjacent": 0.5}, "desc": "获得2层焦香，相邻CD-0.5秒"}],
			"on_activate": [],
			"description": "水煮鱼。"
		},
		{
			"id": "lion_head", "name": "红烧狮子头", "name_cn": "红烧狮子头",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1}, "desc": "获得2层鲜美、1层回味"}],
			"on_activate": [],
			"description": "红烧狮子头。"
		},
		{
			"id": "mapo_eggplant", "name": "鱼香茄子", "name_cn": "鱼香茄子",
			"cuisine": "chuuka", "tier": 2, "size": 1, "cooldown": 5.5,
			"flavor": 12, "mod_slots": 2,
			"tags": ["vegetable", "stir_fried", "rich", "spicy"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "random_chance": 0.25, "on_success": {"flavor_mult": 2.0}}, "desc": "获得1层焦香，25%概率风味翻倍"}],
			"on_activate": [],
			"description": "鱼香茄子。"
		},

		# ===== DIAMOND (Tier 3) =====
		{
			"id": "buddha_jumps_wall", "name": "佛跳墙", "name_cn": "佛跳墙",
			"cuisine": "chuuka", "tier": 3, "size": 3, "cooldown": 12.0,
			"flavor": 24, "mod_slots": 2,
			"tags": ["seafood", "stewed", "rich", "umami_tag", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 3, "add_keyword_2": "aftertaste", "keyword_stacks_2": 2, "flavor_mult": 1.3}, "desc": "获得3层鲜美、2层回味，风味x1.3"}],
			"on_activate": [],
			"description": "佛跳墙。"
		},
		{
			"id": "manhan_quanxi", "name": "满汉全席", "name_cn": "满汉全席",
			"cuisine": "chuuka", "tier": 3, "size": 3, "cooldown": 14.0,
			"flavor": 20, "mod_slots": 2,
			"tags": ["mastered", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 30, "presentation": 20}, "desc": "首次激活风味+30、卖相+20"}],
			"on_activate": [],
			"description": "满汉全席。"
		},
		{
			"id": "dragon_phoenix_platter", "name": "龙凤呈祥", "name_cn": "龙凤呈祥",
			"cuisine": "chuuka", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 22, "mod_slots": 2,
			"tags": ["seafood", "meat", "rich", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 3, "add_keyword_2": "umami", "keyword_stacks_2": 2}, "desc": "获得3层焦香、2层鲜美"}],
			"on_activate": [],
			"description": "龙凤呈祥。"
		},
	]
