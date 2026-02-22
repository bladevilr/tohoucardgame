extends RefCounted
class_name KanmiPool

## 甘味カード・プール (Sweets & Confections)
## 使用者: 咲夜 / アリス / 鈴仙
## 設計方針: 回味收割流 — 回味蓄積→後半指数爆発 / 清除負面→奨励 / 甜品催化器
## キーワード生成: plating, aftertaste, secret_recipe

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) — 回味引擎 =====
		{
			"id": "dango", "name": "团子", "name_cn": "团子",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "if_position": "rightmost", "then": {"add_keyword": "aftertaste", "keyword_stacks": 1}, "else": {}}, "desc": "获得1层摆盘；若在最右侧，额外获得1层回味"}
			],
			"on_activate": [],
			"description": "三色糯米团子串在竹签上，软糯清甜。"
		},
		{
			"id": "dorayaki", "name": "铜锣烧", "name_cn": "铜锣烧",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["sweet"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "clear_environment": "greasy", "clear_amount": 1, "bonus_on_clear": {"type": "gain_keyword", "keyword": "aftertaste"}}, "desc": "获得1层回味；清除1层油腻，成功时额外获得1层回味"}
			],
			"on_activate": [],
			"description": "两片铜锣饼夹住红豆馅的经典和菓子。"
		},
		{
			"id": "daifuku", "name": "大福", "name_cn": "大福",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "reduce_cooldown_adjacent": 1.0}, "desc": "获得1层回味，相邻CD-1秒"},
				{"event": "adjacent_activate", "condition": {"has_tag": "sweet"}, "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1}, "desc": "相邻甜品(甜味)激活时，获得1层回味"}
			],
			"on_activate": [],
			"description": "糯米皮包裹红豆沙的软糯大福。"
		},
		{
			"id": "mochi", "name": "年糕", "name_cn": "年糕",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 3, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "type": "stat_bonus", "presentation": 2}, "desc": "获得1层摆盘，卖相+2"},
				{"event": "friend_activate", "effect": {"reduce_cooldown_self": 1.0}, "desc": "己方其他菜品激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "捣打糯米制成的年糕，绵韧弹牙。"
		},
		{
			"id": "taiyaki_kanmi", "name": "鲷鱼烧", "name_cn": "鲷鱼烧",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["sweet", "grilled"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"random_chance": 0.3, "on_success": {"flavor_mult": 2.0, "add_keyword": "aftertaste", "keyword_stacks": 1}, "add_keyword": "char_aroma", "keyword_stacks": 1}, "desc": "获得1层焦香；30%概率风味翻倍并获得1层回味"}
			],
			"on_activate": [],
			"description": "鱼形的鲷鱼模具烤出的红豆馅饼。"
		},
		{
			"id": "anmitsu", "name": "蜜豆", "name_cn": "蜜豆",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "clear_environment": "taste_fatigue", "clear_amount": 1}, "desc": "获得1层摆盘；清除1层味觉疲劳"}
			],
			"on_activate": [],
			"description": "寒天冻配红豆与水果的清凉甜品。"
		},
		{
			"id": "yokan", "name": "羊羹", "name_cn": "羊羹",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "light", "tea"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "aftertaste"}, "add_keyword": "aftertaste", "keyword_stacks": 1}, "desc": "获得1层回味；清除2层油腻→每层获得回味"}
			],
			"on_activate": [],
			"description": "红豆与寒天凝固的细腻羊羹。"
		},
		{
			"id": "warabi_mochi", "name": "蕨饼", "name_cn": "蕨饼",
			"cuisine": "kanmi", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["sweet", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "chain_right": {"range": 1, "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1}}}, "desc": "获得1层回味，向右传1层回味"}
			],
			"on_activate": [],
			"description": "蕨粉制成的透明糕点，裹满黄豆粉。"
		},

		# ===== SILVER (Tier 1) — 催化+条件 =====
		{
			"id": "matcha_parfait", "name": "抹茶芭菲", "name_cn": "抹茶芭菲",
			"cuisine": "kanmi", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 8, "mod_slots": 2,
			"tags": ["sweet", "tea"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1, "clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "stat_bonus", "presentation": 5}}, "desc": "获得1层摆盘和1层回味；清除2层油腻→+5卖相"}
			],
			"on_activate": [],
			"description": "抹茶冰淇淋与白玉团子的层叠芭菲。"
		},
		{
			"id": "castella", "name": "长崎蛋糕", "name_cn": "长崎蛋糕",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 7, "mod_slots": 2,
			"tags": ["sweet", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "flavor_mult": 1.2, "reduce_cooldown_adjacent": 1.0}, "desc": "获得1层回味，风味×1.2，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "蜂蜜浸润的绵密长崎蛋糕。"
		},
		{
			"id": "sakura_mochi", "name": "樱饼", "name_cn": "樱饼",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["sweet", "seasonal", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 2, "type": "stat_bonus", "presentation": 5, "if_adjacent_has_tag": "sweet", "then_bonus": {"add_keyword": "aftertaste", "keyword_stacks": 1}}, "desc": "获得2层摆盘，卖相+5；若相邻有甜品(甜味)，额外获得1层回味"}
			],
			"on_activate": [],
			"description": "樱叶包裹的粉色糯米饼，春意盎然。"
		},
		{
			"id": "mille_crepe", "name": "千层蛋糕", "name_cn": "千层蛋糕",
			"cuisine": "kanmi", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["sweet", "mastered", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 10, "presentation": 5, "extra": {"add_keyword": "plating", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1}}, "desc": "首次激活风味+10、卖相+5，获得2层摆盘和1层回味"}
			],
			"on_activate": [],
			"description": "数十层薄饼与奶油交叠的千层蛋糕。"
		},
		{
			"id": "tsukimi_dango", "name": "赏月团子", "name_cn": "赏月团子",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 6, "mod_slots": 2,
			"tags": ["sweet", "seasonal", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1, "if_keyword_gte": {"keyword": "aftertaste", "stacks": 3}, "then": {"flavor": 10}, "else": {}}, "desc": "获得1层摆盘和1层回味；回味≥3时额外+10风味"}
			],
			"on_activate": [],
			"description": "月夜下供奉的白色圆月团子。"
		},
		{
			"id": "purin", "name": "布丁", "name_cn": "布丁",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["sweet", "egg", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "delayed_trigger": {"delay_ticks": 15, "effect": {"add_keyword": "aftertaste", "keyword_stacks": 2, "flavor": 8}}}, "desc": "获得1层回味；1.5秒后额外获得2层回味和+8风味"}
			],
			"on_activate": [],
			"description": "焦糖覆顶的丝滑日式布丁。"
		},
		{
			"id": "crepe", "name": "可丽饼", "name_cn": "可丽饼",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 3.5,
			"flavor": 6, "mod_slots": 2,
			"tags": ["sweet"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1, "reduce_cooldown_self": 1.0}, "desc": "获得1层摆盘，自身CD-1秒"},
				{"event": "adjacent_activate", "condition": {"has_tag": "sweet"}, "effect": {"add_keyword": "plating", "keyword_stacks": 1}, "desc": "相邻甜品(甜味)激活时，获得1层摆盘"}
			],
			"on_activate": [],
			"description": "薄饼卷裹鲜奶油与水果的街头甜品。"
		},
		{
			"id": "doll_cookie_set", "name": "人偶饼干套装", "name_cn": "人偶饼干套装",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "presentation": 8, "extra": {"add_keyword": "plating", "keyword_stacks": 2}}, "desc": "首次激活卖相+8，获得2层摆盘"},
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 1}, "desc": "获得1层摆盘"}
			],
			"on_activate": [],
			"description": "精心造型的人偶形状手工饼干。"
		},
		{
			"id": "chestnut_kinton", "name": "栗金团", "name_cn": "栗金团",
			"cuisine": "kanmi", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["sweet", "seasonal"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 2, "accumulate": {"counter_id": "kinton_layers", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 20, "add_keyword": "secret_recipe", "keyword_stacks": 1}}}, "desc": "获得2层回味；每3次爆发+20风味并获得1层秘方"}
			],
			"on_activate": [],
			"description": "秋栗捣成的金黄甜泥，浓郁甘甜。"
		},

		# ===== GOLD (Tier 2) — 回味引爆 =====
		{
			"id": "wagashi_assort", "name": "上生菓子拼盘", "name_cn": "上生菓子拼盘",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 12, "mod_slots": 2,
			"tags": ["sweet", "seasonal", "mastered", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "presentation": 15, "extra": {"add_keyword": "plating", "keyword_stacks": 3, "add_keyword_2": "aftertaste", "keyword_stacks_2": 2}}, "desc": "首次激活卖相+15，获得3层摆盘和2层回味"}
			],
			"on_activate": [],
			"description": "匠人手制的季节生菓子拼盘。"
		},
		{
			"id": "opera_cake", "name": "歌剧院蛋糕", "name_cn": "歌剧院蛋糕",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["sweet", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1, "if_keyword_gte": {"keyword": "aftertaste", "stacks": 3}, "then": {"flavor_mult": 1.5}, "else": {"flavor_mult": 1.2}}, "desc": "获得2层摆盘和1层回味；回味≥3时风味×1.5，否则×1.2"}
			],
			"on_activate": [],
			"description": "巧克力与咖啡交织的多层法式蛋糕。"
		},
		{
			"id": "creme_brulee", "name": "焦糖布丁", "name_cn": "焦糖布丁",
			"cuisine": "kanmi", "tier": 2, "size": 1, "cooldown": 5.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["sweet", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 1, "accumulate": {"counter_id": "brulee_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 35, "add_keyword": "secret_recipe", "keyword_stacks": 1}}}, "desc": "获得1层回味；每3次爆发+35风味并获得1层秘方"}
			],
			"on_activate": [],
			"description": "炙烤糖壳下的丝滑香草蛋奶。"
		},
		{
			"id": "moon_cake_premium", "name": "月兔特制月饼", "name_cn": "月兔特制月饼",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 12, "mod_slots": 2,
			"tags": ["sweet", "seasonal", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 15, "extra": {"add_keyword": "aftertaste", "keyword_stacks": 3, "add_keyword_2": "secret_recipe", "keyword_stacks_2": 1}}, "desc": "首次激活风味+15，获得3层回味和1层秘方"}
			],
			"on_activate": [],
			"description": "月兔特制的精致月饼，馅料饱满。"
		},
		{
			"id": "strawberry_shortcake", "name": "草莓蛋糕", "name_cn": "草莓蛋糕",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["sweet", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 2, "type": "stat_bonus", "presentation": 5, "chain_right": {"range": 1, "effect": {"add_keyword": "plating", "keyword_stacks": 1}}}, "desc": "获得2层摆盘，卖相+5，向右传1层摆盘"}
			],
			"on_activate": [],
			"description": "鲜草莓与轻奶油的日式蛋糕。"
		},
		{
			"id": "mont_blanc", "name": "蒙布朗", "name_cn": "蒙布朗",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 12, "mod_slots": 2,
			"tags": ["sweet", "mastered", "seasonal"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 2, "if_keyword_gte": {"keyword": "aftertaste", "stacks": 4}, "then": {"flavor_mult": 1.5, "add_keyword": "secret_recipe", "keyword_stacks": 1}, "else": {"flavor_mult": 1.2}}, "desc": "获得2层回味；回味≥4时风味×1.5并获得秘方，否则×1.2"}
			],
			"on_activate": [],
			"description": "栗子奶油细丝堆成的优雅小山。"
		},
		{
			"id": "fruit_tart", "name": "水果挞", "name_cn": "水果挞",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 2, "add_keyword_2": "knife_work", "keyword_stacks_2": 1, "reduce_cooldown_adjacent": 1.0}, "desc": "获得2层摆盘和1层刀工，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "酥脆塔壳上排列的新鲜水果宝石。"
		},
		{
			"id": "tiramisu", "name": "提拉米苏", "name_cn": "提拉米苏",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 13, "mod_slots": 2,
			"tags": ["sweet", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 2, "delayed_trigger": {"delay_ticks": 20, "effect": {"add_keyword": "aftertaste", "keyword_stacks": 3, "flavor": 15}}}, "desc": "获得2层回味；2秒后额外获得3层回味和+15风味"}
			],
			"on_activate": [],
			"description": "咖啡酒浸手指饼与马斯卡彭的意式经典。"
		},
		{
			"id": "macaron_tower", "name": "马卡龙塔", "name_cn": "马卡龙塔",
			"cuisine": "kanmi", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "presentation": 12, "extra": {"add_keyword": "plating", "keyword_stacks": 3}}, "desc": "首次激活卖相+12，获得3层摆盘"},
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "plating", "stacks": 5}, "then": {"presentation_mult": 1.3}, "else": {}}, "desc": "摆盘≥5层时卖相×1.3"}
			],
			"on_activate": [],
			"description": "五彩马卡龙堆叠成的华丽糖塔。"
		},

		# ===== DIAMOND (Tier 3) — 回味终极引爆 =====
		{
			"id": "piece_montee", "name": "糖艺塔", "name_cn": "糖艺塔",
			"cuisine": "kanmi", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 3, "type": "first_activate_bonus", "presentation": 25, "extra": {"add_keyword": "aftertaste", "keyword_stacks": 2}}, "desc": "首次激活卖相+25，获得3层摆盘和2层回味"},
				{"event": "item_activated", "condition": "self", "effect": {"if_keyword_gte": {"keyword": "plating", "stacks": 5}, "then": {"presentation_mult": 1.5}, "else": {}}, "desc": "摆盘≥5层时卖相×1.5"}
			],
			"on_activate": [],
			"description": "拉糖工艺打造的甜蜜建筑。"
		},
		{
			"id": "phantasm_parfait", "name": "幻想乡芭菲", "name_cn": "幻想乡芭菲",
			"cuisine": "kanmi", "tier": 3, "size": 3, "cooldown": 11.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["sweet", "mastered", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 3, "add_keyword_2": "aftertaste", "keyword_stacks_2": 3, "if_keyword_gte": {"keyword": "aftertaste", "stacks": 5}, "then": {"flavor_mult": 2.0, "add_keyword_2": "secret_recipe", "keyword_stacks_2": 1}, "else": {"flavor_mult": 1.3}}, "desc": "获得3层摆盘和3层回味；回味≥5时风味×2.0并获得秘方，否则×1.3"}
			],
			"on_activate": [],
			"description": "融合幻想乡风味的梦幻芭菲。"
		},
		{
			"id": "hourai_elixir_sweet", "name": "蓬莱药膳甜品", "name_cn": "蓬莱药膳甜品",
			"cuisine": "kanmi", "tier": 3, "size": 2, "cooldown": 9.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 25, "presentation": 15, "extra": {"add_keyword": "aftertaste", "keyword_stacks": 3, "add_keyword_2": "secret_recipe", "keyword_stacks_2": 1, "haste_adjacent": 2.0, "haste_mult": 2.0}}, "desc": "首次激活风味+25、卖相+15，获得3层回味和1层秘方，相邻加速2秒"}
			],
			"on_activate": [],
			"description": "据说能延年益寿的蓬莱药膳甜品。"
		},
		{
			"id": "sakuya_time_dessert", "name": "时之结晶", "name_cn": "时之结晶",
			"cuisine": "kanmi", "tier": 3, "size": 2, "cooldown": 9.5,
			"flavor": 15, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "aftertaste", "keyword_stacks": 3, "haste_adjacent": 2.0, "haste_mult": 2.0, "reduce_cooldown_adjacent": 1.0}, "desc": "获得3层回味，相邻加速2秒（×2），相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "时间凝结成的水晶般剔透甜品。"
		},
		{
			"id": "alice_doll_cake", "name": "人偶之梦", "name_cn": "人偶之梦",
			"cuisine": "kanmi", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["sweet", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 3, "add_keyword_2": "aftertaste", "keyword_stacks_2": 3, "chain_right": {"range": 2, "effect": {"add_keyword": "plating", "keyword_stacks": 2, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1}}, "reduce_cooldown_adjacent": 1.0}, "desc": "获得3层摆盘和3层回味；向右2格传2层摆盘+1层回味；相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "以人偶为主题的精致多层蛋糕。"
		},
	]
