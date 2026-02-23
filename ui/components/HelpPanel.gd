extends CanvasLayer

## HelpPanel — 游戏帮助面板
## 显示美味度属性说明、关键词列表、核心机制解释。
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

	# ━━━ 美味度属性 ━━━
	_add_section_header(vbox, "美味度属性")
	_add_text(vbox, "每道菜品有一项核心属性——美味度，决定上菜时的基础得分。", Color(0.8, 0.8, 0.85))
	_add_attr_row(vbox, "美味度", "基础得分", "菜品激活时产出的得分，是最核心的数值。通过升星、食材、关键词等途径提升。", Color(1.0, 0.42, 0.21))

	# ━━━ 引擎关键词 ━━━
	_add_section_header(vbox, "引擎关键词")
	_add_text(vbox, "菜品在对决中激活时触发关键词效果，构成你的得分引擎：", Color(0.8, 0.8, 0.85))
	_add_keyword_row(vbox, "开胃", "酸辣前菜激活时推进相邻菜品当前CD的15%，前菜区效果额外+50%。")
	_add_keyword_row(vbox, "上瘾", "重口味每次激活叠加2层，每层每秒产出1.5分。每5秒自然衰减10%层数。")
	_add_keyword_row(vbox, "提味", "同菜系≥2道时，标记右侧邻居下次激活得分×1.8。")
	_add_keyword_row(vbox, "爆香", "烤/炒标签菜激活时积累，满4次后爆发，该次得分×3.0。")
	_add_keyword_row(vbox, "爽脆", "油炸标签菜有25%概率双重激活，第2次得分衰减至70%。")
	_add_keyword_row(vbox, "清口", "清除当前油腻层数的50%，每清1层获得3分并全场CD加速1秒。")
	_add_keyword_row(vbox, "发酵", "首次激活得分×1.3，之后每次激活永久+1%（上限+30%）。")

	# ━━━ 环境关键词 ━━━
	_add_section_header(vbox, "环境关键词（红色）")
	_add_keyword_row(vbox, "油腻", "同时拥有浓郁+油炸标签时叠加油腻，每层减慢全场CD 8%，最多20层。")

	# ━━━ 食材标签 ━━━
	_add_section_header(vbox, "食材标签")
	_add_text(vbox, "菜品和食材带有标签，影响关键词触发条件和菜系搭配：", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "食材标签：肉类、海鲜、素菜、主食、甜品", Color(0.75, 0.8, 0.75))
	_add_text(vbox, "烹饪标签：烤制、炸制、蒸煮、生食", Color(0.75, 0.8, 0.75))

	# ━━━ 核心机制 ━━━
	_add_section_header(vbox, "核心机制")
	_add_text(vbox, "升星：购买同名菜品自动合成——3张1星→2星（属性×2.0），3张2星→3星（属性×3.0）。升星是提升战力的核心手段！", Color(0.98, 0.72, 0.22))
	_add_text(vbox, "撞菜：双方使用相同菜系时，该菜系得分较低的一方扣除50%得分。避免与对手选择相同菜系！", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "相邻效果：许多触发效果需要「相邻」才能生效。大型菜品占3格、中型占2格、小型占1格，合理安排位置是取胜关键！", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "菜系协同：上阵3道以上同菜系菜品可触发菜系纯度加成，提供额外得分倍率。", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "厨具：被动全局效果，最多装备3个。", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "技法：从技法商店获得的遗物，提供全局被动加成，最多4个。", Color(0.8, 0.8, 0.85))

	# ━━━ 奇遇与商店 ━━━
	_add_section_header(vbox, "奇遇与商店")
	_add_text(vbox, "每次行动时会出现3个奇遇选项（泡泡），可能是商店或随机事件。不同角色拥有不同的奇遇池！", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "商店分为小型(3件)、中型(5件)、大型(7件)三种规模。按菜系、标签、类型等维度筛选商品。", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "刷新商店花费1金币（灵梦每天免费刷新1次）。商品品阶随天数提升：前3天铜银为主，第4天起出现金级，第8天起出现钻石级。", Color(0.8, 0.8, 0.85))

	# ━━━ 对决流程 ━━━
	_add_section_header(vbox, "对决流程")
	_add_text(vbox, "每天有6次行动机会。第3次行动为试营业(PvE)，第6次为正式对决(PvP)。", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "对决持续30秒，菜品按冷却时间自动激活产出美味度得分。评委根据菜品美味度、上菜节奏、菜系搭配等综合评分。", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "评委有各自的口味偏好——投其所好能获得额外加分，踩到雷区则会被扣分。", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "输掉对决会扣除声望（基础2点+分差额外扣除），声望归零则游戏结束。赢得10场对决即可通关！", Color(0.8, 0.8, 0.85))

	# ━━━ 料理台 ━━━
	_add_section_header(vbox, "料理台与升级")
	_add_text(vbox, "料理台初始4格，每次升级扩展2格（4→6→8→10）。最高等级4级时满编10格。", Color(0.8, 0.8, 0.85))
	_add_text(vbox, "升级通过积累经验获得：每次行动+1经验，PvE战斗按难度额外+1~3经验。每8经验升一级，升级时可选择奖励。", Color(0.8, 0.8, 0.85))

	# ━━━ 位置策略 ━━━
	_add_section_header(vbox, "位置策略")
	_add_text(vbox, "前菜区（左侧）：开胃效果+50%", Color(0.75, 0.8, 0.75))
	_add_text(vbox, "主菜区（中间）：基础美味度+10%", Color(0.75, 0.8, 0.75))
	_add_text(vbox, "甜品区（右侧）：首次激活得分+25%", Color(0.75, 0.8, 0.75))
	_add_text(vbox, "最左位：基础CD-15%  |  最右位：得分+20%", Color(0.75, 0.8, 0.75))

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
