extends RefCounted
class_name KanmiPool

## 甘味カード・プール (Sweets & Confections)
## 使用者: 咲夜 / アリス / 鈴仙
## キーワード生成: plating, aftertaste, light

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) =====
		{
			"id": "dango", "name": "团子", "name_cn": "团子",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1}, "desc": "获得1层摆盘"}],
			"on_activate": [],
			"description": "【文本已修复】团子。"
		},
		{
			"id": "dorayaki", "name": "铜锣烧", "name_cn": "铜锣烧",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["sweet"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "stat_bonus", "flavor": 3}, "desc": "风味+3"}],
			"on_activate": [],
			"description": "【文本已修复】铜锣烧。"
		},
		{
			"id": "daifuku", "name": "大福", "name_cn": "大福",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1}, "desc": "获得1层回味"}],
			"on_activate": [],
			"description": "【文本已修复】大福。"
		},
		{
			"id": "mochi", "name": "年糕", "name_cn": "年糕",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 3, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "stat_bonus", "presentation": 2}, "desc": "卖相+2"}],
			"on_activate": [],
			"description": "【文本已修复】年糕。"
		},
		{
			"id": "taiyaki", "name": "鲷鱼烧", "name_cn": "鲷鱼烧",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["sweet", "fried"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"random_chance": 0.2, "on_success": {"flavor_mult": 2.0}}, "desc": "20%概率风味翻倍"}],
			"on_activate": [],
			"description": "【文本已修复】鲷鱼烧。"
		},
		{
			"id": "anmitsu", "name": "蜜豆", "name_cn": "蜜豆",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1}, "desc": "获得1层摆盘"}],
			"on_activate": [],
			"description": "【文本已修复】蜜豆。"
		},
		{
			"id": "yokan", "name": "羊羹", "name_cn": "羊羹",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "light", "tea"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 1}, "desc": "清除1层油腻"}],
			"on_activate": [],
			"description": "【文本已修复】羊羹。"
		},
		{
			"id": "warabi_mochi", "name": "蕨饼", "name_cn": "蕨饼",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1}, "desc": "获得1层回味"}],
			"on_activate": [],
			"description": "【文本已修复】蕨饼。"
		},

		# ===== SILVER (Tier 1) =====
		{
			"id": "matcha_parfait", "name": "抹茶芭菲", "name_cn": "抹茶芭菲",
			"cuisine": "kanmi", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 8, "mod_slots": 2,
			"tags": ["sweet", "tea", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "clear_environment": "greasy", "clear_amount": 1}, "desc": "获得1层摆盘，清除1层油腻"}],
			"on_activate": [],
			"description": "【文本已修复】抹茶芭菲。"
		},
		{
			"id": "castella", "name": "长崎蛋糕", "name_cn": "长崎蛋糕",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["sweet", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "flavor_mult": 1.2}, "desc": "获得1层回味，风味x1.2"}],
			"on_activate": [],
			"description": "【文本已修复】长崎蛋糕。"
		},
		{
			"id": "sakura_mochi", "name": "樱饼", "name_cn": "樱饼",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["sweet", "seasonal", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "type": "stat_bonus", "presentation": 5}, "desc": "获得1层摆盘，卖相+5"}],
			"on_activate": [],
			"description": "【文本已修复】樱饼。"
		},
		{
			"id": "mille_crepe", "name": "千层蛋糕", "name_cn": "千层蛋糕",
			"cuisine": "kanmi", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 10, "presentation": 5}, "desc": "首次激活风味+10、卖相+5"}],
			"on_activate": [],
			"description": "【文本已修复】千层蛋糕。"
		},
		{
			"id": "tsukimi_dango", "name": "赏月团子", "name_cn": "赏月团子",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 6, "mod_slots": 2,
			"tags": ["sweet", "seasonal", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1}, "desc": "获得1层摆盘、1层回味"}],
			"on_activate": [],
			"description": "【文本已修复】赏月团子。"
		},
		{
			"id": "purin", "name": "布丁", "name_cn": "布丁",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["sweet", "egg", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "random_chance": 0.25, "on_success": {"flavor_mult": 1.5}}, "desc": "获得1层回味，25%概率风味x1.5"}],
			"on_activate": [],
			"description": "【文本已修复】布丁。"
		},
		{
			"id": "crepe", "name": "可丽饼", "name_cn": "可丽饼",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 3.5,
			"flavor": 6, "mod_slots": 2,
			"tags": ["sweet"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1}, "desc": "获得1层摆盘"}],
			"on_activate": [],
			"description": "【文本已修复】可丽饼。"
		},
		{
			"id": "doll_cookie_set", "name": "人偶饼干套装", "name_cn": "人偶饼干套装",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "presentation": 8}, "desc": "首次激活卖相+8"}],
			"on_activate": [],
			"description": "【文本已修复】人偶饼干套装。"
		},
		{
			"id": "chestnut_kinton", "name": "栗金团", "name_cn": "栗金团",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["sweet", "seasonal"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "type": "stat_bonus", "flavor": 5}, "desc": "获得1层回味，风味+5"}],
			"on_activate": [],
			"description": "【文本已修复】栗金团。"
		},

		# ===== GOLD (Tier 2) =====
		{
			"id": "wagashi_assort", "name": "上生菓子拼盘", "name_cn": "上生菓子拼盘",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 12, "mod_slots": 2,
			"tags": ["sweet", "seasonal", "mastered", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "presentation": 15, "extra": {"add_keyword": "plating", "keyword_stacks": 2}}, "desc": "首次激活卖相+15，获得2层摆盘"}],
			"on_activate": [],
			"description": "【文本已修复】上生菓子拼盘。"
		},
		{
			"id": "opera_cake", "name": "歌剧院蛋糕", "name_cn": "歌剧院蛋糕",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["sweet", "rich", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 2, "flavor_mult": 1.3}, "desc": "获得2层摆盘，风味x1.3"}],
			"on_activate": [],
			"description": "【文本已修复】歌剧院蛋糕。"
		},
		{
			"id": "creme_brulee", "name": "焦糖布丁", "name_cn": "焦糖布丁",
			"cuisine": "kanmi", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["sweet", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"accumulate": {"counter_id": "brulee_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 35}}}, "desc": "每3次激活爆发风味+35"}],
			"on_activate": [],
			"description": "【文本已修复】焦糖布丁。"
		},
		{
			"id": "moon_cake_premium", "name": "月兔特制月饼", "name_cn": "月兔特制月饼",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 12, "mod_slots": 2,
			"tags": ["sweet", "seasonal", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 15, "extra": {"add_keyword": "aftertaste", "keyword_stacks": 2}}, "desc": "首次激活风味+15，获得2层回味"}],
			"on_activate": [],
			"description": "【文本已修复】月兔特制月饼。"
		},
		{
			"id": "strawberry_shortcake", "name": "草莓蛋糕", "name_cn": "草莓蛋糕",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 2, "type": "stat_bonus", "presentation": 5}, "desc": "获得2层摆盘，卖相+5"}],
			"on_activate": [],
			"description": "【文本已修复】草莓蛋糕。"
		},
		{
			"id": "mont_blanc", "name": "蒙布朗", "name_cn": "蒙布朗",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 12, "mod_slots": 2,
			"tags": ["sweet", "mastered", "seasonal"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 2, "flavor_mult": 1.2}, "desc": "获得2层回味，风味x1.2"}],
			"on_activate": [],
			"description": "【文本已修复】蒙布朗。"
		},
		{
			"id": "fruit_tart", "name": "水果挞", "name_cn": "水果挞",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 2, "add_keyword_2": "knife_work", "keyword_stacks_2": 1}, "desc": "获得2层摆盘、1层刀工"}],
			"on_activate": [],
			"description": "【文本已修复】水果挞。"
		},
		{
			"id": "tiramisu", "name": "提拉米苏", "name_cn": "提拉米苏",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 13, "mod_slots": 2,
			"tags": ["sweet", "rich"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 2, "random_chance": 0.25, "on_success": {"flavor_mult": 1.5}}, "desc": "获得2层回味，25%概率风味x1.5"}],
			"on_activate": [],
			"description": "【文本已修复】提拉米苏。"
		},
		{
			"id": "macaron_tower", "name": "马卡龙塔", "name_cn": "马卡龙塔",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "presentation": 12, "extra": {"add_keyword": "plating", "keyword_stacks": 2}}, "desc": "首次激活卖相+12，获得2层摆盘"}],
			"on_activate": [],
			"description": "【文本已修复】马卡龙塔。"
		},

		# ===== DIAMOND (Tier 3) =====
		{
			"id": "piece_montee", "name": "糖艺塔", "name_cn": "糖艺塔",
			"cuisine": "kanmi", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 3, "type": "first_activate_bonus", "presentation": 25}, "desc": "获得3层摆盘，首次激活卖相+25"}],
			"on_activate": [],
			"description": "【文本已修复】糖艺塔。"
		},
		{
			"id": "phantasm_parfait", "name": "幻想乡芭菲", "name_cn": "幻想乡芭菲",
			"cuisine": "kanmi", "tier": 3, "size": 3, "cooldown": 11.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["sweet", "mastered", "light"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 3, "add_keyword_2": "aftertaste", "keyword_stacks_2": 2, "flavor_mult": 1.3}, "desc": "获得3层摆盘、2层回味，风味x1.3"}],
			"on_activate": [],
			"description": "【文本已修复】幻想乡芭菲。"
		},
		{
			"id": "hourai_elixir_sweet", "name": "蓬莱药膳甜点", "name_cn": "蓬莱药膳甜点",
			"cuisine": "kanmi", "tier": 3, "size": 2, "cooldown": 9.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 25, "presentation": 15}, "desc": "首次激活风味+25、卖相+15"}],
			"on_activate": [],
			"description": "【文本已修复】蓬莱药膳甜点。"
		},
		{
			"id": "sakuya_time_dessert", "name": "时之结晶", "name_cn": "时之结晶",
			"cuisine": "kanmi", "tier": 3, "size": 2, "cooldown": 9.5,
			"flavor": 15, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 3, "reduce_cooldown_adjacent": 0.5}, "desc": "获得3层回味，相邻CD-0.5秒"}],
			"on_activate": [],
			"description": "【文本已修复】时之结晶。"
		},
		{
			"id": "alice_doll_cake", "name": "人偶之梦", "name_cn": "人偶之梦",
			"cuisine": "kanmi", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 3, "add_keyword_2": "aftertaste", "keyword_stacks_2": 3}, "desc": "获得3层摆盘、3层回味"}],
			"on_activate": [],
			"description": "【文本已修复】人偶之梦。"
		},
	]

