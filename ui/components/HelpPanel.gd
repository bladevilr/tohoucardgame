extends CanvasLayer

## HelpPanel — 游戏帮助面板
## 显示四维属性说明、关键词列表、核心机制解释。
## 从GameBoard的"?"按钮打开。

var _panel: PanelContainer
var _bg: ColorRect

func _ready():
	layer = 200
	_build_ui()
	visible = false

func toggle():
	visible = not visible

func _build_ui():
	# 半透明背景
	_bg = ColorRect.new()
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.color = Color(0, 0, 0, 0.7)
	_bg.gui_input.connect(_on_bg_input)
	add_child(_bg)

	# 主面板
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.anchor_left = 0.1
	_panel.anchor_right = 0.9
	_panel.anchor_top = 0.05
	_panel.anchor_bottom = 0.95
	_panel.offset_left = 0
	_panel.offset_right = 0
	_panel.offset_top = 0
	_panel.offset_bottom = 0
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.08, 0.15, 0.96)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.788, 0.643, 0.290)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	# 滚动容器
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_panel.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(vbox)

	# 标题
	_add_title(vbox, "帮助 — 游戏机制说明")

	# 关闭提示
	_add_hint(vbox, "点击面板外部关闭")

	# ━━━ 四维属性 ━━━
	_add_section_header(vbox, "四维属性")
	_add_text(vbox, "每道菜品有四项基础属性，决定对决中的不同作用：", Color(0.8, 0.8, 0.85))
	_add_attr_row(vbox, "味道", "直接得分", "菜品上菜时产出的分数，是最核心的得分来源。", Color(1.0, 0.7, 0.3))
	_add_attr_row(vbox, "卖相", "持续压制", "卖相总值高于对手时，每秒持续获得额外得分。差值越大压制越强。", Color(1.0, 0.5, 0.7))
	_add_attr_row(vbox, "技法", "全局倍率", "所有味道得分乘以技法倍率。每点技法+2%倍率（如50技法=×2.0）。", Color(0.6, 0.5, 1.0))
	_add_attr_row(vbox, "香气", "加速冷却", "减少菜品上菜间隔。每10点香气减少5%冷却时间（上限30%）。", Color(0.4, 0.9, 0.5))

	# ━━━ 增益关键词 ━━━
	_add_section_header(vbox, "增益关键词（绿色）")
	_add_keyword_row(vbox, "鲜美", "每层+3味道。5层以上时额外总分×(1+层数×3%)")
	_add_keyword_row(vbox, "焦香", "每层+2味道。5层以上时爆香阈值-1")
	_add_keyword_row(vbox, "摆盘", "每层+3卖相。5层以上时额外总分×(1+层数×2%)")
	_add_keyword_row(vbox, "刀工", "每层+2技法。5层以上时CD额外-2%/层")
	_add_keyword_row(vbox, "聚光", "下次上菜冷却-1秒（消耗）")
	_add_keyword_row(vbox, "回味", "每层味道×1.3")
	_add_keyword_row(vbox, "秘方", "每层味道×1.5（消耗）")

	# ━━━ 环境关键词 ━━━
	_add_section_header(vbox, "环境关键词（红色·双方共享）")
	_add_keyword_row(vbox, "油腻", "每层-2味道（清淡菜品可清除）")
	_add_keyword_row(vbox, "杂乱", "每层-2卖相")
	_add_keyword_row(vbox, "味觉疲劳", "每层味道-15%")
	_add_keyword_row(vbox, "沉闷", "每层冷却+0.3秒")

	# ━━━ 8大引擎机制 ━━━
	_add_section_header(vbox, "引擎机制（标签自动触发）")
	_add_keyword_row(vbox, "开胃", "辣/酸菜→推进相邻CD 15%（前菜区+50%）")
	_add_keyword_row(vbox, "上瘾", "浓郁/鲜味菜→每次+2层，每层每秒1.5分")
	_add_keyword_row(vbox, "爆香", "烤/炒菜→激活4次后爆发，得分×3.0")
	_add_keyword_row(vbox, "爽脆", "油炸菜→25%概率双重激活")
	_add_keyword_row(vbox, "清口", "清淡/茶菜→清50%油腻，每层+3分+0.3s加速")
	_add_keyword_row(vbox, "油腻(机制)", "浓郁+油炸菜→叠油腻，每层减速8%")
	_add_keyword_row(vbox, "提鲜", "鲜味菜+同菜系≥2→右邻下次得分×1.8")
	_add_keyword_row(vbox, "发酵", "首次×1.3，每次激活永久+1%（上限+30%）")

	# ━━━ 核心机制 ━━━
	_add_section_header(vbox, "核心机制")
	_add_text(vbox, "撞菜：双方使用相同菜系时，该菜系得分较低的一方扣除50%得分。避免与对手选择相同菜系！", Color(0.98, 0.72, 0.22))
	_add_text(vbox, "升星：商店中购买3张同名菜品自动合成为2星（属性×1.5），3张2星合成为3星（属性×2.0）。", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "协同：上阵3道以上同菜系菜品触发菜系协同加成，提供额外属性倍率。", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "手法：从技法商人购买手法附魔到菜品上，提升特定属性（同时可能增加冷却）。", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "厨具：被动全局效果，最多装备3个（部分厨师可装备4个）。", Color(0.8, 0.8, 0.85))

	# ━━━ 对决流程 ━━━
	_add_section_header(vbox, "对决流程")
	_add_text(vbox, "对决持续30秒。菜品按冷却时间自动上菜产出味道得分。卖相高的一方持续压制得分。30秒结束后比较总分，输家扣声望。声望归零则游戏结束。赢10场即可通关。", Color(0.8, 0.8, 0.85))

func _add_title(parent: VBoxContainer, text: String):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)

func _add_hint(parent: VBoxContainer, text: String):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)

func _add_section_header(parent: VBoxContainer, text: String):
	var sep = HSeparator.new()
	parent.add_child(sep)
	var label = Label.new()
	label.text = "━━ %s ━━" % text
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)

func _add_text(parent: VBoxContainer, text: String, color: Color = Color(0.8, 0.8, 0.85)):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)

func _add_attr_row(parent: VBoxContainer, name: String, role: String, desc: String, color: Color):
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var name_lbl = Label.new()
	name_lbl.text = "%s（%s）" % [name, role]
	name_lbl.add_theme_font_size_override("font_size", 18)
	name_lbl.add_theme_color_override("font_color", color)
	name_lbl.custom_minimum_size.x = 180
	hbox.add_child(name_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = desc
	desc_lbl.add_theme_font_size_override("font_size", 15)
	desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(desc_lbl)

	parent.add_child(hbox)

func _add_keyword_row(parent: VBoxContainer, name: String, effect: String):
	var label = Label.new()
	label.text = "「%s」— %s" % [name, effect]
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.75, 0.8, 0.75))
	parent.add_child(label)

func _on_bg_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		visible = false

func _input(event: InputEvent):
	if visible and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
			visible = false
			get_viewport().set_input_as_handled()
