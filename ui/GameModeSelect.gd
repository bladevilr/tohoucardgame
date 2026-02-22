extends Control

## 对战模式选择界面 — 排位赛 / 休闲对战

# ── 与游戏整体 UI 一致的配色（参照 CharacterSelect / MainMenu）
const GOLD          := Color(1.0,  0.843, 0.0)          # 标题金
const RANKED_COLOR  := Color(0.96, 0.82,  0.28)         # 排位强调（与 MainMenu 主按钮边框一致）
const CASUAL_COLOR  := Color(0.30, 0.55,  0.88)         # 休闲强调（洋食蓝）
const PANEL_BG      := Color(0.08, 0.09,  0.14, 0.92)   # 面板底色（与 CharacterSelect 一致）
const PANEL_BORDER  := Color(0.38, 0.44,  0.62, 0.75)   # 面板边框
const TEXT_MAIN     := Color(0.94, 0.90,  0.83)         # 正文
const TEXT_DIM      := Color(0.68, 0.65,  0.80)         # 说明文字

var _ui_scale: float = 1.0
var _is_compact: bool = false

func _ready() -> void:
	_build_ui()
	get_viewport().size_changed.connect(_on_viewport_resized)

func _on_viewport_resized() -> void:
	call_deferred("_rebuild_ui")

func _rebuild_ui() -> void:
	for child in get_children():
		child.queue_free()
	_build_ui()

func _build_ui() -> void:
	var vp := get_viewport_rect().size
	_ui_scale = clampf(minf(vp.x / 1920.0, vp.y / 1080.0), 0.55, 1.0)
	_is_compact = vp.x < 980.0
	# 背景（与 CharacterSelect 统一使用高级环境图）
	var bg_tex = load("res://assets/ui/backgrounds/character_select_bg.png")
	if bg_tex:
		var bg_rect = TextureRect.new()
		bg_rect.texture = bg_tex
		bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(bg_rect)
	else:
		var bg := ColorRect.new()
		bg.color = Color(0.05, 0.04, 0.09)
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(bg)

	# 顶部标题
	var title_lbl := Label.new()
	title_lbl.text = "选择对战模式"
	title_lbl.add_theme_font_size_override("font_size", int(round(maxf(26.0, 38.0 * _ui_scale))))
	title_lbl.add_theme_color_override("font_color", GOLD)
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title_lbl.offset_left = 0
	title_lbl.offset_top = 40.0 if _is_compact else 60.0
	title_lbl.offset_right = 0
	title_lbl.offset_bottom = title_lbl.offset_top + (52.0 if _is_compact else 60.0)
	add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "排位赛战绩计入排行榜；休闲对战不影响排名"
	sub_lbl.add_theme_font_size_override("font_size", int(round(maxf(13.0, 16.0 * _ui_scale))))
	sub_lbl.add_theme_color_override("font_color", TEXT_DIM)
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub_lbl.offset_left = 0
	sub_lbl.offset_top = title_lbl.offset_bottom + 6.0
	sub_lbl.offset_right = 0
	sub_lbl.offset_bottom = sub_lbl.offset_top + (34.0 if _is_compact else 32.0)
	add_child(sub_lbl)

	# 主内容（两张卡片）
	var modes_box: BoxContainer = VBoxContainer.new() if _is_compact else HBoxContainer.new()
	modes_box.add_theme_constant_override("separation", int(round(60.0 * _ui_scale if not _is_compact else 16.0)))
	modes_box.set_anchors_preset(Control.PRESET_CENTER)
	var box_size: Vector2
	if _is_compact:
		box_size = Vector2(minf(vp.x - 48.0, 520.0), minf(vp.y - 220.0, 640.0))
	else:
		box_size = Vector2(1000.0, 520.0) * _ui_scale
	modes_box.custom_minimum_size = box_size
	modes_box.position = -box_size * 0.5
	modes_box.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(modes_box)

	modes_box.add_child(_make_mode_card(
		"排位赛",
		"★  排位",
		"对手基于段位匹配\n声望与胜负计入排名\n挑战更强对手，获得更高排名",
		RANKED_COLOR,
		_on_ranked_pressed
	))

	modes_box.add_child(_make_mode_card(
		"休闲对战",
		"♪  休闲",
		"随机匹配对手\n不影响排行榜排名\n自由体验，轻松享受料理对决",
		CASUAL_COLOR,
		_on_casual_pressed
	))

	# 右下：排行榜按钮
	var lb_btn := Button.new()
	lb_btn.text = "排行榜 / 战绩"
	lb_btn.custom_minimum_size = Vector2(200, 44) * _ui_scale
	_style_secondary_button(lb_btn)
	lb_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	lb_btn.position = Vector2(-24.0 - lb_btn.custom_minimum_size.x, -20.0 - lb_btn.custom_minimum_size.y)
	lb_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/Leaderboard.tscn"))
	add_child(lb_btn)

	# 左下：返回按钮
	var back_btn := Button.new()
	back_btn.text = "← 返回"
	back_btn.custom_minimum_size = Vector2(120, 44) * _ui_scale
	_style_secondary_button(back_btn)
	back_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	back_btn.position = Vector2(24.0, -20.0 - back_btn.custom_minimum_size.y)
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/MainMenu.tscn"))
	add_child(back_btn)

	# 右上昵称标签（已设置时显示）
	if SaveManager.has_nickname():
		var nick_lbl := Label.new()
		nick_lbl.text = SaveManager.get_nickname() + "  |  积分：%d" % SaveManager.get_player_rating()
		nick_lbl.add_theme_font_size_override("font_size", int(round(maxf(12.0, 15.0 * _ui_scale))))
		nick_lbl.add_theme_color_override("font_color", Color(0.85, 0.78, 1.0, 0.9))
		nick_lbl.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		nick_lbl.position = Vector2(-300.0 * _ui_scale, 14.0)
		add_child(nick_lbl)

	# 入场动画
	var anims = get_node_or_null("/root/UIAnimations")
	if anims and anims.has_method("fade_in"):
		modulate.a = 0.0
		anims.call("fade_in", self, 0.35, 0.0)

# ── 模式卡片（风格参照 CharacterSelect 厨师按钮：深底色 + 强调色边框）
func _make_mode_card(mode_name: String, tag: String, desc: String,
		accent: Color, callback: Callable) -> Button:
	var card := Button.new()
	var card_w := 440.0 * _ui_scale
	var card_h := 480.0 * _ui_scale
	if _is_compact:
		card_w = minf(get_viewport_rect().size.x - 72.0, 520.0)
		card_h = clampf(300.0 * _ui_scale, 220.0, 320.0)
	card.custom_minimum_size = Vector2(card_w, card_h)
	card.flat = true
	card.mouse_entered.connect(func(): _on_card_hover(card, accent, true))
	card.mouse_exited.connect(func(): _on_card_hover(card, accent, false))

	var wood_tex = load("res://assets/ui/ui_panel_wood.png")

	var normal: StyleBox
	if wood_tex:
		var tex_style = StyleBoxTexture.new()
		tex_style.texture = wood_tex
		tex_style.texture_margin_left = 64
		tex_style.texture_margin_top = 64
		tex_style.texture_margin_right = 64
		tex_style.texture_margin_bottom = 64
		tex_style.modulate_color = Color(0.85, 0.8, 0.9, 0.98) # 微暗以衬托文字
		normal = tex_style
	else:
		var flat = StyleBoxFlat.new()
		flat.bg_color = PANEL_BG
		flat.border_width_left = 2; flat.border_width_top = 2
		flat.border_width_right = 2; flat.border_width_bottom = 2
		flat.border_color = accent.darkened(0.35)
		flat.corner_radius_top_left = 14; flat.corner_radius_top_right = 14
		flat.corner_radius_bottom_right = 14; flat.corner_radius_bottom_left = 14
		normal = flat

	var card_padding := maxf(24.0, 40.0 * _ui_scale)
	normal.content_margin_left = card_padding
	normal.content_margin_top = card_padding
	normal.content_margin_right = card_padding
	normal.content_margin_bottom = card_padding
	card.add_theme_stylebox_override("normal", normal)

	var hover: StyleBox
	if normal is StyleBoxTexture:
		var tex_hover = normal.duplicate() as StyleBoxTexture
		tex_hover.modulate_color = Color(1.0, 1.0, 1.1, 1.0) # 提亮
		hover = tex_hover
	else:
		var flat_hover = normal.duplicate() as StyleBoxFlat
		flat_hover.border_color = accent
		flat_hover.bg_color = Color(0.10, 0.12, 0.18, 0.95)
		flat_hover.shadow_color = accent * Color(1, 1, 1, 0.22)
		flat_hover.shadow_size = int(round(maxf(10.0, 20.0 * _ui_scale)))
		hover = flat_hover

	card.add_theme_stylebox_override("hover", hover)
	card.add_theme_stylebox_override("pressed", hover)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", int(round(maxf(8.0, 14.0 * _ui_scale))))
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(vbox)

	var tag_lbl := Label.new()
	tag_lbl.text = tag
	tag_lbl.add_theme_font_size_override("font_size", int(round(maxf(12.0, 15.0 * _ui_scale))))
	tag_lbl.add_theme_color_override("font_color", accent.lightened(0.35))
	tag_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(tag_lbl)

	var name_lbl := Label.new()
	name_lbl.text = mode_name
	name_lbl.add_theme_font_size_override("font_size", int(round(maxf(22.0, 36.0 * _ui_scale))))
	name_lbl.add_theme_color_override("font_color", GOLD)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", accent.darkened(0.2))
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(sep)

	var desc_lbl := Label.new()
	desc_lbl.text = desc
	desc_lbl.add_theme_font_size_override("font_size", int(round(maxf(13.0, 16.0 * _ui_scale))))
	desc_lbl.add_theme_color_override("font_color", TEXT_MAIN)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(desc_lbl)

	var action_lbl := Label.new()
	action_lbl.text = "选择并开始 →"
	action_lbl.add_theme_font_size_override("font_size", int(round(maxf(14.0, 18.0 * _ui_scale))))
	action_lbl.add_theme_color_override("font_color", accent.lightened(0.3))
	action_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(action_lbl)

	card.pressed.connect(callback)
	return card

# ── 次级按钮样式（与 MainMenu._style_secondary_button 完全一致）
func _style_secondary_button(btn: Button) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.227, 0.176, 0.314, 0.85)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.545, 0.396, 0.306)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", style)
	var hover: StyleBoxFlat = style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.29, 0.24, 0.38, 0.9)
	hover.border_color = Color(0.788, 0.643, 0.290)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_color_override("font_color", Color(0.941, 0.902, 0.827))
	btn.add_theme_font_size_override("font_size", int(round(maxf(13.0, 16.0 * _ui_scale))))

func _on_card_hover(card: Button, accent: Color, hovered: bool) -> void:
	var anims = get_node_or_null("/root/UIAnimations")
	if anims == null:
		return
	if hovered and anims.has_method("hover_lift"):
		anims.call("hover_lift", card, 1.04, 0.12)
	elif not hovered and anims.has_method("hover_reset"):
		anims.call("hover_reset", card, 0.10)

# ============================================================
#  排位赛 — 检查昵称，若没有则弹对话框
# ============================================================

func _on_ranked_pressed() -> void:
	if SaveManager.has_nickname():
		_go_to_character_select("ranked")
	else:
		_show_nickname_dialog()

func _on_casual_pressed() -> void:
	GameManager.game_mode = "casual"
	get_tree().change_scene_to_file("res://ui/CharacterSelect.tscn")

func _go_to_character_select(mode: String) -> void:
	GameManager.game_mode = mode
	get_tree().change_scene_to_file("res://ui/CharacterSelect.tscn")

# ============================================================
#  昵称输入对话框（样式与游戏整体保持一致）
# ============================================================

func _show_nickname_dialog() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var vp := get_viewport_rect().size
	var dialog_scale := maxf(0.75, _ui_scale)

	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.75)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(overlay)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	var panel_size := Vector2(480.0, 300.0) * dialog_scale
	panel_size.x = minf(panel_size.x, vp.x - 40.0)
	panel_size.y = minf(panel_size.y, vp.y - 60.0)
	panel.custom_minimum_size = panel_size
	panel.position = -panel_size * 0.5
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.08, 0.09, 0.14, 0.98)
	ps.border_width_left = 2; ps.border_width_top = 2
	ps.border_width_right = 2; ps.border_width_bottom = 2
	ps.border_color = RANKED_COLOR
	ps.corner_radius_top_left = 14; ps.corner_radius_top_right = 14
	ps.corner_radius_bottom_right = 14; ps.corner_radius_bottom_left = 14
	ps.content_margin_left = 36; ps.content_margin_top = 36
	ps.content_margin_right = 36; ps.content_margin_bottom = 36
	panel.add_theme_stylebox_override("panel", ps)
	layer.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	panel.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "设置你的昵称"
	title_lbl.add_theme_font_size_override("font_size", int(round(maxf(20.0, 26.0 * dialog_scale))))
	title_lbl.add_theme_color_override("font_color", GOLD)
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_lbl)

	var hint_lbl := Label.new()
	hint_lbl.text = "昵称将显示在排行榜与对战过场中（最多16字符）"
	hint_lbl.add_theme_font_size_override("font_size", int(round(maxf(12.0, 13.0 * dialog_scale))))
	hint_lbl.add_theme_color_override("font_color", TEXT_DIM)
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(hint_lbl)

	var line_edit := LineEdit.new()
	line_edit.placeholder_text = "在此输入昵称..."
	line_edit.max_length = 16
	line_edit.custom_minimum_size = Vector2(0, maxf(40.0, 44.0 * dialog_scale))
	line_edit.add_theme_font_size_override("font_size", int(round(maxf(16.0, 20.0 * dialog_scale))))
	var le := StyleBoxFlat.new()
	le.bg_color = Color(0.05, 0.05, 0.09, 0.98)
	le.border_width_left = 1; le.border_width_top = 1
	le.border_width_right = 1; le.border_width_bottom = 1
	le.border_color = Color(0.46, 0.42, 0.58, 0.82)
	le.corner_radius_top_left = 6; le.corner_radius_top_right = 6
	le.corner_radius_bottom_right = 6; le.corner_radius_bottom_left = 6
	le.content_margin_left = 12; le.content_margin_top = 8
	le.content_margin_right = 12; le.content_margin_bottom = 8
	line_edit.add_theme_stylebox_override("normal", le)
	var le_focus: StyleBoxFlat = le.duplicate() as StyleBoxFlat
	le_focus.border_color = RANKED_COLOR
	line_edit.add_theme_stylebox_override("focus", le_focus)
	vbox.add_child(line_edit)
	line_edit.grab_focus()

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)

	var cancel_btn := Button.new()
	cancel_btn.text = "取消"
	cancel_btn.custom_minimum_size = Vector2(120.0, 40.0) * dialog_scale
	_style_secondary_button(cancel_btn)
	cancel_btn.pressed.connect(func(): layer.queue_free())
	btn_row.add_child(cancel_btn)

	var confirm_btn := Button.new()
	confirm_btn.text = "确认进入排位"
	confirm_btn.custom_minimum_size = Vector2(180.0, 40.0) * dialog_scale
	var cs := StyleBoxFlat.new()
	cs.bg_color = Color(0.24, 0.18, 0.08, 0.95)
	cs.border_width_left = 2; cs.border_width_top = 2
	cs.border_width_right = 2; cs.border_width_bottom = 2
	cs.border_color = RANKED_COLOR
	cs.corner_radius_top_left = 6; cs.corner_radius_top_right = 6
	cs.corner_radius_bottom_right = 6; cs.corner_radius_bottom_left = 6
	confirm_btn.add_theme_stylebox_override("normal", cs)
	var cs_h: StyleBoxFlat = cs.duplicate() as StyleBoxFlat
	cs_h.bg_color = Color(0.30, 0.24, 0.12, 0.95)
	confirm_btn.add_theme_stylebox_override("hover", cs_h)
	confirm_btn.add_theme_stylebox_override("pressed", cs)
	confirm_btn.add_theme_color_override("font_color", GOLD)
	confirm_btn.add_theme_font_size_override("font_size", int(round(maxf(13.0, 16.0 * dialog_scale))))
	confirm_btn.pressed.connect(func():
		var n: String = line_edit.text.strip_edges()
		if n == "":
			return
		SaveManager.set_nickname(n)
		layer.queue_free()
		_go_to_character_select("ranked")
	)
	btn_row.add_child(confirm_btn)

	line_edit.text_submitted.connect(func(_t):
		confirm_btn.emit_signal("pressed")
	)

	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)
