extends PanelContainer

const TAG_TEXT := {
	"chinese": "中餐",
	"washoku": "和食",
	"chuuka": "中华",
	"youshoku": "洋食",
	"yatai": "夜市",
	"kanmi": "甜品",
	"yakuzen": "药膳",
	"meat": "肉类",
	"vegetable": "蔬菜",
	"seafood": "海鲜",
	"dessert": "甜点",
	"soup": "汤品",
	"noodle": "面食",
	"stir_fried": "炒制",
	"fried": "油炸",
	"grilled": "烧烤",
	"steamed": "蒸制",
	"stewed": "炖煮",
}

const KEYWORD_TEXT := {
	"umami": "鲜美",
	"char_aroma": "焦香",
	"plating": "摆盘",
	"knife_work": "刀工",
	"aftertaste": "回味",
	"secret_recipe": "秘方",
	"spotlight": "聚光",
	"greasy": "油腻",
	"messy": "杂乱",
	"taste_fatigue": "味觉疲劳",
	"dull": "沉闷",
}

const INGREDIENT_SPECIAL_TEXT := {
	"clear_greasy_1": "开场清除1层油腻",
	"add_env_greasy_2": "首次上菜时给环境增加2层油腻",
	"clear_all_env_1": "开场各清除1层环境减益",
	"double_next_activate": "首次上菜风味倍率翻倍",
	"grant_secret_recipe": "开场获得1层秘方",
	"grant_char_aroma_3": "开场获得3层焦香",
}

const TERM_DEFINITIONS := {
	"上菜": "按冷却顺序上桌，分数 = 风味 × 技法倍率 × 疲劳系数 × 评委修正。",
	"触发": "满足特定事件时自动执行效果，如相邻菜上桌、获得关键字等。",
	"被动": "始终生效的持续效果，无需任何触发条件。",
	"相邻": "棋盘上左右紧贴该菜的卡牌，换位后重新判定。",
	"环境": "全场共享负面状态。油腻 -2 风味/层；杂乱 -2 卖相/层；味觉疲劳 -15% 倍率/层。",
	"鲜美": "每层上菜时额外 +3 风味，不受味觉疲劳影响。",
	"焦香": "每层额外 +2 风味，联动烧烤体系有额外触发。",
	"摆盘": "每层 +3 卖相。卖相差值每秒扣对手 差值×0.6×技法倍率 分（持续伤害）。",
	"刀工": "每层 +2 技法。技法倍率 = 1.0 + 技法 × 0.02（50技法 = ×2.0倍）。",
	"回味": "下一道菜上桌时额外结算本次风味 +30%（延迟触发）。",
	"秘方": "消耗时爆发 +50% 风味，用后清零，可多层叠加。",
	"聚光": "每层消耗后缩短本菜冷却 -1 秒，可提前上桌。",
	"油腻": "环境减益，每层全场 -2 风味/次。清淡菜或药膳可降层。",
	"杂乱": "环境减益，每层全场 -2 卖相/次，双方持续伤害同时受损。",
	"味觉疲劳": "环境减益，每层全场风味倍率 -15%，需及时清除。",
	"沉闷": "每层使该菜冷却增加 +0.3 秒。",
	"融合": "横跨多菜系，可触发多套体系的协同奖励。",
	"精进": "经专项修炼，大幅强化关键字效率或倍率上限。",
	"风味": "核心得分：每次上菜 = 风味 × 技法倍率，对胜负影响最大。",
	"卖相": "持续伤害来源：双方卖相差越大，每秒扣分越多。",
	"技法": "全局倍率：技法 × 0.02 + 1，同时作用于风味和持续伤害。",
	"香气": "加速冷却：每 10 点缩短冷却 5%，上限 35%（70香气最快）。",
}

@onready var name_label: Label = $Margin/VBox/TitleRow/NameLabel
@onready var star_label: Label = $Margin/VBox/TitleRow/StarLabel
@onready var tag_label: Label = $Margin/VBox/TitleRow/TagLabel
@onready var cuisine_label: Label = $Margin/VBox/TypeRow/CuisineLabel
@onready var item_type_label: Label = $Margin/VBox/TypeRow/ItemTypeLabel
@onready var stats_row: HBoxContainer = $Margin/VBox/StatsRow
@onready var cd_row: HBoxContainer = $Margin/VBox/CDRow
@onready var cd_label: Label = $Margin/VBox/CDRow/CDLabel
@onready var effect_label: Label = $Margin/VBox/EffectLabel
@onready var desc_label: Label = $Margin/VBox/DescLabel
@onready var hint_label: Label = $Margin/VBox/HintLabel

# 名词解释副面板
var _glossary_panel: PanelContainer = null
var _glossary_vbox: VBoxContainer = null

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	hint_label.text = "右键查看详情"

	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = load("res://assets/ui/cards/card_bg_texture.png")
	style.texture_margin_left = 12
	style.texture_margin_top = 12
	style.texture_margin_right = 12
	style.texture_margin_bottom = 12
	style.modulate_color = Color(0.15, 0.15, 0.2, 0.98)
	add_theme_stylebox_override("panel", style)

	_build_glossary_panel()

func _build_glossary_panel() -> void:
	_glossary_panel = PanelContainer.new()
	_glossary_panel.z_index = 200
	_glossary_panel.visible = false
	_glossary_panel.modulate.a = 0.0
	# 不设固定最小宽度，由内容自然决定

	var g_style: StyleBoxFlat = StyleBoxFlat.new()
	g_style.bg_color = Color(0.10, 0.10, 0.16, 0.97)
	g_style.border_width_left = 1
	g_style.border_width_top = 1
	g_style.border_width_right = 1
	g_style.border_width_bottom = 1
	g_style.border_color = Color(0.45, 0.4, 0.6, 0.7)
	g_style.corner_radius_top_left = 8
	g_style.corner_radius_top_right = 8
	g_style.corner_radius_bottom_right = 8
	g_style.corner_radius_bottom_left = 8
	g_style.content_margin_left = 10
	g_style.content_margin_top = 8
	g_style.content_margin_right = 10
	g_style.content_margin_bottom = 8
	_glossary_panel.add_theme_stylebox_override("panel", g_style)

	_glossary_vbox = VBoxContainer.new()
	_glossary_vbox.add_theme_constant_override("separation", 6)
	_glossary_panel.add_child(_glossary_vbox)

	# 标题
	var header: Label = Label.new()
	header.text = "— 名词解释 —"
	header.add_theme_color_override("font_color", Color(0.7, 0.65, 0.85))
	header.add_theme_font_size_override("font_size", 12)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_glossary_vbox.add_child(header)

	call_deferred("_attach_glossary_panel")

func _attach_glossary_panel() -> void:
	if get_parent() and _glossary_panel:
		get_parent().add_child(_glossary_panel)

func show_item(item_data: Dictionary, mouse_pos: Vector2) -> void:
	if item_data.is_empty():
		hide_tooltip()
		return

	name_label.text = _get_display_name(item_data)

	var description: String = str(item_data.get("description", ""))
	var text_len: int = description.length()
	if text_len < 20:
		custom_minimum_size.x = 220
	elif text_len < 40:
		custom_minimum_size.x = 260
	else:
		custom_minimum_size.x = 300

	reset_size()

	var star_level: int = int(item_data.get("star_level", 1))
	star_label.text = GameConfig.STAR_NAMES.get(star_level, "★")
	star_label.add_theme_color_override("font_color", GameConfig.STAR_COLORS.get(star_level, Color.WHITE))

	tag_label.text = _build_tag_line(item_data)

	var cuisine: String = str(item_data.get("cuisine", ""))
	cuisine_label.text = _translate_tag(cuisine) if cuisine != "" else ""
	cuisine_label.visible = cuisine != ""

	var item_type: String = str(item_data.get("item_type", item_data.get("type", "dish")))
	item_type_label.text = _get_type_display(item_type)

	var base_stats: Dictionary = item_data.get("base_stats", {})
	_update_stats_row(base_stats)

	var cd: float = float(item_data.get("cooldown", 0))
	if cd > 0:
		cd_row.visible = true
		cd_label.text = "冷却: %.1f秒" % cd
	else:
		cd_row.visible = false

	effect_label.text = _build_effect_summary(item_data)

	if description.length() > 60:
		description = description.substr(0, 58) + "..."
	desc_label.text = description if description != "" else ""
	desc_label.visible = description != ""

	hint_label.text = "右键查看详情"

	global_position = mouse_pos + Vector2(20, 20)
	await get_tree().process_frame
	_keep_on_screen(mouse_pos)

	visible = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.12)

	# 更新并显示名词解释副面板
	_update_glossary(item_data, mouse_pos)

func hide_tooltip() -> void:
	visible = false
	modulate.a = 0.0
	if _glossary_panel:
		_glossary_panel.visible = false
		_glossary_panel.modulate.a = 0.0

func _update_glossary(item_data: Dictionary, mouse_pos: Vector2) -> void:
	if not _glossary_panel or not _glossary_vbox:
		return

	# 清空除标题以外的内容
	var children: Array = _glossary_vbox.get_children()
	for i in range(1, children.size()):
		children[i].queue_free()

	var terms: Array[String] = _collect_tooltip_terms(item_data)
	if terms.is_empty():
		_glossary_panel.visible = false
		return

	for term in terms:
		var def: String = TERM_DEFINITIONS.get(term, "")
		if def == "":
			continue
		_add_glossary_entry(term, def)

	_glossary_panel.reset_size()
	await get_tree().process_frame

	# 定位：主 tooltip 右侧，若超出屏幕则左侧
	var vp: Vector2 = get_viewport_rect().size
	var gx: float = global_position.x + size.x + 8
	if gx + _glossary_panel.size.x > vp.x:
		gx = global_position.x - _glossary_panel.size.x - 8
	_glossary_panel.global_position = Vector2(gx, global_position.y)

	_glossary_panel.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(_glossary_panel, "modulate:a", 1.0, 0.12)

func _add_glossary_entry(term: String, def: String) -> void:
	var row: VBoxContainer = VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)

	var t: Label = Label.new()
	t.text = "▸ " + term
	t.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
	t.add_theme_font_size_override("font_size", 13)
	row.add_child(t)

	var d: Label = Label.new()
	d.text = def
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.custom_minimum_size = Vector2(200, 0)
	d.add_theme_color_override("font_color", Color(0.82, 0.82, 0.88))
	d.add_theme_font_size_override("font_size", 12)
	row.add_child(d)

	_glossary_vbox.add_child(row)

func _collect_tooltip_terms(item_data: Dictionary) -> Array[String]:
	var ordered: Array[String] = []
	var seen: Dictionary = {}
	var push: Callable = func(term: String) -> void:
		if term == "" or seen.has(term):
			return
		if not TERM_DEFINITIONS.has(term):
			return
		seen[term] = true
		ordered.append(term)

	# 来自 tags/cuisine 的关键字
	for tag in item_data.get("tags", []):
		var s: String = str(tag)
		if KEYWORD_TEXT.has(s):
			push.call(KEYWORD_TEXT[s])
		elif s == "fusion":
			push.call("融合")
		elif s == "mastered":
			push.call("精进")

	# 来自 on_activate 效果
	for effect in item_data.get("on_activate", []):
		if not (effect is Dictionary):
			continue
		for kw_key in ["add_keyword", "consume_keyword", "add_env_keyword", "clear_env_keyword", "keyword"]:
			if effect.has(kw_key):
				push.call(KEYWORD_TEXT.get(str(effect[kw_key]), ""))
		var typ: String = str(effect.get("type", ""))
		if typ in ["gain_keyword", "apply_keyword", "consume_keyword"]:
			push.call("触发")

	# 来自 triggers
	for trigger in item_data.get("triggers", []):
		if not (trigger is Dictionary):
			continue
		push.call("触发")
		var event: String = str(trigger.get("event", "")).to_lower()
		if event.find("adjacent") >= 0 or event.find("neighbor") >= 0:
			push.call("相邻")
		if trigger.has("effect") and trigger["effect"] is Dictionary:
			var eff: Dictionary = trigger["effect"]
			for kw_key in ["add_keyword", "consume_keyword", "keyword"]:
				if eff.has(kw_key):
					push.call(KEYWORD_TEXT.get(str(eff[kw_key]), ""))

	return ordered

func _keep_on_screen(mouse_pos: Vector2) -> void:
	var vp: Vector2 = get_viewport_rect().size
	if global_position.x + size.x > vp.x:
		global_position.x = mouse_pos.x - size.x - 20
	if global_position.y + size.y > vp.y:
		global_position.y = mouse_pos.y - size.y - 20

func _get_display_name(item_data: Dictionary) -> String:
	var name_cn: String = str(item_data.get("name_cn", "")).strip_edges()
	if name_cn != "":
		return name_cn
	return str(item_data.get("name", "???"))

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
			return "物品"

func _update_stats_row(stats: Dictionary) -> void:
	for child in stats_row.get_children():
		child.queue_free()

	if stats.is_empty():
		stats_row.visible = false
		return

	stats_row.visible = true
	for stat_key in GameConfig.STAT_KEYS:
		var value: int = int(stats.get(stat_key, 0))
		if value == 0:
			continue

		var stat_label: Label = Label.new()
		var icon: String = str(GameConfig.STAT_ICONS.get(stat_key, ""))
		var stat_name: String = str(GameConfig.STAT_NAMES.get(stat_key, stat_key))
		stat_label.text = "%s%s+%d" % [icon, stat_name, value]
		stat_label.add_theme_font_size_override("font_size", 13)
		stat_label.add_theme_color_override("font_color", GameConfig.STAT_COLORS.get(stat_key, Color.WHITE))
		stats_row.add_child(stat_label)

func _build_tag_line(item_data: Dictionary) -> String:
	var parts: Array[String] = []
	var cuisine: String = str(item_data.get("cuisine", ""))
	if cuisine != "":
		parts.append(_translate_tag(cuisine))

	for tag in item_data.get("tags", []):
		var s: String = str(tag)
		if s == cuisine:
			continue
		if TAG_TEXT.has(s):
			parts.append(TAG_TEXT[s])
		if parts.size() >= 2:
			break

	if parts.is_empty():
		return "普通料理"
	return " / ".join(parts)

func _build_effect_summary(item_data: Dictionary) -> String:
	var lines: Array[String] = []
	var item_type: String = str(item_data.get("item_type", item_data.get("type", "dish")))

	if item_type == "ingredient":
		var stat_mods: Dictionary = item_data.get("stat_modifiers", {})
		var stat_parts: Array[String] = []
		for stat_key in GameConfig.STAT_KEYS:
			var delta: float = float(stat_mods.get(stat_key, 0.0))
			if absf(delta) <= 0.001:
				continue
			var stat_name: String = str(GameConfig.STAT_NAMES.get(stat_key, stat_key))
			if absf(delta - roundf(delta)) <= 0.001:
				stat_parts.append("%s%+d" % [stat_name, int(roundf(delta))])
			else:
				stat_parts.append("%s%+.1f" % [stat_name, delta])
		if not stat_parts.is_empty():
			lines.append("属性: " + "、".join(stat_parts))

		var add_tags: Array = item_data.get("added_tags", [])
		if not add_tags.is_empty():
			var add_names: Array[String] = []
			for tag in add_tags:
				add_names.append(_translate_tag(str(tag)))
			lines.append("附加标签: " + "、".join(add_names))

		var remove_tags: Array = item_data.get("removed_tags", [])
		if not remove_tags.is_empty():
			var remove_names: Array[String] = []
			for tag in remove_tags:
				remove_names.append(_translate_tag(str(tag)))
			lines.append("移除标签: " + "、".join(remove_names))

		var special_id: String = str(item_data.get("special_effect", ""))
		if special_id != "":
			lines.append("特效: " + _describe_ingredient_special(special_id))

		if lines.is_empty():
			var flavor_text: String = str(item_data.get("flavor_text", "")).strip_edges()
			if flavor_text != "":
				lines.append(flavor_text)
			else:
				lines.append("无特殊效果")

		if lines.size() > 3:
			lines = lines.slice(0, 3)
		return "\n".join(lines)

	var active: Array = item_data.get("on_activate", [])
	if not active.is_empty():
		lines.append("上菜: " + _describe_effect(active[0]))

	var triggers: Array = item_data.get("triggers", [])
	if not triggers.is_empty():
		var trigger_desc: String = _describe_trigger(triggers[0])
		if trigger_desc != "":
			lines.append(trigger_desc)

	if lines.is_empty():
		lines.append("无特殊效果")

	if lines.size() > 3:
		lines = lines.slice(0, 3)

	return "\n".join(lines)

func _describe_ingredient_special(effect_id: String) -> String:
	if IngredientManager and IngredientManager.has_method("describe_special_effect"):
		return str(IngredientManager.call("describe_special_effect", effect_id))
	return INGREDIENT_SPECIAL_TEXT.get(effect_id, effect_id)

func _describe_effect(effect: Dictionary) -> String:
	if effect.has("add_keyword"):
		var kw: String = _translate_keyword(str(effect.get("add_keyword", "")))
		var stacks: int = int(effect.get("keyword_stacks", 1))
		var parts: Array[String] = ["获得%d层%s" % [stacks, kw]]
		if effect.has("add_env_keyword"):
			var env_kw: String = _translate_keyword(str(effect.get("add_env_keyword", "")))
			var env_stacks: int = int(effect.get("env_stacks", effect.get("stacks", 1)))
			parts.append("环境+%d层%s" % [env_stacks, env_kw])
		return "、".join(parts)
	if effect.has("clear_env_keyword"):
		var kw: String = _translate_keyword(str(effect.get("clear_env_keyword", "")))
		var stacks: int = int(effect.get("stacks", 1))
		return "清除%d层%s" % [stacks, kw]
	if effect.has("add_env_keyword"):
		var kw: String = _translate_keyword(str(effect.get("add_env_keyword", "")))
		var stacks: int = int(effect.get("env_stacks", effect.get("stacks", 1)))
		return "环境+%d层%s" % [stacks, kw]
	if effect.has("consume_keyword"):
		var kw: String = _translate_keyword(str(effect.get("consume_keyword", "")))
		return "消耗%s" % kw
	if effect.has("flavor_mult"):
		return "风味x%.1f" % float(effect.get("flavor_mult", 1.0))
	if effect.has("presentation_mult"):
		return "卖相x%.1f" % float(effect.get("presentation_mult", 1.0))

	var typ: String = str(effect.get("type", ""))
	match typ:
		"score":
			var parts: Array[String] = []
			if int(effect.get("flavor", 0)) > 0:
				parts.append("风味+%d" % int(effect.get("flavor", 0)))
			if int(effect.get("presentation", 0)) > 0:
				parts.append("卖相+%d" % int(effect.get("presentation", 0)))
			if int(effect.get("technique", 0)) > 0:
				parts.append("技法+%d" % int(effect.get("technique", 0)))
			if int(effect.get("aroma", 0)) > 0:
				parts.append("香气+%d" % int(effect.get("aroma", 0)))
			return "提升" if parts.is_empty() else "提升" + "、".join(parts)
		"gain_keyword", "apply_keyword":
			return "获得%d层%s" % [
				int(effect.get("stacks", 1)),
				_translate_keyword(str(effect.get("keyword", "")))
			]
		"consume_keyword":
			return "消耗%s" % _translate_keyword(str(effect.get("keyword", "")))
		"add_environment", "trigger_environment":
			return "环境+%d层%s" % [
				int(effect.get("stacks", 1)),
				_translate_keyword(str(effect.get("keyword", "")))
			]
		"flavor_mult":
			return "风味x%.1f" % float(effect.get("value", effect.get("mult", 1.0)))
		"presentation_mult":
			return "卖相x%.1f" % float(effect.get("value", effect.get("mult", 1.0)))
		"stat_bonus":
			return "获得属性加成"
		_:
			if effect.has("keyword"):
				return "获得%s" % _translate_keyword(str(effect.get("keyword", "")))
			return "无特殊效果"

func _describe_trigger(trigger: Dictionary) -> String:
	var event: String = str(trigger.get("event", "")).to_lower()
	var prefix: String = "被动: "
	match event:
		"item_activated":
			prefix = "上菜: "
		"when_adjacent_activates", "on_adjacent_activate":
			prefix = "相邻上菜: "
		"when_left_neighbor_activates", "on_left_activate":
			prefix = "左侧上菜: "
		"when_gain_keyword", "on_keyword_gain":
			prefix = "获得关键字: "
		"on_tick":
			prefix = "周期触发: "
		"on_self_activate":
			prefix = "上菜: "

	var desc: String = str(trigger.get("desc", ""))
	if desc != "":
		return prefix + desc
	if trigger.has("effect") and trigger.get("effect") is Dictionary:
		return prefix + _describe_effect(trigger.get("effect"))
	return ""

func _translate_tag(tag: String) -> String:
	return TAG_TEXT.get(tag, tag)

func _translate_keyword(keyword_id: String) -> String:
	return KEYWORD_TEXT.get(keyword_id, keyword_id)
