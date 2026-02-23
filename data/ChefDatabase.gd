extends Node

var chefs: Dictionary = {}
func _ready() -> void:
	_init_chefs()

func _init_chefs() -> void:
	_add(
		"mystia",
		"米斯蒂娅",
		["yatai", "washoku"],
		"夜雀食堂",
		"passive",
		{yatai_cd_reduction = 0.15, night_blindness_on_opponent = true},
		"夜雀的歌声让食客迷失方向，却被夜市的香气引导。夜市菜品冷却减少15%，对手在夜盲中手忙脚乱。",
		3,
		{flavor = 6, technique = 4, presentation = 3}
	)

	_add(
		"sakuya",
		"十六夜咲夜",
		["youshoku", "kanmi"],
		"时停备菜",
		"on_showdown_start",
		{all_dish_cd_reduction = 1.0},
		"「时间停止——完美的准备。」咲夜以时停之力在对决开始前完成所有备菜。全菜品冷却减少1秒。",
		3,
		{flavor = 4, technique = 7, presentation = 6}
	)

	_add(
		"youmu",
		"魂魄妖梦",
		["washoku", "youshoku"],
		"二刀流",
		"on_activate",
		{small_dish_reactivate_chance = 0.30},
		"半人半灵的剑士，楼观剣与白楼剣的双刀流。小型菜品上菜时有30%概率二刀流发动，再次触发！",
		3,
		{flavor = 5, technique = 8, presentation = 3}
	)

	_add(
		"meiling",
		"红美铃",
		["chuuka", "yatai"],
		"气功调味",
		"passive",
		{umami_effect_mult = 1.30, umami_bonus_mult = 1.30},
		"红魔馆门番的气功融入料理之中。提味在她手中化为龙之吐息，提味相关收益提升30%。",
		3,
		{flavor = 8, technique = 4, presentation = 3}
	)

	_add(
		"marisa",
		"雾雨魔理沙",
		["yatai", "yakuzen"],
		"魔法实验",
		"on_activate",
		{extra_random_keyword_chance = 0.20},
		"「借走了！」——普通的魔法使总能从意想不到的地方获得灵感。上菜时有20%概率获得随机关键字。",
		3,
		{flavor = 5, technique = 5, presentation = 4}
	)

	_add(
		"reimu",
		"博丽灵梦",
		["washoku", "yakuzen"],
		"巫女直觉",
		"on_shop_refresh",
		{free_refresh_per_day = 1, donation_gold_chance = 0.15},
		"博丽的巫女直觉在商店中也能发挥作用。每天首次刷新免费，事件中有15%概率额外获得2金币赛钱。",
		3,
		{flavor = 5, technique = 5, presentation = 4}
	)

	_add(
		"alice",
		"爱丽丝",
		["youshoku", "kanmi"],
		"人偶操演",
		"passive",
		{plating_effect_mult = 1.30, plating_output_bonus = 0.30, max_tools = 4},
		"人偶使的精密操控让每一道菜都如艺术品般完美。增色收益提升30%，额外的人偶手臂让厨具栏位+1。",
		4,
		{flavor = 4, technique = 6, presentation = 7}
	)

	_add(
		"patchouli",
		"帕秋莉",
		["youshoku", "chuuka"],
		"五行调和",
		"on_activate",
		{five_element_bonus = true, element_cycle_bonus = 0.20},
		"大图书馆的魔女以五行之力调和料理。火水木金土的循环赋予菜品额外的属性提升。",
		3,
		{flavor = 4, technique = 6, presentation = 6}
	)

	_add(
		"reisen",
		"铃仙",
		["kanmi", "yakuzen"],
		"狂气之瞳",
		"on_showdown_start",
		{opponent_random_cd_increase = 1.0, lunatic_red_eyes = true},
		"月兔的狂气之瞳让对手陷入混乱。开局随机提高对手冷却，红色的眼眸施加疲劳。",
		3,
		{flavor = 5, technique = 5, presentation = 5}
	)

	_add(
		"seija",
		"鬼人正邪",
		["chuuka", "washoku"],
		"天邪鬼翻转",
		"passive",
		{swap_min_max_attrs = true},
		"「颠倒是非黑白才是我的风格！」——天邪鬼将每道菜的最高与最低属性互换。弱点变为强项，强项变为弱点。",
		3,
		{flavor = 5, technique = 5, presentation = 5}
	)

func _add(
	id: String,
	display_name: String,
	cuisines: Array,
	skill_name: String,
	skill_trigger: String,
	skill_effect: Dictionary,
	skill_desc: String,
	tool_slots: int,
	base_stats: Dictionary
) -> void:
	chefs[id] = {
		"id": id,
		"name": display_name,
		"cuisines": cuisines,
		"skill": {
			"name": skill_name,
			"trigger": skill_trigger,
			"effect": skill_effect,
			"description": skill_desc,
		},
		"tool_slots": tool_slots,
		"base_stats": base_stats,
	}

func get_chef(id: String) -> Dictionary:
	return chefs.get(id, {})

func get_all() -> Array:
	return chefs.values()

func get_by_cuisine(cuisine: String) -> Array:
	var result: Array = []
	for c in chefs.values():
		if cuisine in c.cuisines:
			result.append(c)
	return result

func get_chef_cuisines(id: String) -> Array:
	var chef = get_chef(id)
	if chef.is_empty():
		return []
	return chef.get("cuisines", [])

func get_chef_tool_slots(id: String) -> int:
	var chef = get_chef(id)
	if chef.is_empty():
		return 3
	var skill_effect: Dictionary = chef.get("skill", {}).get("effect", {})
	if skill_effect.has("max_tools"):
		return int(skill_effect.get("max_tools", 3))
	return int(chef.get("tool_slots", 3))
