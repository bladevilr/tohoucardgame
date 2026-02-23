extends Node

## 预置对手档案库 — 离线"玩家"对手池
## 模拟大巴扎的异步 PvP：对手为预配置的 AI 存档，显示玩家风格的昵称和 ID

const _OPPONENTS: Array = [
	{"display_name": "八云紫#0001",      "chef_id": "patchouli", "difficulty": 3, "rating": 1850,
	 "title": "幻想乡真正的管理者",      "cuisine_hint": "洋食+中华·五行联动"},
	{"display_name": "西行妖幽幽子#0777","chef_id": "alice",     "difficulty": 3, "rating": 1720,
	 "title": "冥界的饕餮盛宴",          "cuisine_hint": "洋食+甜品·卖相压制"},
	{"display_name": "古明地觉#1000",    "chef_id": "reisen",    "difficulty": 3, "rating": 1680,
	 "title": "读心料理人",              "cuisine_hint": "甜品+药膳·控场反制"},
	{"display_name": "比那名居天子#0001","chef_id": "meiling",   "difficulty": 2, "rating": 1520,
	 "title": "天界的豪华宴",            "cuisine_hint": "中华+夜市·提味爆发"},
	{"display_name": "十六夜咲夜#0016", "chef_id": "sakuya",    "difficulty": 2, "rating": 1450,
	 "title": "完全で瀟洒な料理",        "cuisine_hint": "洋食+甜品·大菜爆发"},
	{"display_name": "东风谷早苗#1024", "chef_id": "reimu",     "difficulty": 2, "rating": 1380,
	 "title": "现人神的奉纳料理",        "cuisine_hint": "和食+药膳·稳健运营"},
	{"display_name": "东方帕秋莉#4096", "chef_id": "patchouli", "difficulty": 2, "rating": 1350,
	 "title": "图书馆的禁断秘方",        "cuisine_hint": "洋食+中华·元素联动"},
	{"display_name": "魂魄妖梦#0010",   "chef_id": "youmu",     "difficulty": 2, "rating": 1290,
	 "title": "半人半灵的斩铁菜",        "cuisine_hint": "和食+洋食·高频小菜"},
	{"display_name": "雾雨魔理沙#3939", "chef_id": "marisa",    "difficulty": 1, "rating": 1150,
	 "title": "普通的魔法使料理",        "cuisine_hint": "夜市+药膳·随机爆发"},
	{"display_name": "铃仙优昙华院#2048","chef_id": "reisen",   "difficulty": 1, "rating": 1100,
	 "title": "月兔的清淡料理",          "cuisine_hint": "甜品+药膳·低风险入门"},
	{"display_name": "红美铃#0006",     "chef_id": "meiling",   "difficulty": 1, "rating": 1080,
	 "title": "红门卫的功夫菜",          "cuisine_hint": "中华+夜市·前期压制"},
	{"display_name": "射命丸文#7777",   "chef_id": "mystia",    "difficulty": 1, "rating": 1020,
	 "title": "速报：今日特餐",          "cuisine_hint": "夜市+和食·高频连打"},
]

func get_all() -> Array:
	return _OPPONENTS.duplicate(true)

func get_opponent_for_mode(mode: String, player_rating: int) -> Dictionary:
	var pool: Array = _OPPONENTS.duplicate(true)
	if mode == "ranked":
		pool.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return absi(int(a["rating"]) - player_rating) < absi(int(b["rating"]) - player_rating)
		)
		var candidates: Array = pool.slice(0, mini(4, pool.size()))
		candidates.shuffle()
		return candidates[0].duplicate(true)
	else:
		pool.shuffle()
		return pool[0].duplicate(true)
