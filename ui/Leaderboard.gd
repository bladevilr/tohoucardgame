extends Control

## 排行榜 + 个人战绩统计界面

const BG_COLOR    := Color(0.05, 0.04, 0.09)           # 与 GameModeSelect 一致
const PANEL_COLOR := Color(0.08, 0.09, 0.14, 0.92)    # 与 CharacterSelect 一致
const ACCENT      := Color(0.85, 0.78, 1.0)
const GOLD_COLOR  := Color(1.0,  0.843, 0.0)           # 与 MainMenu 标题金一致

const CHEF_NAMES := {
	"mystia": "米斯蒂娅", "sakuya": "咲夜", "youmu": "妖梦",
	"meiling": "美铃",   "marisa": "魔理沙", "reimu": "灵梦",
	"alice": "爱丽丝",  "patchouli": "帕秋莉", "reisen": "铃仙",
}

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	# 背景
	var bg := ColorRect.new()
	bg.color = BG_COLOR
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var shader = load("res://ui/shaders/background_gradient.gdshader")
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		bg.material = mat

	# 顶部标题
	var title := Label.new()
	title.text = "排行榜 / 个人战绩"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", GOLD_COLOR)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_left = 0
	title.offset_top = 28
	title.offset_right = 0
	title.offset_bottom = 78
	add_child(title)

	# 主内容
	var main_hbox := HBoxContainer.new()
	main_hbox.add_theme_constant_override("separation", 32)
	main_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_hbox.position = Vector2(60, 100)
	main_hbox.size = Vector2(1800, 900)
	add_child(main_hbox)

	# 左：排行榜列表
	var left_panel := _make_panel()
	left_panel.custom_minimum_size = Vector2(860, 0)
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_hbox.add_child(left_panel)

	var left_vbox := VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 0)
	left_panel.add_child(left_vbox)
	_build_leaderboard(left_vbox)

	# 右：个人信息 + 统计
	var right_vbox := VBoxContainer.new()
	right_vbox.custom_minimum_size = Vector2(560, 0)
	right_vbox.add_theme_constant_override("separation", 20)
	right_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_hbox.add_child(right_vbox)

	_build_player_card(right_vbox)
	_build_stats_panel(right_vbox)

	# 返回按钮（样式与 GameModeSelect 次级按钮一致）
	var back_btn := Button.new()
	back_btn.text = "← 返回"
	back_btn.custom_minimum_size = Vector2(130, 44)
	back_btn.add_theme_font_size_override("font_size", 16)
	var bs := StyleBoxFlat.new()
	bs.bg_color = Color(0.227, 0.176, 0.314, 0.85)
	bs.border_width_left = 1; bs.border_width_top = 1
	bs.border_width_right = 1; bs.border_width_bottom = 1
	bs.border_color = Color(0.545, 0.396, 0.306)
	bs.corner_radius_top_left = 6; bs.corner_radius_top_right = 6
	bs.corner_radius_bottom_right = 6; bs.corner_radius_bottom_left = 6
	back_btn.add_theme_stylebox_override("normal", bs)
	var bs_h: StyleBoxFlat = bs.duplicate() as StyleBoxFlat
	bs_h.bg_color = Color(0.29, 0.24, 0.38, 0.9)
	bs_h.border_color = Color(0.788, 0.643, 0.290)
	back_btn.add_theme_stylebox_override("hover", bs_h)
	back_btn.add_theme_stylebox_override("pressed", bs)
	back_btn.add_theme_color_override("font_color", Color(0.941, 0.902, 0.827))
	back_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	back_btn.position = Vector2(40, -60)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/GameModeSelect.tscn"))
	add_child(back_btn)

# ── 排行榜列表
func _build_leaderboard(container: VBoxContainer) -> void:
	# 表头
	var header := _make_row_container(Color(0.15, 0.12, 0.25, 0.9))
	_add_rank_cell(header, "排名", 60, Color(0.75, 0.72, 0.88))
	_add_rank_cell(header, "玩家昵称", 280, Color(0.75, 0.72, 0.88))
	_add_rank_cell(header, "胜", 80, Color(0.75, 0.72, 0.88))
	_add_rank_cell(header, "负", 80, Color(0.75, 0.72, 0.88))
	_add_rank_cell(header, "胜率", 100, Color(0.75, 0.72, 0.88))
	_add_rank_cell(header, "积分", 120, Color(0.75, 0.72, 0.88))
	container.add_child(header)

	# 合并并排序榜单数据
	var entries: Array = _build_entries()
	var player_nick: String = SaveManager.get_nickname()
	var player_rating: int = SaveManager.get_player_rating()

	var row_idx: int = 0
	for i in range(entries.size()):
		var e: Dictionary = entries[i]
		var is_player: bool = (e.get("is_player", false))
		var row_color := Color(0.06, 0.05, 0.10, 0.9) if row_idx % 2 == 0 else Color(0.08, 0.07, 0.13, 0.9)
		if is_player:
			row_color = Color(0.18, 0.12, 0.32, 0.95)  # 玩家行高亮

		var row := _make_row_container(row_color)

		var rank_color := Color(0.82, 0.78, 0.95)
		if i == 0:
			rank_color = GOLD_COLOR
		elif i == 1:
			rank_color = Color(0.82, 0.82, 0.82)
		elif i == 2:
			rank_color = Color(0.72, 0.44, 0.22)

		_add_rank_cell(row, "#%d" % (i + 1), 60, rank_color)
		var name_color := ACCENT if is_player else Color(0.92, 0.88, 1.0)
		_add_rank_cell(row, str(e.get("display_name", "???")) + ("  ◀ 你" if is_player else ""), 280, name_color)
		_add_rank_cell(row, str(int(e.get("wins", 0))), 80, Color(0.38, 0.92, 0.55))
		_add_rank_cell(row, str(int(e.get("losses", 0))), 80, Color(0.92, 0.45, 0.45))
		var wr: float = float(e.get("winrate", 0.0))
		_add_rank_cell(row, "%.0f%%" % (wr * 100.0), 100, Color(0.85, 0.82, 0.55))
		_add_rank_cell(row, str(int(e.get("rating", 1000))), 120, rank_color)

		container.add_child(row)
		row_idx += 1

func _build_entries() -> Array:
	# 预置对手榜单
	var all_opps: Array = OpponentDatabase.get_all()
	var entries: Array = []
	for opp in all_opps:
		var r: int = int(opp.get("rating", 1000))
		var diff: int = int(opp.get("difficulty", 1))
		# 根据 rating 推算胜负（固定风格）
		var wins: int = int(r / 35) + randi() % 5
		var losses: int = maxi(0, int((2000 - r) / 50))
		entries.append({
			"display_name": opp.get("display_name", "???"),
			"wins": wins, "losses": losses,
			"winrate": float(wins) / float(wins + losses) if (wins + losses) > 0 else 0.5,
			"rating": r,
			"is_player": false,
		})

	# 玩家自己
	var stats := SaveManager.get_stats()
	var pw: int = int(stats.get("ranked_wins", 0))
	var pl: int = int(stats.get("ranked_losses", 0))
	var pr: int = SaveManager.get_player_rating()
	var nick: String = SaveManager.get_nickname()
	if nick == "":
		nick = "旅行者"
	entries.append({
		"display_name": nick,
		"wins": pw, "losses": pl,
		"winrate": float(pw) / float(pw + pl) if (pw + pl) > 0 else 0.0,
		"rating": pr,
		"is_player": true,
	})

	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["rating"]) > int(b["rating"])
	)
	return entries

# ── 玩家个人卡片
func _build_player_card(parent: VBoxContainer) -> void:
	var panel := _make_panel()
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	parent.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var stats := SaveManager.get_stats()
	var nick := SaveManager.get_nickname()
	if nick == "":
		nick = "旅行者（未设置昵称）"
	var rating := SaveManager.get_player_rating()
	var rw: int = int(stats.get("ranked_wins", 0))
	var rl: int = int(stats.get("ranked_losses", 0))
	var cw: int = int(stats.get("casual_wins", 0))
	var cl: int = int(stats.get("casual_losses", 0))

	var name_lbl := Label.new()
	name_lbl.text = nick
	name_lbl.add_theme_font_size_override("font_size", 24)
	name_lbl.add_theme_color_override("font_color", ACCENT)
	vbox.add_child(name_lbl)

	var rating_lbl := Label.new()
	rating_lbl.text = "积分  %d" % rating
	rating_lbl.add_theme_font_size_override("font_size", 20)
	rating_lbl.add_theme_color_override("font_color", GOLD_COLOR)
	vbox.add_child(rating_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(0.35, 0.30, 0.55, 0.6))
	vbox.add_child(sep)

	_add_stat_row(vbox, "排位战绩", "%d胜  %d负" % [rw, rl],
		Color(0.38, 0.92, 0.55) if rw > rl else Color(0.92, 0.45, 0.45))
	_add_stat_row(vbox, "休闲战绩", "%d胜  %d负" % [cw, cl], Color(0.82, 0.78, 0.95))
	_add_stat_row(vbox, "最高声望", str(stats.get("best_prestige", 0)), GOLD_COLOR)
	_add_stat_row(vbox, "最长坚持", "第 %d 天" % int(stats.get("best_day", 0)), Color(0.68, 0.88, 1.0))

# ── 统计面板（各厨师胜率条形图）
func _build_stats_panel(parent: VBoxContainer) -> void:
	var panel := _make_panel()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "各厨师使用统计"
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", Color(0.75, 0.72, 0.95))
	vbox.add_child(title)

	var chef_stats: Dictionary = SaveManager.get_stats().get("chef_stats", {})
	var chefs := ["mystia", "sakuya", "youmu", "meiling", "marisa", "reimu", "alice", "patchouli", "reisen"]
	for chef_id in chefs:
		var cs := SaveManager.get_chef_stat(chef_id)
		var games: int = int(cs.get("games", 0))
		var wins: int  = int(cs.get("wins", 0))
		if games == 0:
			continue
		var wr: float = float(wins) / float(games)
		_add_chef_bar(vbox, chef_id, games, wr)

	if chef_stats.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "还没有任何对战记录"
		empty_lbl.add_theme_font_size_override("font_size", 14)
		empty_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.68))
		vbox.add_child(empty_lbl)

func _add_chef_bar(parent: Control, chef_id: String, games: int, winrate: float) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)

	var name_lbl := Label.new()
	name_lbl.text = CHEF_NAMES.get(chef_id, chef_id)
	name_lbl.custom_minimum_size = Vector2(80, 0)
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(0.85, 0.82, 0.95))
	row.add_child(name_lbl)

	var bar_bg := PanelContainer.new()
	bar_bg.custom_minimum_size = Vector2(260, 18)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.12, 0.10, 0.20)
	bg_style.corner_radius_top_left = 4; bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_right = 4; bg_style.corner_radius_bottom_left = 4
	bar_bg.add_theme_stylebox_override("panel", bg_style)
	row.add_child(bar_bg)

	var bar_fill := ColorRect.new()
	bar_fill.color = Color(0.35, 0.85, 0.50) if winrate >= 0.5 else Color(0.82, 0.38, 0.38)
	bar_fill.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bar_fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	bar_bg.add_child(bar_fill)
	# 设置宽度比例通过 deferred call
	bar_bg.ready.connect(func():
		bar_fill.custom_minimum_size = Vector2(bar_bg.size.x * clampf(winrate, 0, 1), 0)
	)

	var pct_lbl := Label.new()
	pct_lbl.text = "%.0f%%  (%d局)" % [winrate * 100.0, games]
	pct_lbl.add_theme_font_size_override("font_size", 13)
	pct_lbl.add_theme_color_override("font_color", Color(0.72, 0.72, 0.82))
	row.add_child(pct_lbl)

# ── 工具函数
func _make_panel() -> PanelContainer:
	var p := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color = PANEL_COLOR
	s.border_width_left = 1; s.border_width_top = 1
	s.border_width_right = 1; s.border_width_bottom = 1
	s.border_color = Color(0.35, 0.30, 0.55, 0.7)
	s.corner_radius_top_left = 14; s.corner_radius_top_right = 14
	s.corner_radius_bottom_right = 14; s.corner_radius_bottom_left = 14
	s.content_margin_left = 20; s.content_margin_top = 18
	s.content_margin_right = 20; s.content_margin_bottom = 18
	p.add_theme_stylebox_override("panel", s)
	return p

func _make_row_container(color: Color) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 0)
	var bg := ColorRect.new()
	bg.color = color
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(bg)
	return h

func _add_rank_cell(row: HBoxContainer, text: String, min_w: int, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.custom_minimum_size = Vector2(min_w, 36)
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", color)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(lbl)

func _add_stat_row(parent: VBoxContainer, label: String, value: String, val_color: Color) -> void:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	parent.add_child(h)
	var lbl := Label.new()
	lbl.text = label
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", Color(0.68, 0.65, 0.82))
	lbl.custom_minimum_size = Vector2(120, 0)
	h.add_child(lbl)
	var val_lbl := Label.new()
	val_lbl.text = value
	val_lbl.add_theme_font_size_override("font_size", 15)
	val_lbl.add_theme_color_override("font_color", val_color)
	h.add_child(val_lbl)
