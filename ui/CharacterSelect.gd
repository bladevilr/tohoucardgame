extends Control

var _selected_chef: String = ""
var _chef_buttons: Dictionary = {}

@onready var background: TextureRect = $Background
@onready var left_panel: PanelContainer = $HBox/LeftPanel
@onready var right_panel: PanelContainer = $HBox/RightPanel
@onready var chef_grid: GridContainer = $HBox/LeftPanel/LeftVBox/ChefScroll/ChefGrid
@onready var chef_name_label: Label = $HBox/RightPanel/RightVBox/ChefName
@onready var cuisine_label: Label = $HBox/RightPanel/RightVBox/CuisineLabel
@onready var tool_label: Label = $HBox/RightPanel/RightVBox/ToolLabel
@onready var chef_portrait: TextureRect = $HBox/RightPanel/RightVBox/PortraitRow/ChefPortraitPanel/ChefPortrait
@onready var skill_title: Label = $HBox/RightPanel/RightVBox/PortraitRow/SkillPanel/SkillVBox/SkillTitle
@onready var skill_trigger: Label = $HBox/RightPanel/RightVBox/PortraitRow/SkillPanel/SkillVBox/SkillTrigger
@onready var skill_effect: Label = $HBox/RightPanel/RightVBox/PortraitRow/SkillPanel/SkillVBox/SkillEffect
@onready var stats_grid: GridContainer = $HBox/RightPanel/RightVBox/PortraitRow/SkillPanel/SkillVBox/StatsGrid
@onready var flavor_stat: Label = $HBox/RightPanel/RightVBox/PortraitRow/SkillPanel/SkillVBox/StatsGrid/FlavorStat
@onready var present_stat: Label = $HBox/RightPanel/RightVBox/PortraitRow/SkillPanel/SkillVBox/StatsGrid/PresentStat
@onready var tech_stat: Label = $HBox/RightPanel/RightVBox/PortraitRow/SkillPanel/SkillVBox/StatsGrid/TechStat
@onready var aroma_stat: Label = $HBox/RightPanel/RightVBox/PortraitRow/SkillPanel/SkillVBox/StatsGrid/AromaStat
@onready var strategy_label: Label = $HBox/RightPanel/RightVBox/StrategyLabel
@onready var confirm_button: Button = $HBox/RightPanel/RightVBox/ConfirmButton
@onready var back_button: Button = $BackButton

const CHEF_ORDER := ["mystia", "sakuya", "youmu", "meiling", "marisa", "reimu", "alice", "patchouli", "reisen"]

const CHEF_NAMES := {
	"mystia": "米斯蒂娅",
	"sakuya": "十六夜咲夜",
	"youmu": "魂魄妖梦",
	"meiling": "红美铃",
	"marisa": "雾雨魔理沙",
	"reimu": "博丽灵梦",
	"alice": "爱丽丝",
	"patchouli": "帕秋莉",
	"reisen": "铃仙",
}

const SKILL_NAMES := {
	"mystia": "夜雀食堂",
	"sakuya": "时停备菜",
	"youmu": "二刀流",
	"meiling": "气功调味",
	"marisa": "魔法实验",
	"reimu": "巫女直觉",
	"alice": "人偶操演",
	"patchouli": "五行调和",
	"reisen": "狂气之瞳",
}

const CUISINE_COLORS := {
	"washoku": Color("#D45757"),
	"chuuka": Color("#C0392B"),
	"youshoku": Color("#2F6FDF"),
	"yatai": Color("#D17A2A"),
	"kanmi": Color("#9C4BCC"),
	"yakuzen": Color("#2F8D4E"),
}

const CUISINE_NAMES := {
	"washoku": "和食",
	"chuuka": "中华",
	"youshoku": "洋食",
	"yatai": "夜市",
	"kanmi": "甘味",
	"yakuzen": "药膳",
}

const TRIGGER_NAMES := {
	"passive": "被动",
	"on_showdown_start": "对决开始时",
	"on_shop_refresh": "刷新商店时",
	"on_activate": "上菜时",
	"on_enchant": "附魔时",
	"on_score_calc": "结算得分时",
	"on_prestige_damage": "受到声望伤害时",
}

const TRIGGER_HELP_TEXT := {
	"passive": "效果全局常驻生效，无需满足额外条件。",
	"on_showdown_start": "仅在对决开场时触发一次。",
	"on_shop_refresh": "在商店阶段执行刷新时触发。",
	"on_activate": "当菜品上菜成功时触发。",
	"on_enchant": "当食材完成附魔时触发。",
	"on_score_calc": "在得分结算阶段生效。",
	"on_prestige_damage": "当受到声望伤害时触发。",
}

const CHEF_TRAITS := {
	"mystia": "高频上菜型。处理快、节奏强，适合用次数压制对手。",
	"sakuya": "开场提速型。提前触发关键菜品，中后期爆发稳定。",
	"youmu": "小菜连动型。触发次数多，适合滚雪球和连段。",
	"meiling": "焦香强化型。重点围绕“焦香”叠层和收益放大。",
	"marisa": "随机增益型。波动较大但上限高，适合运营和抉择。",
	"reimu": "经济运营型。刷新成本优势，擅长长局资源管理。",
	"alice": "摆盘收益型。卖相和连续输出稳定，容错率高。",
	"patchouli": "多关键词联动型。成型后强度高，但前期需要构筑。",
	"reisen": "节奏干扰型。通过冷却/状态干扰获取对局优势。",
}
const STRATEGY_TEXT := {
	"mystia": "夜市+和食联动，优先堆上菜频率，用次数滚起节奏。",
	"sakuya": "洋食+甘味成型后爆发强，前期注重过渡和关键菜冷却。",
	"youmu": "依赖小菜高频触发，先保证连段稳定，再补终结能力。",
	"meiling": "围绕焦香词条构筑，中期发力明显，适合主动压制。",
	"marisa": "随机增益波动较大，运营时优先保底，再追求上限。",
	"reimu": "刷新与资源管理优势明显，适合稳扎稳打的运营路线。",
	"alice": "摆盘收益稳定，优先保证卖相与出菜节奏的平衡。",
	"patchouli": "关键词联动上限高，前期先凑核心组合，后期强度兑现。",
	"reisen": "干扰能力强，围绕控节奏打反手，拖到优势回合收割。",
}

const GOLD := Color("#FFD66B")
const DEFAULT_CUISINE_COLOR := Color("#3A2D50")

func _ready() -> void:
	_style_panels()
	_build_chef_grid()
	chef_portrait.texture = null
	chef_portrait.visible = false
	confirm_button.pressed.connect(_on_confirm)
	back_button.pressed.connect(_on_back)
	confirm_button.disabled = true
	_apply_responsive_layout()
	get_viewport().size_changed.connect(_apply_responsive_layout)

	var anims = get_node_or_null("/root/UIAnimations")
	if anims and anims.has_method("slide_in_from_bottom"):
		anims.call("slide_in_from_bottom", back_button, 24.0, 0.25, 0.18)

	if not CHEF_ORDER.is_empty() and not ChefDatabase.get_chef(CHEF_ORDER[0]).is_empty():
		_on_chef_preview(CHEF_ORDER[0])

func _apply_responsive_layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	if vp.x <= 0.0 or vp.y <= 0.0:
		return

	var ui_scale := clampf(minf(vp.x / 1920.0, vp.y / 1080.0), 0.62, 1.0)
	var compact := vp.x < 1320.0

	var root_hbox := get_node_or_null("HBox") as HBoxContainer
	if root_hbox:
		var margin := 16.0 if compact else 32.0
		root_hbox.offset_left = margin
		root_hbox.offset_top = margin
		root_hbox.offset_right = -margin
		root_hbox.offset_bottom = -margin
		root_hbox.add_theme_constant_override("separation", int(round(maxf(12.0, 22.0 * ui_scale))))

	left_panel.custom_minimum_size.x = maxf(300.0, 430.0 * ui_scale)
	chef_grid.columns = 1 if vp.x < 980.0 else 2

	var portrait_panel := chef_portrait.get_parent() as PanelContainer
	if portrait_panel:
		portrait_panel.custom_minimum_size.x = maxf(240.0, 360.0 * ui_scale)
	var skill_panel := get_node_or_null("HBox/RightPanel/RightVBox/PortraitRow/SkillPanel") as PanelContainer
	if skill_panel:
		skill_panel.custom_minimum_size.x = maxf(220.0, 320.0 * ui_scale)

	chef_name_label.add_theme_font_size_override("font_size", int(round(maxf(26.0, 38.0 * ui_scale))))
	cuisine_label.add_theme_font_size_override("font_size", int(round(maxf(14.0, 18.0 * ui_scale))))
	tool_label.add_theme_font_size_override("font_size", int(round(maxf(14.0, 18.0 * ui_scale))))
	strategy_label.add_theme_font_size_override("font_size", int(round(maxf(13.0, 16.0 * ui_scale))))
	confirm_button.custom_minimum_size = Vector2(220.0, 48.0) * ui_scale

func _style_panels() -> void:
	var left_style := StyleBoxFlat.new()
	left_style.bg_color = Color(0.12, 0.11, 0.15, 0.85)
	left_style.border_width_left = 2
	left_style.border_width_top = 2
	left_style.border_width_right = 2
	left_style.border_width_bottom = 2
	left_style.border_color = Color(0.40, 0.35, 0.50, 0.75)
	left_style.corner_radius_top_left = 16
	left_style.corner_radius_top_right = 16
	left_style.corner_radius_bottom_right = 16
	left_style.corner_radius_bottom_left = 16
	left_style.shadow_color = Color(0, 0, 0, 0.4)
	left_style.shadow_size = 8
	left_style.content_margin_left = 16
	left_style.content_margin_right = 16
	left_style.content_margin_top = 16
	left_style.content_margin_bottom = 16
	left_panel.add_theme_stylebox_override("panel", left_style)

	var right_style := StyleBoxFlat.new()
	right_style.bg_color = Color(0.12, 0.11, 0.15, 0.85)
	right_style.border_width_left = 2
	right_style.border_width_top = 2
	right_style.border_width_right = 2
	right_style.border_width_bottom = 2
	right_style.border_color = Color(0.40, 0.35, 0.50, 0.75)
	right_style.corner_radius_top_left = 16
	right_style.corner_radius_top_right = 16
	right_style.corner_radius_bottom_right = 16
	right_style.corner_radius_bottom_left = 16
	right_style.shadow_color = Color(0, 0, 0, 0.4)
	right_style.shadow_size = 8
	right_style.content_margin_left = 24
	right_style.content_margin_right = 24
	right_style.content_margin_top = 24
	right_style.content_margin_bottom = 24
	right_panel.add_theme_stylebox_override("panel", right_style)

	var portrait_panel: PanelContainer = chef_portrait.get_parent() as PanelContainer
	if portrait_panel:
		var portrait_style := StyleBoxFlat.new()
		portrait_style.bg_color = Color(0.06, 0.05, 0.08, 0.6)
		portrait_style.border_width_left = 2
		portrait_style.border_width_top = 2
		portrait_style.border_width_right = 2
		portrait_style.border_width_bottom = 2
		portrait_style.border_color = Color(0.40, 0.35, 0.50, 0.5)
		portrait_style.corner_radius_top_left = 12
		portrait_style.corner_radius_top_right = 12
		portrait_style.corner_radius_bottom_right = 12
		portrait_style.corner_radius_bottom_left = 12
		portrait_style.content_margin_left = 12
		portrait_style.content_margin_top = 12
		portrait_style.content_margin_right = 12
		portrait_style.content_margin_bottom = 12
		portrait_panel.add_theme_stylebox_override("panel", portrait_style)

	var skill_panel: PanelContainer = $HBox/RightPanel/RightVBox/PortraitRow/SkillPanel as PanelContainer
	if skill_panel:
		var skill_style := StyleBoxFlat.new()
		skill_style.bg_color = Color(0.06, 0.05, 0.08, 0.6)
		skill_style.corner_radius_top_left = 12
		skill_style.corner_radius_top_right = 12
		skill_style.corner_radius_bottom_right = 12
		skill_style.corner_radius_bottom_left = 12
		skill_style.border_width_left = 2
		skill_style.border_width_top = 2
		skill_style.border_width_right = 2
		skill_style.border_width_bottom = 2
		skill_style.border_color = Color(0.40, 0.35, 0.50, 0.5)
		skill_style.content_margin_left = 16
		skill_style.content_margin_top = 16
		skill_style.content_margin_right = 16
		skill_style.content_margin_bottom = 16
		skill_panel.add_theme_stylebox_override("panel", skill_style)

	var confirm_style := StyleBoxFlat.new()
	confirm_style.bg_color = Color(0.22, 0.58, 0.34, 0.95)
	confirm_style.corner_radius_top_left = 10
	confirm_style.corner_radius_top_right = 10
	confirm_style.corner_radius_bottom_right = 10
	confirm_style.corner_radius_bottom_left = 10
	confirm_button.add_theme_stylebox_override("normal", confirm_style)
	var hover_style: StyleBoxFlat = confirm_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(0.28, 0.68, 0.40, 0.98)
	confirm_button.add_theme_stylebox_override("hover", hover_style)

func _build_chef_grid() -> void:
	for child in chef_grid.get_children():
		child.queue_free()
	_chef_buttons.clear()

	var chefs_by_id: Dictionary = {}
	for chef in ChefDatabase.get_all():
		chefs_by_id[chef.get("id", "")] = chef

	var idx := 0
	for chef_id in CHEF_ORDER:
		if not chefs_by_id.has(chef_id):
			continue
		var chef: Dictionary = chefs_by_id[chef_id]
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(196, 132)
		btn.text = _display_chef_name(chef_id, chef.get("name", ""))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER

		var portrait = ArtDatabase.get_chef_portrait(chef_id)
		if portrait:
			btn.icon = portrait
			btn.expand_icon = true
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER

		btn.pressed.connect(_on_chef_preview.bind(chef_id))
		btn.mouse_entered.connect(func(): _hover_card(btn, true))
		btn.mouse_exited.connect(func(): _hover_card(btn, false))
		_apply_chef_button_style(btn, chef)
		chef_grid.add_child(btn)
		_chef_buttons[chef_id] = btn

		var anims = get_node_or_null("/root/UIAnimations")
		if anims and anims.has_method("pop_in"):
			anims.call("pop_in", btn, 0.24, Vector2(0.86, 0.86), idx * 0.06)
		idx += 1

func _apply_chef_button_style(btn: Button, chef: Dictionary) -> void:
	var cuisines: Array = chef.get("cuisines", [])
	var bg_color := DEFAULT_CUISINE_COLOR
	if cuisines.size() > 0:
		bg_color = CUISINE_COLORS.get(cuisines[0], DEFAULT_CUISINE_COLOR)

	var normal := StyleBoxFlat.new()
	normal.bg_color = bg_color.darkened(0.5)
	normal.bg_color.a = 0.5
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.border_color = bg_color.lightened(0.2)
	normal.border_color.a = 0.6
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_right = 14
	normal.corner_radius_bottom_left = 14

	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = bg_color.darkened(0.3)
	hover.bg_color.a = 0.7
	hover.border_color = GOLD
	hover.border_color.a = 0.9

	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = bg_color.darkened(0.15)
	pressed.bg_color.a = 0.85
	pressed.border_color = GOLD

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color.WHITE)

func _update_selected_button_styles() -> void:
	for id in _chef_buttons:
		var btn: Button = _chef_buttons[id]
		var chef = ChefDatabase.get_chef(id)
		if chef.is_empty():
			continue
		_apply_chef_button_style(btn, chef)

		if id == _selected_chef:
			var cuisines: Array = chef.get("cuisines", [])
			var c := DEFAULT_CUISINE_COLOR
			if cuisines.size() > 0:
				c = CUISINE_COLORS.get(cuisines[0], DEFAULT_CUISINE_COLOR)
			var selected := StyleBoxFlat.new()
			selected.bg_color = c.darkened(0.2)
			selected.bg_color.a = 0.9
			selected.border_width_left = 3
			selected.border_width_top = 3
			selected.border_width_right = 3
			selected.border_width_bottom = 3
			selected.border_color = GOLD
			selected.corner_radius_top_left = 14
			selected.corner_radius_top_right = 14
			selected.corner_radius_bottom_right = 14
			selected.corner_radius_bottom_left = 14
			selected.shadow_color = GOLD
			selected.shadow_color.a = 0.5
			selected.shadow_size = 6
			btn.add_theme_stylebox_override("normal", selected)
			btn.add_theme_stylebox_override("hover", selected)
			btn.add_theme_stylebox_override("pressed", selected)
			var anims = get_node_or_null("/root/UIAnimations")
			if anims and anims.has_method("pulse"):
				anims.call("pulse", btn, 1.04, 1.1)

func _on_chef_preview(chef_id: String) -> void:
	_selected_chef = chef_id
	confirm_button.disabled = false

	var chef = ChefDatabase.get_chef(chef_id)
	if chef.is_empty():
		return

	chef_name_label.text = _display_chef_name(chef_id, chef.get("name", ""))
	chef_portrait.texture = ArtDatabase.get_chef_portrait(chef_id)
	chef_portrait.visible = chef_portrait.texture != null

	var cuisines: Array = chef.get("cuisines", [])
	var cuisine_texts: Array[String] = []
	for c in cuisines:
		cuisine_texts.append(CUISINE_NAMES.get(c, str(c)))
	cuisine_label.text = "擅长菜系: " + (" / ".join(cuisine_texts) if not cuisine_texts.is_empty() else "暂无")

	var tool_slots: int = int(chef.get("tool_slots", 3))
	var skill_effect_data: Dictionary = chef.get("skill", {}).get("effect", {})
	if skill_effect_data.has("max_tools"):
		tool_slots = int(skill_effect_data.get("max_tools", tool_slots))
	tool_label.text = "厨具栏位: %d" % tool_slots

	var skill: Dictionary = chef.get("skill", {})
	var trigger_key: String = str(skill.get("trigger", ""))
	var trigger_name: String = TRIGGER_NAMES.get(trigger_key, trigger_key)
	var trigger_help: String = TRIGGER_HELP_TEXT.get(trigger_key, "")
	skill_title.text = "技能: " + SKILL_NAMES.get(chef_id, _safe_skill_name(skill))
	skill_trigger.text = "触发时机: %s%s" % [
		trigger_name,
		("\n" + trigger_help) if trigger_help != "" else ""
	]
	var skill_desc_raw: String = str(skill.get("description", "")).strip_edges()
	var mechanical_text: String = _describe_skill_effect(skill_effect_data)
	if skill_desc_raw != "":
		skill_effect.text = "机制效果:\n%s\n\n技能特点: %s" % [mechanical_text, skill_desc_raw]
	else:
		skill_effect.text = "机制效果:\n%s" % mechanical_text

	var base_stats: Dictionary = chef.get("base_stats", {})
	flavor_stat.text = "风味: +%d" % int(base_stats.get("flavor", 0))
	present_stat.text = "卖相: +%d" % int(base_stats.get("presentation", 0))
	tech_stat.text = "技法: +%d" % int(base_stats.get("technique", 0))
	aroma_stat.text = "香气: +%d" % int(base_stats.get("aroma", 0))

	strategy_label.text = _build_chef_overview(chef_id, cuisines, base_stats, skill.get("effect", {}))
	_update_selected_button_styles()

func _safe_skill_name(skill: Dictionary) -> String:
	var name := str(skill.get("name", "")).strip_edges()
	if name == "":
		return "专属天赋"
	if name.find("?") >= 0:
		return "专属天赋"
	return name

func _describe_skill_effect(effect: Dictionary) -> String:
	if effect.is_empty():
		return "- 提供稳定的流派增益。"

	var parts: Array[String] = []
	if effect.has("yatai_cd_reduction"):
		parts.append("- 夜市菜品冷却-%d%%" % int(float(effect["yatai_cd_reduction"]) * 100.0))
	if effect.get("night_blindness_on_opponent", false):
		parts.append("- 开局使对手获得负面状态：夜盲")
	if effect.has("all_dish_cd_reduction"):
		parts.append("- 全菜品冷却-%ss" % str(effect["all_dish_cd_reduction"]))
	if effect.has("small_dish_reactivate_chance"):
		parts.append("- 小型菜品%d%%概率再次触发" % int(float(effect["small_dish_reactivate_chance"]) * 100.0))
	if effect.has("char_aroma_effect_mult"):
		parts.append("- 焦香效果提升%d%%" % int((float(effect["char_aroma_effect_mult"]) - 1.0) * 100.0))
	if effect.has("char_aroma_bonus_mult"):
		parts.append("- 焦香额外加成x%s" % str(effect["char_aroma_bonus_mult"]))
	if effect.has("extra_random_keyword_chance"):
		parts.append("- 上菜%d%%概率获得随机关键词" % int(float(effect["extra_random_keyword_chance"]) * 100.0))
	if effect.has("free_refresh_per_day"):
		parts.append("- 每天前%d次刷新免费" % int(effect["free_refresh_per_day"]))
	if effect.has("donation_gold_chance"):
		parts.append("- 事件%d%%概率额外获得金币" % int(float(effect["donation_gold_chance"]) * 100.0))
	if effect.has("plating_effect_mult"):
		parts.append("- 摆盘效果提升%d%%" % int((float(effect["plating_effect_mult"]) - 1.0) * 100.0))
	if effect.has("plating_output_bonus"):
		parts.append("- 摆盘追加输出加成+%d%%" % int(float(effect["plating_output_bonus"]) * 100.0))
	if effect.get("five_element_bonus", false):
		parts.append("- 集齐五元素关键词时触发额外加成")
	if effect.has("element_cycle_bonus"):
		parts.append("- 元素联动加成x%s" % str(effect["element_cycle_bonus"]))
	if effect.has("opponent_random_cd_increase"):
		parts.append("- 开局随机提高对手冷却")
	if effect.get("lunatic_red_eyes", false):
		parts.append("- 上菜时有概率附加负面环境")
	if effect.has("max_tools"):
		parts.append("- 厨具上限+%d" % (int(effect["max_tools"]) - 3))
	if effect.get("swap_min_max_attrs", false):
		parts.append("- 每道菜的最高属性和最低属性互换")

	if parts.is_empty():
		return "- 提供稳定的流派增益。"
	return "\n".join(parts)

func _build_chef_overview(chef_id: String, cuisines: Array, base_stats: Dictionary, skill_effect: Dictionary) -> String:
	var cuisine_names: Array[String] = []
	for c in cuisines:
		cuisine_names.append(CUISINE_NAMES.get(str(c), str(c)))
	var cuisine_line: String = "菜系定位：%s" % (" / ".join(cuisine_names) if not cuisine_names.is_empty() else "未知")

	var trait_line: String = "角色特点：%s" % CHEF_TRAITS.get(
		chef_id,
		"围绕双菜系做联动，优先成型一条主轴。"
	)
	var stats_line: String = "属性倾向：" + _summarize_stat_profile(base_stats)
	var skill_line: String = "技能标签：" + _summarize_skill_archetype(skill_effect)
	var advice_line: String = "上手建议：%s" % STRATEGY_TEXT.get(
		chef_id,
		"先确定一条主轴流派，再用副流派补强短板。"
	)
	return "\n".join([trait_line, cuisine_line, stats_line, skill_line, advice_line])

func _summarize_stat_profile(base_stats: Dictionary) -> String:
	var labels := [
		{"key": "flavor", "name": "风味"},
		{"key": "presentation", "name": "卖相"},
		{"key": "technique", "name": "技法"},
		{"key": "aroma", "name": "香气"},
	]
	var high_name: String = "均衡"
	var high_value: int = -999
	var low_name: String = "均衡"
	var low_value: int = 999
	for entry in labels:
		var v: int = int(base_stats.get(entry["key"], 0))
		if v > high_value:
			high_value = v
			high_name = entry["name"]
		if v < low_value:
			low_value = v
			low_name = entry["name"]
	if high_name == low_name:
		return "%s均衡：%d" % [high_name, high_value]
	return "强项%s(%d)，弱项%s(%d)" % [high_name, high_value, low_name, low_value]

func _summarize_skill_archetype(effect: Dictionary) -> String:
	if effect.is_empty():
		return "稳定型：无特定约束。"
	if effect.has("free_refresh_per_day") or effect.has("donation_gold_chance"):
		return "经济运营型：缓解资源压力"
	if effect.has("all_dish_cd_reduction") or effect.has("small_dish_reactivate_chance") or effect.has("yatai_cd_reduction"):
		return "节奏控制型：上菜频率高"
	if effect.has("char_aroma_effect_mult") or effect.has("plating_effect_mult") or effect.has("plating_output_bonus"):
		return "收益放大型：核心关键词强化"
	if effect.has("opponent_random_cd_increase") or effect.get("lunatic_red_eyes", false):
		return "干扰压制型：限制对手节奏"
	if effect.get("five_element_bonus", false) or effect.has("element_cycle_bonus"):
		return "联动成型型：依赖关键词组合"
	if effect.get("swap_min_max_attrs", false):
		return "特殊机制型：改变属性结构"
	return "综合增强型：灵活适配"

func _display_chef_name(chef_id: String, fallback: String) -> String:
	if CHEF_NAMES.has(chef_id):
		return CHEF_NAMES[chef_id]
	return fallback if str(fallback).strip_edges() != "" else chef_id

func _on_confirm() -> void:
	if _selected_chef == "":
		return
	var mode: String = GameManager.game_mode
	var rating: int = SaveManager.get_player_rating()
	var opponent: Dictionary = OpponentDatabase.get_opponent_for_mode(mode, rating)
	GameManager.start_new_game(_selected_chef, opponent.get("chef_id", ""), mode, opponent)
	var transition = get_node_or_null("/root/SceneTransition")
	if transition and transition.has_method("change_scene"):
		transition.call("change_scene", "res://ui/GameBoard.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/GameBoard.tscn")

func _on_back() -> void:
	var transition = get_node_or_null("/root/SceneTransition")
	if transition and transition.has_method("change_scene"):
		transition.call("change_scene", "res://ui/GameModeSelect.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/GameModeSelect.tscn")

func _hover_card(card: Control, hovered: bool) -> void:
	var anims = get_node_or_null("/root/UIAnimations")
	if anims == null:
		return
	if hovered and anims.has_method("hover_lift"):
		anims.call("hover_lift", card, 1.06, 0.14)
	elif not hovered and anims.has_method("hover_reset"):
		anims.call("hover_reset", card, 0.12)

func _apply_background_shader() -> void:
	pass

