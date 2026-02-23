extends Node

## 东方料理对决 — 全局游戏配置与数值平衡
## 设计原则：前期有成长感、中期有抉择痛、后期有核弹爽感

# === 属性系统 (1 attribute: Flavor) ===
enum Attr { FLAVOR }

# === 品阶 ===
enum Tier { BRONZE, SILVER, GOLD, DIAMOND }

# === 物品大小 ===
enum ItemSize { SMALL = 1, MEDIUM = 2, LARGE = 3 }

# === 游戏阶段 ===
enum Phase { EVENT_CHOICE, PVE_BATTLE, PVP_BATTLE, SHOWDOWN, PREP, SHOP, ENCOUNTER, RESULT, PVE_CHOICE }

# === 大巴扎式日循环 ===
const ACTIONS_PER_DAY := 6
const PVE_ACTION := 3
const PVP_ACTION := 6
const WINS_TO_CLEAR := 10
const MAX_DAYS := 15

# === 板面 ===
const BOARD_SLOTS := 4
const MAX_TOOLS := 3
const MAX_TECHNIQUES := 4  # 技法遗物槽位
const BACKPACK_SIZE := 4           # 起始备菜格（升级后扩展）

# === 等级与经验系统 ===
const XP_PER_LEVEL := 8            # 每级经验阈值（参考大巴扎）
const XP_PER_ACTION := 1           # 完成事件行动 +1 经验
const XP_PER_PVE_BY_DIFF := [0, 1, 2, 3]  # 按难度1/2/3额外获得的经验值
const BACKPACK_SLOTS_PER_LEVEL := 2  # 保留常量，但背包不再升级扩展（初始就是10格）
const BACKPACK_EXPAND_LEVEL_CAP := 0 # 背包不扩展
const BOARD_SLOTS_PER_LEVEL := 2     # 每次升级扩展2个备菜台格子
const BOARD_EXPAND_LEVEL_CAP := 3    # Lv.2/3/4各扩2格：4→6→8→10

# === 对决 ===
const SHOWDOWN_DURATION := 30.0
const TICK_INTERVAL := 0.1



# ============================================================
#  声望系统 — 生存压力
# ============================================================
const STARTING_PRESTIGE := 20
# 对决失败声望扣除：基础2 + floor(分差 / 80)
# 设计意图：大比分输掉更痛，但基础伤害提高到2让前期也有压力
const PRESTIGE_DAMAGE_BASE := 2
const PRESTIGE_DAMAGE_PER_DIFF := 1  # 每80分差额外+1
const PRESTIGE_DIFF_DIVISOR := 80.0
# PvE失败不扣声望，只扣少量金币

# ============================================================
#  经济系统 — 鼓励刷新和冒险
# ============================================================
const STARTING_GOLD := 10
const GOLD_PER_DAY := 6       # 基础日收入提升到6
const DAILY_BASE_INCOME := 5  # 每天基础收入（工资）
const DAY_INCOME_BONUS_PER_DAY := 1
const DAY_INCOME_BONUS_CAP := 6  # 最大日收入 = 6 + 6 = 12
const WIN_BONUS_GOLD := 2
const SHOP_REFRESH_COST := 1   # 降到1金币！鼓励疯狂D牌
const SELL_REFUND_RATIO := 0.5
const SELL_TECHNIQUE_REFUND := 1

# Win streak: 2连+1, 3连+2, 5连+4
static func get_streak_bonus(streak: int) -> int:
	if streak >= 5:
		return 4  # 提升连胜奖励
	elif streak >= 3:
		return 2
	elif streak >= 2:
		return 1
	return 0

# Loss streak: 3连+2, 5连+3 (保底机制更强)
static func get_loss_streak_bonus(streak: int) -> int:
	var abs_streak = absi(streak)
	if abs_streak >= 5:
		return 3
	elif abs_streak >= 3:
		return 2
	return 0

# === 商店 (定价已移至 ShopManager) ===
const SHOP_SLOTS_DISH := 5
const SHOP_SLOTS_INGREDIENT := 3
const SHOP_SLOTS_TECHNIQUE := 2
const SHOP_SLOTS_TOOL := 2
const SHOP_SLOTS_BLACKMARKET := 2
const BLACKMARKET_CHANCE := 0.20
const BLACKMARKET_PRICE_MULT := 1.5

# === 品阶概率 (legacy, ShopManager has its own) ===
const TIER_WEIGHTS := {
	1: {Tier.BRONZE: 75, Tier.SILVER: 25, Tier.GOLD: 0, Tier.DIAMOND: 0},
	4: {Tier.BRONZE: 35, Tier.SILVER: 40, Tier.GOLD: 20, Tier.DIAMOND: 5},
	7: {Tier.BRONZE: 15, Tier.SILVER: 30, Tier.GOLD: 35, Tier.DIAMOND: 20},
	10: {Tier.BRONZE: 5, Tier.SILVER: 20, Tier.GOLD: 40, Tier.DIAMOND: 35},
}

# ============================================================
#  升星系统 — 三连升星
# ============================================================
const STAR_UPGRADE_COUNT := 3
const STAR2_MULTIPLIER := 2.0  # 2星=属性×2 (从1.5提升，更有升星动力)
const STAR3_MULTIPLIER := 3.0  # 3星=属性×3 (从2.0提升，3星是终极目标)

# ============================================================
#  撞菜系统
# ============================================================
const CLASH_LOSER_SCORE_MULT := 0.5

# === 触发系统 ===
const MAX_CHAIN_DEPTH := 10

# === 战斗系统 (legacy) ===
const MAX_COMBAT_TICKS := 10
const BASE_COMBAT_HP := 100.0
const BASE_DAMAGE := 10.0
const HP_LOSS_BASE_PER_ROUND := 2
const MIN_HP_LOSS := 1

# === Buff槽 ===
const BUFF_SLOT_COUNT := 3

# ============================================================
#  属性显示
# ============================================================
const STAT_KEYS := ["flavor"]
const STAT_NAMES := {
	"flavor": "风味",
}
const STAT_ICONS := {
	"flavor": "🔥",
}
const STAT_COLORS := {
	"flavor": Color(1.0, 0.42, 0.21),    # #FF6B35 暖橙
}

# === 品质 ===
const QUALITY_NAME := {
	0: "铜",
	1: "银",
	2: "金",
	3: "钻",
}
const QUALITY_COLOR := {
	0: Color(0.80, 0.50, 0.20),  # 铜色
	1: Color(0.75, 0.75, 0.75),  # 银色
	2: Color(1.0, 0.84, 0.0),    # 金色
	3: Color(0.73, 0.95, 1.0),   # 钻石蓝
}

# === 星级显示 ===
const STAR_NAMES := {1: "★", 2: "★★", 3: "★★★"}
const STAR_COLORS := {
	1: Color(0.8, 0.8, 0.8),
	2: Color(1.0, 0.84, 0.0),
	3: Color(1.0, 0.4, 0.1),
}

# === 关键词 ===
const KEYWORD_TYPES := {
	"buff": ["umami", "plating", "knife_work", "spotlight", "aftertaste", "secret_recipe"],
	"environment": ["greasy", "messy", "taste_fatigue", "dull"],
	"mark": ["fusion", "mastered", "rich", "light"]
}

# ============================================================
#  关键词数值 — 每层效果
# ============================================================
const FLAVOR_BOOST_PER_STACK := 1        # 提味：+1美味度/层
const VISUAL_BOOST_PER_STACK := 1        # 增色：+1卖相/层
const TECH_BOOST_PER_STACK := 1          # 精技：+1技法/层
const SPOTLIGHT_CD_PER_STACK := 1.0      # 加速：-1秒CD/层(消耗)
const AFTERTASTE_FLAVOR_MULT := 0.30     # 回味：+30%美味度/层
const SECRET_RECIPE_FLAVOR_MULT := 0.50  # 秘方：+50%美味度/层(消耗)
const GREASY_FLAVOR_PENALTY := 2         # 油腻：-2美味度/层
const MESSY_PRES_PENALTY := 2            # 杂乱：-2卖相/层
const TASTE_FATIGUE_MULT := -0.15        # 疲劳：-15%美味度/层
const DULL_CD_PENALTY := 1.0             # 沉闷：+1秒CD/层


# ============================================================
#  静态工具函数
# ============================================================
static func get_tier_weights(day: int) -> Dictionary:
	var best_key := 1
	for key in TIER_WEIGHTS:
		if day >= key and key >= best_key:
			best_key = key
	return TIER_WEIGHTS[best_key]



static func get_prestige_damage(score_diff: float) -> int:
	var safe_diff = maxf(0.0, score_diff)
	return PRESTIGE_DAMAGE_BASE + int(floorf(safe_diff / PRESTIGE_DIFF_DIVISOR)) * PRESTIGE_DAMAGE_PER_DIFF

# ============================================================
#  V2 战斗系统 — 上菜顺序制
# ============================================================
const BATTLE_SYSTEM_V2 := true

# V2 Showdown
const V2_SHOWDOWN_DURATION := 30.0
const SCORE_DIFF_WIN_THRESHOLD := 100.0

# V2 Scoring - Base
const V2_TECH_MULT_BASE := 0.85
const V2_TECH_MULT_PER_POINT := 1.0 / 40.0  # dish.tech / 40
const V2_FATIGUE_PER_DISH := 0.05
const V2_FATIGUE_FLOOR := 0.55
const V2_SIZE_EXPONENT := 0.6
const V2_SIZE_COMPENSATION := 1.1

# V2 Threshold System
const V2_THRESHOLD_DECAY_PER_COUNT := 0.05
const V2_THRESHOLD_FLOOR := 0.60
const V2_ADDICTION_REVERSAL_START := 8
const V2_ADDICTION_REVERSAL_RATE := 0.1

# V2 Need System
const V2_NEED_BONUS_THIRST := 0.5
const V2_NEED_BONUS_GREASY := 0.4
const V2_NEED_BONUS_STAPLE := 0.35
const V2_NEED_BONUS_SWEET := 0.5
const V2_NEED_BONUS_NOVELTY := 0.35
const V2_NEED_BONUS_AFTERGLOW := 0.25
const V2_NEED_BONUS_ADDICTION := 0.6
const V2_NEED_FLAT_MULT := 4.0
const V2_NEED_DIMINISH_RATE := 0.06
const V2_NEED_DIMINISH_FLOOR := 0.35
const V2_UTILITY_FLOOR_BASE := 2.5
const V2_UTILITY_FLOOR_PER_NEED := 2.0
const V2_UNMET_PENALTY_RATE := 0.10
const V2_UNMET_PENALTY_FLOOR := 0.45

# V2 Mood & Preference
const V2_MOOD_MULT_PER_POINT := 0.04
const V2_MOOD_FLOOR := 0.55
const V2_PREF_BONUS := 0.08
const V2_HATE_PENALTY := 0.12

# V2 Satiety
const V2_SATIETY_THRESHOLD := 0.7
const V2_SATIETY_PENALTY_RATE := 0.55
const V2_SATIETY_BASE_MULT := 0.9
const V2_SATIETY_FLOOR := 0.25
const V2_SATIETY_SWEET_FLOOR := 0.7
const V2_SAT_BASE := [0, 5, 11, 18]  # by size
const V2_SAT_TASTINESS_THRESHOLDS := [0.5, 1.0, 1.5]
const V2_SAT_TASTINESS_MULTS := [0.3, 0.65, 1.1, 1.6]
const V2_SAT_PREF_MULT := 1.2

# V2 Cuisine-specific
const V2_YAKUZEN_MULT := 1.15
const V2_YAKUZEN_CLEANSE := 2.0
const V2_BASE_CLEANSE := 0.7
const V2_KANMI_PRES_BONUS_PER_POINT := 0.04
const V2_KANMI_PRES_THRESHOLD := 3
const V2_YOUSHOKU_COURSE_BONUS := 0.06
const V2_YOUSHOKU_COURSE_MIN_COUNT := 2

# V2 Streaks & Patterns
const V2_GRILL_STREAK_BONUS := 0.08
const V2_SPICY_STREAK_BONUS := 0.05
const V2_SPICY_STREAK_CAP := 2
const V2_COHERENCE_BONUS_MAX := 0.08
const V2_COHERENCE_MIN_DISHES := 3
const V2_SMALL_DISH_SATURATION_THRESHOLD := 4
const V2_SMALL_DISH_SATURATION_RATE := 0.07
const V2_SMALL_DISH_SATURATION_FLOOR := 0.65
const V2_CUISINE_PURITY_BONUS := 0.07
const V2_CUISINE_PURITY_MIN_COUNT := 3
const V2_CLEANSE_THRESHOLD_MULT := 0.25
const V2_CLEANSE_CAP := 3.0
const V2_PREDICTABILITY_PENALTY := 0.08
const V2_PREDICTABILITY_FLOOR := 0.7

# V2 Presentation Surprise
const V2_SURPRISE_BASE := 5.0
const V2_SURPRISE_PER_DISH := 0.6
const V2_SURPRISE_YOUSHOKU_KANMI_MULT := 0.035
const V2_SURPRISE_DEFAULT_MULT := 0.015

# V2 Threshold Update
const V2_THRESHOLD_LIGHT_SWEET_INC := 0.5
const V2_THRESHOLD_NORMAL_INC := 1.0

# V2 Need Generation
const V2_NEED_TTL_THIRST := 2
const V2_NEED_TTL_GREASY := 2
const V2_NEED_TTL_STAPLE := 3
const V2_NEED_TTL_SWEET := 4
const V2_NEED_TTL_NOVELTY := 2
const V2_NEED_TTL_AFTERGLOW := 1
const V2_NEED_TTL_ADDICTION := 2
const V2_SMALL_STREAK_THRESHOLD := 3
const V2_SATIETY_SWEET_TRIGGER := 0.35
const V2_AFTERGLOW_MULT := 1.4
const V2_ADDICTION_BASE_THRESHOLD := 3


# ============================================================
#  V2 Tick 模式调参
# ============================================================
# 原始V2为~10-15次上菜/30秒，tick模式为~40-80次激活/30秒
# 疲劳、饱腹、阈值需要相应降低
const V2_TICK_FATIGUE_PER_DISH := 0.02
const V2_TICK_SAT_BASE := [0, 3, 7, 12]
const V2_TICK_THRESHOLD_NORMAL_INC := 0.4
const V2_TICK_THRESHOLD_LIGHT_SWEET_INC := 0.2

# 通用引擎常量
const MIN_CD_FLOOR := 1.0                    # 最低CD 1.0s（原0.5s，对齐The Bazaar）

# ============================================================
#  区域效果与尽头加成（10格棋盘位置策略）
# ============================================================
const ZONE_APPETIZER_BONUS := 0.5            # 前菜区：开胃效果+50%
const ZONE_MAIN_BONUS := 0.10                # 主菜区：基础风味+10%
const ZONE_DESSERT_BONUS := 0.25             # 甜品区：首次激活得分+25%
const EDGE_LEFT_CD_BONUS := 0.15             # 最左位：基础CD-15%
const EDGE_RIGHT_SCORE_BONUS := 0.20         # 最右位：得分+20%

# ============================================================
#  关键词高层乘算转化（5+层时触发）
# ============================================================
const KEYWORD_MULT_THRESHOLD := 10           # 10层以上触发乘算
const UMAMI_HIGH_SCORE_MULT := 0.03          # 提味：总分×(1+层数×0.03)
const PLATING_HIGH_SCORE_MULT := 0.02        # 增色：总分×(1+层数×0.02)
const KNIFE_WORK_HIGH_CD_PERCENT := 0.05     # 精技：基础CD-5%×层数
	# ============================================================
#  标签冲突规则
# ============================================================
# 开胃触发 (spicy/sour) 被 顶饱 (rich+staple) 压制
# 清口触发 (light/tea) 与 油腻触发 (rich+fried) 同时存在时清口优先
# fried + steamed 互斥（食材层面阻止）

# === 数值期望参考 (设计备注 — 食材改革后) ===
# Day 1-3 (温饱期):
#   板面: 4-6格，铜/银菜品，总风味~40-60
#   食材: 每个仅+1~2风味，核心价值在标签
#   每次对决得分: ~200-400分
#   声望损失: 2-3/败
#
# Day 4-7 (成型期):
#   板面: 6-8格，含2-3个金级，开始有2星菜品
#   食材: 每个+2风味+行为效果，引擎联动成型
#   技法遗物: 2-3个全局被动
#   每次对决得分: ~600-1200分
#   声望损失: 2-5/败
#
# Day 8-15 (神仙期):
#   板面: 满编10格，多个2-3星菜品，钻石级
#   食材: 每个+2~3风味+强力行为，引擎全速运转
#   技法遗物: 4个全局被动
#   每次对决得分: ~2000-5000分（引擎机制爆发可达更高）
#   声望损失: 3-8/败

func get_knife_work_high_cd_percent() -> float:
	return KNIFE_WORK_HIGH_CD_PERCENT
