extends RefCounted
class_name YakuzenPool

## 薬膳カード・プール (Medicinal / Herbal / Alchemy)
## 使用者: 魔理沙 / 霊夢 / 鈴仙
## 設計方針: 解毒支援流 — 環境清除専家 / 清除→報酬 / 全体加速支援 / 対手反制
## キーワード生成: umami, spotlight, secret_recipe, aftertaste

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) — 清除引擎 =====
		{
			"id": "herbal_tea", "name": "草药茶", "name_cn": "草药茶",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 3, "mod_slots": 2,
			"tags": ["tea", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "taste_fatigue", "clear_amount": 1, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}, "add_keyword": "umami", "keyword_stacks": 1}, "desc": "获得1层鲜美；清除1层味觉疲劳→获得鲜美"}
			],
			"on_activate": [],
			"description": "多种草药煎泡的清苦茶饮，提神醒脑。"
		},
		{
			"id": "nanakusa_gayu", "name": "七草粥", "name_cn": "七草粥",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["rice", "light", "seasonal"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}, "reduce_cooldown_adjacent": 1.0}, "desc": "清除2层油腻→获得鲜美；相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "正月初七食用的七种野草粥，清肠养胃。"
		},
		{
			"id": "ginger_soup", "name": "姜汤", "name_cn": "姜汤",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["soup", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"flavor_mult": 1.3, "add_keyword": "umami", "keyword_stacks": 1}, "desc": "风味×1.3，获得1层鲜美"},
				{"event": "adjacent_activate", "effect": {"reduce_cooldown_self": 1.0}, "desc": "相邻菜品激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "老姜熬煮的辛辣热汤，驱寒暖身。"
		},
		{
			"id": "mushroom_tea", "name": "蘑菇茶", "name_cn": "蘑菇茶",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["tea", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "chain_right": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 1}}}, "desc": "获得1层鲜美，向右传1层鲜美"}
			],
			"on_activate": [],
			"description": "香菇干贝熬成的菌香茶汤，鲜味醇厚。"
		},
		{
			"id": "kuzu_yu", "name": "葛汤", "name_cn": "葛汤",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 3, "mod_slots": 2,
			"tags": ["light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "stat_bonus", "flavor": 4, "technique": 2, "reduce_cooldown_adjacent": 1.0}, "desc": "+4风味、+2技巧，相邻CD-1秒"},
				{"event": "environment_applied", "condition": {"keyword": "greasy"}, "effect": {"clear_environment": "greasy", "clear_amount": 1}, "desc": "油腻出现时自动清除1层"}
			],
			"on_activate": [],
			"description": "葛根粉冲成的温热饮品，润肺养胃。"
		},
		{
			"id": "amazake_latte", "name": "甘酒拿铁", "name_cn": "甘酒拿铁",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "fermented", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "clear_environment": "messy", "clear_amount": 1, "bonus_on_clear": {"type": "gain_keyword", "keyword": "aftertaste"}}, "desc": "获得1层回味；清除1层杂乱→获得回味"}
			],
			"on_activate": [],
			"description": "甘酒与牛奶调和的温润饮品。"
		},
		{
			"id": "ninjin_shiri", "name": "金平胡萝卜", "name_cn": "金平胡萝卜",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 3, "mod_slots": 2,
			"tags": ["vegetable", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "messy", "clear_amount": 2, "bonus_on_clear": {"type": "stat_bonus", "presentation": 5}}, "desc": "清除2层杂乱→+5卖相"},
				{"event": "friend_activate", "effect": {"reduce_cooldown_self": 1.0}, "desc": "己方其他菜品激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "胡萝卜切丝炒制的金平小菜。"
		},
		{
			"id": "chrysanthemum_tea", "name": "菊花茶", "name_cn": "菊花茶",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 3, "mod_slots": 2,
			"tags": ["tea", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 1, "clear_env_keyword_2": "taste_fatigue", "stacks_2": 1, "reduce_cooldown_adjacent": 1.0}, "desc": "清除1层油腻和1层味觉疲劳；相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "菊花泡出的淡雅花茶，清肝明目。"
		},

		# ===== SILVER (Tier 1) — 转化+条件 =====
		{
			"id": "yakuzen_nabe", "name": "药膳火锅", "name_cn": "药膳火锅",
			"cuisine": "yakuzen", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"convert_keyword": {"from": "greasy", "to": "umami", "ratio": 1.0}, "add_keyword": "umami", "keyword_stacks": 1, "reduce_cooldown_adjacent": 1.0}, "desc": "将油腻转化为鲜美，额外获得1层鲜美，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "药材与食材同炖的滋补火锅。"
		},
		{
			"id": "magic_mushroom_soup", "name": "魔法蘑菇汤", "name_cn": "魔法蘑菇汤",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["soup", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "umami", "stacks": 2}, "then": {"flavor_mult": 1.8, "add_keyword": "umami", "keyword_stacks": 1}, "else": {"add_keyword": "umami", "keyword_stacks": 2}}, "desc": "鲜美≥2时风味×1.8并+1鲜美；否则获得2层鲜美"}
			],
			"on_activate": [],
			"description": "魔法森林采集的稀有蘑菇熬成的浓汤。"
		},
		{
			"id": "samgyetang", "name": "参鸡汤", "name_cn": "参鸡汤",
			"cuisine": "yakuzen", "tier": 1, "size": 2, "cooldown": 6.5,
			"flavor": 9, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "accumulate": {"counter_id": "samgyetang_brew", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 25, "add_keyword": "aftertaste", "keyword_stacks": 2, "haste_adjacent": 1.0, "haste_mult": 2.0}}}, "desc": "获得1层鲜美；每3次爆发+25风味、2层回味并相邻加速1秒"}
			],
			"on_activate": [],
			"description": "整鸡填入人参糯米慢炖的滋补汤品。"
		},
		{
			"id": "shrine_amazake", "name": "神社甘酒", "name_cn": "神社甘酒",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["sweet", "fermented", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "taste_fatigue", "clear_amount": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "secret_recipe"}, "add_keyword": "aftertaste", "keyword_stacks": 1}, "desc": "获得1层回味；清除2层味觉疲劳→获得秘方"},
				{"event": "environment_applied", "condition": {"keyword": "taste_fatigue"}, "effect": {"clear_environment": "taste_fatigue", "clear_amount": 1}, "desc": "味觉疲劳出现时自动清除1层"}
			],
			"on_activate": [],
			"description": "神社酿造的天然甘酒，温暖身心。"
		},
		{
			"id": "reishi_congee", "name": "灵芝粥", "name_cn": "灵芝粥",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["rice", "light", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "secret_recipe", "keyword_stacks_2": 1, "reduce_cooldown_adjacent": 1.0}, "desc": "获得1层鲜美和1层秘方，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "灵芝切片熬入粥中，滋补养神。"
		},
		{
			"id": "tonic_soup", "name": "药膳补汤", "name_cn": "药膳补汤",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["soup", "umami_tag", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 3, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}, "reduce_cooldown_adjacent": 1.0}, "desc": "清除3层油腻→获得鲜美；相邻CD-1秒"},
				{"event": "adjacent_activate", "effect": {"clear_environment": "greasy", "clear_amount": 1}, "desc": "相邻菜品激活时，清除1层油腻"}
			],
			"on_activate": [],
			"description": "多味药材慢火熬煮的补益汤品。"
		},
		{
			"id": "lotus_root_soup", "name": "莲藕汤", "name_cn": "莲藕汤",
			"cuisine": "yakuzen", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["soup", "vegetable", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"chain_right": {"range": 2, "effect": {"add_keyword": "umami", "keyword_stacks": 1}}, "chain_left": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 1}}}, "desc": "向左1格和右2格传递1层鲜美"}
			],
			"on_activate": [],
			"description": "莲藕炖至粉糯的清甜养生汤。"
		},
		{
			"id": "goji_congee", "name": "枸杞粥", "name_cn": "枸杞粥",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["rice", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 12, "extra": {"add_keyword": "umami", "keyword_stacks": 2, "reduce_cooldown_adjacent": 1.0}}, "desc": "首次激活+12风味，获得2层鲜美，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "红艳枸杞点缀的养生米粥。"
		},
		{
			"id": "cordyceps_broth", "name": "虫草清汤", "name_cn": "虫草清汤",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 5.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["soup", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_adjacent_has_tag": "tea", "then_bonus": {"type": "stat_bonus", "flavor": 8, "add_keyword": "umami", "keyword_stacks": 1}, "reduce_cooldown_adjacent": 1.0}, "desc": "相邻有茶类时+8风味和1层鲜美；相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "虫草炖出的金黄清汤，名贵滋补。"
		},

		# ===== GOLD (Tier 2) — 转化+条件爆发 =====
		{
			"id": "eirin_elixir", "name": "永琳秘药", "name_cn": "永琳秘药",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 6.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 20, "extra": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "secret_recipe", "keyword_stacks_2": 2, "haste_adjacent": 1.5, "haste_mult": 2.0}}, "desc": "首次激活+20风味，获得2层鲜美和2层秘方，相邻加速1.5秒"}
			],
			"on_activate": [],
			"description": "永琳调配的神秘药剂，功效非凡。"
		},
		{
			"id": "five_element_soup", "name": "五行汤", "name_cn": "五行汤",
			"cuisine": "yakuzen", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 12, "mod_slots": 2,
			"tags": ["soup", "mastered", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 3, "clear_env_keyword_2": "taste_fatigue", "stacks_2": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}, "accumulate": {"counter_id": "five_element_cycle", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 35, "add_keyword": "secret_recipe", "keyword_stacks": 1}}}, "desc": "清除3层油腻和2层疲劳→获得鲜美；每3次爆发+35风味和1层秘方"}
			],
			"on_activate": [],
			"description": "金木水火土五味调和的平衡汤品。"
		},
		{
			"id": "master_spark_brew", "name": "魔炮煎药", "name_cn": "魔炮煎药",
			"cuisine": "yakuzen", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"chain_right": {"range": 2, "effect": {"add_keyword": "spotlight", "keyword_stacks": 2}}, "chain_left": {"range": 1, "effect": {"add_keyword": "spotlight", "keyword_stacks": 1}}, "haste_adjacent": 1.0, "haste_mult": 2.0}, "desc": "向右2格传2层聚光，向左1格传1层聚光；相邻加速1秒"}
			],
			"on_activate": [],
			"description": "魔理沙以魔法火力煎制的猛药。"
		},
		{
			"id": "yin_yang_tea", "name": "阴阳玉茶", "name_cn": "阴阳玉茶",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["tea", "mastered", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"convert_keyword": {"from": "greasy", "to": "umami", "ratio": 1.0}, "reduce_cooldown_adjacent": 1.0}, "desc": "将油腻转鲜美；相邻CD-1秒"},
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "taste_fatigue", "clear_amount": 3, "bonus_on_clear": {"type": "gain_keyword", "keyword": "aftertaste"}}, "desc": "清除味觉疲劳→获得回味"},
				{"event": "environment_applied", "effect": {"clear_environment": "greasy", "clear_amount": 1, "clear_env_keyword_2": "taste_fatigue", "stacks_2": 1}, "desc": "环境词条出现时，清除1层油腻和1层疲劳"}
			],
			"on_activate": [],
			"description": "阴阳调和的双色茶饮，平衡百味。"
		},
		{
			"id": "immortal_peach", "name": "仙桃", "name_cn": "仙桃",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 6.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "umami", "stacks": 3}, "then": {"flavor_mult": 1.8, "add_keyword": "aftertaste", "keyword_stacks": 2}, "else": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1}}, "desc": "鲜美≥3时风味×1.8和2层回味；否则获得2层鲜美和1层回味"}
			],
			"on_activate": [],
			"description": "据传吃了能长生不老的仙界蟠桃。"
		},
		{
			"id": "matcha_medicine", "name": "抹茶药茶", "name_cn": "抹茶药茶",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["tea", "light", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "taste_fatigue", "clear_amount": 3, "bonus_on_clear": {"type": "gain_keyword", "keyword": "secret_recipe"}, "clear_env_keyword_2": "dull", "stacks_2": 2, "reduce_cooldown_adjacent": 1.0}, "desc": "清除3层疲劳→获得秘方；清除2层沉闷；相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "抹茶粉融入药茶的清苦饮品。"
		},
		{
			"id": "black_sesame_soup", "name": "黑芝麻糊", "name_cn": "黑芝麻糊",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 5.5,
			"flavor": 9, "mod_slots": 2,
			"tags": ["sweet", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "secret_recipe", "keyword_stacks_2": 1, "if_keyword_gte": {"keyword": "umami", "stacks": 4}, "then": {"flavor_mult": 1.5}, "else": {}}, "desc": "获得2层鲜美和1层秘方；鲜美≥4时风味×1.5"}
			],
			"on_activate": [],
			"description": "研磨黑芝麻煮成的浓稠甜汤。"
		},
		{
			"id": "moon_rabbit_mochi", "name": "月兔麻糬", "name_cn": "月兔麻糬",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 9, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"random_chance": 0.4, "on_success": {"flavor_mult": 2.0, "add_keyword": "aftertaste", "keyword_stacks": 2}, "add_keyword": "umami", "keyword_stacks": 1}, "desc": "获得1层鲜美；40%概率风味×2.0并获得2层回味"}
			],
			"on_activate": [],
			"description": "月兔在月球上捣制的神奇麻糬。"
		},
		{
			"id": "bamboo_shoot_elixir", "name": "竹笋灵药", "name_cn": "竹笋灵药",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 6.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["vegetable", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "messy", "clear_amount": 3, "bonus_on_clear": {"type": "stat_bonus", "flavor": 10, "presentation": 5}}, "desc": "清除3层杂乱→+10风味和+5卖相"},
				{"event": "adjacent_activate", "condition": {"has_tag": "light"}, "effect": {"add_keyword": "umami", "keyword_stacks": 1}, "desc": "相邻和食(清淡)菜品激活时，获得1层鲜美"}
			],
			"on_activate": [],
			"description": "鲜竹笋提取的清甜灵药。"
		},

		# ===== DIAMOND (Tier 3) — 全场净化+终极支援 =====
		{
			"id": "hourai_elixir", "name": "蓬莱之药", "name_cn": "蓬莱之药",
			"cuisine": "yakuzen", "tier": 3, "size": 2, "cooldown": 10.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 40, "extra": {"add_keyword": "umami", "keyword_stacks": 3, "add_keyword_2": "secret_recipe", "keyword_stacks_2": 2, "haste_adjacent": 2.0, "haste_mult": 2.0}}, "desc": "首次激活+40风味，获得3层鲜美和2层秘方，相邻加速2秒"},
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 5, "clear_env_keyword_2": "taste_fatigue", "stacks_2": 3, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}}, "desc": "每次激活清除5层油腻和3层疲劳→获得鲜美"}
			],
			"on_activate": [],
			"description": "传说中的蓬莱仙药，饮之不老。"
		},
		{
			"id": "hakurei_feast", "name": "博丽之宴", "name_cn": "博丽之宴",
			"cuisine": "yakuzen", "tier": 3, "size": 3, "cooldown": 12.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["mastered", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 5, "clear_env_keyword_2": "taste_fatigue", "stacks_2": 5, "haste_adjacent": 3.0, "haste_mult": 2.0, "add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 2}, "desc": "全场净化：清除5层油腻和5层疲劳；获得2层鲜美和2层回味；相邻加速3秒（×2）"}
			],
			"on_activate": [],
			"description": "博丽神社的净化之宴，百邪不侵。"
		},
		{
			"id": "philosopher_stone_dish", "name": "贤者之石膳", "name_cn": "贤者之石膳",
			"cuisine": "yakuzen", "tier": 3, "size": 3, "cooldown": 11.0,
			"flavor": 20, "mod_slots": 2,
			"tags": ["mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"convert_keyword": {"from": "greasy", "to": "umami", "ratio": 2.0}, "accumulate": {"counter_id": "philosopher_transmute", "increment": 1, "threshold": 2, "reset_counter": true, "on_threshold": {"flavor": 50, "add_keyword": "secret_recipe", "keyword_stacks": 2, "chain_right": {"range": 2, "effect": {"add_keyword": "umami", "keyword_stacks": 2}}}}}, "desc": "油腻→鲜美（1:2转化）；每2次爆发+50风味、2层秘方并向右传鲜美"}
			],
			"on_activate": [],
			"description": "以炼金术原理调配的点石成金之膳。"
		},
		{
			"id": "lunar_capital_banquet", "name": "月都盛宴", "name_cn": "月都盛宴",
			"cuisine": "yakuzen", "tier": 3, "size": 3, "cooldown": 12.0,
			"flavor": 22, "mod_slots": 2,
			"tags": ["mastered", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "umami", "stacks": 5}, "then": {"flavor_mult": 2.5, "add_keyword": "secret_recipe", "keyword_stacks": 2, "slow": 2.0, "slow_mult": 0.5}, "else": {"add_keyword": "umami", "keyword_stacks": 3, "add_keyword_2": "aftertaste", "keyword_stacks_2": 2}}, "desc": "鲜美≥5层：风味×2.5、2层秘方、减速对手2秒；否则获得3层鲜美和2层回味"}
			],
			"on_activate": [],
			"description": "月之都贵族享用的华贵宴席。"
		},
	]
