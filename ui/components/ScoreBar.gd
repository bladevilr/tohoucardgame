extends VBoxContainer

## 分差制血槽 — 200分总量，中间为0分差，左右各100分
## P1(我方)得分推向右侧蓝色，P2(对手)得分推向左侧红色

@onready var p1_score_label: Label = $ScoreRow/P1Score
@onready var p2_score_label: Label = $ScoreRow/P2Score
@onready var diff_bar: ProgressBar = $ScoreRow/BarWrapper/DiffBar
@onready var center_line: ColorRect = $ScoreRow/BarWrapper/CenterLine
@onready var diff_label: Label = $DetailRow/DiffLabel

var _threshold: float = 100.0

func _ready() -> void:
	_threshold = GameConfig.SCORE_DIFF_WIN_THRESHOLD
	if p1_score_label:
		p1_score_label.visible = true
		p1_score_label.add_theme_font_size_override("font_size", 48)
	if p2_score_label:
		p2_score_label.visible = true
		p2_score_label.add_theme_font_size_override("font_size", 48)
	if diff_label:
		diff_label.add_theme_font_size_override("font_size", 24)
	_apply_bar_styles()

func _apply_bar_styles() -> void:
	if diff_bar == null:
		return
	diff_bar.max_value = _threshold * 2.0
	diff_bar.value = _threshold
	diff_bar.custom_minimum_size.y = 48
	diff_bar.show_percentage = false

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.85, 0.35, 0.3, 0.9)
	bg.corner_radius_top_left = 6; bg.corner_radius_top_right = 6
	bg.corner_radius_bottom_left = 6; bg.corner_radius_bottom_right = 6
	bg.border_width_left = 2; bg.border_width_top = 2
	bg.border_width_right = 2; bg.border_width_bottom = 2
	bg.border_color = Color(0.4, 0.35, 0.5, 0.8)

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.35, 0.7, 1.0, 0.95)
	fill.corner_radius_top_left = 4; fill.corner_radius_bottom_left = 4

	diff_bar.add_theme_stylebox_override("background", bg)
	diff_bar.add_theme_stylebox_override("fill", fill)

func update_scores(p1_score: float, p2_score: float) -> void:
	if p1_score_label:
		p1_score_label.text = "%d" % int(p1_score)
	if p2_score_label:
		p2_score_label.text = "%d" % int(p2_score)

	var diff := p1_score - p2_score
	# bar value: threshold = center (tie), 2*threshold = P1 wins, 0 = P2 wins
	if diff_bar:
		diff_bar.value = _threshold + clampf(diff, -_threshold, _threshold)

	_update_leader_glow(diff)
	_update_diff(diff)

func _update_leader_glow(diff: float) -> void:
	if p1_score_label == null or p2_score_label == null:
		return
	if absf(diff) < 1.0:
		p1_score_label.remove_theme_color_override("font_color")
		p2_score_label.remove_theme_color_override("font_color")
		return
	if diff > 0:
		p1_score_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
		p2_score_label.add_theme_color_override("font_color", Color(0.78, 0.78, 0.82))
	else:
		p2_score_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
		p1_score_label.add_theme_color_override("font_color", Color(0.78, 0.78, 0.82))

func _update_diff(diff: float) -> void:
	if diff_label == null:
		return
	if absf(diff) < 1.0:
		diff_label.text = "平分秋色"
		diff_label.add_theme_color_override("font_color", Color(0.78, 0.78, 0.82))
	elif diff > 0:
		diff_label.text = "我方领先 +%d / %d" % [int(diff), int(_threshold)]
		diff_label.add_theme_color_override("font_color", Color(0.27, 0.85, 0.48))
	else:
		diff_label.text = "对手领先 +%d / %d" % [int(absf(diff)), int(_threshold)]
		diff_label.add_theme_color_override("font_color", Color(0.96, 0.30, 0.30))

func update_dot(_dot_per_sec: float, _leading_player: int) -> void:
	pass

func update_environment(_env_keywords: Dictionary) -> void:
	pass
