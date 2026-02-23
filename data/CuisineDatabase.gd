extends Node

var cuisines: Dictionary = {}
var fusion_combos: Dictionary = {}
func _ready():
	_init_cuisines()
	_init_fusion_combos()

func _init_cuisines():
	# === 三大基本菜系 ===
	_add_cuisine("washoku", "和食",
		{flavor="normal", technique="strong", presentation="normal"},
		{count=3, name="旬味极致", effect={per_washoku_flavor_bonus=0.10}, desc="「旬の味を極める」——三道和食共鸣，季节的精华在舌尖绽放。每道和食风味+10%。"})

	_add_cuisine("chuuka", "中华",
		{flavor="strong", technique="normal", presentation="weak"},
		{count=3, name="火候精通", effect={chuuka_cd_reduction=0.15}, desc="「火候就是一切」——三道中华的锅气汇聚，炉火纯青。所有中华CD-15%。"})

	_add_cuisine("youshoku", "洋食",
		{flavor="normal", technique="strong", presentation="strong"},
		{count=3, name="美食美学", effect={presentation_output_bonus=0.25}, desc="「料理即是艺术」——三道洋食的美学共鸣，视觉盛宴。卖相产出+25%。"})

	# === 三大特殊菜系 ===
	_add_cuisine("yatai", "夜市",
		{flavor="strong", technique="weak", presentation="weak"},
		{count=3, name="夜市匠心", effect={first_activate_flavor_mult=1.5}, desc="「夜市的第一口最重要！」——三道夜市的匠心，开场即巅峰。首次激活风味×1.5。"})

	_add_cuisine("kanmi", "甜品",
		{flavor="normal", technique="normal", presentation="very_strong"},
		{count=3, name="甘美回味", effect={aftertaste_bonus_mult=1.5}, desc="「甜蜜的回味久久不散」——三道甜品的甘美共鸣，回味无穷。回味关键词效果×1.5。"})

	_add_cuisine("yakuzen", "药膳",
		{flavor="weak", technique="strong", presentation="normal"},
		{count=3, name="养生之道", effect={env_debuff_clear_bonus=1, secret_recipe_bonus=0.25}, desc="「药食同源，养生之道」——三道药膳的调和之力，净化身心。每次清除环境debuff额外清1层，秘方效果+25%。"})

func _init_fusion_combos():
	# === 二菜系Fusion (对应英雄双池) ===
	_add_fusion("yatai_washoku", ["yatai", "washoku"],
		"夜雀食桌",
		{umami_bonus_mult=1.5},
		"夜雀食堂的独特调味让提味效果×1.5。")

	_add_fusion("youshoku_kanmi", ["youshoku", "kanmi"],
		"完美午后",
		{plating_double_effect=true, on_serve_sweet=true},
		"红魔馆的完美午后——咲夜与爱丽丝的下午茶时光。甜味菜品激活时增色效果翻倍。")

	_add_fusion("washoku_youshoku", ["washoku", "youshoku"],
		"白玉楼盛宴",
		{knife_work_bonus_mult=1.3, large_dish_bonus=0.15},
		"白玉楼的跨界盛宴——妖梦以双刀融合东西方刀法。精技效果+30%，大型菜品全属性+15%。")

	_add_fusion("chuuka_yatai", ["chuuka", "yatai"],
		"龙之铁板",
		{umami_cap_increase=3, greasy_resistance=0.5},
		"龙之铁板——美铃的气功与炭火的碰撞。提味上限+3，油腻负面效果减半。")

	_add_fusion("yatai_yakuzen", ["yatai", "yakuzen"],
		"恋色魔炮",
		{random_bonus_on_grill=true, mushroom_bonus=0.20},
		"恋色魔炮——魔理沙的疯狂实验料理。夜市激活时20%触发随机Buff，蘑菇菜品效果+20%。")

	_add_fusion("washoku_yakuzen", ["washoku", "yakuzen"],
		"博丽茶会",
		{env_clear_on_light=true, donation_flavor=2},
		"博丽茶会——灵梦的净化之力融入料理。清淡菜品激活时自动清1层环境debuff，每次清除+2风味。")

	_add_fusion("youshoku_chuuka", ["youshoku", "chuuka"],
		"五行图书馆",
		{five_element_fusion=true, all_attr_bonus=0.08},
		"五行图书馆——帕秋莉以魔法融合东西方料理精华。同时拥有洋食+中华时全属性+8%。")

	_add_fusion("kanmi_yakuzen", ["kanmi", "yakuzen"],
		"月兔秘药点心",
		{aftertaste_to_secret=true, conversion_threshold=3},
		"月兔秘药点心——铃仙将永琳的药学融入甜品。回味叠到3层时自动转化为1层秘方。")

	# === 万国博览 (4+菜系特殊) ===
	_add_fusion("world_expo", [],
		"万国料理博览会",
		{board_presentation=0.20},
		"万国料理博览会——幻想乡的文化大熔炉。四种以上菜系齐聚，全场卖相+20%。")

func _add_cuisine(id: String, display_name: String, attr_profile: Dictionary, synergy: Dictionary):
	cuisines[id] = {
		"id": id,
		"name": display_name,
		"attr_profile": attr_profile,
		"synergy": synergy
	}

func _add_fusion(id: String, required_cuisines: Array, display_name: String, bonuses: Dictionary, desc: String):
	fusion_combos[id] = {
		"id": id,
		"required_cuisines": required_cuisines,
		"name": display_name,
		"bonuses": bonuses,
		"description": desc
	}

func get_cuisine(id: String) -> Dictionary:
	return cuisines.get(id, {})

func get_all_cuisines() -> Array:
	return cuisines.values()

func get_attr_strength(cuisine_id: String, attr: String) -> String:
	var cuisine = get_cuisine(cuisine_id)
	if cuisine.is_empty():
		return "normal"
	return cuisine.attr_profile.get(attr, "normal")

func get_strength_multiplier(strength: String) -> float:
	match strength:
		"very_strong": return 1.4
		"strong": return 1.2
		"normal": return 1.0
		"weak": return 0.8
	return 1.0

func check_synergy(cuisine_id: String, count: int) -> Dictionary:
	var cuisine = get_cuisine(cuisine_id)
	if cuisine.is_empty():
		return {}
	if count >= cuisine.synergy.count:
		return cuisine.synergy
	return {}

func check_fusion_combos(active_cuisines: Array) -> Array:
	var triggered: Array = []
	for combo in fusion_combos.values():
		if combo.id == "world_expo":
			if active_cuisines.size() >= 4:
				triggered.append(combo)
		else:
			var all_present := true
			for req in combo.required_cuisines:
				if req not in active_cuisines:
					all_present = false
					break
			if all_present:
				triggered.append(combo)
	return triggered

func get_fusion_combo(id: String) -> Dictionary:
	return fusion_combos.get(id, {})

func get_all_fusions() -> Array:
	return fusion_combos.values()
