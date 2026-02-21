extends VBoxContainer

# Compact showdown score widget with bars, diff indicator, and DoT/environment text.
@onready var p1_score_label: Label = $ScoreRow/P1Score
@onready var p2_score_label: Label = $ScoreRow/P2Score
@onready var p1_bar: ProgressBar = $ScoreRow/BarContainer/P1Bar
@onready var p2_bar: ProgressBar = $ScoreRow/BarContainer/P2Bar
@onready var dot_label: Label = $InfoRow/DotLabel
@onready var env_label: Label = $InfoRow/EnvLabel
@onready var diff_label: Label = $DetailRow/DiffLabel

var _display_p1 = 0.0
var _display_p2 = 0.0

func _ready() -> void:
	_apply_bar_shader(p1_bar)
	_apply_bar_shader(p2_bar)
	# 确保Label可见且有默认样式
	if p1_score_label:
		p1_score_label.visible = true
		p1_score_label.modulate = Color.WHITE
	if p2_score_label:
		p2_score_label.visible = true
		p2_score_label.modulate = Color.WHITE

func update_scores(p1_score: float, p2_score: float):
	print("ScoreBar.update_scores called: p1=", p1_score, " p2=", p2_score)
	print("ScoreBar @onready nodes: p1_score_label=", p1_score_label != null, " p2_score_label=", p2_score_label != null)

	if p1_score_label == null or p2_score_label == null:
		print("ERROR: ScoreBar labels are null!")
		return

	# 使用@onready变量
	p1_score_label.text = "%d" % int(p1_score)
	p2_score_label.text = "%d" % int(p2_score)
	print("ScoreBar: Set texts to ", p1_score_label.text, " and ", p2_score_label.text)
	print("ScoreBar: Label visible? p1=", p1_score_label.visible, " p2=", p2_score_label.visible)

	var total = maxf(1.0, p1_score + p2_score)
	if p1_bar:
		p1_bar.max_value = total
		p1_bar.value = p1_score
	if p2_bar:
		p2_bar.max_value = total
		p2_bar.value = p2_score

	_display_p1 = p1_score
	_display_p2 = p2_score
	_update_leader_glow(p1_score, p2_score)
	_update_diff(p1_score, p2_score)

func update_dot(dot_per_sec: float, leading_player: int):
	if dot_label == null:
		return
	if absf(dot_per_sec) < 0.01:
		dot_label.text = "卖相压制: --"
		dot_label.remove_theme_color_override("font_color")
	else:
		var side = "我方" if leading_player == 0 else "对手"
		dot_label.text = "卖相压制: %s +%.1f/秒" % [side, dot_per_sec]
		var color = Color(0.27, 0.85, 0.48) if leading_player == 0 else Color(0.96, 0.30, 0.30)
		dot_label.add_theme_color_override("font_color", color)

func update_environment(env_keywords: Dictionary):
	if env_label == null:
		return
	var parts: Array[String] = []
	for kw_id in env_keywords:
		var stacks = env_keywords[kw_id]
		if stacks > 0:
			var kw = KeywordDatabase.get_keyword(kw_id)
			var name = kw.get("name", kw_id) if not kw.is_empty() else kw_id
			parts.append("%s ×%d" % [name, stacks])
	env_label.text = "环境: " + (" ".join(parts) if not parts.is_empty() else "无")

func _update_leader_glow(p1_score: float, p2_score: float) -> void:
	if p1_score_label == null or p2_score_label == null:
		return

	if absf(p1_score - p2_score) < 0.01:
		p1_score_label.remove_theme_color_override("font_color")
		p2_score_label.remove_theme_color_override("font_color")
		return
	if p1_score > p2_score:
		p1_score_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
		p2_score_label.add_theme_color_override("font_color", Color(0.78, 0.78, 0.82))
	else:
		p2_score_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
		p1_score_label.add_theme_color_override("font_color", Color(0.78, 0.78, 0.82))

func _apply_bar_shader(bar: ProgressBar) -> void:
	if bar == null:
		return
	var shader = load("res://ui/shaders/score_bar_fill.gdshader")
	if shader:
		var mat = ShaderMaterial.new()
		mat.shader = shader
		bar.material = mat

func _update_diff(p1_score: float, p2_score: float) -> void:
	# Keeps the lead state readable without scanning both raw scores.
	if diff_label == null:
		return
	var diff = p1_score - p2_score
	if absf(diff) < 1.0:
		diff_label.text = "平分秋色"
		diff_label.add_theme_color_override("font_color", Color(0.78, 0.78, 0.82))
	elif diff > 0:
		diff_label.text = "我方领先 +%d" % int(diff)
		diff_label.add_theme_color_override("font_color", Color(0.27, 0.85, 0.48))
	else:
		diff_label.text = "对手领先 +%d" % int(absf(diff))
		diff_label.add_theme_color_override("font_color", Color(0.96, 0.30, 0.30))


