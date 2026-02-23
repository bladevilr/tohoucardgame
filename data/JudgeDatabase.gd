extends Node

var judges: Dictionary = {}
func _ready():
	_init_judges()

func _init_judges():
	# ===== 西行寺幽幽子 =====
	# 亡灵公主 · 无底胃 · 暴食
	_add("yuyuko", "西行寺幽幽子",
		{flavor_mult=1.5},
		"无底胃袋",
		{keyword_bonus_tags=["umami"], keyword_bonus_mult=0.50},
		"「再来十份！」——亡灵公主的无底胃袋让美味度评分×1.5。提味在她舌尖绽放，「提味」关键词效果+50%。",
		"白玉楼的主人，永远吃不饱的优雅亡灵。")

	# ===== 饕餮尤魔 =====
	# 饕餮 · 吞食一切
	_add("yuuma", "饕餮尤魔",
		{flavor_mult=1.2, aroma_cap=0.40},
		"饕餮品鉴",
		{tag_bonus="rich", tag_bonus_attr="flavor", tag_bonus_value=0.15},
		"「吞噬即是存在的意义。」——饕餮的本能让风味×1.2，但香气上限40%。浓郁厚重的味道才能满足她，「浓郁」标签菜品风味+15%。",
		"畜生界的支配者，吞食一切的饕餮化身。")

	# ===== 四季映姬 =====
	# 阎魔 · 裁决善恶
	_add("eiki", "四季映姬",
		{technique_mult=1.5},
		"天秤裁定",
		{score_diff_threshold=0.10, both_bonus=0.30},
		"「善恶自有天秤裁定。」——阎魔的公正让技巧评分×1.5。若双方势均力敌(分差<10%)，则各获+30%加成——公平竞争才是美德。",
		"彼岸的最高裁判者，以绝对公正审判一切。")

	# ===== 射命丸文 =====
	# 天狗记者 · 追逐头条
	_add("aya", "射命丸文",
		{dot_mult=1.3},
		"独家头条",
		{highest_presentation_bonus_attr="flavor", highest_presentation_bonus_value=0.20},
		"「这可是独家头条！」——天狗记者的追逐让持续伤害×1.3。卖相最高的菜品额外获得20%风味——毕竟上镜最重要。",
		"妖怪之山的狗仔队长，永远在追逐下一个大新闻。")

	# ===== 八雲紫 =====
	# 境界妖怪 · 规则操控者
	_add("yukari", "八雲紫",
		{random_daily=true},
		"境界操作",
		{random_attr_boost=2.0, random_attr_penalty=0.5},
		"「境界是如此暧昧不清呢。」——妖怪贤者的兴致每日随机：一项属性×2.0，另一项×0.5。今天她想看什么表演？",
		"幻想乡的管理者，操纵一切境界的隙间妖怪。")

	# ===== 风见幽香 =====
	# 花妖怪 · 纯粹的力量
	_add("yuuka", "风见幽香",
		{dot_mult=1.5},
		"花之美学",
		{presentation_dot_crush_bonus=0.25},
		"「美丽之物，也需要力量守护。」——花之暴君让持续伤害×1.5。当卖相DoT形成碾压时，她会露出微笑：额外+25%。",
		"太阳花田的主人，以绝对力量诠释美学的妖怪。")

	# ===== 比那名居天子 =====
	# 天人 · 刁蛮的审美
	_add("tenshi", "比那名居天子",
		{flavor_mult=1.2, technique_mult=1.2},
		"天人之舌",
		{environment_debuff_bonus=0.50},
		"「无聊无聊，太无聊了！」——刁蛮天人的挑剔让风味×1.2，技巧×1.2。她最爱看人出丑，环境负面效果强度+50%。",
		"天界的问题儿童，以找乐子为生的任性天人。")

	# ===== 秦心 =====
	# 面灵气 · 读取内心
	_add("kokoro", "秦心",
		{dot_mult=1.3},
		"感情读取",
		{fusion_dish_bonus_attr="presentation", fusion_dish_bonus_value=0.25},
		"「你的内心，我全都看得见。」——面灵气读取厨师的情感，持续伤害×1.3。Fusion菜品承载的复杂情感让她着迷，卖相+25%。",
		"希望之面的付丧神，透过面具读取他人感情。")

	# ===== 蕾米莉亚 =====
	# 红魔馆大小姐 · 挑剔的贵族
	_add("remilia", "蕾米莉亚",
		{presentation_mult=1.5},
		"绯红晚餐",
		{light_tag_penalty=0.20, rich_tag_bonus_flavor=0.20},
		"「平民的食物可入不了本小姐的眼。」——吸血鬼的贵族品味让卖相评分×1.5。「清淡」？那是什么寒酸东西(-20%)。「浓郁」才配得上红魔馆(风味+20%)。",
		"红魔馆的主人，五百岁的傲娇吸血鬼大小姐。")

	# ===== 永江衣玖 =====
	# 龙宫使者 · 读空气达人
	_add("iku", "永江衣玖",
		{aroma_mult=1.4},
		"读空气",
		{env_debuff_penalty_reduction=0.50, per_cuisine_diversity_bonus=0.05},
		"「气氛...有些不对劲呢。」——龙宫使者敏锐地感知一切，香气×1.4。她化解紧张气氛(环境debuff效果减半)，欣赏多元文化(每多1种菜系+5%全属性)。",
		"龙宫的使者，能读懂任何场合气氛的优雅妖怪。")

	# ===== 丰聪耳神子 =====
	# 圣人 · 倾听十人之言
	_add("miko", "丰聪耳神子",
		{flavor_mult=1.1, presentation_mult=1.1, technique_mult=1.1},
		"和之圣德",
		{mastered_tag_bonus=0.15, harmony_bonus_threshold=3},
		"「吾能同时倾听十人之言。」——圣德太子的智慧让全属性×1.1。她赞赏精进修行(「精进」标签+15%)，崇尚和谐共存(3+种菜系时额外全属性+10%)。",
		"神灵庙的圣人，能同时倾听十人话语的古代皇子。")

	# ===== 堀川雷鼓 =====
	# 太鼓付丧神 · 节奏与速度
	_add("raiko", "堀川雷鼓",
		{},
		"黄昏节奏",
		{cd_reduction_global=0.10, activate_count_bonus=true, per_activate_bonus=0.02},
		"「跟上我的节奏！」——太鼓的鼓点加速一切，所有菜品CD-10%。随着激活次数增加，节奏越来越快：每次激活叠加+2%全属性(每道菜独立计算)。",
		"黄昏酒场的鼓手，以激烈节奏震撼全场的付丧神。")

func _add(id: String, display_name: String, scoring_mods: Dictionary, special_name: String, special_effect: Dictionary, desc: String, flavor_text: String):
	judges[id] = {
		"id": id,
		"name": display_name,
		"scoring_modifiers": scoring_mods,
		"special": {
			"name": special_name,
			"effect": special_effect
		},
		"description": desc,
		"flavor_text": flavor_text
	}

func get_judge(id: String) -> Dictionary:
	return judges.get(id, {})

func get_all() -> Array:
	return judges.values()

func get_scoring_modifier(judge_id: String, attr: String) -> float:
	var judge = get_judge(judge_id)
	if judge.is_empty():
		return 1.0
	var key = attr + "_mult"
	if judge.scoring_modifiers.has(key):
		return judge.scoring_modifiers[key]
	return 1.0

func has_aroma_cap(judge_id: String) -> bool:
	var judge = get_judge(judge_id)
	if judge.is_empty():
		return false
	return judge.scoring_modifiers.has("aroma_cap")

func get_aroma_cap(judge_id: String) -> float:
	var judge = get_judge(judge_id)
	if judge.is_empty():
		return 1.0
	return judge.scoring_modifiers.get("aroma_cap", 1.0)

func is_random_daily(judge_id: String) -> bool:
	var judge = get_judge(judge_id)
	if judge.is_empty():
		return false
	return judge.scoring_modifiers.get("random_daily", false)

# ============================================================
#  V2 评委数据 — 上菜顺序制专用
# ============================================================

var _judges_v2 := {
	"yuyuko": {
		"name": "幽幽子",
		"gluttony": 1.6,
		"satiety_cap": 140,
		"need_sens": {"addiction": 1.8, "thirst": 0.3, "greasy": 0.3},
		"pref": ["umami_tag", "rich"],
		"hate": ["light"],
		"flavor_mult": 1.15
	},
	"eiki": {
		"name": "映姬",
		"gluttony": 0.6,
		"satiety_cap": 100,
		"need_sens": {},
		"pref": [],
		"hate": [],
		"flavor_mult": 1.0,
		"need_reward_mult": 1.6
	},
	"aya": {
		"name": "文",
		"gluttony": 0.7,
		"satiety_cap": 100,
		"need_sens": {"novelty": 2.0},
		"pref": ["seasonal", "raw"],
		"hate": [],
		"flavor_mult": 0.95,
		"repeat_penalty": 2.0
	},
	"yukari": {
		"name": "紫",
		"gluttony": 1.0,
		"satiety_cap": 110,
		"need_sens": {},
		"pref": ["mastered"],
		"hate": [],
		"flavor_mult": 1.0,
		"ignore_small_first": 2
	},
	"remilia": {
		"name": "蕾米莉亚",
		"gluttony": 0.6,
		"satiety_cap": 100,
		"need_sens": {},
		"pref": ["rich", "mastered"],
		"hate": ["light"],
		"flavor_mult": 1.05
	},
	"raiko": {
		"name": "雷鼓",
		"gluttony": 1.1,
		"satiety_cap": 100,
		"need_sens": {},
		"pref": ["grilled"],
		"hate": [],
		"flavor_mult": 1.0,
		"rhythm_bonus": true
	},
	"tenshi": {
		"name": "天子",
		"gluttony": 1.0,
		"satiety_cap": 100,
		"need_sens": {},
		"pref": ["rich"],
		"hate": [],
		"flavor_mult": 1.0,
		"unmet_penalty_mult": 2.0
	},
	"iku": {
		"name": "衣玖",
		"gluttony": 0.8,
		"satiety_cap": 100,
		"need_sens": {},
		"pref": ["light"],
		"hate": [],
		"flavor_mult": 1.0,
		"need_duration_bonus": 1,
		"cuisine_diversity_bonus": 0.035
	},
	"miko": {
		"name": "神子",
		"gluttony": 1.0,
		"satiety_cap": 100,
		"need_sens": {},
		"pref": ["mastered"],
		"hate": [],
		"flavor_mult": 1.0,
		"cuisine_diversity_bonus": 0.025
	},
	"kokoro": {
		"name": "心",
		"gluttony": 1.0,
		"satiety_cap": 100,
		"need_sens": {"addiction": 1.8},
		"pref": ["sweet"],
		"hate": [],
		"flavor_mult": 1.0,
		"mood_swing_mult": 2.5
	},
	"yuuka": {
		"name": "幽香",
		"gluttony": 0.8,
		"satiety_cap": 100,
		"need_sens": {},
		"pref": ["vegetable", "light", "tea"],
		"hate": ["fried"],
		"flavor_mult": 1.0,
		"afterglow_duration_mult": 2.0
	},
	"yuuma": {
		"name": "饕餮",
		"gluttony": 1.8,
		"satiety_cap": 180,
		"need_sens": {"greasy": 0, "thirst": 0},
		"pref": ["rich", "meat", "fried"],
		"hate": ["light"],
		"flavor_mult": 1.2
	}
}

func get_judge_v2(judge_id: String) -> Dictionary:
	return _judges_v2.get(judge_id, _judges_v2["eiki"])
