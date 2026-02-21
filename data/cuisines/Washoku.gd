extends RefCounted
class_name WashokuPool

## 和食カード・プール (Traditional Japanese)
## 使用者: ミスティア / 妖梦 / 霊夢
## キーワード生成: knife_work, light, umami

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) — 基本和食 =====
		{
			"id": "onigiri", "name": "饭团", "name_cn": "饭团",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["rice", "light", "staple"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层刀工", "effect": {"add_keyword": "knife_work", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "饭团。"
		},
		{
			"id": "miso_shiru", "name": "味噌汤", "name_cn": "味噌汤",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 4.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["soup", "umami_tag", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美", "effect": {"add_keyword": "umami", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "味噌汤。"
		},
		{
			"id": "tamagoyaki", "name": "玉子烧", "name_cn": "玉子烧",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["egg", "light", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+8", "effect": {"type": "first_activate_bonus", "flavor": 8}}
			],
			"on_activate": [],
			"description": "玉子烧。"
		},
		{
			"id": "tsukemono", "name": "渍物", "name_cn": "渍物",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["vegetable", "light", "fermented"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层回味", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "渍物。"
		},
		{
			"id": "edamame", "name": "毛豆", "name_cn": "毛豆",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 2.5,
			"flavor": 3, "mod_slots": 2,
			"tags": ["vegetable", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "风味+3", "effect": {"type": "stat_bonus", "flavor": 3}}
			],
			"on_activate": [],
			"description": "毛豆。"
		},
		{
			"id": "hiyayakko", "name": "冷豆腐", "name_cn": "冷豆腐",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 2.5,
			"flavor": 3, "mod_slots": 2,
			"tags": ["vegetable", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层刀工", "effect": {"add_keyword": "knife_work", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "冷豆腐。"
		},
		{
			"id": "yakitori", "name": "烤鸡肉串", "name_cn": "烤鸡肉串",
			"cuisine": "washoku", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["meat", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "每3次激活爆发风味+25", "effect": {"accumulate": {"counter_id": "yakitori_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 25}}}}
			],
			"on_activate": [],
			"description": "烤鸡肉串。"
		},

		# ===== SILVER (Tier 1) — 定番和食 =====
		{
			"id": "sashimi_moriawase", "name": "刺身拼盘", "name_cn": "刺身拼盘",
			"cuisine": "washoku", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 12, "mod_slots": 2,
			"tags": ["seafood", "raw", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层刀工", "effect": {"add_keyword": "knife_work", "keyword_stacks": 2}}
			],
			"on_activate": [],
			"description": "刺身拼盘。"
		},
		{
			"id": "chawanmushi", "name": "茶碗蒸", "name_cn": "茶碗蒸",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["egg", "steamed", "umami_tag", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美，右邻也获得1层", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "chain_right": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 1}}}}
			],
			"on_activate": [],
			"description": "茶碗蒸。"
		},
		{
			"id": "yakizakana", "name": "烤鱼", "name_cn": "烤鱼",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 9, "mod_slots": 2,
			"tags": ["seafood", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "每3次激活爆发风味+30", "effect": {"accumulate": {"counter_id": "yakizakana_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 30}}}}
			],
			"on_activate": [],
			"description": "烤鱼。"
		},
		{
			"id": "nikujaga", "name": "肉土豆", "name_cn": "肉土豆",
			"cuisine": "washoku", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美、1层回味", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1}}
			],
			"on_activate": [],
			"description": "肉土豆。"
		},
		{
			"id": "tofu_dengaku", "name": "味噌烤豆腐", "name_cn": "味噌烤豆腐",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["vegetable", "grilled", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层焦香，右邻也获得1层", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "chain_right": {"range": 1, "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1}}}}
			],
			"on_activate": [],
			"description": "味噌烤豆腐。"
		},
		{
			"id": "nimono", "name": "煮物", "name_cn": "煮物",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["vegetable", "stewed", "light", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美，相邻CD-0.3秒", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "reduce_cooldown_adjacent": 0.3}}
			],
			"on_activate": [],
			"description": "煮物。"
		},
		{
			"id": "kitsune_udon", "name": "狐狸乌冬", "name_cn": "狐狸乌冬",
			"cuisine": "washoku", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 9, "mod_slots": 2,
			"tags": ["noodle", "umami_tag", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "风味x1.3", "effect": {"flavor_mult": 1.3}}
			],
			"on_activate": [],
			"description": "狐狸乌冬。"
		},
		{
			"id": "agedashi_tofu", "name": "炸出汁豆腐", "name_cn": "炸出汁豆腐",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["vegetable", "fried", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层鲜美", "effect": {"add_keyword": "umami", "keyword_stacks": 1}}
			],
			"on_activate": [],
			"description": "炸出汁豆腐。"
		},
		{
			"id": "takoyaki", "name": "章鱼烧", "name_cn": "章鱼烧",
			"cuisine": "washoku", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["seafood", "fried"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得1层摆盘，30%概率额外获得1层焦香", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "random_chance": 0.3, "on_success": {"add_keyword": "char_aroma", "keyword_stacks": 1}}}
			],
			"on_activate": [],
			"description": "章鱼烧。"
		},

		# ===== GOLD (Tier 2) — 料亭級 =====
		{
			"id": "tempura_moriawase", "name": "天妇罗拼盘", "name_cn": "天妇罗拼盘",
			"cuisine": "washoku", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 14, "mod_slots": 2,
			"tags": ["seafood", "fried", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+15、卖相+10", "effect": {"type": "first_activate_bonus", "flavor": 15, "presentation": 10}}
			],
			"on_activate": [],
			"description": "天妇罗拼盘。"
		},
		{
			"id": "unagi_kabayaki", "name": "蒲烧鳗鱼", "name_cn": "蒲烧鳗鱼",
			"cuisine": "washoku", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["seafood", "grilled", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美，每3次激活爆发风味+40", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "accumulate": {"counter_id": "unagi_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 40}}}}
			],
			"on_activate": [],
			"description": "蒲烧鳗鱼。"
		},
		{
			"id": "sukiyaki", "name": "寿喜烧", "name_cn": "寿喜烧",
			"cuisine": "washoku", "tier": 2, "size": 3, "cooldown": 8.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美、1层回味", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1}}
			],
			"on_activate": [],
			"description": "寿喜烧。"
		},
		{
			"id": "ochazuke", "name": "茶泡饭", "name_cn": "茶泡饭",
			"cuisine": "washoku", "tier": 2, "size": 1, "cooldown": 4.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["rice", "light", "tea"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "清除2层油腻，每层清除风味+5", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "stat_bonus", "flavor": 10}}}
			],
			"on_activate": [],
			"description": "茶泡饭。"
		},
		{
			"id": "soba_tsuyu", "name": "冷荞麦面", "name_cn": "冷荞麦面",
			"cuisine": "washoku", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["noodle", "light", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+12，获得1层刀工", "effect": {"type": "first_activate_bonus", "flavor": 12, "extra": {"add_keyword": "knife_work", "keyword_stacks": 1}}}
			],
			"on_activate": [],
			"description": "冷荞麦面。"
		},
		{
			"id": "kaisendon", "name": "海鲜盖饭", "name_cn": "海鲜盖饭",
			"cuisine": "washoku", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 13, "mod_slots": 2,
			"tags": ["seafood", "raw", "rice"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层刀工，卖相+5", "effect": {"add_keyword": "knife_work", "keyword_stacks": 2, "type": "stat_bonus", "presentation": 5}}
			],
			"on_activate": [],
			"description": "海鲜盖饭。"
		},
		{
			"id": "chanko_nabe", "name": "相扑火锅", "name_cn": "相扑火锅",
			"cuisine": "washoku", "tier": 2, "size": 3, "cooldown": 7.5,
			"flavor": 15, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美，风味x1.2", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "flavor_mult": 1.2}}
			],
			"on_activate": [],
			"description": "相扑火锅。"
		},
		{
			"id": "katsudon", "name": "炸猪排盖饭", "name_cn": "炸猪排盖饭",
			"cuisine": "washoku", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["meat", "fried", "rice", "rich"],
			"triggers": [],
			"on_activate": [],
			"description": "炸猪排盖饭。"
		},

		# ===== DIAMOND (Tier 3) — 极致和食 =====
		{
			"id": "kaiseki_hassun", "name": "怀石八寸", "name_cn": "怀石八寸",
			"cuisine": "washoku", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 20, "mod_slots": 2,
			"tags": ["seasonal", "mastered", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活卖相+20，获得3层摆盘", "effect": {"type": "first_activate_bonus", "presentation": 20, "extra": {"add_keyword": "plating", "keyword_stacks": 3}}}
			],
			"on_activate": [],
			"description": "怀石八寸。"
		},
		{
			"id": "fugu_course", "name": "河豚全席", "name_cn": "河豚全席",
			"cuisine": "washoku", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 22, "mod_slots": 2,
			"tags": ["seafood", "raw", "mastered", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "首次激活风味+25，获得3层刀工", "effect": {"type": "first_activate_bonus", "flavor": 25, "extra": {"add_keyword": "knife_work", "keyword_stacks": 3}}}
			],
			"on_activate": [],
			"description": "河豚全席。"
		},
		{
			"id": "tai_no_sugata", "name": "鲷鱼姿造", "name_cn": "鲷鱼姿造",
			"cuisine": "washoku", "tier": 3, "size": 3, "cooldown": 9.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["seafood", "raw", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得3层刀工，卖相+15", "effect": {"add_keyword": "knife_work", "keyword_stacks": 3, "type": "stat_bonus", "presentation": 15}}
			],
			"on_activate": [],
			"description": "鲷鱼姿造。"
		},
		{
			"id": "osechi_jubako", "name": "御节料理重箱", "name_cn": "御节料理重箱",
			"cuisine": "washoku", "tier": 3, "size": 3, "cooldown": 12.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["seasonal", "mastered", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得2层鲜美、2层摆盘", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "add_keyword_2": "plating", "keyword_stacks_2": 2}}
			],
			"on_activate": [],
			"description": "御节料理重箱。"
		},
		{
			"id": "matsutake_dobin", "name": "松茸土瓶蒸", "name_cn": "松茸土瓶蒸",
			"cuisine": "washoku", "tier": 3, "size": 2, "cooldown": 9.0,
			"flavor": 19, "mod_slots": 2,
			"tags": ["seasonal", "steamed", "umami_tag", "light", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "desc": "获得3层鲜美，风味x1.3", "effect": {"add_keyword": "umami", "keyword_stacks": 3, "flavor_mult": 1.3}}
			],
			"on_activate": [],
			"description": "松茸土瓶蒸。"
		},
	]
