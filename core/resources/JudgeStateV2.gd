extends RefCounted
class_name JudgeStateV2

## V2 战斗系统 — 评委状态机
## 共享状态，双方的菜都作用于同一位评委

# 评委配置（从 JudgeDatabase 加载）
var judge_config: Dictionary

# 核心状态
var satiety: float = 0.0
var mood: float = 0.0
var threshold: Dictionary = {}      # tag -> float (味觉阈值)
var needs: Array = []               # [{type: String, ttl: int}]
var cuisines_seen: Dictionary = {}  # cuisine -> true (用 Dict 模拟 Set)
var dish_count: int = 0
var small_dish_count: int = 0
var cons_flavor: Dictionary = {"tag": "", "count": 0}  # 连续风味追踪（上瘾）
var last_score: float = 0.0

# 追踪变量（用于复杂公式）
var _total_needs_met: int = 0
var _cuisine_count: Dictionary = {}
var _grill_streak: int = 0
var _spicy_streak: int = 0
var _size_history: Array = []
var _predict_count: int = 0
var _small_streak: int = 0
var _last_cuisine: String = ""

func _init(config: Dictionary) -> void:
	judge_config = config

# ============================================================
#  需求系统
# ============================================================

func has_need(type: String) -> bool:
	for n in needs:
		if n.type == type:
			return true
	return false

func satisfy_need(type: String) -> bool:
	for i in range(needs.size()):
		if needs[i].type == type:
			needs.remove_at(i)
			return true
	return false

func add_need(type: String, ttl: int) -> void:
	var duration: int = ttl + get_need_duration_bonus()
	if not has_need(type):
		needs.append({"type": type, "ttl": duration})

func tick_needs() -> void:
	var remaining: Array = []
	for n in needs:
		n.ttl -= 1
		if n.ttl > 0:
			remaining.append(n)
	needs = remaining

# ============================================================
#  评委属性 Getter（从 judge_config 读取）
# ============================================================

func get_satiety_cap() -> float:
	return judge_config.get("satiety_cap", 100.0)

func get_gluttony() -> float:
	return judge_config.get("gluttony", 1.0)

func get_flavor_mult() -> float:
	return judge_config.get("flavor_mult", 1.0)

func get_need_reward_mult() -> float:
	return judge_config.get("need_reward_mult", 1.0)

func get_need_duration_bonus() -> int:
	return judge_config.get("need_duration_bonus", 0)

func get_unmet_penalty_mult() -> float:
	return judge_config.get("unmet_penalty_mult", 1.0)

func get_mood_swing_mult() -> float:
	return judge_config.get("mood_swing_mult", 1.0)

func get_afterglow_duration_mult() -> float:
	return judge_config.get("afterglow_duration_mult", 1.0)

func get_ignore_small_first() -> int:
	return judge_config.get("ignore_small_first", 0)

func get_repeat_penalty() -> float:
	return judge_config.get("repeat_penalty", 1.0)

func get_cuisine_diversity_bonus() -> float:
	return judge_config.get("cuisine_diversity_bonus", 0.0)

func has_rhythm_bonus() -> bool:
	return judge_config.get("rhythm_bonus", false)

func get_pref_tags() -> Array:
	return judge_config.get("pref", [])

func get_hate_tags() -> Array:
	return judge_config.get("hate", [])

func get_need_sensitivity(need_type: String) -> float:
	var need_sens: Dictionary = judge_config.get("need_sens", {})
	if need_sens.has(need_type):
		return need_sens[need_type]
	return 1.0

# ============================================================
#  调试输出
# ============================================================

func _to_string() -> String:
	return "JudgeState(sat=%.1f/%.0f, mood=%d, needs=%d, dishes=%d, cuisines=%d)" % [
		satiety, get_satiety_cap(), mood, needs.size(), dish_count, cuisines_seen.size()
	]
