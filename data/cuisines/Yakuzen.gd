extends RefCounted
class_name YakuzenPool

## 薬膳カード・プー�?(Medicinal / Herbal / Alchemy)
## 使用�? 魔理�?/ 霊夢 / 鈴仙
## キーワード生�? umami, spotlight, secret_recipe

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) =====
		{
			"id": "herbal_tea", "name": "草药茶", "name_cn": "草药茶",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 3, "mod_slots": 2,
			"tags": ["tea", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "taste_fatigue", "clear_amount": 1}, "desc": "激活时清除1层味觉疲劳"}
			],
			"on_activate": [],
			"description": "【文本已修复】草药茶。"
		},
		{
			"id": "nanakusa_gayu", "name": "七草粥", "name_cn": "七草粥",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["rice", "light", "seasonal"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 1, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}}, "desc": "激活时清除1层油腻，若成功则获得1层鲜美"}
			],
			"on_activate": [],
			"description": "【文本已修复】七草粥。"
		},
		{
			"id": "ginger_soup", "name": "姜汤", "name_cn": "姜汤",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["soup", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"flavor_mult": 1.3}, "desc": "激活时风味x1.3"}
			],
			"on_activate": [],
			"description": "【文本已修复】姜汤。"
		},
		{
			"id": "mushroom_tea", "name": "蘑菇茶", "name_cn": "蘑菇茶",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["tea", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1}, "desc": "激活时获得1层鲜美"}
			],
			"on_activate": [],
			"description": "【文本已修复】蘑菇茶。"
		},
		{
			"id": "kuzu_yu", "name": "葛汤", "name_cn": "葛汤",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 3, "mod_slots": 2,
			"tags": ["light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "stat_bonus", "flavor": 4, "technique": 2}, "desc": "激活时+4风味，+2技巧"}
			],
			"on_activate": [],
			"description": "【文本已修复】葛汤。"
		},
		{
			"id": "amazake_latte", "name": "甘酒拿铁", "name_cn": "甘酒拿铁",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "fermented", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"random_chance": 0.3, "on_success": {"flavor_mult": 1.5}}, "desc": "激活时30%概率风味x1.5"}
			],
			"on_activate": [],
			"description": "【文本已修复】甘酒拿铁。"
		},
		{
			"id": "ninjin_shiri", "name": "金平胡萝卜", "name_cn": "金平胡萝卜",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 3, "mod_slots": 2,
			"tags": ["vegetable", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "messy", "clear_amount": 1}, "desc": "激活时清除1层杂乱"}
			],
			"on_activate": [],
			"description": "【文本已修复】金平胡萝卜。"
		},
		{
			"id": "chrysanthemum_tea", "name": "菊花茶", "name_cn": "菊花茶",
			"cuisine": "yakuzen", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 3, "mod_slots": 2,
			"tags": ["tea", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 1}, "desc": "激活时清除1层油腻"}
			],
			"on_activate": [],
			"description": "【文本已修复】菊花茶。"
		},

		# ===== SILVER (Tier 1) =====
		{
			"id": "yakuzen_nabe", "name": "药膳火锅", "name_cn": "药膳火锅",
			"cuisine": "yakuzen", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"convert_keyword": {"from": "greasy", "to": "umami", "ratio": 1.0}}, "desc": "激活时将所有油腻转化为鲜美"}
			],
			"on_activate": [],
			"description": "【文本已修复】药膳火锅。"
		},
		{
			"id": "magic_mushroom_soup", "name": "魔法蘑菇汤", "name_cn": "魔法蘑菇汤",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["soup", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "umami", "stacks": 2}, "then": {"flavor_mult": 1.8}, "else": {"add_keyword": "umami", "keyword_stacks": 1}}, "desc": "鲜美>=2时风味x1.8，否则获得1层鲜美"}
			],
			"on_activate": [],
			"description": "【文本已修复】魔法蘑菇汤。"
		},
		{
			"id": "samgyetang", "name": "参鸡汤", "name_cn": "参鸡汤",
			"cuisine": "yakuzen", "tier": 1, "size": 2, "cooldown": 6.5,
			"flavor": 9, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"accumulate": {"counter_id": "samgyetang_brew", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 25}}}, "desc": "每激活3次，爆发+25风味（慢炖参鸡）"}
			],
			"on_activate": [],
			"description": "【文本已修复】参鸡汤。"
		},
		{
			"id": "shrine_amazake", "name": "神社甘酒", "name_cn": "神社甘酒",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["sweet", "fermented", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "taste_fatigue", "clear_amount": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "secret_recipe"}}, "desc": "清除2层味觉疲劳，若成功则获得秘方"}
			],
			"on_activate": [],
			"description": "【文本已修复】神社甘酒。"
		},
		{
			"id": "reishi_congee", "name": "灵芝粥", "name_cn": "灵芝粥",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["rice", "light", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "secret_recipe", "keyword_stacks_2": 1}, "desc": "激活时获得1层鲜美和1层秘方"}
			],
			"on_activate": [],
			"description": "【文本已修复】灵芝粥。"
		},
		{
			"id": "tonic_soup", "name": "药膳补汤", "name_cn": "药膳补汤",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["soup", "umami_tag", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}}, "desc": "清除2层油腻，若成功则获得鲜美"}
			],
			"on_activate": [],
			"description": "【文本已修复】药膳补汤。"
		},
		{
			"id": "lotus_root_soup", "name": "莲藕汤", "name_cn": "莲藕汤",
			"cuisine": "yakuzen", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["soup", "vegetable", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"chain_right": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 1}}}, "desc": "激活时向右相邻料理传递1层鲜美"}
			],
			"on_activate": [],
			"description": "【文本已修复】莲藕汤。"
		},
		{
			"id": "goji_congee", "name": "枸杞粥", "name_cn": "枸杞粥",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["rice", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 12}, "desc": "首次激活时+12风味"}
			],
			"on_activate": [],
			"description": "【文本已修复】枸杞粥。"
		},
		{
			"id": "cordyceps_broth", "name": "虫草清汤", "name_cn": "虫草清汤",
			"cuisine": "yakuzen", "tier": 1, "size": 1, "cooldown": 5.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["soup", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_adjacent_has_tag": "tea", "then_bonus": {"type": "stat_bonus", "flavor": 8}}, "desc": "相邻有茶类料理时+8风味"}
			],
			"on_activate": [],
			"description": "【文本已修复】虫草清汤。"
		},

		# ===== GOLD (Tier 2) =====
		{
			"id": "eirin_elixir", "name": "永琳秘药", "name_cn": "永琳秘药",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 6.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 20, "extra": {"add_keyword": "umami", "keyword_stacks": 2}}, "desc": "首次激活时+20风味并获得2层鲜美"}
			],
			"on_activate": [],
			"description": "【文本已修复】永琳秘药。"
		},
		{
			"id": "five_element_soup", "name": "五行汤", "name_cn": "五行汤",
			"cuisine": "yakuzen", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 12, "mod_slots": 2,
			"tags": ["soup", "mastered", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"accumulate": {"counter_id": "five_element_cycle", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 35}}}, "desc": "每激活3次，五行循环爆发+35风味"}
			],
			"on_activate": [],
			"description": "【文本已修复】五行汤。"
		},
		{
			"id": "master_spark_brew", "name": "魔炮煎药", "name_cn": "魔炮煎药",
			"cuisine": "yakuzen", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"chain_right": {"range": 1, "effect": {"add_keyword": "spotlight", "keyword_stacks": 2}}}, "desc": "激活时向右相邻料理传递2层聚光"}
			],
			"on_activate": [],
			"description": "【文本已修复】魔炮煎药。"
		},
		{
			"id": "yin_yang_tea", "name": "阴阳玉茶", "name_cn": "阴阳玉茶",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["tea", "mastered", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"convert_keyword": {"from": "greasy", "to": "umami", "ratio": 1.0}}, "desc": "激活时阴阳调和，将油腻转化为鲜美"}
			],
			"on_activate": [],
			"description": "【文本已修复】阴阳玉茶。"
		},
		{
			"id": "immortal_peach", "name": "仙桃", "name_cn": "仙桃",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 6.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "umami", "stacks": 3}, "then": {"flavor_mult": 1.8}, "else": {"add_keyword": "umami", "keyword_stacks": 2}}, "desc": "鲜美>=3时风味x1.8，否则获得2层鲜美"}
			],
			"on_activate": [],
			"description": "【文本已修复】仙桃。"
		},
		{
			"id": "matcha_medicine", "name": "抹茶药茶", "name_cn": "抹茶药茶",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["tea", "light", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "taste_fatigue", "clear_amount": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "secret_recipe"}}, "desc": "清除2层味觉疲劳，若成功则获得秘方"}
			],
			"on_activate": [],
			"description": "【文本已修复】抹茶药茶。"
		},
		{
			"id": "black_sesame_soup", "name": "黑芝麻糊", "name_cn": "黑芝麻糊",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 5.5,
			"flavor": 9, "mod_slots": 2,
			"tags": ["sweet", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "secret_recipe", "keyword_stacks_2": 1}, "desc": "激活时获得2层鲜美和1层秘方"}
			],
			"on_activate": [],
			"description": "【文本已修复】黑芝麻糊。"
		},
		{
			"id": "moon_rabbit_mochi", "name": "月兔麻糬", "name_cn": "月兔麻糬",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 9, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"random_chance": 0.4, "on_success": {"flavor_mult": 2.0}}, "desc": "激活时40%概率风味x2.0（月兔的幸运）"}
			],
			"on_activate": [],
			"description": "【文本已修复】月兔麻糬。"
		},
		{
			"id": "bamboo_shoot_elixir", "name": "竹笋灵药", "name_cn": "竹笋灵药",
			"cuisine": "yakuzen", "tier": 2, "size": 1, "cooldown": 6.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["vegetable", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "messy", "clear_amount": 2, "bonus_on_clear": {"type": "stat_bonus", "flavor": 10}}, "desc": "清除2层杂乱，若成功则+10风味"}
			],
			"on_activate": [],
			"description": "【文本已修复】竹笋灵药。"
		},

		# ===== DIAMOND (Tier 3) =====
		{
			"id": "hourai_elixir", "name": "蓬莱之药", "name_cn": "蓬莱之药",
			"cuisine": "yakuzen", "tier": 3, "size": 2, "cooldown": 10.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 40, "extra": {"add_keyword": "umami", "keyword_stacks": 3}}, "desc": "首次激活时+40风味并获得3层鲜美（不死之药）"}
			],
			"on_activate": [],
			"description": "【文本已修复】蓬莱之药。"
		},
		{
			"id": "hakurei_feast", "name": "博丽之宴", "name_cn": "博丽之宴",
			"cuisine": "yakuzen", "tier": 3, "size": 3, "cooldown": 12.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["mastered", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"reduce_cooldown_adjacent": 0.3}, "desc": "激活时降低相邻料理30%冷却时间（博丽结界之力）"}
			],
			"on_activate": [],
			"description": "【文本已修复】博丽之宴。"
		},
		{
			"id": "philosopher_stone_dish", "name": "贤者之石膳", "name_cn": "贤者之石膳",
			"cuisine": "yakuzen", "tier": 3, "size": 3, "cooldown": 11.0,
			"flavor": 20, "mod_slots": 2,
			"tags": ["mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"accumulate": {"counter_id": "philosopher_transmute", "increment": 1, "threshold": 2, "reset_counter": true, "on_threshold": {"flavor": 50}}}, "desc": "每激活2次，贤者炼成爆发+50风味"}
			],
			"on_activate": [],
			"description": "【文本已修复】贤者之石膳。"
		},
		{
			"id": "lunar_capital_banquet", "name": "月都盛宴", "name_cn": "月都盛宴",
			"cuisine": "yakuzen", "tier": 3, "size": 3, "cooldown": 12.0,
			"flavor": 22, "mod_slots": 2,
			"tags": ["mastered", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "umami", "stacks": 5}, "then": {"flavor_mult": 2.5}, "else": {"add_keyword": "umami", "keyword_stacks": 3}}, "desc": "鲜美>=5时风味x2.5，否则获得3层鲜美（月都极致盛宴）"}
			],
			"on_activate": [],
			"description": "【文本已修复】月都盛宴。"
		},
	]


