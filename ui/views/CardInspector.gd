extends Control

signal close_requested

const ItemCardScene = preload("res://ui/components/ItemCard.tscn")

const TAG_TEXT := {
	"chinese": "中华",
	"washoku": "和食",
	"chuuka": "中华",
	"youshoku": "洋食",
	"yatai": "夜市",
	"kanmi": "甜品",
	"yakuzen": "药膳",
	"meat": "肉类",
	"vegetable": "蔬菜",
	"seafood": "海鲜",
	"dessert": "甜品",
	"soup": "汤品",
	"noodle": "面食",
	"grilled": "烧烤",
	"fried": "油炸",
	"stir_fried": "炒制",
	"steamed": "蒸制",
	"stewed": "炖煮",
	"light": "清淡",
	"rich": "浓郁",
	"spicy": "辛辣",
	"sour": "酸味",
	"sweet": "甜味",
	"umami_tag": "鲜味",
	"fermented": "发酵",
	"egg": "蛋类",
	"rare": "稀有",
	"medicinal": "药用",
	"numbing": "麻味",
	"divine": "神圣",
	"greasy": "油腻",
	"fusion": "融合",
	"mastered": "精进",
}

const KEYWORD_TEXT := {
	"umami": "鲜美",
	"char_aroma": "焦香",
	"plating": "摆盘",
	"knife_work": "刀工",
	"spotlight": "聚光",
	"aftertaste": "回味",
	"secret_recipe": "秘方",
	"greasy": "油腻",
	"messy": "杂乱",
	"taste_fatigue": "味觉疲劳",
	"dull": "沉闷",
	"burst": "爆发",
}

const INGREDIENT_SPECIAL_TEXT := {
	"appetize_right_20": "右侧相邻菜品上菜时额外+20风味",
	"clear_greasy_1": "开场清除1层油腻",
	"score_right_raw_30": "右侧生食菜品上菜时额外+30风味",
	"fermented_growth_boost": "发酵类效果成长速度提升",
	"umami_on_3rd_activate": "每第3次上菜时额外获得1层鲜美",
	"dessert_zone_bonus": "甜品区菜品获得额外加成",
	"addiction_double_stack": "与上瘾类效果联动时叠层翻倍",
	"add_env_greasy_2": "首次上菜时给环境增加2层油腻",
	"first_activate_bonus_50": "首次上菜额外+50风味",
	"clear_all_env_1": "开场各清除1层环境减益",
	"sizzle_threshold_minus_1": "爆香类爆发阈值-1",
	"all_scores_mult_1_5": "该菜品最终得分×1.5",
	"double_next_activate": "首次上菜风味倍率翻倍",
	"grant_secret_recipe": "开场获得1层秘方",
	"refreshing_full_clear": "开场清除全部沉闷与味觉疲劳",
	"grant_char_aroma_3": "开场获得3层焦香",
}

const TERM_DEFINITIONS := {
	"上菜": "每道菜按冷却时间顺序逐一上桌，触发上菜效果并产出分数。分数 = 风味 × 技法倍率 × 疲劳系数（随上菜数递减）× 评委口味修正。",
	"触发": "满足特定事件（如相邻菜上桌、获得关键字）时自动执行效果，无需手动操作。",
	"被动": "始终生效的持续效果，无需触发条件，贯穿整场对决。",
	"相邻": "棋盘上左右紧贴该菜的卡牌。换位后相邻关系随之改变。",
	"环境": "全场共享的负面状态。油腻每层 -2 风味；杂乱每层 -2 卖相；味觉疲劳每层 -15% 风味倍率。环境效果对双方同时生效。",
	"鲜美": "正面效果。叠加生效：每拥有 1 层，该菜品每次上菜时额外增加 3 点基础风味。当层数达到 5 层或以上时，还会根据层数获得额外的总分百分比加成。",
	"焦香": "正面效果。叠加生效：每拥有 1 层，该菜品每次上菜时额外增加 2 点基础风味。",
	"摆盘": "正面效果。叠加生效：每拥有 1 层，该菜品每次上菜时额外增加 3 点基础卖相。当层数达到 5 层或以上时，还会根据层数获得额外的总分百分比加成。",
	"刀工": "正面效果。叠加生效：每拥有 1 层，该菜品额外增加 2 点基础技法属性。当层数达到 5 层或以上时，还会根据层数额外减少自身的上菜冷却时间。",
	"回味": "延迟效果。叠加生效：每拥有 1 层，当下一道菜上桌时，会额外产生相当于本次风味得分 30% 的加分。",
	"秘方": "一次性爆发。上菜时消耗所有层数，每消耗 1 层使本次上菜的风味得分极大地增加 50%。",
	"聚光": "特殊状态。获得时立即消耗所有层数，每消耗 1 层使该菜品当前的冷却时间立刻缩短 1 秒。",
	"油腻": "全场共享的负面状态。每增加 1 层，全场所有菜品及其效果导致的风味得分固定减少 2 点。",
	"杂乱": "全场共享的负面状态。每增加 1 层，全场所有菜品带来的卖相得分固定减少 2 点。",
	"味觉疲劳": "全场共享的负面状态。每增加 1 层，全场的最终风味得分倍率降低 15%。",
	"沉闷": "负面状态。每叠加 1 层，该菜品的冷却时间增加 0.3 秒。",
	"爆发": "条件触发效果。当该菜品累计完成要求次数的上菜后，会额外触发一次强力的效果。触发后计数清零重新开始计算。",
	"融合": "菜品标签。表示该菜横跨多个菜系，通常可触发多套体系的协同奖励。",
	"精进": "菜品标签。表示该菜经过专项修炼，通常大幅强化关键字效率或倍率上限。",
	"风味": "核心得分属性。每次上菜的基础分 = 风味值 × 技法倍率。对最终胜负影响最大。",
	"卖相": "持续伤害属性。双方卖相差每秒产生持续伤害 = 差值 × 0.6 × 技法倍率，高卖相方持续扣对手分。",
	"技法": "全局倍率属性。公式：倍率 = 1.0 + 技法总值 × 0.02。对全场所有风味和持续伤害同步生效。",
	"香气": "加速属性。每 10 点香气缩短该菜冷却的 5%，上限 35%（70 香气 = 最快）。",
}

const EFFECT_TERMS := {
	"gain_keyword": [],
	"apply_keyword": [],
	"consume_keyword": [],
	"add_environment": ["环境"],
	"trigger_environment": ["环境"],
	"clear_environment": ["环境"],
	"score": ["风味", "卖相", "技法", "香气"],
	"stat_bonus": ["风味", "卖相", "技法", "香气"],
	"flavor_mult": ["风味"],
	"presentation_mult": ["卖相"],
}

@onready var card_container: CenterContainer = $Content/LeftArea/CardCenter
@onready var title_label: Label = $Content/RightArea/Margin/VBox/TitleLabel
@onready var cuisine_label: Label = $Content/RightArea/Margin/VBox/TypeRow/CuisineLabel
@onready var star_label: Label = $Content/RightArea/Margin/VBox/TypeRow/StarLabel
@onready var item_type_label: Label = $Content/RightArea/Margin/VBox/TypeRow/ItemTypeLabel
@onready var stats_grid: GridContainer = $Content/RightArea/Margin/VBox/StatsGrid
@onready var description_label: RichTextLabel = $Content/RightArea/Margin/VBox/DescriptionLabel
@onready var ingredient_title: Label = $Content/RightArea/Margin/VBox/IngredientTitle
@onready var ingredient_list: VBoxContainer = $Content/RightArea/Margin/VBox/IngredientList
@onready var effect_text: RichTextLabel = $Content/RightArea/Margin/VBox/EffectsText
@onready var glossary_box: VBoxContainer = $Content/RightArea/Margin/VBox/GlossaryScroll/GlossaryContainer
@onready var background: ColorRect = $Background

var _open_guard_until_ms: int = 0
var _closing: bool = false

func _ready() -> void:
	_open_guard_until_ms = Time.get_ticks_msec() + 120
	background.gui_input.connect(_on_bg_input)
	_apply_styles()
	_animate_open()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()

func inspect_item(item_data: Dictionary) -> void:
	_spawn_preview_card(item_data)
	title_label.text = _get_display_name(item_data)

	# TypeRow: cuisine, star, item type
	var cuisine: String = str(item_data.get("cuisine", ""))
	cuisine_label.text = _translate_tag(cuisine) if cuisine != "" else "普通"

	var star: int = int(item_data.get("star_level", 1))
	star_label.text = GameConfig.STAR_NAMES.get(star, "★")
	star_label.add_theme_color_override("font_color", GameConfig.STAR_COLORS.get(star, Color.WHITE))

	item_type_label.text = _get_type_display(str(item_data.get("item_type", item_data.get("type", "dish"))))

	# Stats grid
	_build_stats_grid(item_data)

	# Description
	description_label.text = str(item_data.get("description", ""))

	# Effects
	effect_text.text = _build_effect_text(item_data)

	# Ingredient history
	var history: Array = item_data.get("_ingredient_history", [])
	if history.is_empty():
		ingredient_title.visible = false
		ingredient_list.visible = false
	else:
		ingredient_title.visible = true
		ingredient_list.visible = true
		_build_ingredient_history(history)

	# Glossary
	_rebuild_glossary(item_data)
	
	# Sell button
	_add_sell_button(item_data)

func _spawn_preview_card(item_data: Dictionary) -> void:
	for child in card_container.get_children():
		child.queue_free()

	# 清除之前注入到 LeftArea 的全图
	var left_area: PanelContainer = $Content/LeftArea as PanelContainer
	var prev_fill: Node = left_area.get_node_or_null("ArtFill")
	if prev_fill:
		prev_fill.queue_free()

	# 尝试加载菜品/食材大图
	var item_id: String = str(item_data.get("id", ""))
	var item_type: String = str(item_data.get("item_type", item_data.get("type", "dish")))
	var tex: Texture2D = null

	if item_id != "":
		match item_type:
			"ingredient":
				tex = ArtDatabase.get_ingredient_icon(item_id)
			"tool":
				tex = ArtDatabase.get_tool_icon(item_id)
			"technique":
				tex = ArtDatabase.get_technique_icon(item_id)
			_:
				tex = ArtDatabase.get_dish_icon(item_id)

	if tex:
		# 全图模式：填满 LeftArea，长边自适应保持全图可见
		card_container.visible = false

		var art_rect: TextureRect = TextureRect.new()
		art_rect.name = "ArtFill"
		art_rect.texture = tex
		art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		art_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# 不要 set_anchors_and_offsets_preset，由 PanelContainer 负责布局
		art_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		art_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		left_area.add_child(art_rect)

		# 入场动画（pivot 等布局稳定后再设）
		art_rect.modulate.a = 0.0
		var tween: Tween = create_tween()
		tween.tween_property(art_rect, "modulate:a", 1.0, 0.2)
	else:
		# 无图时回退到卡牌显示
		card_container.visible = true
		var big_card = ItemCardScene.instantiate()
		card_container.add_child(big_card)
		big_card.setup(item_data)
		big_card.scale = Vector2(1.95, 1.95)
		big_card.rotation_degrees = -2.5
		big_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(big_card, "scale", Vector2(2.05, 2.05), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(big_card, "rotation_degrees", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _build_stats_grid(item_data: Dictionary) -> void:
	for child in stats_grid.get_children():
		child.queue_free()

	var stats: Dictionary = item_data.get("base_stats", {})
	for stat_key in GameConfig.STAT_KEYS:
		var stat_value: int = int(stats.get(stat_key, 0))
		var stat_name: String = str(GameConfig.STAT_NAMES.get(stat_key, stat_key))
		var stat_color: Color = GameConfig.STAT_COLORS.get(stat_key, Color.WHITE)

		# Stat name + ⓘ help button in an HBox
		var name_row: HBoxContainer = HBoxContainer.new()
		name_row.add_theme_constant_override("separation", 4)
		
		var name_label: Label = Label.new()
		name_label.text = stat_name
		name_label.add_theme_color_override("font_color", stat_color)
		name_label.add_theme_font_size_override("font_size", 15)
		name_row.add_child(name_label)
		
		var help_btn: Button = _create_help_icon(stat_name)
		name_row.add_child(help_btn)
		
		stats_grid.add_child(name_row)

		# Value + progress bar
		var value_box: HBoxContainer = HBoxContainer.new()
		value_box.add_theme_constant_override("separation", 8)

		var value_label: Label = Label.new()
		value_label.text = str(stat_value)
		value_label.add_theme_font_size_override("font_size", 15)
		value_label.custom_minimum_size = Vector2(30, 0)
		value_box.add_child(value_label)

		var progress: ProgressBar = ProgressBar.new()
		progress.max_value = 50
		progress.value = stat_value
		progress.show_percentage = false
		progress.custom_minimum_size = Vector2(120, 12)
		value_box.add_child(progress)

		stats_grid.add_child(value_box)

	# Add CD row with help
	var cd_value: float = float(item_data.get("cooldown", 0))
	if cd_value > 0:
		var cd_row: HBoxContainer = HBoxContainer.new()
		cd_row.add_theme_constant_override("separation", 4)
		var cd_label: Label = Label.new()
		cd_label.text = "冷却"
		cd_label.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
		cd_label.add_theme_font_size_override("font_size", 15)
		cd_row.add_child(cd_label)
		cd_row.add_child(_create_help_icon("上菜"))
		stats_grid.add_child(cd_row)
		
		var cd_val_label: Label = Label.new()
		cd_val_label.text = "%.1f秒" % cd_value
		cd_val_label.add_theme_font_size_override("font_size", 15)
		stats_grid.add_child(cd_val_label)

	# Add size row
	var item_size: int = int(item_data.get("size", 1))
	if item_size > 0:
		var size_label: Label = Label.new()
		size_label.text = "体量"
		size_label.add_theme_color_override("font_color", Color(0.8, 0.75, 0.6))
		size_label.add_theme_font_size_override("font_size", 15)
		stats_grid.add_child(size_label)
		
		var size_names: Dictionary = {1: "小型", 2: "中型", 3: "大型"}
		var size_val: Label = Label.new()
		size_val.text = size_names.get(item_size, str(item_size))
		size_val.add_theme_font_size_override("font_size", 15)
		stats_grid.add_child(size_val)

func _create_help_icon(term: String) -> Button:
	"""Create a small ⓘ button that shows TERM_DEFINITIONS[term] as tooltip on hover."""
	var btn: Button = Button.new()
	btn.text = "ⓘ"
	btn.flat = true
	btn.custom_minimum_size = Vector2(20, 20)
	btn.add_theme_font_size_override("font_size", 12)
	btn.add_theme_color_override("font_color", Color(0.6, 0.7, 1.0, 0.8))
	btn.add_theme_color_override("font_hover_color", Color(0.8, 0.9, 1.0, 1.0))
	btn.mouse_filter = Control.MOUSE_FILTER_PASS
	btn.mouse_default_cursor_shape = Control.CURSOR_HELP
	
	var definition: String = TERM_DEFINITIONS.get(term, "")
	if definition != "":
		btn.tooltip_text = "%s\n─────\n%s" % [term, definition]
	else:
		btn.tooltip_text = term
	
	return btn

func _build_ingredient_history(history: Array) -> void:
	for child in ingredient_list.get_children():
		child.queue_free()

	for entry in history:
		if not (entry is Dictionary):
			continue
		var ingredient_name: String = str(entry.get("name", "未知食材"))
		var effect_desc: String = str(entry.get("effect", ""))

		var row: Label = Label.new()
		row.text = "• %s: %s" % [ingredient_name, effect_desc]
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_theme_font_size_override("font_size", 14)
		row.add_theme_color_override("font_color", Color(0.85, 0.85, 0.88))
		ingredient_list.add_child(row)

func _get_type_display(item_type: String) -> String:
	match item_type:
		"dish":
			return "菜品"
		"ingredient":
			return "食材"
		"tool":
			return "厨具"
		"technique":
			return "技法"
		_:
			return "未知"

func _build_effect_text(item_data: Dictionary) -> String:
	var lines: Array[String] = []
	var item_type: String = str(item_data.get("item_type", item_data.get("type", "dish")))

	if item_type == "ingredient":
		var stat_mods: Dictionary = item_data.get("stat_modifiers", {})
		var stat_parts: Array[String] = []
		for stat_key in GameConfig.STAT_KEYS:
			var delta: float = float(stat_mods.get(stat_key, 0.0))
			if absf(delta) <= 0.001:
				continue
			var stat_name: String = _attr_name(stat_key)
			if absf(delta - roundf(delta)) <= 0.001:
				stat_parts.append("%s%+d" % [stat_name, int(roundf(delta))])
			else:
				stat_parts.append("%s%+.1f" % [stat_name, delta])
		if not stat_parts.is_empty():
			lines.append("• 属性：" + "、".join(stat_parts))

		var add_tags: Array = item_data.get("added_tags", [])
		if not add_tags.is_empty():
			var add_names: Array[String] = []
			for tag in add_tags:
				add_names.append(_translate_tag(str(tag)))
			lines.append("• 附加标签：" + "、".join(add_names))

		var remove_tags: Array = item_data.get("removed_tags", [])
		if not remove_tags.is_empty():
			var remove_names: Array[String] = []
			for tag in remove_tags:
				remove_names.append(_translate_tag(str(tag)))
			lines.append("• 移除标签：" + "、".join(remove_names))

		var special_id: String = str(item_data.get("special_effect", ""))
		if special_id != "":
			lines.append("• 特效：" + _describe_ingredient_special(special_id))

		if lines.is_empty():
			var flavor_text: String = str(item_data.get("flavor_text", "")).strip_edges()
			if flavor_text != "":
				lines.append("• " + flavor_text)
			else:
				lines.append("• 无特殊效果")

		return "\n".join(lines)

	var on_activate: Array = item_data.get("on_activate", [])
	for effect in on_activate:
		if effect is Dictionary:
			lines.append("• 上菜：%s" % _describe_effect(effect))

	var triggers: Array = item_data.get("triggers", [])
	for trigger in triggers:
		if trigger is Dictionary:
			lines.append("• %s" % _describe_trigger(trigger))

	if lines.is_empty():
		lines.append("• 无特殊效果")

	return "\n".join(lines)

func _rebuild_glossary(item_data: Dictionary) -> void:
	for child in glossary_box.get_children():
		child.queue_free()

	var terms: Array[String] = _collect_terms(item_data)
	if terms.is_empty():
		_add_glossary_entry("无", "该卡没有额外机制术语。")
		return

	for term in terms:
		var desc: String = str(TERM_DEFINITIONS.get(term, "该词条由卡牌效果触发，请结合效果文本理解。"))
		_add_glossary_entry(term, desc)

func _collect_terms(item_data: Dictionary) -> Array[String]:
	var ordered: Array[String] = []
	var seen: Dictionary = {}
	var push_term: Callable = func(term: String) -> void:
		if term == "" or seen.has(term):
			return
		seen[term] = true
		ordered.append(term)

	push_term.call("上菜")

	for tag in item_data.get("tags", []):
		var key: String = str(tag)
		if KEYWORD_TEXT.has(key):
			push_term.call(KEYWORD_TEXT[key])
		elif key == "fusion":
			push_term.call("融合")
		elif key == "mastered":
			push_term.call("精进")

	# (V1 标签驱动引擎机制已作为显式触发器重构，此处不再自动注入名词)

	for effect in item_data.get("on_activate", []):
		_collect_effect_terms(effect, push_term)

	for trigger in item_data.get("triggers", []):
		if not (trigger is Dictionary):
			continue
		var event: String = str(trigger.get("event", "")).to_lower()
		if event.find("adjacent") >= 0 or event.find("neighbor") >= 0:
			push_term.call("相邻")
		if trigger.has("keyword"):
			push_term.call(_translate_keyword(str(trigger.get("keyword", ""))))
		if trigger.has("effect"):
			_collect_effect_terms(trigger.get("effect"), push_term)

	# Always include stat terms since we show stats grid
	push_term.call("风味")
	push_term.call("卖相")
	push_term.call("技法")
	push_term.call("香气")

	return ordered

func _collect_effect_terms(effect: Variant, push_term: Callable) -> void:
	if not (effect is Dictionary):
		return
	var eff: Dictionary = effect
	var typ: String = str(eff.get("type", ""))
	if EFFECT_TERMS.has(typ):
		for term in EFFECT_TERMS[typ]:
			push_term.call(term)

	if eff.has("keyword"):
		push_term.call(_translate_keyword(str(eff.get("keyword", ""))))
	if eff.has("gain_keyword"):
		push_term.call(_translate_keyword(str(eff.get("gain_keyword", ""))))

	if eff.has("condition") and eff["condition"] is Dictionary:
		var cond: Dictionary = eff["condition"]
		if cond.has("adjacent_has_all_tags"):
			push_term.call("相邻")
		if cond.has("has_tag"):
			var tag_name: String = _translate_tag(str(cond.get("has_tag", "")))
			if tag_name != "":
				push_term.call(tag_name)
	
	if eff.has("accumulate"):
		push_term.call("爆发")

func _add_glossary_entry(title: String, desc: String) -> void:
	var row: VBoxContainer = VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var t: Label = Label.new()
	t.text = title
	t.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	t.add_theme_font_size_override("font_size", 17)

	var d: Label = Label.new()
	d.text = desc
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.add_theme_color_override("font_color", Color(0.86, 0.86, 0.9))
	d.add_theme_font_size_override("font_size", 14)

	row.add_child(t)
	row.add_child(d)
	glossary_box.add_child(row)

func _describe_trigger(trigger: Dictionary) -> String:
	var event: String = str(trigger.get("event", "")).to_lower()
	var head: String = "被动触发"
	match event:
		"item_activated":
			head = "上菜时"
		"when_adjacent_activates", "on_adjacent_activate":
			head = "相邻上菜时"
		"when_left_neighbor_activates", "on_left_activate":
			head = "左侧上菜时"
		"when_gain_keyword", "on_keyword_gain":
			head = "获得关键字时"
		"on_tick":
			head = "周期触发"
		"on_self_activate":
			head = "自身上菜时"

	var desc: String = str(trigger.get("desc", ""))
	if desc != "":
		# Replace raw english tags that might have leaked into descriptions
		for key in TAG_TEXT:
			if desc.find("(" + key + ")") >= 0:
				desc = desc.replace("(" + key + ")", "(%s)" % TAG_TEXT[key])
		
		# Clarify cooldown mechanics
		desc = desc.replace("自身CD-", "自身当前冷却缩短")
		desc = desc.replace("全场CD-", "全场当前冷却缩短")
		desc = desc.replace("CD-", "当前冷却缩短")
		desc = desc.replace("自身CD+", "自身当前冷却增加")
		desc = desc.replace("全场CD+", "全场当前冷却增加")
		desc = desc.replace("CD+", "当前冷却增加")
		
		return "%s：%s" % [head, desc]
	if trigger.has("effect") and trigger.get("effect") is Dictionary:
		return "%s：%s" % [head, _describe_effect(trigger.get("effect"))]
	return head

func _describe_effect(effect: Dictionary) -> String:
	# --- Direct keyword fields used by dish trigger data ---
	if effect.has("add_keyword"):
		var kw = _translate_keyword(str(effect.get("add_keyword", "")))
		var stacks = int(effect.get("keyword_stacks", 1))
		var parts: Array[String] = ["获得%d层%s" % [stacks, kw]]
		if effect.has("add_env_keyword"):
			var env_kw = _translate_keyword(str(effect.get("add_env_keyword", "")))
			var env_stacks = int(effect.get("env_stacks", effect.get("stacks", 1)))
			parts.append("环境+%d层%s" % [env_stacks, env_kw])
		return "、".join(parts)
	if effect.has("clear_env_keyword"):
		var kw = _translate_keyword(str(effect.get("clear_env_keyword", "")))
		var stacks = int(effect.get("stacks", 1))
		return "清除%d层%s" % [stacks, kw]
	if effect.has("add_env_keyword"):
		var kw = _translate_keyword(str(effect.get("add_env_keyword", "")))
		var stacks = int(effect.get("env_stacks", effect.get("stacks", 1)))
		return "环境+%d层%s" % [stacks, kw]
	if effect.has("consume_keyword"):
		var kw = _translate_keyword(str(effect.get("consume_keyword", "")))
		return "消耗%s" % kw
	if effect.has("flavor_mult"):
		return "风味倍率x%.2f" % float(effect.get("flavor_mult", 1.0))
	if effect.has("presentation_mult"):
		return "卖相倍率x%.2f" % float(effect.get("presentation_mult", 1.0))

	# --- Type-based effects (legacy/trigger system) ---
	var typ: String = str(effect.get("type", ""))
	match typ:
		"score":
			var parts: Array[String] = []
			for key in ["flavor", "presentation", "technique", "aroma"]:
				var val: int = int(effect.get(key, 0))
				if val > 0:
					parts.append("%s+%d" % [_attr_name(key), val])
			if parts.is_empty():
				return "提升基础得分"
			return "提升" + "、".join(parts)
		"gain_keyword", "apply_keyword":
			return "获得%d层%s" % [
				int(effect.get("stacks", 1)),
				_translate_keyword(str(effect.get("keyword", "")))
			]
		"consume_keyword":
			if effect.get("all_stacks", false):
				return "消耗所有%s" % _translate_keyword(str(effect.get("keyword", "")))
			return "消耗%d层%s" % [
				int(effect.get("stacks", 1)),
				_translate_keyword(str(effect.get("keyword", "")))
			]
		"add_environment", "trigger_environment":
			return "环境增加%d层%s" % [
				int(effect.get("stacks", 1)),
				_translate_keyword(str(effect.get("keyword", "")))
			]
		"clear_environment":
			return "环境清除%d层%s" % [
				int(effect.get("stacks", 1)),
				_translate_keyword(str(effect.get("keyword", "")))
			]
		"flavor_mult":
			return "风味倍率x%.2f" % float(effect.get("value", effect.get("mult", 1.0)))
		"presentation_mult":
			return "卖相倍率x%.2f" % float(effect.get("value", effect.get("mult", 1.0)))
		"stat_bonus":
			var s: Array[String] = []
			for key in ["flavor", "presentation", "technique", "aroma"]:
				var val: int = int(effect.get(key, 0))
				if val != 0:
					s.append("%s%+d" % [_attr_name(key), val])
			return "属性调整：" + " / ".join(s) if not s.is_empty() else "属性加成"
		_:
			if effect.has("keyword"):
				return "与%s联动" % _translate_keyword(str(effect.get("keyword", "")))
			return "特殊效果"

func _attr_name(key: String) -> String:
	match key:
		"flavor":
			return "风味"
		"presentation":
			return "卖相"
		"technique":
			return "技法"
		"aroma":
			return "香气"
	return key

func _get_display_name(item_data: Dictionary) -> String:
	var name_cn: String = str(item_data.get("name_cn", "")).strip_edges()
	if name_cn != "":
		return name_cn
	return str(item_data.get("name", "???"))

func _translate_tag(tag: String) -> String:
	return TAG_TEXT.get(tag, tag)

func _translate_keyword(keyword_id: String) -> String:
	return KEYWORD_TEXT.get(keyword_id, keyword_id)

func _on_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and _can_close():
		close()

func _can_close() -> bool:
	return Time.get_ticks_msec() >= _open_guard_until_ms

func close() -> void:
	if _closing:
		return
	if not _can_close():
		return
	_closing = true
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_property($Content, "scale", Vector2(0.98, 0.98), 0.15)
	tween.finished.connect(func():
		close_requested.emit()
		queue_free()
	)

func _animate_open() -> void:
	modulate.a = 0.0
	$Content.scale = Vector2(0.96, 0.96)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.18)
	tween.tween_property($Content, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _apply_styles() -> void:
	var left_panel: PanelContainer = $Content/LeftArea as PanelContainer
	var right_panel: PanelContainer = $Content/RightArea as PanelContainer
	if left_panel:
		var left_style: StyleBoxFlat = StyleBoxFlat.new()
		left_style.bg_color = Color(0.12, 0.1, 0.16, 0.88)
		left_style.border_width_left = 1
		left_style.border_width_top = 1
		left_style.border_width_right = 1
		left_style.border_width_bottom = 1
		left_style.border_color = Color(0.45, 0.4, 0.58, 0.8)
		left_style.corner_radius_top_left = 14
		left_style.corner_radius_top_right = 14
		left_style.corner_radius_bottom_right = 14
		left_style.corner_radius_bottom_left = 14
		left_style.content_margin_left = 10
		left_style.content_margin_top = 10
		left_style.content_margin_right = 10
		left_style.content_margin_bottom = 10
		left_style.shadow_size = 10
		left_style.shadow_color = Color(0, 0, 0, 0.4)
		left_panel.add_theme_stylebox_override("panel", left_style)

	if right_panel:
		var right_style: StyleBoxFlat = StyleBoxFlat.new()
		right_style.bg_color = Color(0.1, 0.1, 0.14, 0.92)
		right_style.border_width_left = 1
		right_style.border_width_top = 1
		right_style.border_width_right = 1
		right_style.border_width_bottom = 1
		right_style.border_color = Color(0.42, 0.47, 0.62, 0.8)
		right_style.corner_radius_top_left = 14
		right_style.corner_radius_top_right = 14
		right_style.corner_radius_bottom_right = 14
		right_style.corner_radius_bottom_left = 14
		right_style.shadow_size = 10
		right_style.shadow_color = Color(0, 0, 0, 0.4)
		right_panel.add_theme_stylebox_override("panel", right_style)

func _add_sell_button(item_data: Dictionary) -> void:
	var vbox = get_node_or_null("Content/RightArea/Margin/VBox")
	if vbox == null:
		return
	
	# Remove old sell button if exists
	var old_btn = vbox.get_node_or_null("SellButton")
	if old_btn:
		old_btn.queue_free()
	
	var sell_price: int = maxi(1, int(item_data.get("price", 0)) / 2)
	var item_type: String = str(item_data.get("item_type", item_data.get("type", "")))
	var player_preview: PlayerState = GameManager.get_player(0) as PlayerState
	var owned_in_backpack: bool = false
	var owned_on_board: bool = false
	if player_preview:
		owned_in_backpack = player_preview.backpack.find(item_data) >= 0
		owned_on_board = player_preview.board.find(item_data) >= 0
	var is_owned: bool = owned_in_backpack or owned_on_board
	
	var sep = ColorRect.new()
	sep.name = "SellSep"
	sep.custom_minimum_size = Vector2(0, 1)
	sep.color = Color(0.6, 0.3, 0.3, 0.5)
	vbox.add_child(sep)
	
	var btn: Button = Button.new()
	btn.name = "SellButton"
	if not is_owned:
		btn.text = "未持有（不可出售）"
	else:
		btn.text = "出售（获得 %d 金）" % sell_price
	btn.custom_minimum_size = Vector2(0, 40)
	btn.add_theme_font_size_override("font_size", 16)
	btn.disabled = not is_owned
	
	# Red sell button style
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.6, 0.15, 0.15, 0.9)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16
	style.content_margin_right = 16
	btn.add_theme_stylebox_override("normal", style)
	
	var hover_style: StyleBoxFlat = style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(0.75, 0.2, 0.2, 1.0)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.add_theme_color_override("font_color", Color(1, 0.9, 0.8))
	
	btn.pressed.connect(func():
		var player: PlayerState = GameManager.get_player(0) as PlayerState
		if player:
			var board_idx: int = player.board.find(item_data)
			var bp_idx_before: int = player.backpack.find(item_data)
			if board_idx < 0 and bp_idx_before < 0:
				return

			player.add_gold(sell_price)

			# 按持有位置移除被出售物品
			if board_idx >= 0:
				player.board[board_idx] = null

			var bp_idx: int = player.backpack.find(item_data)
			if board_idx < 0 and bp_idx >= 0:
				player.backpack.remove_at(bp_idx)

			SignalBus.item_sold.emit(player.player_idx, item_data)
		
		close()
		# Refresh parent GameBoard
		var game_board = get_tree().current_scene
		if game_board and game_board.has_method("_refresh_all"):
			game_board._refresh_all()
	)
	
	vbox.add_child(btn)

func _describe_ingredient_special(effect_id: String) -> String:
	if IngredientManager and IngredientManager.has_method("describe_special_effect"):
		return str(IngredientManager.call("describe_special_effect", effect_id))
	return INGREDIENT_SPECIAL_TEXT.get(effect_id, effect_id)
