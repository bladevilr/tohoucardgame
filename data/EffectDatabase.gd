extends Node

## EffectDatabase - 特效定义与战斗时机

enum EffectTiming {
	PRE_COMBAT,
	ON_HIT,
	ON_DAMAGE_TAKEN,
	ON_KILL,
	POST_TICK,
	ON_DEATH,
	PASSIVE,
}

# 所有特效描述（移植自 CookingDatabase.EFFECT_DESCRIPTIONS）
const EFFECT_DESCRIPTIONS := {
	# 回复类
	"regen_1": "每 tick 回复 1 HP",
	"kill_heal_3_percent": "击杀回复3%HP",
	"kill_heal_8_percent": "击杀回复8%HP",
	"phoenix_regen": "HP<20%时每 tick 回复2%HP",
	"drink_regen_3": "每 tick 回复 3 HP",
	# 攻击类
	"combo_damage_up": "连击加伤：连续命中每击+6%，上限+30%",
	"light_shockwave": "攻击附带冲击，+10%伤害",
	"flame_fist_bonus": "攻击附带火焰，+25%伤害",
	"flame_combo_rush": "5连拳，总伤害×2.5",
	"heavy_armor_break": "攻击无视20%减伤",
	"fire_trail_visual": "攻击附带火焰，+15%伤害",
	"attack_up_10": "攻击力+10%",
	# 防御类
	"hitstun_resist_20": "受伤减免+20%",
	"high_hp_guard": "HP>70%时减伤额外+15%",
	# 速度类
	"dash_distance_15": "先手权+15%",
	"dash_bonus_100": "首击伤害+100%",
	"afterimage_step": "先手权翻倍",
	"speed_up_8": "先手权+8%",
	"jump_boost_20": "先手权+20%",
	# 灵力类
	"spirit_pulse": "符卡命中后，下3次攻击附带灵力冲击",
	"spirit_charge_bonus": "灵力充能+10%",
	"tracking_bullets": "攻击额外发射2枚追踪弹（+2伤害）",
	"drink_focus": "灵力充能+15%",
	# 触发类
	"berserk_burn": "HP<30%时攻击力×1.8",
	"rebirth_once": "死亡时复活一次（50%HP）",
	# 饮品特有
	"risk_taken_up_10": "受击伤害+10%（高风险高回报）",
	"night_vision": "先手权+5%",
	"reveal_collectibles": "首回合伤害+10%",
}

# 战斗效果实际数据
const EFFECT_COMBAT_DATA := {
	# 回复
	"regen_1": {"timing": EffectTiming.POST_TICK, "heal_per_tick": 1.0},
	"kill_heal_3_percent": {"timing": EffectTiming.ON_KILL, "heal_percent": 0.03},
	"kill_heal_8_percent": {"timing": EffectTiming.ON_KILL, "heal_percent": 0.08},
	"phoenix_regen": {"timing": EffectTiming.POST_TICK, "hp_threshold": 0.20, "heal_percent_per_tick": 0.02},
	"drink_regen_3": {"timing": EffectTiming.POST_TICK, "heal_per_tick": 3.0},
	# 攻击加成
	"combo_damage_up": {"timing": EffectTiming.ON_HIT, "bonus_per_hit": 0.06, "max_bonus": 0.30},
	"light_shockwave": {"timing": EffectTiming.PASSIVE, "damage_mult_bonus": 0.10},
	"flame_fist_bonus": {"timing": EffectTiming.PASSIVE, "damage_mult_bonus": 0.25},
	"flame_combo_rush": {"timing": EffectTiming.PRE_COMBAT, "hit_count": 5, "total_mult": 2.5},
	"heavy_armor_break": {"timing": EffectTiming.ON_HIT, "armor_penetration": 0.20},
	"fire_trail_visual": {"timing": EffectTiming.PASSIVE, "damage_mult_bonus": 0.15},
	"attack_up_10": {"timing": EffectTiming.PASSIVE, "damage_mult_bonus": 0.10},
	# 防御
	"hitstun_resist_20": {"timing": EffectTiming.PASSIVE, "reduction_bonus": 0.20},
	"high_hp_guard": {"timing": EffectTiming.ON_DAMAGE_TAKEN, "hp_threshold": 0.70, "reduction_bonus": 0.15},
	# 速度/先手
	"dash_distance_15": {"timing": EffectTiming.PASSIVE, "initiative_bonus": 0.15},
	"dash_bonus_100": {"timing": EffectTiming.PRE_COMBAT, "first_hit_bonus": 1.00},
	"afterimage_step": {"timing": EffectTiming.PASSIVE, "initiative_mult": 2.0},
	"speed_up_8": {"timing": EffectTiming.PASSIVE, "initiative_bonus": 0.08},
	"jump_boost_20": {"timing": EffectTiming.PASSIVE, "initiative_bonus": 0.20},
	# 灵力
	"spirit_pulse": {"timing": EffectTiming.ON_HIT, "spirit_hits": 3, "spirit_bonus_damage": 5.0},
	"spirit_charge_bonus": {"timing": EffectTiming.PASSIVE, "spirit_bonus": 0.10},
	"tracking_bullets": {"timing": EffectTiming.ON_HIT, "extra_damage": 2.0},
	"drink_focus": {"timing": EffectTiming.PASSIVE, "spirit_bonus": 0.15},
	# 触发
	"berserk_burn": {"timing": EffectTiming.PRE_COMBAT, "hp_threshold": 0.30, "atk_mult": 1.8},
	"rebirth_once": {"timing": EffectTiming.ON_DEATH, "revive_hp_percent": 0.50},
	# 饮品
	"risk_taken_up_10": {"timing": EffectTiming.PASSIVE, "damage_taken_increase": 0.10},
	"night_vision": {"timing": EffectTiming.PASSIVE, "initiative_bonus": 0.05},
	"reveal_collectibles": {"timing": EffectTiming.PRE_COMBAT, "first_hit_bonus": 0.10},
}

static func get_description(effect_id: String) -> String:
	return EFFECT_DESCRIPTIONS.get(effect_id, "未知效果")

static func get_combat_data(effect_id: String) -> Dictionary:
	return EFFECT_COMBAT_DATA.get(effect_id, {})

static func get_timing(effect_id: String) -> int:
	var data := get_combat_data(effect_id)
	return data.get("timing", EffectTiming.PASSIVE)

static func get_effects_by_timing(timing: int) -> Array:
	var result: Array = []
	for effect_id in EFFECT_COMBAT_DATA:
		if EFFECT_COMBAT_DATA[effect_id].get("timing", -1) == timing:
			result.append(effect_id)
	return result
