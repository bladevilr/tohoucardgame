extends RefCounted
class_name YataiPool

## 屋台カード・プー�?(Street Stall / Grill)
## 使用�? ミスティ�?/ 美鈴 / 魔理�?
## キーワード生�? char_aroma, greasy, burst

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) =====
		{
			"id": "yatai_yakitori", "name": "烤鸡串", "name_cn": "烤鸡串",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 2.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["meat", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"accumulate": {"counter_id": "sizzle_yatai_yakitori", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 30}}}, "desc": "每激活3次，获得30风味"}
			],
			"on_activate": [],
			"description": "烤鸡串。"
		},
		{
			"id": "yaki_tomorokoshi", "name": "烤玉米", "name_cn": "烤玉米",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["vegetable", "grilled"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"add_keyword": "char_aroma", "keyword_stacks": 1,
					"chain_right": {"range": 1, "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1}}
				},
				"desc": "获得1层焦香，并向右传递1层焦香"
			}],
			"on_activate": [],
			"description": "烤玉米。"
		},
		{
			"id": "yatai_takoyaki", "name": "章鱼烧", "name_cn": "章鱼烧",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["seafood", "grilled"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"add_keyword": "char_aroma", "keyword_stacks": 1,
					"random_chance": 0.3,
					"on_success": {"add_keyword": "plating", "keyword_stacks": 1}
				},
				"desc": "获得1层焦香，30%概率额外获得1层摆盘"
			}],
			"on_activate": [],
			"description": "章鱼烧。"
		},
		{
			"id": "ikayaki", "name": "烤鱿鱼", "name_cn": "烤鱿鱼",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["seafood", "grilled"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"add_keyword": "char_aroma", "keyword_stacks": 1,
					"if_adjacent_has_tag": "yatai",
					"then_bonus": {"reduce_cooldown_self": 0.3}
				},
				"desc": "获得1层焦香；若相邻有夜市菜品，减少0.3秒冷却"
			}],
			"on_activate": [],
			"description": "烤鱿鱼。"
		},
		{
			"id": "yaki_imo", "name": "烤红薯", "name_cn": "烤红薯",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["vegetable", "grilled", "sweet"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"accumulate": {
						"counter_id": "sweetness",
						"increment": 1,
						"threshold": 2,
						"on_threshold": {"add_keyword": "aftertaste", "keyword_stacks": 3, "reset_counter": true}
					}
				},
				"desc": "每激活2次，获得3层回味"
			}],
			"on_activate": [],
			"description": "烤红薯。"
		},
		{
			"id": "hashimaki", "name": "筷卷", "name_cn": "筷卷",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 2.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["fried", "staple"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"copy_adjacent_keyword": {
						"target": "left",
						"keyword": "any",
						"stacks": 1
					}
				},
				"desc": "复制左侧料理的1层关键词"
			}],
			"on_activate": [],
			"description": "筷卷。"
		},
		{
			"id": "yaki_onigiri", "name": "烤饭团", "name_cn": "烤饭团",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["rice", "grilled"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"add_keyword": "char_aroma", "keyword_stacks": 1,
					"if_position": "leftmost",
					"then_bonus": {"add_keyword": "umami", "keyword_stacks": 1}
				},
				"desc": "获得1层焦香；若在最左侧，额外获得1层鲜美"
			}],
			"on_activate": [],
			"description": "烤饭团。"
		},
		{
			"id": "taiyaki", "name": "鲷鱼烧", "name_cn": "鲷鱼烧",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["sweet", "grilled"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"if_keyword_gte": {"keyword": "char_aroma", "stacks": 2},
					"then": {"consume_keyword": "char_aroma", "per_stack_presentation_bonus": 3.0},
					"else": {"add_keyword": "char_aroma", "keyword_stacks": 1}
				},
				"desc": "若焦香≥2层，消耗焦香并每层+3摆盘；否则获得1层焦香"
			}],
			"on_activate": [],
			"description": "鲷鱼烧。"
		},

		# ===== SILVER (Tier 1) =====
		{
			"id": "yatai_ramen", "name": "夜市拉面", "name_cn": "夜市拉面",
			"cuisine": "yatai", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 10, "mod_slots": 2,
			"tags": ["noodle", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 1, "add_keyword_2": "char_aroma", "keyword_stacks_2": 1}, "desc": "获得1层鲜美和1层焦香"}
			],
			"on_activate": [],
			"description": "夜市拉面。"
		},
		{
			"id": "kushikatsu", "name": "炸串", "name_cn": "炸串",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["meat", "fried", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "accumulate": {"counter_id": "fry_kushikatsu", "increment": 1, "threshold": 2, "reset_counter": true, "on_threshold": {"add_environment": "greasy", "environment_stacks": 1}}}, "desc": "获得1层焦香；每激活2次，添加1层油腻环境"}
			],
			"on_activate": [],
			"description": "炸串。"
		},
		{
			"id": "okonomiyaki", "name": "大阪烧", "name_cn": "大阪烧",
			"cuisine": "yatai", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 9, "mod_slots": 2,
			"tags": ["seafood", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "stat_bonus", "flavor": 8, "technique": 5}, "desc": "获得8风味和5技巧加成"}
			],
			"on_activate": [],
			"description": "大阪烧。"
		},
		{
			"id": "grilled_lamprey", "name": "烤八目鳗", "name_cn": "烤八目鳗",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 9, "mod_slots": 2,
			"tags": ["seafood", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "chain_right": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 1}}}, "desc": "获得1层焦香，并向右传递1层鲜美"}
			],
			"on_activate": [],
			"description": "烤八目鳗。"
		},
		{
			"id": "teppan_yasai", "name": "铁板烤蔬菜", "name_cn": "铁板烤蔬菜",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["vegetable", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 1, "bonus_on_clear": {"type": "gain_keyword", "keyword": "char_aroma"}}, "desc": "清除1层油腻环境，成功时获得焦香"}
			],
			"on_activate": [],
			"description": "铁板烤蔬菜。"
		},
		{
			"id": "monjayaki", "name": "文字烧", "name_cn": "文字烧",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["grilled", "seafood"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"random_chance": 0.4, "on_success": {"flavor_mult": 1.5}}, "desc": "40%概率风味×1.5"}
			],
			"on_activate": [],
			"description": "文字烧。"
		},
		{
			"id": "karaage", "name": "炸鸡", "name_cn": "炸鸡",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["meat", "fried", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1, "add_environment": "greasy", "environment_stacks": 1}, "desc": "获得1层焦香，添加1层油腻环境"}
			],
			"on_activate": [],
			"description": "炸鸡。"
		},
		{
			"id": "yakisoba", "name": "日式炒面", "name_cn": "日式炒面",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["noodle", "stir_fried"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "stat_bonus", "flavor": 15}}, "desc": "清除2层油腻环境，成功时获得15风味加成"}
			],
			"on_activate": [],
			"description": "日式炒面。"
		},
		{
			"id": "negima", "name": "葱鸡串", "name_cn": "葱鸡串",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["meat", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_adjacent_has_tag": "grilled", "then_bonus": {"type": "stat_bonus", "flavor": 10}}, "desc": "若相邻有烤物，获得10风味加成"}
			],
			"on_activate": [],
			"description": "葱鸡串。"
		},

		# ===== GOLD (Tier 2) =====
		{
			"id": "motsunabe", "name": "内脏锅", "name_cn": "内脏锅",
			"cuisine": "yatai", "tier": 2, "size": 3, "cooldown": 7.0,
			"flavor": 15, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 25, "extra": {"add_keyword": "umami", "keyword_stacks": 2}}, "desc": "首次激活获得25风味和2层鲜美"}
			],
			"on_activate": [],
			"description": "内脏锅。"
		},
		{
			"id": "robatayaki_moriawase", "name": "炉端烧拼盘", "name_cn": "炉端烧拼盘",
			"cuisine": "yatai", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 14, "mod_slots": 2,
			"tags": ["seafood", "grilled", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 2, "chain_right": {"range": 1, "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1}}}, "desc": "获得2层焦香，并向右传递1层焦香"}
			],
			"on_activate": [],
			"description": "炉端烧拼盘。"
		},
		{
			"id": "jingisukan", "name": "成吉思汗烤肉", "name_cn": "成吉思汗烤肉",
			"cuisine": "yatai", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["meat", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 2, "add_environment": "greasy", "environment_stacks": 1}, "desc": "获得2层焦香，添加1层油腻环境"}
			],
			"on_activate": [],
			"description": "成吉思汗烤肉。"
		},
		{
			"id": "kinoko_hoiru", "name": "锡纸烤蘑菇", "name_cn": "锡纸烤蘑菇",
			"cuisine": "yatai", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["vegetable", "grilled", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "reduce_cooldown_adjacent": 0.3}, "desc": "获得2层鲜美，减少相邻料理0.3秒冷却"}
			],
			"on_activate": [],
			"description": "锡纸烤蘑菇。"
		},
		{
			"id": "wagyu_steak", "name": "和牛牛排", "name_cn": "和牛牛排",
			"cuisine": "yatai", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "char_aroma", "stacks": 3}, "then": {"flavor_mult": 1.6}, "else": {"add_keyword": "char_aroma", "keyword_stacks": 2}}, "desc": "若焦香≥3层，风味×1.6；否则获得2层焦香"}
			],
			"on_activate": [],
			"description": "和牛牛排。"
		},
		{
			"id": "hiroshima_yaki", "name": "广岛烧", "name_cn": "广岛烧",
			"cuisine": "yatai", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 13, "mod_slots": 2,
			"tags": ["noodle", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"accumulate": {"counter_id": "hiroshima_layers", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 40, "add_keyword": "char_aroma", "keyword_stacks": 2}}}, "desc": "每激活3次，获得40风味和2层焦香"}
			],
			"on_activate": [],
			"description": "广岛烧。"
		},
		{
			"id": "horumon_yaki", "name": "烤内脏", "name_cn": "烤内脏",
			"cuisine": "yatai", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"convert_keyword": {"from": "greasy", "to": "char_aroma", "ratio": 1.0}}, "desc": "将油腻转化为焦香（1:1比例）"}
			],
			"on_activate": [],
			"description": "烤内脏。"
		},
		{
			"id": "tsukune", "name": "鸡肉丸串", "name_cn": "鸡肉丸串",
			"cuisine": "yatai", "tier": 2, "size": 1, "cooldown": 5.5,
			"flavor": 12, "mod_slots": 2,
			"tags": ["meat", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 2, "if_adjacent_has_tag": "grilled", "then_bonus": {"type": "stat_bonus", "flavor": 12}}, "desc": "获得2层焦香；若相邻有烤物，额外获得12风味"}
			],
			"on_activate": [],
			"description": "鸡肉丸串。"
		},
		{
			"id": "sanma_shioyaki", "name": "盐烤秋刀鱼", "name_cn": "盐烤秋刀鱼",
			"cuisine": "yatai", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 13, "mod_slots": 2,
			"tags": ["seafood", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}}, "desc": "清除2层油腻环境，成功时获得鲜美"}
			],
			"on_activate": [],
			"description": "盐烤秋刀鱼。"
		},

		# ===== DIAMOND (Tier 3) =====
		{
			"id": "sparrow_night_feast", "name": "夜雀之宴", "name_cn": "夜雀之宴",
			"cuisine": "yatai", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 22, "mod_slots": 2,
			"tags": ["seafood", "grilled", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 50, "extra": {"add_keyword": "char_aroma", "keyword_stacks": 3, "add_keyword_2": "umami", "keyword_stacks_2": 2}}, "desc": "首次激活获得50风味、3层焦香和2层鲜美"}
			],
			"on_activate": [],
			"description": "夜雀之宴。"
		},
		{
			"id": "teppanyaki_course", "name": "铁板烧全席", "name_cn": "铁板烧全席",
			"cuisine": "yatai", "tier": 3, "size": 3, "cooldown": 11.0,
			"flavor": 20, "mod_slots": 2,
			"tags": ["meat", "seafood", "grilled", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 3, "chain_right": {"range": 1, "effect": {"add_keyword": "char_aroma", "keyword_stacks": 2}}}, "desc": "获得3层焦香，并向右传递2层焦香"}
			],
			"on_activate": [],
			"description": "铁板烧全席。"
		},
		{
			"id": "magma_grill", "name": "岩浆烧烤", "name_cn": "岩浆烧烤",
			"cuisine": "yatai", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 24, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "char_aroma", "stacks": 5}, "then": {"flavor_mult": 2.0}, "else": {"add_keyword": "char_aroma", "keyword_stacks": 3}}, "desc": "若焦香≥5层，风味×2.0；否则获得3层焦香"}
			],
			"on_activate": [],
			"description": "岩浆烧烤。"
		},
		{
			"id": "phoenix_rebirth_skewer", "name": "不死鸟之串", "name_cn": "不死鸟之串",
			"cuisine": "yatai", "tier": 3, "size": 2, "cooldown": 9.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["meat", "grilled", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"accumulate": {"counter_id": "phoenix_rebirth", "increment": 1, "threshold": 2, "reset_counter": true, "on_threshold": {"flavor": 60, "add_keyword": "char_aroma", "keyword_stacks": 3}}}, "desc": "每激活2次，获得60风味和3层焦香"}
			],
			"on_activate": [],
			"description": "不死鸟之串。"
		},
		{
			"id": "mystia_secret_grill", "name": "米斯蒂娅的秘传烧烤", "name_cn": "米斯蒂娅的秘传烧烤",
			"cuisine": "yatai", "tier": 3, "size": 3, "cooldown": 10.5,
			"flavor": 21, "mod_slots": 2,
			"tags": ["seafood", "grilled", "mastered", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "char_aroma", "keyword_stacks": 3, "add_keyword_2": "umami", "keyword_stacks_2": 3, "reduce_cooldown_adjacent": 0.5}, "desc": "获得3层焦香和3层鲜美，减少相邻料理0.5秒冷却"}
			],
			"on_activate": [],
			"description": "米斯蒂娅的秘传烧烤。"
		},
		{
			"id": "meiling_wok_fire", "name": "美铃的火焰锅", "name_cn": "美铃的火焰锅",
			"cuisine": "yatai", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 23, "mod_slots": 2,
			"tags": ["meat", "stir_fried", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 3, "bonus_on_clear": {"type": "stat_bonus", "flavor": 40}, "add_keyword": "char_aroma", "keyword_stacks": 3}, "desc": "获得3层焦香；清除3层油腻环境，成功时获得40风味"}
			],
			"on_activate": [],
			"description": "美铃的火焰锅。"
		},
	]

