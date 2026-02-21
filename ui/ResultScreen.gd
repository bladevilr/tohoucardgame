extends Control

@onready var title_label: Label = $Center/MainPanel/Margin/VBox/TitleLabel
@onready var p_base: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/PlayerCol/ScoreRows/Base
@onready var p_tech: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/PlayerCol/ScoreRows/Tech
@onready var p_pres: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/PlayerCol/ScoreRows/Pres
@onready var p_judge: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/PlayerCol/ScoreRows/Judge
@onready var p_total: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/PlayerCol/Total
@onready var p_name: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/PlayerCol/Name
@onready var p_portrait: TextureRect = $Center/MainPanel/Margin/VBox/ScoreBoard/PlayerCol/Portrait

@onready var o_base: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/OpponentCol/ScoreRows/Base
@onready var o_tech: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/OpponentCol/ScoreRows/Tech
@onready var o_pres: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/OpponentCol/ScoreRows/Pres
@onready var o_judge: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/OpponentCol/ScoreRows/Judge
@onready var o_total: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/OpponentCol/Total
@onready var o_name: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/OpponentCol/Name
@onready var o_portrait: TextureRect = $Center/MainPanel/Margin/VBox/ScoreBoard/OpponentCol/Portrait

@onready var row_l1: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/LabelsCol/RowLabels/L1
@onready var row_l2: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/LabelsCol/RowLabels/L2
@onready var row_l3: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/LabelsCol/RowLabels/L3
@onready var row_l4: Label = $Center/MainPanel/Margin/VBox/ScoreBoard/LabelsCol/RowLabels/L4

@onready var contrib_list: VBoxContainer = $Center/MainPanel/Margin/VBox/AnalysisPanel/ContribList
@onready var clash_label: Label = $Center/MainPanel/Margin/VBox/AnalysisPanel/ClashLabel
@onready var comments_box: VBoxContainer = $Center/MainPanel/Margin/VBox/JudgeComments
@onready var continue_btn: Button = $Center/MainPanel/Margin/VBox/ContinueButton

const CHEF_NAME_MAP := {
	"mystia": "米斯蒂娅",
	"sakuya": "十六夜咲夜",
	"youmu": "魂魄妖梦",
	"meiling": "红美铃",
	"marisa": "雾雨魔理沙",
	"reimu": "博丽灵梦",
	"alice": "爱丽丝",
	"patchouli": "帕秋莉",
	"reisen": "铃仙",
	"seija": "鬼人正邪",
}

const CUISINE_NAME_MAP := {
	"washoku": "和食",
	"chuuka": "中华",
	"youshoku": "洋食",
	"yatai": "夜市",
	"kanmi": "甜品",
	"yakuzen": "药膳",
}

func _ready() -> void:
	_apply_bg_shader()
	var match_state = GameManager.get_match_state()
	if not match_state:
		return

	_apply_localized_labels(match_state)
	_reset_labels()
	continue_btn.visible = false
	clash_label.text = ""

	var scores: Array = match_state.showdown_scores
	var analysis: Dictionary = match_state.get_meta("showdown_analysis", {})
	var p_data := _parse_player_data(float(scores[0]), analysis, 0)
	var o_data := _parse_player_data(float(scores[1]), analysis, 1)

	var tween := create_tween()

	tween.tween_callback(func():
		_show_row(p_base, o_base, p_data.base, o_data.base)
	).set_delay(0.45)

	tween.tween_callback(func():
		p_tech.text = "x%.2f" % p_data.tech
		o_tech.text = "x%.2f" % o_data.tech
		_pulse([p_tech, o_tech])
	).set_delay(0.55)

	tween.tween_callback(func():
		_show_row(p_pres, o_pres, p_data.dot, o_data.dot, true)
	).set_delay(0.55)

	tween.tween_callback(func():
		_show_row(p_judge, o_judge, p_data.judge, o_data.judge, true)
	).set_delay(0.55)

	tween.tween_interval(0.35)
	tween.tween_method(_animate_totals.bind(p_data.total, o_data.total), 0.0, 1.0, 0.95).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_callback(func():
		_show_result(p_data.total, o_data.total)
		_show_analysis(analysis)
		_show_comments(match_state.judges, scores, analysis)
		continue_btn.visible = true
	)

	continue_btn.pressed.connect(_on_continue)

func _apply_localized_labels(match_state) -> void:
	var p = match_state.get_player(0)
	var o = match_state.get_player(1)
	p_name.text = "我方 · " + _display_chef_name(p.chef_id)
	o_name.text = "对手 · " + _display_chef_name(o.chef_id)
	p_portrait.texture = ArtDatabase.get_chef_portrait(p.chef_id)
	o_portrait.texture = ArtDatabase.get_chef_portrait(o.chef_id)
	p_portrait.visible = p_portrait.texture != null
	o_portrait.visible = o_portrait.texture != null

	row_l1.text = "上菜基础分"
	row_l2.text = "技法倍率"
	row_l3.text = "卖相压制"
	row_l4.text = "评委修正"
	continue_btn.text = "继续"

func _parse_player_data(total_score: float, analysis: Dictionary, idx: int) -> Dictionary:
	var tech_mults: Array = analysis.get("technique_mults", [1.0, 1.0])
	var dot_totals: Array = analysis.get("dot_totals", [0.0, 0.0])
	var tech := float(tech_mults[idx]) if tech_mults.size() > idx else 1.0
	var dot := float(dot_totals[idx]) if dot_totals.size() > idx else 0.0
	var base := (total_score - dot) / maxf(tech, 0.1)

	return {
		"base": int(base),
		"tech": tech,
		"dot": int(dot),
		"judge": 0,
		"total": int(total_score),
	}

func _reset_labels() -> void:
	p_base.text = "-"
	o_base.text = "-"
	p_tech.text = "-"
	o_tech.text = "-"
	p_pres.text = "-"
	o_pres.text = "-"
	p_judge.text = "-"
	o_judge.text = "-"
	p_total.text = "0"
	o_total.text = "0"
	title_label.text = ""

func _show_row(l1: Label, l2: Label, v1: float, v2: float, show_sign: bool = false) -> void:
	var fmt := "%+d" if show_sign else "%d"
	l1.text = fmt % int(v1)
	l2.text = fmt % int(v2)
	_pulse([l1, l2])

func _pulse(nodes: Array) -> void:
	var anims = get_node_or_null("/root/UIAnimations")
	if anims:
		for n in nodes:
			anims.call("pop_in", n, 0.2)

func _animate_totals(t: float, target_p: int, target_o: int) -> void:
	p_total.text = "%d" % int(lerp(0.0, float(target_p), t))
	o_total.text = "%d" % int(lerp(0.0, float(target_o), t))

func _show_result(p_score: int, o_score: int) -> void:
	var match_state = GameManager.get_match_state()
	var is_pve := false
	if match_state:
		is_pve = match_state.current_action_data.get("phase", "") == "PVE_BATTLE"

	var prefix := "试营业 · " if is_pve else ""

	if p_score > o_score:
		title_label.text = prefix + "胜利"
		title_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	elif p_score < o_score:
		title_label.text = prefix + "败北"
		title_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	else:
		title_label.text = prefix + "平局"
		title_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

	var anims = get_node_or_null("/root/UIAnimations")
	if anims:
		anims.call("pulse", title_label, 1.2, 0.5)

func _show_analysis(analysis: Dictionary) -> void:
	for child in contrib_list.get_children():
		child.queue_free()

	var item_contributions: Array = analysis.get("item_contributions", [{}, {}])
	if item_contributions.size() > 0 and item_contributions[0] is Dictionary:
		var p_contribs: Dictionary = item_contributions[0]
		var sorted_items: Array = []
		for slot_idx in p_contribs:
			var data = p_contribs[slot_idx]
			if data is Dictionary:
				sorted_items.append({"name": data.get("name", "???"), "score": float(data.get("total_score", 0.0))})
		sorted_items.sort_custom(func(a, b): return a.score > b.score)

		var total_flavor: float = 0.0
		for it in sorted_items:
			total_flavor += it.score

		for i in range(mini(sorted_items.size(), 5)):
			var item = sorted_items[i]
			var pct: float = (item.score / maxf(1.0, total_flavor)) * 100.0
			var label: Label = Label.new()
			label.text = "%d. %s: %d分 (%.0f%%)" % [i + 1, item.name, int(item.score), pct]
			label.add_theme_font_size_override("font_size", 16)
			label.add_theme_color_override("font_color", Color(1, 0.88, 0.35) if i == 0 else Color(0.8, 0.8, 0.85))
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			contrib_list.add_child(label)

	var clash_penalties: Array = analysis.get("clash_penalties", [])
	if clash_penalties.is_empty():
		clash_label.text = ""
		return

	var clash_parts: Array[String] = []
	for cp in clash_penalties:
		if cp is Dictionary:
			var cuisine_key := str(cp.get("cuisine", ""))
			var cuisine_name: String = CUISINE_NAME_MAP.get(cuisine_key, cuisine_key)
			var loser := "我方" if int(cp.get("loser_idx", 0)) == 0 else "对手"
			var penalty := int(cp.get("penalty", 0))
			clash_parts.append("撞菜[%s]: %s -%d分" % [cuisine_name, loser, penalty])

	clash_label.text = "；".join(clash_parts)

func _show_comments(judges: Array, scores: Array, analysis: Dictionary) -> void:
	for child in comments_box.get_children():
		child.queue_free()

	for judge in judges:
		var panel := PanelContainer.new()
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.18, 0.25, 0.6)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_bottom_left = 8
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 6
		style.content_margin_bottom = 6
		panel.add_theme_stylebox_override("panel", style)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 16)
		var name_lbl := Label.new()
		name_lbl.text = str(judge.get("name", "评委"))
		name_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.6))

		var comment_lbl := Label.new()
		comment_lbl.text = "“%s”" % _get_dynamic_comment(judge, scores, analysis)
		comment_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		comment_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		comment_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		hbox.add_child(name_lbl)
		hbox.add_child(comment_lbl)
		panel.add_child(hbox)
		comments_box.add_child(panel)

func _get_dynamic_comment(judge: Dictionary, scores: Array, analysis: Dictionary) -> String:
	var won := float(scores[0]) > float(scores[1])
	var scoring: Dictionary = judge.get("scoring_modifiers", {})
	var dot_totals: Array = analysis.get("dot_totals", [0.0, 0.0])
	var tech_mults: Array = analysis.get("technique_mults", [1.0, 1.0])

	if scoring.has("flavor_mult"):
		return "风味层次很亮眼，技法倍率达到 x%.2f。" % float(tech_mults[0]) if won else "对手风味掌控更稳，后续可加强风味爆发。"

	if scoring.has("dot_mult"):
		var p_dot := float(dot_totals[0])
		var o_dot := float(dot_totals[1])
		if p_dot > o_dot:
			return "卖相压制明显，持续得分优势建立得很好。"
		elif o_dot > p_dot:
			return "对手卖相更强，建议补足摆盘体系。"
		return "双方卖相势均力敌，胜负主要看爆发。"

	if judge.get("id", "") == "eiki":
		var diff := absf(float(scores[0]) - float(scores[1]))
		var total := float(scores[0]) + float(scores[1])
		if total > 0.0 and diff / (total / 2.0) < 0.10:
			return "势均力敌，双方都拿到了额外裁定加成。"
		return "胜负明确，判定结果无争议。" if won else "结果已经确定，下局还有机会翻盘。"

	return "这次发挥很出色，节奏和数值都到位。" if won else "思路没问题，再优化联动顺序会更强。"

func _display_chef_name(chef_id: String) -> String:
	if CHEF_NAME_MAP.has(chef_id):
		return CHEF_NAME_MAP[chef_id]
	var chef = ChefDatabase.get_chef(chef_id)
	if not chef.is_empty():
		return str(chef.get("name", chef_id))
	return chef_id

func _on_continue() -> void:
	var match_state = GameManager.get_match_state()
	if match_state:
		var p0 = match_state.get_player(0)
		var p1 = match_state.get_player(1)
		if p0.prestige <= 0 \
			or p1.prestige <= 0 \
			or p0.wins >= GameConfig.WINS_TO_CLEAR \
			or p1.wins >= GameConfig.WINS_TO_CLEAR:
			get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
			return
	GameManager.advance_phase()
	get_tree().change_scene_to_file("res://ui/GameBoard.tscn")

func _apply_bg_shader() -> void:
	var shader = load("res://ui/shaders/background_gradient.gdshader")
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		$Background.material = mat
