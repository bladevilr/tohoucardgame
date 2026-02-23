extends RefCounted
class_name YataiPool

## 屋台カード・プール (Street Stall / Grill)
## 使用者: ミスティア / 美鈴 / 魔理沙
## 設計方針: 爆香連鎖エンジン — 提味蓄積→閾値爆発 / 油膩双刃剣 / 隣接加速
## キーワード生成: umami, greasy

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) — 引擎型小菜 =====
		{
			"id": "yatai_yakitori", "name": "烤鸡串", "name_cn": "烤鸡串",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 2.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["meat", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "accumulate": {"counter_id": "sizzle_yatai_yakitori", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 25, "reduce_cooldown_adjacent": 1.0}}}, "desc": "获得2层提味；每激活3次，爆发25美味度并加速相邻0.5秒"}
			],
			"on_activate": [],
			"description": "酱汁反复刷涂的炭烤鸡肉串。"
		},
		{
			"id": "yaki_tomorokoshi", "name": "烤玉米", "name_cn": "烤玉米",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["vegetable", "grilled"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"add_keyword": "umami", "keyword_stacks": 2,
					"chain_right": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 2}}
				},
				"desc": "获得2层提味，并向右传递2层提味"
			}],
			"on_activate": [],
			"description": "刷满酱油的炭烤甜玉米，提味诱人。"
		},
		{
			"id": "yatai_takoyaki", "name": "章鱼烧", "name_cn": "章鱼烧",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["seafood", "grilled"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"add_keyword": "umami", "keyword_stacks": 2,
					"random_chance": 0.35,
					"on_success": {"add_keyword": "plating", "keyword_stacks": 3, "reduce_cooldown_self": 1.0}
				},
				"desc": "获得2层提味；35%概率额外获得3层增色并自身CD-1秒"
			}],
			"on_activate": [],
			"description": "外酥内软的章鱼烧，撒满柴鱼花。"
		},
		{
			"id": "ikayaki", "name": "烤鱿鱼", "name_cn": "烤鱿鱼",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["seafood", "grilled"],
			"triggers": [
				{
					"event": "item_activated", "condition": "self",
					"effect": {
						"add_keyword": "umami", "keyword_stacks": 2,
						"if_adjacent_has_tag": "grilled",
						"then_bonus": {"reduce_cooldown_self": 1.0}
					},
					"desc": "获得2层提味；若相邻有烤物，自身CD-1秒"
				},
				{
					"event": "adjacent_activate",
					"effect": {"add_keyword": "umami", "keyword_stacks": 2},
					"desc": "相邻菜品激活时，获得2层提味"
				}
			],
			"on_activate": [],
			"description": "整条鱿鱼刷酱在铁板上烤至卷曲。"
		},
		{
			"id": "yaki_imo", "name": "烤红薯", "name_cn": "烤红薯",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["vegetable", "grilled", "sweet"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"add_keyword": "aftertaste", "keyword_stacks": 1,
					"delayed_trigger": {
						"delay_ticks": 20,
						"effect": {"add_keyword": "aftertaste", "keyword_stacks": 2, "flavor": 8}
					}
				},
				"desc": "获得1层回味；2秒后额外获得2层回味和8美味度"
			}],
			"on_activate": [],
			"description": "炭火慢烤的红薯，甜蜜绵软。"
		},
		{
			"id": "hashimaki", "name": "筷卷", "name_cn": "筷卷",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 2.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["fried", "staple"],
			"triggers": [
				{
					"event": "item_activated", "condition": "self",
					"effect": {
						"copy_adjacent_keyword": {"target": "left", "keyword": "any", "stacks": 1}
					},
					"desc": "复制左侧料理的1层关键词"
				},
				{
					"event": "adjacent_activate",
					"effect": {"reduce_cooldown_self": 1.0},
					"desc": "相邻菜品激活时，自身CD-1秒"
				}
			],
			"on_activate": [],
			"description": "用筷子卷起的铁板烧面糊卷。"
		},
		{
			"id": "yaki_onigiri", "name": "烤饭团", "name_cn": "烤饭团",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["rice", "grilled"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"add_keyword": "umami", "keyword_stacks": 2,
					"if_position": "leftmost",
					"then": {"add_keyword": "umami", "keyword_stacks": 3, "flavor": 5},
					"else": {}
				},
				"desc": "获得2层提味；若在最左侧，额外获得3层提味和5美味度"
			}],
			"on_activate": [],
			"description": "酱油刷面烤出焦壳的三角饭团。"
		},
		{
			"id": "taiyaki", "name": "鲷鱼烧", "name_cn": "鲷鱼烧",
			"cuisine": "yatai", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["sweet", "grilled"],
			"triggers": [{
				"event": "item_activated", "condition": "self",
				"effect": {
					"if_keyword_gte": {"keyword": "umami", "stacks": 4},
					"then": {"type": "consume_keyword", "keyword": "umami", "stacks": 4, "per_stack_bonus": {"presentation": 4}},
					"else": {"add_keyword": "umami", "keyword_stacks": 2}
				},
				"desc": "若提味≥4层，消耗4层提味并每层+4卖相；否则获得2层提味"
			}],
			"on_activate": [],
			"description": "鲷鱼形状的铜板烧红豆饼。"
		},

		# ===== SILVER (Tier 1) — 条件加成 + CD操控 =====
		{
			"id": "yatai_ramen", "name": "夜市拉面", "name_cn": "夜市拉面",
			"cuisine": "yatai", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 10, "mod_slots": 2,
			"tags": ["noodle", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 5, "reduce_cooldown_adjacent": 1.0}, "desc": "获得5层提味，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "深夜屋台飘来的浓郁豚骨拉面香。"
		},
		{
			"id": "kushikatsu", "name": "炸串", "name_cn": "炸串",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["meat", "fried", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "accumulate": {"counter_id": "fry_kushikatsu", "increment": 1, "threshold": 2, "reset_counter": true, "on_threshold": {"add_environment": "greasy", "environment_stacks": 1, "flavor": 15}}}, "desc": "获得2层提味；每激活2次，获得15美味度但添加1层油腻"}
			],
			"on_activate": [],
			"description": "裹面包糠炸至金黄的一口炸串。"
		},
		{
			"id": "okonomiyaki", "name": "大阪烧", "name_cn": "大阪烧",
			"cuisine": "yatai", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 9, "mod_slots": 2,
			"tags": ["seafood", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "if_adjacent_has_tag": "grilled", "then_bonus": {"flavor": 10, "add_keyword": "plating", "keyword_stacks": 3}}, "desc": "获得2层提味；若相邻有夜市(烧烤)，额外+10美味度和3层增色"}
			],
			"on_activate": [],
			"description": "海鲜蔬菜面糊煎成的铁板大阪烧。"
		},
		{
			"id": "grilled_lamprey", "name": "烤八目鳗", "name_cn": "烤八目鳗",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 9, "mod_slots": 2,
			"tags": ["seafood", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "chain_right": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 3}}, "chain_left": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 2}}}, "desc": "获得2层提味，向右传3层提味，向左传2层提味"}
			],
			"on_activate": [],
			"description": "炭火炙烤的八目鳗，肉质紧实提味。"
		},
		{
			"id": "teppan_yasai", "name": "铁板烤蔬菜", "name_cn": "铁板烤蔬菜",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["vegetable", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}, "reduce_cooldown_adjacent": 1.0}, "desc": "清除2层油腻，成功时获得提味；相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "铁板高温快烤的新鲜时蔬。"
		},
		{
			"id": "monjayaki", "name": "文字烧", "name_cn": "文字烧",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["grilled", "seafood"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"random_chance": 0.4, "on_success": {"flavor_mult": 1.5, "add_keyword": "umami", "keyword_stacks": 2}}, "desc": "40%概率美味度×1.5并获得2层提味"}
			],
			"on_activate": [],
			"description": "半熟黏稠的东京风铁板烧。"
		},
		{
			"id": "karaage", "name": "炸鸡", "name_cn": "炸鸡",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["meat", "fried", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 4, "add_environment": "greasy", "environment_stacks": 1, "reduce_cooldown_self": 1.0}, "desc": "获得4层提味和1层油腻环境；自身CD-1秒"}
			],
			"on_activate": [],
			"description": "炸至外酥内嫩多汁的日式炸鸡块。"
		},
		{
			"id": "yakisoba", "name": "日式炒面", "name_cn": "日式炒面",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["noodle", "stir_fried"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "stat_bonus", "flavor": 15}, "add_keyword": "umami", "keyword_stacks": 2}, "desc": "获得2层提味；清除2层油腻，成功时+15美味度"}
			],
			"on_activate": [],
			"description": "浓厚酱汁炒制的日式铁板炒面。"
		},
		{
			"id": "negima", "name": "葱鸡串", "name_cn": "葱鸡串",
			"cuisine": "yatai", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["meat", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "if_adjacent_has_tag": "grilled", "then_bonus": {"flavor": 10, "reduce_cooldown_self": 1.0}}, "desc": "获得2层提味；若相邻有夜市(烧烤)，+10美味度并自身CD-1秒"},
				{"event": "adjacent_activate", "condition": {"has_tag": "grilled"}, "effect": {"reduce_cooldown_self": 1.0}, "desc": "相邻夜市(烧烤)激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "鸡肉与大葱交替串烤的经典串物。"
		},

		# ===== GOLD (Tier 2) — 阈值引爆 + 环境处理 =====
		{
			"id": "motsunabe", "name": "内脏锅", "name_cn": "内脏锅",
			"cuisine": "yatai", "tier": 2, "size": 3, "cooldown": 7.0,
			"flavor": 15, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 25, "extra": {"add_keyword": "umami", "keyword_stacks": 8}}, "desc": "首次激活获得25美味度、8层提味"},
				{"event": "item_activated", "condition": "self", "effect": {"convert_keyword": {"from": "greasy", "to": "umami", "ratio": 1.0}}, "desc": "每次激活将油腻转化为提味"}
			],
			"on_activate": [],
			"description": "内脏与蔬菜在味噌汤中翻滚的博多名锅。"
		},
		{
			"id": "robatayaki_moriawase", "name": "炉端烧拼盘", "name_cn": "炉端烧拼盘",
			"cuisine": "yatai", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 14, "mod_slots": 2,
			"tags": ["seafood", "grilled", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 4, "chain_right": {"range": 2, "effect": {"add_keyword": "umami", "keyword_stacks": 2}}, "reduce_cooldown_adjacent": 1.0}, "desc": "获得4层提味，向右2格各传2层提味，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "炉端炭火慢烤的海鲜拼盘。"
		},
		{
			"id": "jingisukan", "name": "成吉思汗烤肉", "name_cn": "成吉思汗烤肉",
			"cuisine": "yatai", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["meat", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 4, "add_environment": "greasy", "environment_stacks": 1, "if_keyword_gte": {"keyword": "umami", "stacks": 8}, "then": {"flavor_mult": 1.5}, "else": {}}, "desc": "获得4层提味和1层油腻；若提味≥8层，美味度×1.5"}
			],
			"on_activate": [],
			"description": "北海道名物，铁帽烤架上的鲜嫩羊肉。"
		},
		{
			"id": "kinoko_hoiru", "name": "锡纸烤蘑菇", "name_cn": "锡纸烤蘑菇",
			"cuisine": "yatai", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["vegetable", "grilled", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 6, "reduce_cooldown_adjacent": 1.0}, "desc": "获得6层提味，相邻CD-1秒"},
				{"event": "adjacent_activate", "effect": {"add_keyword": "umami", "keyword_stacks": 3}, "desc": "相邻菜品激活时，获得3层提味"}
			],
			"on_activate": [],
			"description": "锡纸包裹的菌菇在炭火上慢蒸。"
		},
		{
			"id": "wagyu_steak", "name": "和牛牛排", "name_cn": "和牛牛排",
			"cuisine": "yatai", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "umami", "stacks": 6}, "then": {"flavor_mult": 1.8, "add_keyword": "plating", "keyword_stacks": 6}, "else": {"add_keyword": "umami", "keyword_stacks": 4}}, "desc": "若提味≥6层，美味度×1.8并获得6层增色；否则获得4层提味"}
			],
			"on_activate": [],
			"description": "大理石纹路的和牛在铁板上滋滋作响。"
		},
		{
			"id": "hiroshima_yaki", "name": "广岛烧", "name_cn": "广岛烧",
			"cuisine": "yatai", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 13, "mod_slots": 2,
			"tags": ["noodle", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"accumulate": {"counter_id": "hiroshima_layers", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 40, "add_keyword": "umami", "keyword_stacks": 4, "haste_adjacent": 1.5, "haste_mult": 2.0}}}, "desc": "每激活3次，爆发40美味度、4层提味，相邻加速1.5秒"}
			],
			"on_activate": [],
			"description": "面条蛋饼蔬菜层层叠放的广岛烧。"
		},
		{
			"id": "horumon_yaki", "name": "烤内脏", "name_cn": "烤内脏",
			"cuisine": "yatai", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"convert_keyword": {"from": "greasy", "to": "umami", "ratio": 1.0}, "add_keyword": "umami", "keyword_stacks": 2}, "desc": "将油腻转化为提味（1:1），额外获得2层提味"}
			],
			"on_activate": [],
			"description": "炭火炙烤的牛内脏，越嚼越香。"
		},
		{
			"id": "tsukune", "name": "鸡肉丸串", "name_cn": "鸡肉丸串",
			"cuisine": "yatai", "tier": 2, "size": 1, "cooldown": 5.5,
			"flavor": 12, "mod_slots": 2,
			"tags": ["meat", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 4, "if_adjacent_has_tag": "grilled", "then_bonus": {"flavor": 12, "reduce_cooldown_adjacent": 1.0}}, "desc": "获得4层提味；若相邻有夜市(烧烤)，+12美味度并相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "手打鸡肉泥捏成的串烤丸子。"
		},
		{
			"id": "sanma_shioyaki", "name": "盐烤秋刀鱼", "name_cn": "盐烤秋刀鱼",
			"cuisine": "yatai", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 13, "mod_slots": 2,
			"tags": ["seafood", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}, "add_keyword": "umami", "keyword_stacks": 2, "if_position": "rightmost", "then": {"flavor": 15}, "else": {}}, "desc": "获得2层提味；清除2层油腻→获得提味；最右侧时额外+15美味度"}
			],
			"on_activate": [],
			"description": "撒粗盐炭烤的肥美秋刀鱼。"
		},

		# ===== DIAMOND (Tier 3) — 多条件引爆器 =====
		{
			"id": "sparrow_night_feast", "name": "夜雀之宴", "name_cn": "夜雀之宴",
			"cuisine": "yatai", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 22, "mod_slots": 2,
			"tags": ["seafood", "grilled", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 50, "extra": {"add_keyword": "umami", "keyword_stacks": 12}}, "desc": "首次激活获得50美味度、12层提味"},
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "umami", "stacks": 8}, "then": {"flavor_mult": 1.5, "reduce_cooldown_adjacent": 1.0}, "else": {}}, "desc": "提味≥8层时美味度×1.5并相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "夜雀屋台的秘传炭烤海鲜盛宴。"
		},
		{
			"id": "teppanyaki_course", "name": "铁板烧全席", "name_cn": "铁板烧全席",
			"cuisine": "yatai", "tier": 3, "size": 3, "cooldown": 11.0,
			"flavor": 20, "mod_slots": 2,
			"tags": ["meat", "seafood", "grilled", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 6, "chain_right": {"range": 2, "effect": {"add_keyword": "umami", "keyword_stacks": 4}}, "haste_adjacent": 2.0, "haste_mult": 2.0}, "desc": "获得6层提味，向右2格各传4层提味，相邻加速2秒（×2）"}
			],
			"on_activate": [],
			"description": "主厨在铁板前现场表演的烤物全席。"
		},
		{
			"id": "magma_grill", "name": "岩浆烧烤", "name_cn": "岩浆烧烤",
			"cuisine": "yatai", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 24, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "umami", "stacks": 10}, "then": {"flavor_mult": 2.5, "chain_right": {"range": 2, "effect": {"add_keyword": "umami", "keyword_stacks": 4}}, "slow": 2.0, "slow_mult": 0.5}, "else": {"add_keyword": "umami", "keyword_stacks": 6, "add_environment": "greasy", "environment_stacks": 1}}, "desc": "提味≥10层：美味度×2.5，右传4层提味，减速对手2秒；否则+6层提味+1层油腻"}
			],
			"on_activate": [],
			"description": "以灼热岩石为热源的极致烧烤。"
		},
		{
			"id": "phoenix_rebirth_skewer", "name": "不死鸟之串", "name_cn": "不死鸟之串",
			"cuisine": "yatai", "tier": 3, "size": 2, "cooldown": 9.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["meat", "grilled", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"accumulate": {"counter_id": "phoenix_rebirth", "increment": 1, "threshold": 2, "reset_counter": true, "on_threshold": {"flavor": 60, "add_keyword": "umami", "keyword_stacks": 6, "reduce_cooldown_adjacent": 1.0}}}, "desc": "每激活2次，爆发60美味度、6层提味并相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "炭火中涅槃重生的传说之串。"
		},
		{
			"id": "mystia_secret_grill", "name": "米斯蒂娅的秘传烧烤", "name_cn": "米斯蒂娅的秘传烧烤",
			"cuisine": "yatai", "tier": 3, "size": 3, "cooldown": 10.5,
			"flavor": 21, "mod_slots": 2,
			"tags": ["seafood", "grilled", "mastered", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 15, "reduce_cooldown_adjacent": 1.0, "slow": 1.5, "slow_mult": 0.5}, "desc": "获得15层提味，相邻CD-1秒，减速对手1.5秒"}
			],
			"on_activate": [],
			"description": "米斯蒂娅独创的秘制酱烤海鲜。"
		},
		{
			"id": "meiling_wok_fire", "name": "美铃的火焰锅", "name_cn": "美铃的火焰锅",
			"cuisine": "yatai", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 23, "mod_slots": 2,
			"tags": ["meat", "stir_fried", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 5, "bonus_on_clear": {"type": "stat_bonus", "flavor": 50}, "add_keyword": "umami", "keyword_stacks": 6, "haste_adjacent": 2.0, "haste_mult": 2.0}, "desc": "获得6层提味；清除5层油腻→+50美味度；相邻加速2秒（×2）"}
			],
			"on_activate": [],
			"description": "美铃以中华锅技驾驭的火焰炒菜。"
		},
	]
