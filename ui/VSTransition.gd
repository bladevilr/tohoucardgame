extends Control

## VS 过场界面 — 对决开始前的双方厨师头像动画
## 3.5秒后自动跳转到 ShowdownView.tscn

const CUISINE_COLORS := {
	"washoku":  Color(0.83, 0.34, 0.34),
	"chuuka":   Color(0.80, 0.20, 0.18),
	"youshoku": Color(0.18, 0.44, 0.88),
	"yatai":    Color(0.82, 0.48, 0.12),
	"kanmi":    Color(0.62, 0.30, 0.82),
	"yakuzen":  Color(0.18, 0.56, 0.32),
}

func _ready() -> void:
	var match_state := GameManager.get_match_state()
	if match_state == null:
		_advance()
		return

	var player_chef_id: String = match_state.players[0].chef_id
	var opp_chef_id: String    = match_state.players[1].chef_id
	var player_name: String    = SaveManager.get_nickname()
	if player_name == "":
		player_name = _chef_display_name(player_chef_id)
	var opp_name: String       = match_state.opponent_display_name
	if opp_name == "":
		opp_name = _chef_display_name(opp_chef_id)
	var day: int               = match_state.current_day
	var player_color: Color    = _chef_accent(player_chef_id)

	_build_scene(player_chef_id, opp_chef_id, player_name, opp_name, day, player_color)

func _build_scene(player_chef: String, opp_chef: String,
		player_name: String, opp_name: String, day: int, player_color: Color) -> void:
	# ── 黑色背景
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.01, 0.04)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# ── 中央粒子（如有）
	var pfx = get_node_or_null("/root/ParticleFactory")
	if pfx and pfx.has_method("spawn_ambient"):
		pfx.call("spawn_ambient", self, Color(0.18, 0.12, 0.35, 0.25))

	# ── 左侧玩家区
	# ── 左侧玩家区（占左半屏）
	var left_anchor := Control.new()
	left_anchor.anchor_left = 0.0
	left_anchor.anchor_right = 0.5
	left_anchor.anchor_top = 0.0
	left_anchor.anchor_bottom = 1.0
	left_anchor.offset_left = 0
	left_anchor.offset_right = 0
	left_anchor.offset_top = 0
	left_anchor.offset_bottom = 0
	add_child(left_anchor)

	var player_portrait := _make_portrait(player_chef, player_color)
	player_portrait.set_anchors_preset(Control.PRESET_CENTER)
	player_portrait.position = Vector2(-1200, -200)  # 从左侧屏外开始
	left_anchor.add_child(player_portrait)

	var player_name_lbl := _make_name_label(player_name, player_color.lightened(0.3), 22)
	player_name_lbl.set_anchors_preset(Control.PRESET_CENTER)
	player_name_lbl.position = Vector2(-260, 160)
	player_name_lbl.modulate.a = 0.0
	left_anchor.add_child(player_name_lbl)

	var player_sub := _make_name_label("★ 我方", Color(0.75, 0.75, 0.85), 14)
	player_sub.set_anchors_preset(Control.PRESET_CENTER)
	player_sub.position = Vector2(-260, 188)
	player_sub.modulate.a = 0.0
	left_anchor.add_child(player_sub)

	# ── 右侧对手区（占右半屏）
	var right_anchor := Control.new()
	right_anchor.anchor_left = 0.5
	right_anchor.anchor_right = 1.0
	right_anchor.anchor_top = 0.0
	right_anchor.anchor_bottom = 1.0
	right_anchor.offset_left = 0
	right_anchor.offset_right = 0
	right_anchor.offset_top = 0
	right_anchor.offset_bottom = 0
	add_child(right_anchor)

	var opp_color := Color(0.82, 0.18, 0.18)
	var opp_portrait := _make_portrait(opp_chef, opp_color)
	opp_portrait.set_anchors_preset(Control.PRESET_CENTER)
	opp_portrait.position = Vector2(1200, -200)  # 从右侧屏外开始
	right_anchor.add_child(opp_portrait)

	var opp_name_lbl := _make_name_label(opp_name, opp_color.lightened(0.3), 22)
	opp_name_lbl.set_anchors_preset(Control.PRESET_CENTER)
	opp_name_lbl.position = Vector2(-260, 160)
	opp_name_lbl.modulate.a = 0.0
	right_anchor.add_child(opp_name_lbl)

	var opp_sub := _make_name_label("★ 对手", Color(0.75, 0.75, 0.85), 14)
	opp_sub.set_anchors_preset(Control.PRESET_CENTER)
	opp_sub.position = Vector2(-260, 188)
	opp_sub.modulate.a = 0.0
	right_anchor.add_child(opp_sub)

	# ── 中央 VS 文字
	var vs_lbl := Label.new()
	vs_lbl.text = "对决"
	vs_lbl.add_theme_font_size_override("font_size", 96)
	vs_lbl.add_theme_color_override("font_color", Color.WHITE)
	vs_lbl.add_theme_color_override("font_outline_color", Color(0.6, 0.3, 0.0, 0.9))
	vs_lbl.add_theme_constant_override("outline_size", 6)
	vs_lbl.set_anchors_preset(Control.PRESET_CENTER)
	vs_lbl.position = Vector2(-50, -60)
	vs_lbl.modulate.a = 0.0
	vs_lbl.scale = Vector2(0.1, 0.1)
	add_child(vs_lbl)

	# ── 底部信息
	var day_lbl := Label.new()
	day_lbl.text = "第 %d 天  ·  深夜料理对决" % day
	day_lbl.add_theme_font_size_override("font_size", 20)
	day_lbl.add_theme_color_override("font_color", Color(0.78, 0.72, 0.88, 0.85))
	day_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	day_lbl.offset_left = 0
	day_lbl.offset_top = -80
	day_lbl.offset_right = 0
	day_lbl.offset_bottom = -40
	day_lbl.modulate.a = 0.0
	add_child(day_lbl)

	# ── 动画序列
	_run_animation(player_portrait, opp_portrait, vs_lbl,
		player_name_lbl, player_sub, opp_name_lbl, opp_sub, day_lbl)

func _run_animation(pp, op, vs, pn, ps, on, os_, dl) -> void:
	var t := create_tween()
	t.set_parallel(false)

	# 0.15s: 双侧头像同时滑入
	t.tween_interval(0.15)
	t.tween_callback(func():
		print("VS: sliding portraits to x=50 and x=-610")
		var tw2 := create_tween()
		tw2.set_parallel(true)
		tw2.tween_property(pp, "position:x", 50.0, 0.40).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw2.tween_property(op, "position:x", -610.0, 0.40).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	t.tween_interval(0.52)

	# 0.67s: VS 爆出
	t.tween_callback(func():
		var sfx = get_node_or_null("/root/ScreenFX")
		if sfx and sfx.has_method("flash"):
			sfx.call("flash", Color.WHITE, 0.12)
		var tw3 := create_tween()
		tw3.set_parallel(true)
		tw3.tween_property(vs, "modulate:a", 1.0, 0.12)
		tw3.tween_property(vs, "scale", Vector2(1.3, 1.3), 0.14).set_trans(Tween.TRANS_BACK)
	)
	t.tween_interval(0.18)
	t.tween_property(vs, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_SPRING)

	# 1.0s: 双侧昵称淡入
	t.tween_interval(0.08)
	t.tween_callback(func():
		var tw4 := create_tween()
		tw4.set_parallel(true)
		tw4.tween_property(pn, "modulate:a", 1.0, 0.3)
		tw4.tween_property(ps, "modulate:a", 1.0, 0.3)
		tw4.tween_property(on, "modulate:a", 1.0, 0.3)
		tw4.tween_property(os_, "modulate:a", 1.0, 0.3)
	)
	t.tween_interval(0.4)

	# 1.5s: 日期信息
	t.tween_property(dl, "modulate:a", 1.0, 0.35)
	t.tween_interval(1.5)

	# 3.0s: 全体淡出
	t.tween_property(self, "modulate:a", 0.0, 0.4)
	t.tween_interval(0.1)
	t.tween_callback(_advance)

func _advance() -> void:
	get_tree().change_scene_to_file("res://ui/ShowdownView.tscn")

# ── 头像容器（带发光边框）
func _make_portrait(chef_id: String, glow_color: Color) -> Control:
	var container := Control.new()
	container.custom_minimum_size = Vector2(340, 400)

	# 发光背景
	var glow := ColorRect.new()
	glow.color = glow_color * Color(1, 1, 1, 0.18)
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.grow_horizontal = Control.GROW_DIRECTION_BOTH
	glow.grow_vertical = Control.GROW_DIRECTION_BOTH
	container.add_child(glow)

	# 边框
	var border := PanelContainer.new()
	border.set_anchors_preset(Control.PRESET_FULL_RECT)
	var b_style := StyleBoxFlat.new()
	b_style.bg_color = Color(0.06, 0.05, 0.10, 0.92)
	b_style.border_width_left = 3
	b_style.border_width_top = 3
	b_style.border_width_right = 3
	b_style.border_width_bottom = 3
	b_style.border_color = glow_color
	b_style.corner_radius_top_left = 16
	b_style.corner_radius_top_right = 16
	b_style.corner_radius_bottom_right = 16
	b_style.corner_radius_bottom_left = 16
	border.add_theme_stylebox_override("panel", b_style)
	container.add_child(border)

	# 头像
	var portrait := TextureRect.new()
	portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex = ArtDatabase.get_chef_portrait(chef_id)
	if tex:
		portrait.texture = tex
	else:
		# 无头像时显示厨师名
		var fallback := Label.new()
		fallback.text = chef_id
		fallback.add_theme_font_size_override("font_size", 28)
		fallback.add_theme_color_override("font_color", glow_color.lightened(0.3))
		fallback.set_anchors_preset(Control.PRESET_CENTER)
		fallback.position = Vector2(-60, -20)
		container.add_child(fallback)
	border.add_child(portrait)

	return container

func _make_name_label(text: String, color: Color, size: int) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(520, 0)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lbl

func _chef_accent(chef_id: String) -> Color:
	var chef := ChefDatabase.get_chef(chef_id)
	if chef.is_empty():
		return Color(0.5, 0.5, 0.8)
	var cuisines: Array = chef.get("cuisines", [])
	if cuisines.is_empty():
		return Color(0.5, 0.5, 0.8)
	return CUISINE_COLORS.get(str(cuisines[0]), Color(0.5, 0.5, 0.8))

func _chef_display_name(chef_id: String) -> String:
	var names := {"mystia": "米斯蒂娅", "sakuya": "咲夜", "youmu": "妖梦",
		"meiling": "美铃", "marisa": "魔理沙", "reimu": "灵梦",
		"alice": "爱丽丝", "patchouli": "帕秋莉", "reisen": "铃仙"}
	return names.get(chef_id, chef_id)
