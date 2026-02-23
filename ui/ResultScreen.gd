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

@onready var stats_grid_parent: VBoxContainer = $Center/MainPanel/Margin/VBox/AnalysisScroll/AnalysisPanel/StatsGrid
@onready var contrib_list: VBoxContainer = $Center/MainPanel/Margin/VBox/AnalysisScroll/AnalysisPanel/ContribList
@onready var clash_label: Label = $Center/MainPanel/Margin/VBox/AnalysisScroll/AnalysisPanel/ClashLabel
@onready var comments_box: VBoxContainer = $Center/MainPanel/Margin/VBox/JudgeComments
@onready var continue_btn: Button = $Center/MainPanel/Margin/VBox/ContinueButton

const ItemCardScene := preload("res://ui/components/ItemCard.tscn")
const CARD_SCALE := 0.55
const STAT_ROW_LABELS := ["基础风味", "触发次数", "总输出", "场均输出", "输出占比"]

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
	var diff := absi(p_score - o_score)

	if p_score > o_score:
		title_label.text = prefix + "胜利！领先 +%d 分" % diff
		title_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	elif p_score < o_score:
		title_label.text = prefix + "败北…落后 %d 分" % diff
		title_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	else:
		title_label.text = prefix + "平局"
		title_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

	var anims = get_node_or_null("/root/UIAnimations")
	if anims:
		anims.call("pulse", title_label, 1.2, 0.5)

func _show_analysis(analysis: Dictionary) -> void:
	# Clear previous content
	for child in contrib_list.get_children():
		child.queue_free()
	for child in stats_grid_parent.get_children():
		child.queue_free()

	var item_contributions: Array = analysis.get("item_contributions", [{}, {}])
	if item_contributions.size() == 0 or not (item_contributions[0] is Dictionary):
		return

	var p_contribs: Dictionary = item_contributions[0]
	var match_state = GameManager.get_match_state()
	if not match_state:
		return

	# Collect board items in slot order
	var board_items: Array = []  # [{slot, item_data, contrib_data}]
	var p_board: Array = match_state.players[0].board
	for i in range(p_board.size()):
		var item = p_board[i]
		if item != null and item is Dictionary and not item.has("_ref_to"):
			var item_id := str(item.get("id", ""))
			if not item_id.is_empty():
				var contrib: Dictionary = {}
				if p_contribs.has(i):
					contrib = p_contribs[i]
				board_items.append({
					"slot": i,
					"item_data": item,
					"name": str(contrib.get("name", item.get("name", "???"))),
					"base_flavor": float(contrib.get("base_flavor", item.get("flavor", 0))),
					"trigger_count": int(contrib.get("trigger_count", 0)),
					"total_score": float(contrib.get("total_score", 0.0)),
				})

	if board_items.is_empty():
		return

	# Compute totals and MVP
	var total_flavor: float = 0.0
	var max_score: float = 0.0
	var mvp_idx: int = -1
	for i in range(board_items.size()):
		total_flavor += board_items[i].total_score
		if board_items[i].total_score > max_score:
			max_score = board_items[i].total_score
			mvp_idx = i

	var col_count: int = 1 + board_items.size()  # label col + item cols

	# --- Build GridContainer ---
	var grid := GridContainer.new()
	grid.columns = col_count
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)

	# Row 0: Header row — empty corner + ItemCards
	var corner := Control.new()
	corner.custom_minimum_size = Vector2(80, int(240 * CARD_SCALE))
	grid.add_child(corner)

	for bi in board_items:
		var card_wrapper := Control.new()
		var scaled_w := int(160 * CARD_SCALE * bi.item_data.get("size", 1))
		var scaled_h := int(240 * CARD_SCALE)
		card_wrapper.custom_minimum_size = Vector2(scaled_w, scaled_h)
		card_wrapper.clip_contents = true
		var card = ItemCardScene.instantiate()
		card.setup(bi.item_data)
		card.scale = Vector2(CARD_SCALE, CARD_SCALE)
		card.position = Vector2.ZERO
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_wrapper.add_child(card)
		grid.add_child(card_wrapper)

	# Stat rows
	for row_idx in range(STAT_ROW_LABELS.size()):
		# Row label
		var row_label := Label.new()
		row_label.text = STAT_ROW_LABELS[row_idx]
		row_label.add_theme_font_size_override("font_size", 14)
		row_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
		row_label.custom_minimum_size = Vector2(80, 0)
		row_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		grid.add_child(row_label)

		# Data cells
		for i in range(board_items.size()):
			var bi = board_items[i]
			var cell := Label.new()
			cell.add_theme_font_size_override("font_size", 15)
			cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cell.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cell.custom_minimum_size = Vector2(int(160 * CARD_SCALE), 0)

			var is_mvp := (i == mvp_idx and max_score > 0.0)

			match row_idx:
				0:  # 基础风味
					cell.text = "%d" % int(bi.base_flavor)
					cell.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
				1:  # 触发次数
					cell.text = "%d 次" % bi.trigger_count
					cell.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
				2:  # 总输出
					cell.text = "%d" % int(bi.total_score)
					if is_mvp:
						cell.add_theme_color_override("font_color", Color(0.95, 0.82, 0.45))
					else:
						cell.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
				3:  # 场均输出
					var avg: float = bi.total_score / maxf(1.0, float(bi.trigger_count))
					cell.text = "%.1f" % avg
					cell.add_theme_color_override("font_color", Color(0.8, 0.9, 0.8))
				4:  # 输出占比
					var pct: float = (bi.total_score / maxf(1.0, total_flavor)) * 100.0
					cell.text = "%.0f%%" % pct
					if is_mvp:
						cell.add_theme_color_override("font_color", Color(0.95, 0.82, 0.45))
					else:
						cell.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))

			grid.add_child(cell)

	# MVP row
	var mvp_label := Label.new()
	mvp_label.text = "MVP"
	mvp_label.add_theme_font_size_override("font_size", 14)
	mvp_label.add_theme_color_override("font_color", Color(0.95, 0.82, 0.45))
	mvp_label.custom_minimum_size = Vector2(80, 0)
	mvp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	grid.add_child(mvp_label)

	for i in range(board_items.size()):
		var cell := Label.new()
		cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.custom_minimum_size = Vector2(int(160 * CARD_SCALE), 0)
		if i == mvp_idx and max_score > 0.0:
			cell.text = "★"
			cell.add_theme_font_size_override("font_size", 20)
			cell.add_theme_color_override("font_color", Color(0.95, 0.82, 0.45))
		else:
			cell.text = ""
		grid.add_child(cell)

	stats_grid_parent.add_child(grid)

	# --- Score summary ---
	var scores: Array = match_state.showdown_scores
	var p_score: float = float(scores[0])
	var o_score: float = float(scores[1])
	var diff: float = absf(p_score - o_score)
	var total_triggers := 0
	for bi in board_items:
		total_triggers += bi.trigger_count

	var summary_label := Label.new()
	summary_label.add_theme_font_size_override("font_size", 15)
	summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if p_score > o_score:
		summary_label.text = "以 %d 分优势获胜 (总计 %d 分 / 触发 %d 次)" % [int(diff), int(total_flavor), total_triggers]
		summary_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	elif p_score < o_score:
		summary_label.text = "以 %d 分之差落败 (总计 %d 分 / 触发 %d 次)" % [int(diff), int(total_flavor), total_triggers]
		summary_label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.5))
	else:
		summary_label.text = "平局 (总计 %d 分 / 触发 %d 次)" % [int(total_flavor), total_triggers]
		summary_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	contrib_list.add_child(summary_label)

	# --- Clash penalties ---
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

func _extract_best_dish(analysis: Dictionary, p_idx: int) -> Dictionary:
	var item_contributions: Array = analysis.get("item_contributions", [{}, {}])
	if p_idx >= item_contributions.size():
		return {"name": "", "score": 0.0, "triggers": 0}
	var contribs: Dictionary = item_contributions[p_idx]
	var best := {"name": "", "score": 0.0, "triggers": 0}
	for slot_idx in contribs:
		var data = contribs[slot_idx]
		if data is Dictionary:
			var sc: float = float(data.get("total_score", 0.0))
			if sc > best.score:
				best = {"name": str(data.get("name", "???")), "score": sc, "triggers": int(data.get("trigger_count", 0))}
	return best

func _count_pref_matches(judge: Dictionary, analysis: Dictionary) -> int:
	var match_state = GameManager.get_match_state()
	if not match_state:
		return 0
	var jid := str(judge.get("id", "")).to_lower()
	var judge_v2: Dictionary = JudgeDatabase.get_judge_v2(jid)
	var pref_tags: Array = judge_v2.get("pref", [])
	if pref_tags.is_empty():
		return 0
	var count := 0
	var p_board: Array = match_state.players[0].board
	for item in p_board:
		if item != null and item is Dictionary and not item.has("_ref_to"):
			var tags: Array = item.get("tags", [])
			for pt in pref_tags:
				if tags.has(pt):
					count += 1
					break
	return count

func _count_hate_matches(judge: Dictionary, analysis: Dictionary) -> int:
	var match_state = GameManager.get_match_state()
	if not match_state:
		return 0
	var jid := str(judge.get("id", "")).to_lower()
	var judge_v2: Dictionary = JudgeDatabase.get_judge_v2(jid)
	var hate_tags: Array = judge_v2.get("hate", [])
	if hate_tags.is_empty():
		return 0
	var count := 0
	var p_board: Array = match_state.players[0].board
	for item in p_board:
		if item != null and item is Dictionary and not item.has("_ref_to"):
			var tags: Array = item.get("tags", [])
			for ht in hate_tags:
				if tags.has(ht):
					count += 1
					break
	return count

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
	var p_score := float(scores[0])
	var o_score := float(scores[1])
	var won := p_score > o_score
	var diff := absf(p_score - o_score)
	var total := p_score + o_score
	var margin := diff / maxf(1.0, total / 2.0)
	var is_close := margin < 0.10
	var is_stomp := margin > 0.40
	var jid := str(judge.get("id", "unknown")).to_lower()

	# Extract data-driven context
	var best_dish: Dictionary = _extract_best_dish(analysis, 0)
	var best_name: String = best_dish.get("name", "")
	var best_score: int = int(best_dish.get("score", 0))
	var pref_count: int = _count_pref_matches(judge, analysis)
	var hate_count: int = _count_hate_matches(judge, analysis)

	# Build data snippet for insertion
	var dish_mention := ""
	if not best_name.is_empty() and best_score > 0:
		dish_mention = "「%s」贡献了%d分，" % [best_name, best_score]

	match jid:
		"yuyuko":
			if won and is_stomp:
				return "%s把我喂得饱饱的！以%d分的巨大优势碾压对手，这桌菜太丰盛了！" % [dish_mention, int(diff)]
			if won:
				return "%s真是一道好菜！这顿饭吃得心满意足，以%d分的优势赢下了这场比试。" % [dish_mention, int(diff)]
			if is_close:
				return "两边的菜都很好吃，差距只有%d分...不过我总觉得还差那么一口，再多加点料就好了。" % int(diff)
			return "没吃饱呢...%s虽然不错，但整体菜单的分量不够。输了%d分，下次多准备些硬菜吧。" % [dish_mention if not dish_mention.is_empty() else "你的招牌菜", int(diff)]

		"yuuma":
			if won and is_stomp:
				return "痛快！%s这道菜的霸道味道让我很满意！%d分的碾压，这才配得上饕餮的食桌！" % [dish_mention, int(diff)]
			if won:
				return "%s味道够劲！以%d分获胜，你的菜有那股让人上瘾的狠劲。" % [dish_mention, int(diff)]
			if is_close:
				return "就差%d分...两边都不够猛。你的菜缺少那种让人一口就被征服的冲击力。" % int(diff)
			return "太弱了！%s%d分的差距说明你根本不懂什么叫浓郁。给我端上真正有力量的菜来！" % [dish_mention, int(diff)]

		"eiki":
			if won:
				if pref_count >= 3:
					return "%s表现出色。以%d分获胜，菜单中有%d道菜符合我的审美标准，这是一份端正的菜谱。" % [dish_mention, int(diff), pref_count]
				return "%s以%d分的优势取胜。整体发挥均衡得体，这是正道的胜利。" % [dish_mention, int(diff)]
			if is_close:
				return "仅差%d分。双方实力相当，但你在细节上稍有懈怠。回去仔细复盘每道菜的表现吧。" % int(diff)
			if hate_count >= 2:
				return "你有%d道菜与我的口味相悖，这直接拖累了评分。输掉%d分，必须重新审视你的菜单。" % [hate_count, int(diff)]
			return "%s虽有亮点，但整体不够严谨。%d分的败北，说明菜单中存在明显的短板。" % [dish_mention, int(diff)]

		"remilia":
			if won:
				if pref_count >= 3:
					return "哼，%s总算拿得出手了。%d道菜合本小姐的口味，以%d分赢下比赛，勉强及格。" % [dish_mention, pref_count, int(diff)]
				return "%s还行吧。以%d分获胜，但别得意，离红魔馆的标准还差得远呢。" % [dish_mention, int(diff)]
			if hate_count >= 2:
				return "你居然敢端上%d道清淡寡味的菜？！输掉%d分是你活该，本小姐需要的是浓郁华贵的料理！" % [hate_count, int(diff)]
			return "%s平民的水准。输了%d分，回去好好学学什么叫贵族的餐桌吧。" % [dish_mention, int(diff)]

		"tenshi":
			if won and is_stomp:
				return "哈哈哈！%s这道菜太过瘾了！%d分的大胜，就是这种碾压的感觉才有趣嘛！" % [dish_mention, int(diff)]
			if won:
				return "%s不错嘛！以%d分取胜，这顿饭还挺刺激的。" % [dish_mention, int(diff)]
			if is_close:
				return "啊~就差%d分，太无聊了！两边都不够刺激，能不能做点更有爆发力的菜？" % int(diff)
			return "就这？%s也就那样吧。输了%d分，你这厨艺一点也不好玩。" % [dish_mention, int(diff)]

		"kokoro":
			if won:
				return "从%s中我感受到了厨师的热情。以%d分获胜，你的菜里充满了真挚的感情。" % [dish_mention, int(diff)]
			if is_close:
				return "两位厨师的情感都很复杂呢...%d分之差，你的表达只差一点就能打动我了。" % int(diff)
			return "%s虽然有心意，但%d分的差距说明情感的传达还不够充分。再用心一些吧。" % [dish_mention, int(diff)]

		"iku":
			if won:
				if pref_count >= 3:
					return "%s让整桌菜的氛围非常和谐。%d道菜与我的品味相符，以%d分优雅地赢下了比赛。" % [dish_mention, pref_count, int(diff)]
				return "%s以%d分取胜。今天的用餐氛围不错，希望下次能看到更多元化的菜系搭配。" % [dish_mention, int(diff)]
			return "气氛有些沉重呢...%s%d分的差距，或许增加一些清爽的菜品能改善整体节奏。" % [dish_mention, int(diff)]

		"miko":
			if won:
				if pref_count >= 3:
					return "吾感受到了和谐之美。%s表现优异，%d道精进之作让菜单整体以%d分获胜。" % [dish_mention, pref_count, int(diff)]
				return "%s以%d分取胜。菜单展现了不错的平衡感，继续精进吧。" % [dish_mention, int(diff)]
			return "%s%d分之差落败。吾建议拓宽菜系的多样性，让不同风味和谐共存。" % [dish_mention, int(diff)]

		"yuuka":
			if won:
				return "%s如同精心培育的花朵般绽放了。以%d分获胜，这份美感让我很满意。" % [dish_mention, int(diff)]
			if hate_count >= 1:
				return "油炸物的粗糙让我皱眉...%d分的落差，请多用些新鲜蔬菜和清雅的茶品。" % int(diff)
			return "%s力量不足。%d分的差距，需要更纯粹的美学表达。" % [dish_mention, int(diff)]

		"raiko":
			if won:
				return "节奏感很棒！%s的出菜频率完美踩上了鼓点！以%d分获胜，请继续保持这个tempo！" % [dish_mention, int(diff)]
			return "节奏乱了...%s%d分的差距说明出菜的节奏还需要磨练。跟上我的鼓点！" % [dish_mention, int(diff)]

		"yukari":
			if won:
				return "呵呵，%s倒是挺有意思的。以%d分获胜——不过，今天的规则，由我来定。" % [dish_mention, int(diff)]
			return "境界之外的东西果然还是差了点呢。%s%d分的差距，想赢我的评审可没那么容易。" % [dish_mention, int(diff)]

		"aya":
			if won:
				return "独家报道！%s惊艳全场！以%d分力压对手的精彩一战！这条新闻一定能上头版！" % [dish_mention, int(diff)]
			if is_close:
				return "只差%d分...本来想写条大新闻的，结果虎头蛇尾。菜单里需要更多上镜的亮点菜品。" % int(diff)
			return "这种平庸的菜谱完全不值得报道。%s%d分的惨败，毫无新闻价值。" % [dish_mention, int(diff)]

		"patchouli":
			if won:
				return "理论上讲，%s的元素配比接近最优解。以%d分获胜，这是经过深思熟虑的菜谱设计。" % [dish_mention, int(diff)]
			return "%s的理论构架存在缺陷。%d分的差距揭示了调味配比中的系统性问题，需要重新计算。" % [dish_mention, int(diff)]

	# Fallback for unmapped judges
	if won:
		return "%s表现突出，以%d分的优势赢得了比赛。" % [dish_mention, int(diff)]
	else:
		return "%s%d分之差落败，菜单整体还有提升空间。" % [dish_mention, int(diff)]

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
