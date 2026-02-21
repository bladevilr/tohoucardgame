extends CanvasLayer
## TutorialOverlay — 首次引导教程
## 5步引导教程，覆盖半透明遮罩，高亮重点区域，帮助新玩家快速上手。

var _current_step := 0
var _total_steps := 5
var _overlay: ColorRect
var _panel: PanelContainer
var _title_label: Label
var _desc_label: Label
var _step_label: Label
var _next_button: Button
var _skip_button: Button

signal tutorial_completed

func _ready() -> void:
	layer = 200
	_build_ui()
	visible = false

func _build_ui() -> void:
	# Dark overlay
	_overlay = ColorRect.new()
	_overlay.name = "Overlay"
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0, 0, 0, 0.75)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	# Center panel
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(520, 260)
	_panel.offset_left = -260
	_panel.offset_top = -130
	_panel.offset_right = 260
	_panel.offset_bottom = 130
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.137, 0.110, 0.208, 0.96)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.788, 0.643, 0.290)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 24
	style.content_margin_top = 20
	style.content_margin_right = 24
	style.content_margin_bottom = 20
	_panel.add_theme_stylebox_override("panel", style)
	_overlay.add_child(_panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	_panel.add_child(vbox)

	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 28)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	vbox.add_child(_title_label)

	var sep = ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 1)
	sep.color = Color(0.788, 0.643, 0.29, 0.5)
	vbox.add_child(sep)

	_desc_label = Label.new()
	_desc_label.add_theme_font_size_override("font_size", 17)
	_desc_label.add_theme_color_override("font_color", Color(0.941, 0.902, 0.827))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_desc_label)

	_step_label = Label.new()
	_step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_step_label.add_theme_font_size_override("font_size", 15)
	_step_label.add_theme_color_override("font_color", Color(0.62, 0.584, 0.69))
	vbox.add_child(_step_label)

	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)

	_skip_button = Button.new()
	_skip_button.text = "跳过教程"
	_skip_button.custom_minimum_size = Vector2(120, 36)
	_skip_button.pressed.connect(_on_skip)
	_apply_button_style(_skip_button, false)
	btn_row.add_child(_skip_button)

	_next_button = Button.new()
	_next_button.text = "下一步 >"
	_next_button.custom_minimum_size = Vector2(120, 36)
	_next_button.pressed.connect(_on_next)
	_apply_button_style(_next_button, true)
	btn_row.add_child(_next_button)

func _apply_button_style(btn: Button, is_primary: bool) -> void:
	var style = StyleBoxFlat.new()
	if is_primary:
		style.bg_color = Color(0.24, 0.18, 0.08, 0.95)
		style.border_color = Color(0.96, 0.82, 0.28)
	else:
		style.bg_color = Color(0.227, 0.176, 0.314, 0.95)
		style.border_color = Color(0.62, 0.584, 0.69)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)

func start_tutorial() -> void:
	_current_step = 0
	visible = true
	_show_step()

func _show_step() -> void:
	var step = _get_step_data(_current_step)
	_title_label.text = step.title
	_desc_label.text = step.desc
	_step_label.text = "%d / %d" % [_current_step + 1, _total_steps]

	if _current_step >= _total_steps - 1:
		_next_button.text = "开始游戏!"
	else:
		_next_button.text = "下一步 >"

	# Animate
	_panel.scale = Vector2(0.85, 0.85)
	_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_panel, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.2)

func _get_step_data(step: int) -> Dictionary:
	match step:
		0:
			return {
				"title": "欢迎来到东方料理对决!",
				"desc": "这是一款料理自走棋游戏。你需要扮演东方角色，购买食材和菜品，将它们排列在料理台上，与对手进行得分对决。\n\n每天分为「商店 → 准备 → 对决」三个阶段，赢得10场胜利即可通关!",
			}
		1:
			return {
				"title": "商店阶段",
				"desc": "在商店阶段，你可以从不同商人处购买物品:\n- 食材商人: 低价辅助物品，放在菜品旁边触发加成\n- 菜品商人: 核心得分物品，每种菜系有不同特色\n- 技法商人: 给菜品附魔，增强属性\n- 厨具商人: 全局被动效果\n\n点击商品即可购买，也可拖拽到料理台。",
			}
		2:
			return {
				"title": "料理台与布局",
				"desc": "料理台共10个槽位。菜品在对决时按冷却时间自动上菜产生得分。\n\n物品的位置很重要! 许多触发效果需要「相邻」才能生效。大型菜品占3格、中型占2格、小型占1格。\n\n点击料理台上的物品可以查看详情，合理安排相邻关系是取胜关键。",
			}
		3:
			return {
				"title": "四维属性",
				"desc": "每个菜品有四种属性:\n\n味道 (橙): 上菜时直接产生得分\n卖相 (粉): 双方卖相差形成持续压制得分\n技法 (紫): 累计越高，所有味道得分的倍率越大\n香气 (绿): 累计越高，冷却时间越短，上菜越快\n\n四维相互配合，不同角色擅长不同的属性组合。",
			}
		4:
			return {
				"title": "羁绊与关键词",
				"desc": "集齐同菜系的菜品可触发「羁绊」加成，例如3道中华料理可激活味道+15%。\n\n菜品上菜时会产生「关键词」效果:\n- 增益(绿): 鲜美、焦香、摆盘等，增强下次上菜\n- 环境(红): 油腻、沉闷等，对双方都有负面影响\n\n准备好后点击「准备就绪」开始对决!祝你好运!",
			}
		_:
			return {"title": "", "desc": ""}

func _on_next() -> void:
	_current_step += 1
	if _current_step >= _total_steps:
		_finish()
	else:
		_show_step()

func _on_skip() -> void:
	_finish()

func _finish() -> void:
	var tween = create_tween()
	tween.tween_property(_overlay, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func():
		visible = false
		tutorial_completed.emit()
	)
