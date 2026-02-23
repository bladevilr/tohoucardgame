extends RefCounted
class_name ChuukaPool

## 中華カード・プール (Chinese Cuisine)
## 使用者: 妖梦 / 美鈴 / パチュリー
## 設計方針: 旺火速攻流 — 短CD快速輪転 / 中華菜互相加速 / 猛火連鎖
## キーワード生成: umami, rich

static func get_dishes() -> Array:
	return [
		# ===== BRONZE (Tier 0) — 速攻引擎 =====
		{
			"id": "chahan", "name": "蛋炒饭", "name_cn": "蛋炒饭",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 6, "mod_slots": 2,
			"tags": ["rice", "stir_fried", "egg"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "reduce_cooldown_adjacent": 1.0}, "desc": "获得2层提味，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "大火翻炒的粒粒分明蛋炒饭，镬气十足。"
		},
		{
			"id": "gyoza", "name": "煎饺", "name_cn": "煎饺",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 5, "mod_slots": 2,
			"tags": ["meat", "fried", "rich"],
			"triggers": [
				{"event": "adjacent_activate",
				 "effect": {"add_keyword": "umami", "keyword_stacks": 3, "accumulate": {"counter_id": "gyoza_steam", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 20}}},
				 "desc": "相邻菜品激活时获得3层提味；每3次触发，爆发20美味度"}
			],
			"on_activate": [],
			"description": "底部煎至金黄的薄皮饺子，肉汁丰盈。"
		},
		{
			"id": "mapo_tofu", "name": "麻婆豆腐", "name_cn": "麻婆豆腐",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 4.0,
			"flavor": 8, "mod_slots": 2,
			"tags": ["vegetable", "spicy", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 5, "reduce_cooldown_adjacent": 1.0}, "desc": "获得5层提味，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "花椒与辣椒交织的麻辣豆腐，下饭利器。"
		},
		{
			"id": "xiaolongbao", "name": "小笼包", "name_cn": "小笼包",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 6, "mod_slots": 2,
			"tags": ["meat", "steamed", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 8, "extra": {"add_keyword": "umami", "keyword_stacks": 3}}, "desc": "首次激活美味度+8并获得3层提味"},
				{"event": "adjacent_activate", "effect": {"reduce_cooldown_self": 1.0}, "desc": "相邻菜品激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "轻咬一口汤汁涌出的精巧小笼包。"
		},
		{
			"id": "congee", "name": "白粥", "name_cn": "白粥",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 4, "mod_slots": 2,
			"tags": ["rice", "light", "staple"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "stat_bonus", "flavor": 6}, "reduce_cooldown_adjacent": 1.0}, "desc": "清除2层油腻→每层+3美味度；相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "米粒熬至绵软的白粥，温润养胃。"
		},
		{
			"id": "baozi", "name": "肉包子", "name_cn": "肉包子",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["meat", "steamed"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 3, "if_position": "leftmost", "then": {"flavor": 5, "add_keyword": "aftertaste", "keyword_stacks": 1}, "else": {}}, "desc": "获得3层提味；若在最左侧，额外+5美味度和1层回味"}
			],
			"on_activate": [],
			"description": "厚皮大馅的手工肉包子，蒸汽腾腾。"
		},
		{
			"id": "hotpot_base", "name": "火锅底料", "name_cn": "火锅底料",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 6, "mod_slots": 2,
			"tags": ["spicy", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "reduce_cooldown_adjacent": 1.0, "chain_right": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 2}}}, "desc": "获得2层提味，相邻CD-1秒，向右传2层提味"}
			],
			"on_activate": [],
			"description": "麻辣翻滚的红油火锅底料。"
		},
		{
			"id": "scallion_pancake", "name": "葱油饼", "name_cn": "葱油饼",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.0,
			"flavor": 5, "mod_slots": 2,
			"tags": ["fried", "staple", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"convert_keyword": {"from": "greasy", "to": "umami", "ratio": 1.0}, "add_keyword": "umami", "keyword_stacks": 2}, "desc": "将油腻转化为提味（1:1）；额外获得2层提味"}
			],
			"on_activate": [],
			"description": "层层酥脆的葱油饼，葱香扑鼻。"
		},
		{
			"id": "wonton_soup", "name": "馄饨汤", "name_cn": "馄饨汤",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 3.5,
			"flavor": 6, "mod_slots": 2,
			"tags": ["meat", "soup", "light"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 3, "clear_environment": "taste_fatigue", "clear_amount": 1}, "desc": "获得3层提味，清除1层疲劳"}
			],
			"on_activate": [],
			"description": "薄皮大馅浮于清汤中的馄饨。"
		},
		{
			"id": "youtiao", "name": "油条", "name_cn": "油条",
			"cuisine": "chuuka", "tier": 0, "size": 1, "cooldown": 2.5,
			"flavor": 4, "mod_slots": 2,
			"tags": ["fried", "staple", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2}, "desc": "获得2层提味"},
				{"event": "friend_activate", "effect": {"reduce_cooldown_self": 1.0}, "desc": "己方其他菜品激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "炸至金黄蓬松的油条，外脆内空。"
		},

		# ===== SILVER (Tier 1) — 猛火连锁 =====
		{
			"id": "kung_pao_chicken", "name": "宫保鸡丁", "name_cn": "宫保鸡丁",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["meat", "stir_fried", "spicy"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "accumulate": {"counter_id": "kungpao_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 30, "haste_adjacent": 1.0, "haste_mult": 2.0}}}, "desc": "获得2层提味；每3次爆发+30美味度并相邻加速1秒"}
			],
			"on_activate": [],
			"description": "花生与辣椒爆炒的鸡丁，麻辣鲜香。"
		},
		{
			"id": "sweet_sour_pork", "name": "糖醋排骨", "name_cn": "糖醋排骨",
			"cuisine": "chuuka", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["meat", "fried", "sweet", "sour", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "plating", "keyword_stacks": 3, "add_keyword_2": "umami", "keyword_stacks_2": 3, "random_chance": 0.25, "on_success": {"flavor_mult": 1.5}}, "desc": "获得3层增色和3层提味；25%概率美味度×1.5"}
			],
			"on_activate": [],
			"description": "外酥内嫩裹满糖醋汁的排骨。"
		},
		{
			"id": "dan_dan_noodles", "name": "担担面", "name_cn": "担担面",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 9, "mod_slots": 2,
			"tags": ["noodle", "spicy", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 5, "reduce_cooldown_self": 1.0}, "desc": "获得5层提味，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "芝麻酱与红油交融的麻辣拌面。"
		},
		{
			"id": "char_siu", "name": "叉烧", "name_cn": "叉烧",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 5.5,
			"flavor": 10, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 4, "accumulate": {"counter_id": "charsiu_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 35, "reduce_cooldown_adjacent": 1.0}}}, "desc": "获得4层提味；每3次爆发+35美味度并相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "蜜汁腌制烤至焦红的广式叉烧。"
		},
		{
			"id": "spring_rolls", "name": "春卷", "name_cn": "春卷",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 4.0,
			"flavor": 7, "mod_slots": 2,
			"tags": ["vegetable", "fried"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"chain_right": {"range": 1, "effect": {"reduce_cooldown_self": 1.0}}, "random_chance": 0.3, "on_success": {"add_keyword": "plating", "keyword_stacks": 6}}, "desc": "加速右邻0.5秒；30%概率获得6层增色"},
				{"event": "friend_activate", "effect": {"reduce_cooldown_self": 1.0}, "desc": "己方其他菜品激活时，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "薄皮包裹蔬菜炸至酥脆的春卷。"
		},
		{
			"id": "niurou_mian", "name": "台式牛肉面", "name_cn": "台式牛肉面",
			"cuisine": "chuuka", "tier": 1, "size": 2, "cooldown": 5.5,
			"flavor": 10, "mod_slots": 2,
			"tags": ["noodle", "meat", "stewed", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 3, "flavor_mult": 1.2, "reduce_cooldown_adjacent": 1.0}, "desc": "获得3层提味，美味度×1.2，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "浓郁牛骨汤底配大块炖牛肉的面食。"
		},
		{
			"id": "maoxuewang", "name": "毛血旺", "name_cn": "毛血旺",
			"cuisine": "chuuka", "tier": 1, "size": 2, "cooldown": 6.0,
			"flavor": 11, "mod_slots": 2,
			"tags": ["meat", "spicy", "rich", "stewed"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 4, "add_environment": "greasy", "environment_stacks": 1, "if_keyword_gte": {"keyword": "umami", "stacks": 3}, "then": {"flavor_mult": 1.4}, "else": {}}, "desc": "获得4层提味+1层油腻；提味≥3时美味度×1.4"}
			],
			"on_activate": [],
			"description": "红油翻滚中的各式内脏与血旺。"
		},
		{
			"id": "xo_sauce_noodle", "name": "XO酱炒面", "name_cn": "XO酱炒面",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 4.5,
			"flavor": 8, "mod_slots": 2,
			"tags": ["noodle", "stir_fried", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "chain_right": {"range": 2, "effect": {"add_keyword": "umami", "keyword_stacks": 2}}, "reduce_cooldown_self": 1.0}, "desc": "获得2层提味，向右2格各传2层提味，自身CD-1秒"}
			],
			"on_activate": [],
			"description": "XO酱的鲜辣裹挟每一根炒面。"
		},
		{
			"id": "twice_cooked_pork", "name": "回锅肉", "name_cn": "回锅肉",
			"cuisine": "chuuka", "tier": 1, "size": 1, "cooldown": 5.0,
			"flavor": 10, "mod_slots": 2,
			"tags": ["meat", "stir_fried", "rich", "spicy"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 2, "convert_keyword": {"from": "greasy", "to": "umami", "ratio": 1.0}, "accumulate": {"counter_id": "huiguo_heat", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {"flavor": 30}}}, "desc": "获得2层提味；将油腻转提味；每3次爆发+30美味度"}
			],
			"on_activate": [],
			"description": "先煮后炒的五花肉片，肥而不腻。"
		},

		# ===== GOLD (Tier 2) — 大火爆发 =====
		{
			"id": "peking_duck", "name": "北京烤鸭", "name_cn": "北京烤鸭",
			"cuisine": "chuuka", "tier": 2, "size": 3, "cooldown": 8.0,
			"flavor": 18, "mod_slots": 2,
			"tags": ["meat", "grilled", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 20, "extra": {"add_keyword": "umami", "keyword_stacks": 6, "add_keyword_2": "plating", "keyword_stacks_2": 6}}, "desc": "首次激活美味度+20，获得6层提味和6层增色"},
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 4, "reduce_cooldown_adjacent": 1.0}, "desc": "获得4层提味，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "皮脆肉嫩的烤鸭卷饼，京城名菜。"
		},
		{
			"id": "dongpo_pork", "name": "东坡肉", "name_cn": "东坡肉",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 16, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 6, "flavor_mult": 1.3, "delayed_trigger": {"delay_ticks": 30, "effect": {"add_keyword": "aftertaste", "keyword_stacks": 2, "flavor": 15}}}, "desc": "获得6层提味，美味度×1.3；3秒后额外获得2层回味+15美味度"}
			],
			"on_activate": [],
			"description": "酱油慢炖至入口即化的方块五花肉。"
		},
		{
			"id": "wuxing_chaohe", "name": "五行干炒河粉", "name_cn": "五行干炒河粉",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["noodle", "stir_fried", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 4, "chain_right": {"range": 2, "effect": {"flavor": 5, "reduce_cooldown_self": 1.0}}}, "desc": "获得4层提味；右侧2格各+5美味度和CD-1秒"}
			],
			"on_activate": [],
			"description": "猛火爆炒的宽河粉，镬气逼人。"
		},
		{
			"id": "steamed_fish", "name": "清蒸鲈鱼", "name_cn": "清蒸鲈鱼",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 13, "mod_slots": 2,
			"tags": ["seafood", "steamed", "light", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 6, "add_keyword_2": "knife_work", "keyword_stacks_2": 2, "clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "gain_keyword", "keyword": "umami"}}, "desc": "获得6层提味和2层精技；清除2层油腻→获得提味"}
			],
			"on_activate": [],
			"description": "姜葱铺底、热油浇淋的清蒸鲈鱼。"
		},
		{
			"id": "dim_sum_platter", "name": "点心拼盘", "name_cn": "点心拼盘",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 6.0,
			"flavor": 12, "mod_slots": 2,
			"tags": ["steamed", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 15, "presentation": 10, "extra": {"reduce_cooldown_adjacent": 1.0}}, "desc": "首次激活美味度+15、卖相+10，相邻CD-1秒"}
			],
			"on_activate": [],
			"description": "虾饺烧卖叉烧包的精选点心拼盘。"
		},
		{
			"id": "shuizhu_yu", "name": "水煮鱼", "name_cn": "水煮鱼",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 6.5,
			"flavor": 15, "mod_slots": 2,
			"tags": ["seafood", "spicy", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 4, "reduce_cooldown_adjacent": 1.0, "add_environment": "greasy", "environment_stacks": 1, "slow": 1.0, "slow_mult": 0.5}, "desc": "获得4层提味，相邻CD-1秒，+1层油腻；减速对手1秒"}
			],
			"on_activate": [],
			"description": "麻辣红油中滚烫的嫩滑鱼片。"
		},
		{
			"id": "lion_head", "name": "红烧狮子头", "name_cn": "红烧狮子头",
			"cuisine": "chuuka", "tier": 2, "size": 2, "cooldown": 7.0,
			"flavor": 14, "mod_slots": 2,
			"tags": ["meat", "stewed", "rich", "umami_tag"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 6, "add_keyword_2": "aftertaste", "keyword_stacks_2": 1, "if_keyword_gte": {"keyword": "umami", "stacks": 3}, "then": {"flavor_mult": 1.3}, "else": {}}, "desc": "获得6层提味和1层回味；提味≥3时美味度×1.3"}
			],
			"on_activate": [],
			"description": "大肉丸在酱汤中炖至酥烂的经典淮扬菜。"
		},
		{
			"id": "mapo_eggplant", "name": "鱼香茄子", "name_cn": "鱼香茄子",
			"cuisine": "chuuka", "tier": 2, "size": 1, "cooldown": 5.5,
			"flavor": 12, "mod_slots": 2,
			"tags": ["vegetable", "stir_fried", "rich", "spicy"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 5, "random_chance": 0.25, "on_success": {"flavor_mult": 2.0}}, "desc": "获得5层提味；25%概率美味度翻倍"}
			],
			"on_activate": [],
			"description": "鱼香酱汁烧制的软糯茄子。"
		},

		# ===== DIAMOND (Tier 3) — 中华极致 =====
		{
			"id": "buddha_jumps_wall", "name": "佛跳墙", "name_cn": "佛跳墙",
			"cuisine": "chuuka", "tier": 3, "size": 3, "cooldown": 12.0,
			"flavor": 24, "mod_slots": 2,
			"tags": ["seafood", "stewed", "rich", "umami_tag", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 9, "add_keyword_2": "aftertaste", "keyword_stacks_2": 2, "flavor_mult": 1.3, "haste_adjacent": 2.0, "haste_mult": 2.0}, "desc": "获得9层提味和2层回味，美味度×1.3；相邻加速2秒（×2）"}
			],
			"on_activate": [],
			"description": "集山珍海味于一坛，极尽奢华的滋补名菜。"
		},
		{
			"id": "manhan_quanxi", "name": "满汉全席", "name_cn": "满汉全席",
			"cuisine": "chuuka", "tier": 3, "size": 3, "cooldown": 14.0,
			"flavor": 20, "mod_slots": 2,
			"tags": ["mastered", "rich"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"type": "first_activate_bonus", "flavor": 30, "presentation": 20, "extra": {"add_keyword": "umami", "keyword_stacks": 9, "add_keyword_2": "plating", "keyword_stacks_2": 9, "haste_adjacent": 3.0, "haste_mult": 2.0}}, "desc": "首次激活美味度+30、卖相+20，获得9层提味和9层增色，相邻加速3秒"}
			],
			"on_activate": [],
			"description": "汇集百余道珍馐的宫廷盛宴。"
		},
		{
			"id": "dragon_phoenix_platter", "name": "龙凤呈祥", "name_cn": "龙凤呈祥",
			"cuisine": "chuuka", "tier": 3, "size": 3, "cooldown": 10.0,
			"flavor": 22, "mod_slots": 2,
			"tags": ["seafood", "meat", "rich", "mastered"],
			"triggers": [
				{"event": "item_activated", "condition": "self", "effect": {"add_keyword": "umami", "keyword_stacks": 12, "chain_right": {"range": 2, "effect": {"add_keyword": "umami", "keyword_stacks": 5}}, "slow": 2.0, "slow_mult": 0.5}, "desc": "获得12层提味；向右2格传递提味；减速对手2秒"}
			],
			"on_activate": [],
			"description": "龙虾与凤爪同盘的吉庆大菜。"
		},
	]
