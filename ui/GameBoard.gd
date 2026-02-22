extends Control

const ItemCardScene = preload("res://ui/components/ItemCard.tscn")
const BoardSlotScene = preload("res://ui/components/BoardSlot.tscn")
const BubbleItemScene = preload("res://ui/components/BubbleItem.tscn")
const CardInspectorScene = preload("res://ui/views/CardInspector.tscn")
const AdjacencyVisualizerScript = preload("res://ui/effects/AdjacencyVisualizer.gd")
const DragManagerScript = preload("res://ui/effects/DragManager.gd")
const FloatingTextScript = preload("res://ui/effects/FloatingText.gd")
const PhaseBannerScene = preload("res://ui/components/PhaseBanner.tscn")
const HelpPanelScript = preload("res://ui/components/HelpPanel.gd")
const ItemTooltipScene = preload("res://ui/components/ItemTooltip.tscn")

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
	"seija": "鬼人正邪"
}

var _current_merchant: String = ""
var _current_encounter_icon: String = ""
var _current_encounter: Dictionary = {}
var _event_resolved_action: int = -1
var _last_action_seen: int = 0  # Track current action for shop reset logic
var _board_slots: Array = []
var _selected_board_slot: int = -1
var _merchant_buttons: Dictionary = {}
var _adjacency_visualizer: Control = null
var _drag_manager: Node = null
var _phase_banner = null
var _help_panel = null
var _status_initialized = false
var _last_gold = 0
var _last_prestige = 0
var _item_tooltip = null
var _item_tooltip_layer: CanvasLayer = null
var _pending_ingredient_idx: int = -1
var _ingredient_mode: bool = false
var _level_label: Label = null
var _xp_bar: ProgressBar = null
var _sell_zone: ColorRect = null
var _sell_zone_label: Label = null

const BUBBLE_EVENT_EFFECTS := {
	"shrine_blessing": [
		{"effect_id": "gain_gold_3", "summary": "灵梦的祈福带来财运（金币 +3）。"},
		{"effect_id": "gain_prestige_1", "summary": "神社庇佑提升了你的名望（声望 +1）。"},
		{"effect_id": "gain_random_ingredient_silver", "summary": "赛钱箱回响，你得到了一份御神供食材。"},
	],
	"tengu_gamble": [
		{"effect_id": "gamble_small", "summary": "你参加了文文的赌局。"},
		{"effect_id": "gain_gold_4", "summary": "文文给了你一笔“内幕费”（金币 +4）。"},
		{"effect_id": "lose_gold_2_random_reward", "summary": "你用2金币换了一份可疑包裹。"},
	],
	"chef_training": [
		{"effect_id": "all_dish_technique_plus_3", "summary": "修行后，你的刀工明显提升（全菜品技法 +3）。"},
		{"effect_id": "all_dish_cd_minus_05", "summary": "训练让你的出菜节奏更快（全菜品冷却 -0.5 秒）。"},
		{"effect_id": "gain_random_technique", "summary": "你领悟了一门新的技法。"},
	],
	"treasure_hunt": [
		{"effect_id": "gain_random_ingredient_gold", "summary": "你挖到了稀有食材。"},
		{"effect_id": "gain_random_technique", "summary": "你找到了遗失的技法卷轴。"},
		{"effect_id": "gain_gold_5", "summary": "宝箱里装着一袋金币（金币 +5）。"},
	],
}

@onready var background: TextureRect = $Background
var day_label: Label = null
var prestige_label: Label = null
var gold_label: Label = null
var chef_label: Label = null
var judge_panel = null
var chef_portrait_frame: PanelContainer = null
var chef_portrait: TextureRect = null
var merchant_portrait: TextureRect = null
var shop_name_label: Label = null
var shop_desc_label: Label = null

var merchant_tabs: VBoxContainer = null
var shop_container: HBoxContainer = null
var refresh_button: Button = null
var bubble_shop: Control = null  # BubbleShop instance

var board_container: HBoxContainer = null
var tool_container: HBoxContainer = null

var ready_button: Button = null
var backpack_drawer = null
var video_overlay = null

func _ready():
	_ensure_effect_nodes()
	_resolve_ui_nodes()
	_setup_phase_banner()
	_setup_help_panel()
	_setup_item_tooltip()
	_setup_judge_drawer()
	_apply_visuals()
	_setup_board()
	_setup_signals()
	_setup_sell_zone()
	_setup_level_display()
	# 注释已修复
	if shop_container:
		shop_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# V2: Hide shop row initially, show bubbles instead
	if GameConfig.BATTLE_SYSTEM_V2:
		var shop_row = _find_node(["ContentLayer/MerchantZone/ShopRow"])
		if shop_row: shop_row.visible = false
		var portrait_border = _find_node(["ContentLayer/MerchantZone/MerchantPortraitBorder"])
		if portrait_border: portrait_border.visible = false

	var match_state = GameManager.get_match_state()
	var player = GameManager.get_player(0)
	if match_state and player and match_state.current_phase == GameConfig.Phase.SHOP:
		if ShopManager.get_shop("ingredient").is_empty():
			ShopManager.generate_shop(player, match_state.current_day)
	
		backpack_drawer.setup(player)
	_refresh_all()
	
	if video_overlay and video_overlay.has_signal("video_finished"):
		video_overlay.video_finished.connect(_on_video_finished)

	if match_state and _phase_banner:
		_phase_banner.show_phase(match_state.current_phase)

	# Check for pending level-ups missed during scene transition
	if GameManager.pop_pending_level_up():
		call_deferred("_show_level_up_overlay")

	_apply_responsive_layout()
	get_viewport().size_changed.connect(_on_viewport_resized)

func _setup_level_display() -> void:
	var vbox: VBoxContainer = get_node_or_null("LeftSidebar/VBox") as VBoxContainer
	if vbox == null:
		return
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(0.4, 0.35, 0.55, 0.5))
	vbox.add_child(sep)

	_level_label = Label.new()
	_level_label.name = "LevelLabel"
	_level_label.text = "等级 1"
	_level_label.add_theme_font_size_override("font_size", 18)
	_level_label.add_theme_color_override("font_color", Color(0.25, 0.15, 0.4)) # Dark Purple
	vbox.add_child(_level_label)

	_xp_bar = ProgressBar.new()
	_xp_bar.name = "XpBar"
	_xp_bar.max_value = GameConfig.XP_PER_LEVEL
	_xp_bar.value = 0
	_xp_bar.show_percentage = false
	_xp_bar.custom_minimum_size = Vector2(0, 10)
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.55, 0.25, 0.95)
	fill_style.corner_radius_top_left = 3
	fill_style.corner_radius_top_right = 3
	fill_style.corner_radius_bottom_right = 3
	fill_style.corner_radius_bottom_left = 3
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.8, 0.75, 0.7) # Darker parchment for bar bg
	bg_style.corner_radius_top_left = 3
	bg_style.corner_radius_top_right = 3
	bg_style.corner_radius_bottom_right = 3
	bg_style.corner_radius_bottom_left = 3
	_xp_bar.add_theme_stylebox_override("fill", fill_style)
	_xp_bar.add_theme_stylebox_override("background", bg_style)
	vbox.add_child(_xp_bar)

	var xp_text := Label.new()
	xp_text.name = "XpTextLabel"
	xp_text.text = "0 / 8 经验"
	xp_text.add_theme_font_size_override("font_size", 11)
	xp_text.add_theme_color_override("font_color", Color(0.3, 0.2, 0.4)) # Dark text
	vbox.add_child(xp_text)

	var bp_label := Label.new()
	bp_label.name = "BackpackSizeLabel"
	bp_label.add_theme_font_size_override("font_size", 11)
	bp_label.add_theme_color_override("font_color", Color(0.2, 0.3, 0.2)) # Dark Green
	vbox.add_child(bp_label)

func _find_node(paths: Array) -> Node:
	for p in paths:
		var n := get_node_or_null(str(p))
		if n != null:
			return n
	return null

func _on_viewport_resized() -> void:
	_apply_responsive_layout()

func _apply_responsive_layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	if vp.x <= 0.0 or vp.y <= 0.0:
		return

	var ui_scale := clampf(minf(vp.x / 1920.0, vp.y / 1080.0), 0.62, 1.0)
	var compact := vp.x < 1400.0

	var content_layer := get_node_or_null("ContentLayer") as VBoxContainer
	if content_layer:
		content_layer.offset_left = 80.0 * ui_scale
		content_layer.offset_right = -170.0 * ui_scale

	var board_panel := get_node_or_null("ContentLayer/PlayerZone/BoardArea/BoardContainer") as PanelContainer
	if board_panel:
		board_panel.custom_minimum_size.y = maxf(220.0, 330.0 * ui_scale)

	var selection_bubbles := get_node_or_null("ContentLayer/MerchantZone/SelectionBubbleContainer") as HBoxContainer
	if selection_bubbles:
		selection_bubbles.add_theme_constant_override("separation", int(round(maxf(60.0, 80.0 * ui_scale))))

	var left_sidebar := get_node_or_null("LeftSidebar") as PanelContainer
	if left_sidebar:
		var side_w := maxf(110.0, 132.0 * ui_scale)
		var half_h := maxf(72.0, 90.0 * ui_scale)
		left_sidebar.offset_left = 8.0
		left_sidebar.offset_right = 8.0 + side_w
		left_sidebar.offset_top = -half_h
		left_sidebar.offset_bottom = half_h

		# 注释已修复
		if backpack_drawer:
			var sidebar_right_x := 8.0 + side_w + 8.0
			backpack_drawer.set_anchors_preset(Control.PRESET_TOP_LEFT)
			backpack_drawer.anchor_right = 1.0
			backpack_drawer.offset_left = sidebar_right_x
			backpack_drawer.offset_right = -8.0
			backpack_drawer.offset_top = 0.0
			backpack_drawer.offset_bottom = 220.0
			# Sell zone is 80px tall; keep an 8px gap below it.
			backpack_drawer.open_y_override = 88.0
			var tab_c := backpack_drawer.get_node_or_null("TabContainer") as Control
			if tab_c:
				tab_c.visible = false

	var ready_btn := get_node_or_null("ControlsLayer/ReadyButton") as Button
	if ready_btn:
		ready_btn.add_theme_font_size_override("font_size", int(round(maxf(14.0, 18.0 * ui_scale))))
		var ready_w := maxf(120.0, 150.0 * ui_scale)
		var ready_h := maxf(30.0, 35.0 * ui_scale)
		ready_btn.offset_right = -24.0
		ready_btn.offset_left = ready_btn.offset_right - ready_w
		ready_btn.offset_bottom = -20.0
		ready_btn.offset_top = ready_btn.offset_bottom - ready_h

	var refresh_btn := get_node_or_null("ControlsLayer/FloatRefreshButton") as Button
	if refresh_btn:
		refresh_btn.add_theme_font_size_override("font_size", int(round(maxf(14.0, 18.0 * ui_scale))))
		var refresh_w := maxf(124.0, 150.0 * ui_scale)
		var refresh_h := maxf(30.0, 35.0 * ui_scale)
		refresh_btn.offset_right = ready_btn.offset_left - 12.0 if ready_btn else -190.0
		refresh_btn.offset_left = refresh_btn.offset_right - refresh_w
		refresh_btn.offset_bottom = -20.0
		refresh_btn.offset_top = refresh_btn.offset_bottom - refresh_h

	var bp_btn := _find_node(["LeftSidebar/VBox/FloatBackpackButton"]) as Button
	if bp_btn:
		bp_btn.add_theme_font_size_override("font_size", int(round(maxf(12.0, 14.0 * ui_scale))))

	if chef_portrait_frame:
		var portrait_w := maxf(150.0, 230.0 * ui_scale)
		var portrait_h := maxf(180.0, 330.0 * ui_scale)
		chef_portrait_frame.offset_left = -portrait_w - 10.0
		chef_portrait_frame.offset_right = -10.0
		chef_portrait_frame.offset_top = -portrait_h - 10.0
		chef_portrait_frame.offset_bottom = -10.0

	# Removed automatic slot scaling override to respect the explicit setup value (0.75)
	# var slot_scale := clampf(0.68 * ui_scale / 0.85, 0.5, 0.75)
	# for slot in _board_slots:
	# 	if slot:
	# 		slot.scale = Vector2(slot_scale, slot_scale)

	if backpack_drawer and backpack_drawer.has_method("_on_viewport_resized"):
		backpack_drawer.call("_on_viewport_resized")

	if compact:
		var tool_area := get_node_or_null("ContentLayer/PlayerZone/BoardArea/ToolArea") as Control
		if tool_area:
			tool_area.custom_minimum_size.x = maxf(84.0, 120.0 * ui_scale)

func _resolve_ui_nodes() -> void:
	# Top Bar / Sidebar
	day_label = _find_node(["LeftSidebar/VBox/DayLabel"]) as Label
	gold_label = _find_node(["LeftSidebar/VBox/GoldLabel"]) as Label
	prestige_label = _find_node(["LeftSidebar/VBox/PrestigeLabel"]) as Label
	
	# Fix Text Color for sidebar (Dark on Parchment)
	var dark_color = Color(0.25, 0.15, 0.1)
	if day_label: day_label.add_theme_color_override("font_color", dark_color)
	if gold_label: gold_label.add_theme_color_override("font_color", dark_color)
	if prestige_label: prestige_label.add_theme_color_override("font_color", dark_color)

	var left_sidebar = _find_node(["LeftSidebar"]) as PanelContainer
	if left_sidebar:
		var panel_tex = load("res://assets/ui/theme/panel_bg.png")
		if panel_tex:
			var style = StyleBoxTexture.new()
			style.texture = panel_tex
			style.texture_margin_left = 12
			style.texture_margin_top = 12
			style.texture_margin_right = 12
			style.texture_margin_bottom = 12
			style.content_margin_left = 16
			style.content_margin_top = 16
			style.content_margin_right = 16
			style.content_margin_bottom = 16
			left_sidebar.add_theme_stylebox_override("panel", style)

	judge_panel = _find_node([
		"JudgeDrawer/JudgeSlidePanel/JudgePanel"
	])
	
	# Portrait Layer (Bottom Overlay)
	chef_portrait_frame = _find_node([
		"PortraitLayer/ChefPortraitFrame"
	]) as PanelContainer
	chef_portrait = _find_node([
		"PortraitLayer/ChefPortraitFrame/ChefPortrait"
	]) as TextureRect

	# Merchant Zone
	merchant_tabs = _find_node([
		"ContentLayer/MerchantZone/ShopRow/MerchantTabs"
	]) as VBoxContainer
	shop_container = _find_node([
		"ContentLayer/MerchantZone/ShopRow/ShopScroll/ShopItems"
	]) as HBoxContainer
	refresh_button = _find_node([
		"ContentLayer/MerchantZone/ShopRow/ActionsColumn/RefreshButton"
	]) as Button
	
	# 注释已修复
	var actions_col = _find_node(["ContentLayer/MerchantZone/ShopRow/ActionsColumn"])
	if actions_col:
		actions_col.visible = false
	var controls_layer = get_node_or_null("ControlsLayer")
	if controls_layer:
		var float_refresh = Button.new()
		float_refresh.text = "刷新商店"
		float_refresh.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		float_refresh.offset_left = -560.0
		float_refresh.offset_top = -385.0
		float_refresh.offset_right = -410.0
		float_refresh.offset_bottom = -350.0
		float_refresh.add_theme_font_size_override("font_size", 18)
		float_refresh.pressed.connect(_on_refresh)
		controls_layer.add_child(float_refresh)
		refresh_button = float_refresh
	merchant_portrait = _find_node([
		"ContentLayer/MerchantZone/MerchantPortraitBorder/ShopHeader/MerchantPortrait"
	]) as TextureRect
	shop_name_label = _find_node([
		"ContentLayer/MerchantZone/MerchantPortraitBorder/ShopHeader/ShopInfo/ShopNameLabel"
	]) as Label
	shop_desc_label = _find_node([
		"ContentLayer/MerchantZone/MerchantPortraitBorder/ShopHeader/ShopInfo/ShopDescLabel"
	]) as Label

	# Player Zone
	board_container = _find_node([
		"ContentLayer/PlayerZone/BoardArea/BoardContainer/BoardSlots"
	]) as HBoxContainer
	tool_container = _find_node([
		"ContentLayer/PlayerZone/BoardArea/ToolArea/ToolSlots"
	]) as HBoxContainer

	# Controls Layer
	ready_button = _find_node([
		"ControlsLayer/ReadyButton"
	]) as Button
	backpack_drawer = get_node_or_null("BackpackDrawer")
	video_overlay = get_node_or_null("VideoOverlay")
	var vbox_sidebar = _find_node(["LeftSidebar/VBox"]) as VBoxContainer
	if vbox_sidebar:
		var bp_btn = Button.new()
		bp_btn.text = "背包"
		bp_btn.add_theme_font_size_override("font_size", 14)
		var bp_style := StyleBoxFlat.new()
		bp_style.bg_color = Color(0.22, 0.16, 0.32, 0.88)
		bp_style.corner_radius_top_left = 6
		bp_style.corner_radius_top_right = 6
		bp_style.corner_radius_bottom_left = 6
		bp_style.corner_radius_bottom_right = 6
		bp_style.content_margin_top = 5
		bp_style.content_margin_bottom = 5
		bp_btn.add_theme_stylebox_override("normal", bp_style)
		bp_btn.pressed.connect(_on_backpack_button_pressed)
		vbox_sidebar.add_child(bp_btn)

func _ensure_effect_nodes() -> void:
	if get_node_or_null("AdjacencyVisualizer") == null:
		_adjacency_visualizer = AdjacencyVisualizerScript.new()
		_adjacency_visualizer.name = "AdjacencyVisualizer"
		_adjacency_visualizer.set_anchors_preset(Control.PRESET_FULL_RECT)
		_adjacency_visualizer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_adjacency_visualizer)
	else:
		_adjacency_visualizer = get_node("AdjacencyVisualizer")
		
	if get_node_or_null("DragManager") == null:
		_drag_manager = DragManagerScript.new()
		_drag_manager.name = "DragManager"
		add_child(_drag_manager)
	else:
		_drag_manager = get_node("DragManager")

func _setup_phase_banner() -> void:
	_phase_banner = PhaseBannerScene.instantiate()
	_phase_banner.name = "PhaseBannerInstance"
	add_child(_phase_banner)

func _setup_help_panel() -> void:
	_help_panel = HelpPanelScript.new()
	_help_panel.name = "HelpPanel"
	add_child(_help_panel)
	var help_btn = Button.new()
	help_btn.text = "?"
	help_btn.custom_minimum_size = Vector2(36, 36)
	help_btn.add_theme_font_size_override("font_size", 20)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.22, 0.35, 0.8)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	help_btn.add_theme_stylebox_override("normal", style)
	var hover_style = style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(0.35, 0.32, 0.45, 0.9)
	help_btn.add_theme_stylebox_override("hover", hover_style)
	help_btn.pressed.connect(func(): _help_panel.toggle())
	var status_bar = _find_node([
		"RootHBox/MainLayout/TopPanel/VBox/StatusBar",
		"MainLayout/TopPanel/VBox/StatusBar"
	])
	if status_bar:
		status_bar.add_child(help_btn)

func _setup_item_tooltip() -> void:
	_item_tooltip_layer = CanvasLayer.new()
	_item_tooltip_layer.layer = 120
	add_child(_item_tooltip_layer)
	_item_tooltip = ItemTooltipScene.instantiate()
	_item_tooltip_layer.add_child(_item_tooltip)
	SignalBus.item_hovered.connect(_on_item_hovered)
	SignalBus.item_unhovered.connect(_on_item_unhovered)

var _judge_drawer_open := false
var _judge_slide_panel: PanelContainer = null
var _judge_tab: Button = null

func _setup_judge_drawer() -> void:
	_judge_tab = get_node_or_null("JudgeDrawer/JudgeTab") as Button
	_judge_slide_panel = get_node_or_null("JudgeDrawer/JudgeSlidePanel") as PanelContainer
	
	if _judge_tab == null or _judge_slide_panel == null:
		return
	
	# Style the tab button (Neutral Dark + Gold Border)
	# Style the tab button (Match Refresh Button)
	var btn_tex = load("res://assets/ui/theme/button_normal.png")
	if btn_tex:
		var tab_style := StyleBoxTexture.new()
		tab_style.texture = btn_tex
		tab_style.texture_margin_left = 12
		tab_style.texture_margin_top = 12
		tab_style.texture_margin_right = 12
		tab_style.texture_margin_bottom = 12
		tab_style.modulate_color = Color(0.9, 0.9, 0.9) # Slightly dim
		_judge_tab.add_theme_stylebox_override("normal", tab_style)
		
		var hover = tab_style.duplicate()
		hover.modulate_color = Color(1.1, 1.1, 1.1)
		_judge_tab.add_theme_stylebox_override("hover", hover)
		_judge_tab.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05)) # Dark Text
	else:
		# Fallback
		var tab_style := StyleBoxFlat.new()
		tab_style.bg_color = Color(0.12, 0.12, 0.15, 0.95)
		_judge_tab.add_theme_stylebox_override("normal", tab_style)
		
		var tab_hover: StyleBoxFlat = tab_style.duplicate() as StyleBoxFlat
		tab_hover.bg_color = Color(0.18, 0.18, 0.22, 1.0)
		tab_hover.border_color = Color(0.8, 0.7, 0.4, 1.0)
		_judge_tab.add_theme_stylebox_override("hover", tab_hover)
		_judge_tab.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	
	# Style the slide panel with texture
	var panel_tex = load("res://assets/ui/theme/panel_bg.png")
	if panel_tex:
		var panel_style := StyleBoxTexture.new()
		panel_style.texture = panel_tex
		panel_style.texture_margin_left = 12
		panel_style.texture_margin_top = 12
		panel_style.texture_margin_right = 12
		panel_style.texture_margin_bottom = 12
		panel_style.content_margin_left = 16
		panel_style.content_margin_top = 16
		panel_style.content_margin_right = 16
		panel_style.content_margin_bottom = 16
		_judge_slide_panel.add_theme_stylebox_override("panel", panel_style)
	else:
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color(0.08, 0.08, 0.1, 0.98)
		panel_style.border_width_left = 2
		panel_style.border_width_top = 2
		panel_style.border_width_bottom = 2
		panel_style.border_color = Color(0.6, 0.5, 0.3, 0.7)
		panel_style.corner_radius_top_left = 10
		panel_style.corner_radius_bottom_left = 10
		_judge_slide_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Initially hidden off-screen to the right (Closed)
	# Closed: offset_left=0, offset_right=320 (relative to Right Anchor) -> [Width, Width+320]
	_judge_slide_panel.visible = true
	_judge_slide_panel.modulate.a = 0.0
	_judge_slide_panel.offset_left = 0
	_judge_slide_panel.offset_right = 320
	
	# Connect click only (hover was unreliable)
	_judge_tab.pressed.connect(_toggle_judge_drawer)

func _toggle_judge_drawer():
	if _judge_drawer_open:
		_close_judge_drawer()
	else:
		_open_judge_drawer()

func _open_judge_drawer():
	if _judge_slide_panel == null: return
	_judge_drawer_open = true
	var tween := create_tween()
	tween.set_parallel(true)
	# Slide IN: offset -320 to 0 relative to Right Anchor -> [Width-320, Width]
	tween.tween_property(_judge_slide_panel, "offset_left", -320.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_judge_slide_panel, "offset_right", 0.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_judge_slide_panel, "modulate:a", 1.0, 0.2)
	
	# Hide Tab text or dim it? Optional.

func _close_judge_drawer():
	if _judge_slide_panel == null: return
	_judge_drawer_open = false
	var tween := create_tween()
	tween.set_parallel(true)
	# Slide OUT: offset 0 to 320 relative to Right Anchor -> [Width, Width+320]
	tween.tween_property(_judge_slide_panel, "offset_left", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(_judge_slide_panel, "offset_right", 320.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(_judge_slide_panel, "modulate:a", 0.0, 0.15)

func _setup_board():
	if board_container == null:
		push_warning("GameBoard: board_container not found, skip board setup.")
		return
	var player := GameManager.get_player(0)
	var slot_count: int = player.board_size if player else GameConfig.BOARD_SLOTS
	for i in range(slot_count):
		var slot = BoardSlotScene.instantiate()
		board_container.add_child(slot)
		slot.setup(i)
		slot.scale = Vector2(0.8, 0.8)
		slot.item_dropped.connect(_on_item_dropped_on_slot)
		slot.slot_clicked.connect(_on_slot_clicked)
		_board_slots.append(slot)

func _setup_sell_zone() -> void:
	# Create sell zone overlay at top of screen (hidden by default)
	_sell_zone = ColorRect.new()
	_sell_zone.name = "SellZone"
	_sell_zone.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_sell_zone.offset_bottom = 80.0
	_sell_zone.color = Color(0.8, 0.1, 0.1, 0.0) # Invisible until drag
	_sell_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sell_zone.z_index = 50
	_sell_zone.add_to_group("sell_zone")
	add_child(_sell_zone)
	_sell_zone_label = Label.new()
	_sell_zone_label.text = "拖到此处出售（价格 = 基础价 / 2）"
	_sell_zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sell_zone_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_sell_zone_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_sell_zone_label.add_theme_font_size_override("font_size", 20)
	_sell_zone_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	_sell_zone.add_child(_sell_zone_label)
	
	# Connect to DragManager
	if _drag_manager:
		if _drag_manager.has_signal("drag_started"):
			_drag_manager.drag_started.connect(_on_drag_started)
		if _drag_manager.has_signal("drag_ended"):
			_drag_manager.drag_ended.connect(_on_drag_ended)

func _on_drag_started(_data: Dictionary) -> void:
	if _sell_zone:
		# Fade in sell zone
		var tween = create_tween()
		tween.tween_property(_sell_zone, "color", Color(0.8, 0.1, 0.1, 0.45), 0.2)

func _on_drag_ended(_success: bool) -> void:
	if _sell_zone:
		# Fade out sell zone
		var tween = create_tween()
		tween.tween_property(_sell_zone, "color", Color(0.8, 0.1, 0.1, 0.0), 0.15)

func _setup_signals():
	if ready_button:
		if not ready_button.pressed.is_connected(_on_ready):
			ready_button.pressed.connect(_on_ready)
	if refresh_button:
		if not refresh_button.pressed.is_connected(_on_refresh):
			refresh_button.pressed.connect(_on_refresh)
	
	if not SignalBus.phase_changed.is_connected(_on_phase_changed):
		SignalBus.phase_changed.connect(_on_phase_changed)
	
	# Lamdas are harder to check, but usually safe if _setup_signals runs once.
	# However, if it runs multiple times, we might accumulate connections.
	# For safety, we can disconnect or just not re-connect if we assume single run.
	# But given the error, let's keep it simple for now and trust SignalBus signals are global.
	
	# Check strictly for the refresh button error reported.
	if not SignalBus.item_purchased.is_connected(_refresh_all_wrapper):
		SignalBus.item_purchased.connect(_refresh_all_wrapper)
	if not SignalBus.item_sold.is_connected(_refresh_all_wrapper):
		SignalBus.item_sold.connect(_refresh_all_wrapper)
	if not SignalBus.item_placed.is_connected(_refresh_board_wrapper):
		SignalBus.item_placed.connect(_refresh_board_wrapper)
	if not SignalBus.item_removed.is_connected(_refresh_board_wrapper):
		SignalBus.item_removed.connect(_refresh_board_wrapper)
	
	if backpack_drawer:
		if backpack_drawer.has_signal("item_clicked") and not backpack_drawer.item_clicked.is_connected(_on_backpack_item_clicked_wrapper):
			backpack_drawer.item_clicked.connect(_on_backpack_item_clicked_wrapper)
		if backpack_drawer.has_signal("item_right_clicked") and not backpack_drawer.item_right_clicked.is_connected(_inspect_card):
			backpack_drawer.item_right_clicked.connect(_inspect_card)
		if backpack_drawer.has_signal("drawer_toggled") and not backpack_drawer.drawer_toggled.is_connected(_on_backpack_toggled):
			backpack_drawer.drawer_toggled.connect(_on_backpack_toggled)
		if backpack_drawer.has_signal("item_dropped_in") and not backpack_drawer.item_dropped_in.is_connected(_on_item_dropped_in_backpack):
			backpack_drawer.item_dropped_in.connect(_on_item_dropped_in_backpack)

	if merchant_tabs and merchant_tabs.get_child_count() == 0:
		for tab_name in ["ingredient", "technique", "tool"]:
			var btn = Button.new()
			btn.text = _get_merchant_display_name(tab_name)
			btn.custom_minimum_size = Vector2(0, 36)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.pressed.connect(_on_merchant_tab.bind(tab_name))
			merchant_tabs.add_child(btn)
			_merchant_buttons[tab_name] = btn
	_update_merchant_tab_styles()

func _on_backpack_button_pressed() -> void:
	if backpack_drawer == null:
		return
	if not backpack_drawer.visible:
		backpack_drawer.visible = true
		backpack_drawer.setup(GameManager.get_player(0))
	backpack_drawer.toggle()

func _apply_visuals() -> void:
	var bg_shader = load("res://ui/shaders/background_gradient.gdshader")
	if bg_shader:
		var mat = ShaderMaterial.new()
		mat.shader = bg_shader
		# background.material = mat # Disabled to show texture

	var btn_green = load("res://assets/ui/theme/button_normal.png")
	if btn_green and ready_button:
		ready_button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		
		var style = StyleBoxTexture.new()
		style.texture = btn_green
		style.texture_margin_left = 64
		style.texture_margin_top = 64
		style.texture_margin_right = 64
		style.texture_margin_bottom = 64
		style.content_margin_left = 20
		style.content_margin_top = 10
		style.content_margin_right = 20
		style.content_margin_bottom = 10
		style.modulate_color = Color(0.9, 0.95, 0.9)
		
		ready_button.add_theme_stylebox_override("normal", style)
		
		var hover = style.duplicate()
		hover.modulate_color = Color(1.1, 1.1, 1.1)
		ready_button.add_theme_stylebox_override("hover", hover)
		
		var pressed = style.duplicate()
		pressed.modulate_color = Color(0.7, 0.7, 0.7)
		ready_button.add_theme_stylebox_override("pressed", pressed)
		
		# 注释已修复
		ready_button.add_theme_color_override("font_color", Color(0.15, 0.1, 0.05))
		ready_button.add_theme_color_override("font_shadow_color", Color(1, 0.95, 0.85, 0.6))
		ready_button.add_theme_constant_override("shadow_offset_x", 1)
		ready_button.add_theme_constant_override("shadow_offset_y", 1)
	_apply_font_styling()

	var portrait_style = StyleBoxFlat.new()
	portrait_style.bg_color = Color(0.09, 0.08, 0.12, 0.72)
	portrait_style.border_width_left = 2
	portrait_style.border_width_top = 2
	portrait_style.border_width_right = 2
	portrait_style.border_width_bottom = 2
	portrait_style.border_color = Color(0.40, 0.36, 0.55, 0.70)
	portrait_style.corner_radius_top_left = 14
	portrait_style.corner_radius_top_right = 14
	portrait_style.corner_radius_bottom_right = 14
	portrait_style.corner_radius_bottom_left = 14
	portrait_style.content_margin_left = 6
	portrait_style.content_margin_top = 6
	portrait_style.content_margin_right = 6
	portrait_style.content_margin_bottom = 6
	# chef_portrait_frame.add_theme_stylebox_override("panel", portrait_style)
	if chef_portrait_frame:
		chef_portrait_frame.modulate = Color(1, 1, 1, 1.0)
		chef_portrait_frame.self_modulate = Color(1, 1, 1, 1)
	var dark_text = Color(0.2, 0.12, 0.08)
	var shadow_color = Color(1, 0.95, 0.85, 0.5)
	for label_node in [day_label, gold_label, prestige_label]:
		if label_node and label_node is Label:
			label_node.add_theme_color_override("font_color", dark_text)
			label_node.add_theme_color_override("font_shadow_color", shadow_color)
			label_node.add_theme_constant_override("shadow_offset_x", 1)
			label_node.add_theme_constant_override("shadow_offset_y", 1)
	
	# 注释已修复
	if refresh_button:
		var btn_tex = load("res://assets/ui/theme/button_normal.png")
		if btn_tex:
			var btn_style = StyleBoxTexture.new()
			btn_style.texture = btn_tex
			btn_style.texture_margin_left = 12
			btn_style.texture_margin_top = 12
			btn_style.texture_margin_right = 12
			btn_style.texture_margin_bottom = 12
			btn_style.content_margin_left = 12
			btn_style.content_margin_top = 6
			btn_style.content_margin_right = 12
			btn_style.content_margin_bottom = 6
			refresh_button.add_theme_stylebox_override("normal", btn_style)
			var hover_s = btn_style.duplicate()
			hover_s.modulate_color = Color(1.1, 1.1, 1.0)
			refresh_button.add_theme_stylebox_override("hover", hover_s)
		refresh_button.add_theme_color_override("font_color", dark_text)
		refresh_button.add_theme_color_override("font_shadow_color", shadow_color)
		refresh_button.add_theme_constant_override("shadow_offset_x", 1)
		refresh_button.add_theme_constant_override("shadow_offset_y", 1)
		refresh_button.add_theme_font_size_override("font_size", 16)

func _apply_font_styling() -> void:
	var dark_text = Color(0.2, 0.12, 0.08)
	var shadow_color = Color(1.0, 0.95, 0.85, 0.5)

	for label_node in [day_label, gold_label, prestige_label]:
		if label_node and label_node is Label:
			label_node.add_theme_color_override("font_color", dark_text)
			label_node.add_theme_color_override("font_shadow_color", shadow_color)
			label_node.add_theme_constant_override("shadow_offset_x", 1)
			label_node.add_theme_constant_override("shadow_offset_y", 1)

	for button_node in [ready_button, refresh_button]:
		if button_node and button_node is Button:
			button_node.add_theme_color_override("font_color", dark_text)
			button_node.add_theme_color_override("font_shadow_color", shadow_color)
			button_node.add_theme_constant_override("shadow_offset_x", 1)
			button_node.add_theme_constant_override("shadow_offset_y", 1)

	for tab_name in _merchant_buttons:
		var tab_button := _merchant_buttons[tab_name] as Button
		if tab_button:
			tab_button.add_theme_color_override("font_color", dark_text)
			tab_button.add_theme_color_override("font_shadow_color", shadow_color)
			tab_button.add_theme_constant_override("shadow_offset_x", 1)
			tab_button.add_theme_constant_override("shadow_offset_y", 1)

func _get_merchant_display_name(merchant: String) -> String:
	match merchant:
		"ingredient":
			return "食材"
		"dish":
			return "菜品"
		"technique":
			return "技法"
		"tool":
			return "厨具"
		"blackmarket":
			return "黑市"
	return merchant

func _refresh_all_wrapper(_p, _i):
	# 注释已修复
	_refresh_board()
	_refresh_tools()
	_refresh_techniques()
	_refresh_status()
	if backpack_drawer and backpack_drawer.has_method("refresh"):
		backpack_drawer.refresh()

func _refresh_board_wrapper(_p, _s, _i):
	_refresh_board()

func _on_backpack_item_clicked_wrapper(idx):
	_on_backpack_item_clicked(idx)

func _update_action_buttons() -> void:
	var match_state: MatchState = GameManager.get_match_state()
	var phase: int = match_state.current_phase if match_state else -1
	var player: PlayerState = GameManager.get_player(0)

	if ready_button:
		match phase:
			GameConfig.Phase.SHOP:
				ready_button.text = "进入下一行动"
			GameConfig.Phase.PVE_CHOICE:
				ready_button.text = "选择挑战后继续"
			GameConfig.Phase.PREP:
				ready_button.text = "开始对决"
			_:
				ready_button.text = "下一阶段"

	if refresh_button:
		var in_shop: bool = (phase == GameConfig.Phase.SHOP)
		refresh_button.visible = in_shop
		if not in_shop:
			return

		var is_free_refresh: bool = (
			player != null
			and player.chef_id == "reimu"
			and not player.free_refresh_used
		)
		var cost_text: String = "(免费)" if is_free_refresh else "(1G)"
		if GameConfig.BATTLE_SYSTEM_V2:
			if _current_merchant == "_temp_encounter":
				refresh_button.text = "刷新当前商店%s" % cost_text
			else:
				refresh_button.text = "重掷奇遇%s" % cost_text
		else:
			refresh_button.text = "刷新商店%s" % cost_text

func _refresh_all():
	_refresh_shop()
	_refresh_board()
	_refresh_tools()
	_refresh_techniques()
	_refresh_status()
	if backpack_drawer and backpack_drawer.has_method("refresh"):
		backpack_drawer.refresh()

func _refresh_shop():
	var portrait_border = _find_node(["ContentLayer/MerchantZone/MerchantPortraitBorder"])

	if GameConfig.BATTLE_SYSTEM_V2 and _current_merchant == "":
		_setup_selection_bubbles()
		if shop_container:
			shop_container.visible = false
		var shop_row = _find_node(["ContentLayer/MerchantZone/ShopRow"])
		if shop_row:
			shop_row.visible = false
		# 隐藏商店头像区（显示遭遇选择泡泡时不需要）
		if portrait_border:
			portrait_border.visible = false
		_update_action_buttons()
		return

	# 显示商店头像和商品区
	if portrait_border:
		portrait_border.visible = true
	var shop_row = _find_node(["ContentLayer/MerchantZone/ShopRow"])
	if shop_row:
		shop_row.visible = true
	if shop_container:
		shop_container.visible = true
	if shop_container == null:
		return

	# Clean up old items
	for child in shop_container.get_children():
		child.queue_free()

	# V1 Tabs Logic (Hide in V2 if using bubbles)
	if not GameConfig.BATTLE_SYSTEM_V2:
		if merchant_tabs == null:
			return
		for child in merchant_tabs.get_children():
			if child is Button and (
				str(child.text).contains("Black Market")
				or str(child.text).contains("blackmarket")
				or str(child.text).contains("黑市")
			):
				child.visible = ShopManager.is_blackmarket_available()
		_update_merchant_tab_styles()
		merchant_tabs.visible = true
	else:
		if merchant_tabs: merchant_tabs.visible = false

	_update_merchant_portrait()

	var shop_items = ShopManager.get_shop(_current_merchant)
	for i in range(shop_items.size()):
		# Wrap card + price in a VBox
		var wrapper = VBoxContainer.new()
		wrapper.alignment = BoxContainer.ALIGNMENT_CENTER
		wrapper.add_theme_constant_override("separation", 4)
		shop_container.add_child(wrapper)
		
		var card = ItemCardScene.instantiate()
		wrapper.add_child(card)
		card.setup(shop_items[i])
		# Shop items
		card.scale = Vector2(1.2, 1.2)
		card.set_meta("source_type", "shop")
		card.set_meta("source_index", i)
		card.card_clicked.connect(_on_shop_item_clicked.bind(i))
		card.card_right_clicked.connect(_inspect_card)
		
		# 注释已修复
		var price_val: int = int(shop_items[i].get("price", 0))
		var price_pill := PanelContainer.new()
		var pill_style := StyleBoxFlat.new()
		pill_style.bg_color = Color(0.06, 0.04, 0.10, 0.90)
		pill_style.corner_radius_top_left = 6
		pill_style.corner_radius_top_right = 6
		pill_style.corner_radius_bottom_left = 6
		pill_style.corner_radius_bottom_right = 6
		pill_style.content_margin_left = 10
		pill_style.content_margin_right = 10
		pill_style.content_margin_top = 3
		pill_style.content_margin_bottom = 3
		price_pill.add_theme_stylebox_override("panel", pill_style)
		price_pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var ext_price := Label.new()
		ext_price.text = "%d 金币" % price_val
		ext_price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ext_price.add_theme_font_size_override("font_size", 15)
		ext_price.add_theme_color_override("font_color", Color(1.0, 0.92, 0.35))
		ext_price.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
		ext_price.add_theme_constant_override("outline_size", 5)
		price_pill.add_child(ext_price)
		wrapper.add_child(price_pill)
		
		var anims = get_node_or_null("/root/UIAnimations")
		if anims and anims.has_method("flip_reveal"):
			anims.call("flip_reveal", card, 0.2, i * 0.05)
	_update_action_buttons()

var _selection_bubbles: Array = []

func _update_merchant_portrait():
	if merchant_portrait == null: return
	var tex_name = "reimu"
	var display_name := ""
	var display_desc := ""

	if _current_merchant == "_temp_encounter":
		tex_name = _current_encounter_icon
		display_name = str(_current_encounter.get("name", ""))
		display_desc = str(_current_encounter.get("desc", ""))
	else:
		match _current_merchant:
			"ingredient":
				tex_name = "marisa"
				display_name = "食材商店"
			"technique":
				tex_name = "patchouli"
				display_name = "技法秘籍"
			"tool":
				tex_name = "sakuya"
				display_name = "厨具工坊"
			"blackmarket":
				tex_name = "reisen"
				display_name = "黑市"

	var tex: Texture2D = null
	# 1. Try judge portrait (优先使用评委头像作为商人图标)
	var judge_path := "res://assets/ui/judges/%s.png" % tex_name
	if ResourceLoader.exists(judge_path):
		tex = load(judge_path)
	# 2. Try ChefDatabase/ArtDatabase
	if tex == null and ArtDatabase.has_chef_portrait(tex_name):
		tex = ArtDatabase.get_chef_portrait(tex_name)
	# 3. Try direct merchant asset
	if tex == null and ResourceLoader.exists("res://assets/merchants/%s.png" % tex_name):
		tex = load("res://assets/merchants/%s.png" % tex_name)

	merchant_portrait.texture = tex

	# Update shop header labels
	if shop_name_label:
		shop_name_label.text = display_name
	if shop_desc_label:
		shop_desc_label.text = display_desc

func _setup_selection_bubbles():
	var container = _find_node(["ContentLayer/MerchantZone/SelectionBubbleContainer"])
	if container == null:
		push_error("SelectionBubbleContainer not found")
		return

	for child in container.get_children():
		child.queue_free()
	_selection_bubbles.clear()

	var shop_row = _find_node(["ContentLayer/MerchantZone/ShopRow"])
	if shop_row:
		shop_row.visible = false

	var player = GameManager.get_player(0)
	var match_state = GameManager.get_match_state()
	var day = match_state.current_day if match_state else 1
	var choices = EncounterPool.generate_three_choices(player, day)
	if choices.is_empty() or BubbleItemScene == null:
		_setup_selection_bubbles_fallback()
		return

	var v_drops := [0, 90, 0]
	for i in range(choices.size()):
		var encounter: Dictionary = choices[i]
		var bubble = BubbleItemScene.instantiate()
		if bubble == null:
			continue

		var bubble_data: Dictionary = {
			"name": encounter.get("name", "???"),
			"name_cn": encounter.get("name", "???"),
			"icon": encounter.get("icon", "unknown"),
			"description": encounter.get("desc", "")
		}
		bubble.setup(bubble_data, "event")
		bubble.custom_minimum_size = Vector2(380, 380)
		bubble.bubble_clicked.connect(_on_encounter_bubble_clicked.bind(encounter))

		var wrapper := MarginContainer.new()
		wrapper.add_theme_constant_override("margin_top", v_drops[i % v_drops.size()])
		wrapper.add_child(bubble)
		container.add_child(wrapper)
		_selection_bubbles.append(bubble)

		bubble.modulate.a = 0.0
		bubble.scale = Vector2(0.8, 0.8)
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(bubble, "modulate:a", 1.0, 0.4).set_delay(i * 0.15)
		tween.parallel().tween_property(bubble, "scale", Vector2(1.0, 1.0), 0.4).set_delay(i * 0.15)

func _on_encounter_bubble_clicked(encounter: Dictionary):
	_current_encounter = encounter.duplicate(true)
	_current_encounter_icon = encounter.get("icon", "reimu")
	var encounter_type = str(encounter.get("type", ""))

	if encounter_type == "shop":
		var filter = encounter.get("filter", {})
		var slots = int(encounter.get("slots", 5))
		var price_mult = float(encounter.get("price_mult", 1.0))
		var tier_offset = int(encounter.get("tier_max_offset", 0))
		var match_state = GameManager.get_match_state()
		var day = match_state.current_day if match_state else 1
		var shop_items = ShopManager.generate_filtered_shop(filter, slots, day, price_mult, tier_offset)
		ShopManager.set_temp_shop(shop_items)
		_current_merchant = "_temp_encounter"
		_refresh_shop()

		var shop_row = _find_node(["ContentLayer/MerchantZone/ShopRow"])
		if shop_row:
			shop_row.visible = true

		var container = _find_node(["ContentLayer/MerchantZone/SelectionBubbleContainer"])
		if container:
			container.visible = false
		return

	var state_now := GameManager.get_match_state()
	if state_now and _event_resolved_action == int(state_now.current_action):
		FloatingTextScript.spawn(
			self,
			"本行动奇遇已结算，点击右下角进入下一行动",
			get_viewport_rect().size * 0.5,
			Color(1.0, 0.78, 0.36),
			1.5,
			44.0,
			18
		)
		return
	if state_now:
		_event_resolved_action = int(state_now.current_action)
	var container_event := _find_node(["ContentLayer/MerchantZone/SelectionBubbleContainer"])
	if container_event:
		container_event.visible = false

	var event_data = _trigger_event(str(encounter.get("event_id", "")), encounter)
	_show_event_overlay(event_data)

func _trigger_event(event_id: String, encounter: Dictionary) -> Dictionary:
	var event_data: Dictionary = encounter.get("event", {})
	if event_data.is_empty():
		event_data = {
			"name": encounter.get("name", "事件"),
			"description": encounter.get("desc", ""),
			"result": {"text": encounter.get("desc", "")}
		}
	event_data["result"] = _resolve_bubble_event(event_id, encounter)
	return event_data

func _resolve_bubble_event(event_id: String, encounter: Dictionary) -> Dictionary:
	var player: PlayerState = GameManager.get_player(0)
	if player == null:
		return {"text": "事件结算失败：找不到玩家数据。"}

	var options: Array = BUBBLE_EVENT_EFFECTS.get(event_id, [])
	if options.is_empty():
		return {"text": str(encounter.get("desc", "奇遇发生了，但没有获得额外效果。"))}

	var rolled: Dictionary = options[randi() % options.size()]
	var base_text: String = str(rolled.get("summary", "奇遇触发。"))
	var effect_id: String = str(rolled.get("effect_id", ""))
	var pseudo_encounter := {
		"choices": [
			{
				"label": "事件",
				"text": str(encounter.get("name", "奇遇")),
				"effect_id": effect_id,
				"result_text": base_text,
			}
		]
	}
	var result: Dictionary = EncounterManager.resolve_encounter(player, pseudo_encounter, 0)
	var reward_names: Array[String] = _grant_encounter_rewards(player, result.get("rewards", []))
	result["text"] = _build_bubble_event_result_text(base_text, result, reward_names)
	return result

func _grant_encounter_rewards(player: PlayerState, rewards: Array) -> Array[String]:
	var names: Array[String] = []
	for reward_var in rewards:
		if not (reward_var is Dictionary):
			continue
		var reward: Dictionary = reward_var
		var item_name: String = str(reward.get("name_cn", reward.get("name", reward.get("id", "奖励物品"))))
		var placed := BoardManager.auto_place_item(player, reward)
		if placed < 0:
			player.add_to_backpack(reward)
		names.append(item_name)
	return names

func _build_bubble_event_result_text(base_text: String, result: Dictionary, reward_names: Array[String]) -> String:
	var lines: Array[String] = []
	if base_text.strip_edges() != "":
		lines.append(base_text)

	var gold_gained: int = int(result.get("gold_gained", 0))
	if gold_gained > 0:
		lines.append("+%d 金币" % gold_gained)
	var gold_lost: int = int(result.get("gold_lost", 0))
	if gold_lost > 0:
		lines.append("-%d 金币" % gold_lost)

	var prestige_gained: int = int(result.get("prestige_gained", 0))
	if prestige_gained > 0:
		lines.append("声望 +%d" % prestige_gained)
	var prestige_lost: int = int(result.get("prestige_lost", 0))
	if prestige_lost > 0:
		lines.append("声望 -%d" % prestige_lost)

	if str(result.get("buff", "")) != "":
		lines.append("获得强化：%s" % str(result.get("buff", "")))
	if result.get("shop_discount", false):
		lines.append("获得效果：下次商店刷新半价")
	if result.get("synergy_bonus", false):
		lines.append("获得效果：羁绊加成 +20%")
	if str(result.get("keyword_gained", "")) != "":
		lines.append("获得关键词：%s" % str(result.get("keyword_gained", "")))
	if str(result.get("added_tag", "")) != "":
		lines.append("随机菜品获得标签：%s" % str(result.get("added_tag", "")))
	if str(result.get("upgraded_dish", "")) != "":
		lines.append("升级菜品：%s" % str(result.get("upgraded_dish", "")))
	if str(result.get("mutated_dish", "")) != "":
		lines.append("改造菜品：%s" % str(result.get("mutated_dish", "")))
	if not reward_names.is_empty():
		lines.append("获得物品：%s" % ", ".join(reward_names))

	if lines.is_empty():
		lines.append("奇遇完成。")
	return "\n".join(lines)

func _show_event_overlay(event: Dictionary) -> void:
	var result_var: Variant = event.get("result", {"text": event.get("description", "")})
	if result_var is Dictionary:
		_show_event_result_overlay(event, result_var)
	else:
		_show_event_result_overlay(event, {"text": str(result_var)})

func _show_event_result_overlay(event: Dictionary, result: Dictionary) -> void:
	var layer := CanvasLayer.new()
	layer.name = "EventResultLayer"
	layer.layer = 91
	add_child(layer)

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.02, 0.1, 0.88)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_CENTER)
	root.custom_minimum_size = Vector2(600, 350)
	root.position = Vector2(-300, -175)
	root.add_theme_constant_override("separation", 16)
	layer.add_child(root)

	var title := Label.new()
	title.text = "%s - 结果" % str(event.get("name", "事件"))
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.4))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	var result_lbl := Label.new()
	result_lbl.text = str(result.get("text", event.get("description", "")))
	result_lbl.add_theme_font_size_override("font_size", 16)
	result_lbl.add_theme_color_override("font_color", Color(0.92, 0.9, 0.98))
	result_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(result_lbl)

	var confirm := Button.new()
	confirm.text = "确认"
	confirm.custom_minimum_size = Vector2(160, 44)
	confirm.add_theme_font_size_override("font_size", 18)
	confirm.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	confirm.pressed.connect(_on_event_result_confirmed.bind(layer))
	root.add_child(confirm)

	root.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(root, "modulate:a", 1.0, 0.2)

func _on_event_result_confirmed(layer: Node) -> void:
	layer.queue_free()
	var match_state := GameManager.get_match_state()
	if match_state and _event_resolved_action == int(match_state.current_action):
		GameManager.advance_phase()
	else:
		_refresh_all()

func _on_merchant_bubble_clicked(merchant_type: String):
	"""Legacy merchant bubble click handler."""
	print("Merchant bubble clicked (legacy): ", merchant_type)
	_current_merchant = merchant_type
	_refresh_shop()

	# Show shop row
	var shop_row = _find_node(["ContentLayer/MerchantZone/ShopRow"])
	if shop_row: shop_row.visible = true

	# Hide selection bubbles
	var container = _find_node(["ContentLayer/MerchantZone/SelectionBubbleContainer"])
	if container: container.visible = false

func _setup_selection_bubbles_fallback():
	"""Fallback to button-based selection if BubbleItem not available."""
	var container = _find_node(["ContentLayer/MerchantZone/SelectionBubbleContainer"])
	if container == null: return

	var choices = [
		{"type": "dish", "name": "夜雀食堂\n(便宜 / 快速)", "icon": "mystia"},
		{"type": "ingredient", "name": "魔法森林\n(高风险)", "icon": "marisa"},
		{"type": "tool", "name": "红魔工坊\n(稳定收益)", "icon": "sakuya"}
	]

	for i in range(choices.size()):
		var data = choices[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(200, 140)
		btn.text = str(data.get("name", "查看"))
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.pressed.connect(_on_merchant_bubble_clicked.bind(data.type))
		container.add_child(btn)
		_selection_bubbles.append(btn)

func _on_bubble_selected(data: Dictionary):
	var container = _find_node(["ContentLayer/MerchantZone/SelectionBubbleContainer"])
	if container:
		# Hide bubbles
		for child in container.get_children():
			child.visible = false
			
	var shop_row = _find_node(["ContentLayer/MerchantZone/ShopRow"])
	if shop_row: shop_row.visible = true
	
	var portrait_border = _find_node(["ContentLayer/MerchantZone/MerchantPortraitBorder"])
	if portrait_border: portrait_border.visible = true
	
	_current_merchant = data.type
	_refresh_shop()
	_update_merchant_portrait()


func _update_merchant_tab_styles() -> void:
	var btn_tex = load("res://assets/ui/theme/button_normal.png")
	var colors_node = get_node_or_null("/root/UIColors")
	
	for tab_name in _merchant_buttons:
		var btn: Button = _merchant_buttons[tab_name]
		if btn == null: continue
		btn.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		
		var is_selected = (tab_name == _current_merchant)
		var base_color = Color(0.4, 0.4, 0.45)
		if colors_node and colors_node.has_method("get_merchant_color"):
			var c = colors_node.call("get_merchant_color", tab_name)
			if is_selected: base_color = c
			else: base_color = c.darkened(0.5)
		
		if btn_tex:
			var style = StyleBoxTexture.new()
			style.texture = btn_tex
			style.texture_margin_left = 64
			style.texture_margin_top = 32
			style.texture_margin_right = 64
			style.texture_margin_bottom = 32
			style.content_margin_left = 16
			
			if is_selected:
				style.modulate_color = base_color.lightened(0.2)
			else:
				style.modulate_color = base_color.darkened(0.2)
			
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_stylebox_override("hover", style)
			btn.add_theme_stylebox_override("pressed", style)
		else:
			# Fallback
			var style = StyleBoxFlat.new()
			style.bg_color = base_color
			btn.add_theme_stylebox_override("normal", style)
		
		if is_selected:
			btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			btn.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

func _refresh_board():
	var player = GameManager.get_player(0)
	if player == null: return
	if _board_slots.is_empty():
		return

	var limit_count: int = player.board_size
	
	# First pass: determine which slots are consumed by multi-size dishes
	var consumed_slots: Dictionary = {}# slot_index -> true (slot is consumed by a previous multi-size dish)
	for i in range(mini(limit_count, player.board.size())):
		var item = player.board[i]
		if item != null and not item.has("_ref_to"):
			var dish_size: int = int(item.get("size", 1))
			# Mark subsequent slots as consumed
			for j in range(1, dish_size):
				if (i + j) < limit_count:
					consumed_slots[i + j] = true
	
	# Second pass: render slots
	for i in range(_board_slots.size()):
		var slot = _board_slots[i]
		# Hide the background of the slot (Visual Request: "Cancel grid display")
		slot.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		
		if i >= limit_count:
			slot.visible = false
			slot.set_item_card(null)
			continue
		
		# If this slot is consumed by a multi-size dish in the previous slot, hide it
		if consumed_slots.has(i):
			slot.visible = false
			slot.set_item_card(null)
			continue
		
		slot.visible = true
		var item = player.board[i]
		if item == null:
			slot.set_occupied(false)
			slot.set_item_card(null)
		elif item.has("_ref_to"):
			slot.set_occupied(true, true)
			slot.set_item_card(null)
		else:
			slot.set_occupied(true)
			var card = ItemCardScene.instantiate()
			slot.set_item_card(card)
			card.setup(item)
			card.set_meta("source_type", "board")
			card.set_meta("source_index", i)
			card.card_clicked.connect(_on_board_item_clicked.bind(i))
			card.card_right_clicked.connect(_inspect_card)
			
			# Note: ItemCard._update_display() already handles sizing based on dish size

			if GameConfig.BATTLE_SYSTEM_V2 and "serve_queue" in player:
				var queue_pos: int = player.serve_queue.find(i)
				if queue_pos >= 0:
					_set_slot_queue_number(slot, queue_pos + 1)

	_update_adjacency_visual(_selected_board_slot)

func _refresh_tools():
	if tool_container == null:
		return
	for child in tool_container.get_children():
		child.queue_free()
	var player = GameManager.get_player(0)
	if player == null: return
	
	for i in range(player.tools.size()):
		var card = ItemCardScene.instantiate()
		tool_container.add_child(card)
		card.setup(player.tools[i])
		card.set_meta("draggable", false)
		card.scale = Vector2(0.8, 0.8) # Small tool cards
		card.card_clicked.connect(_on_tool_clicked.bind(i))
		card.card_right_clicked.connect(_inspect_card)

func _on_tool_clicked(item_data: Dictionary, tool_index: int):
	var player = GameManager.get_player(0)
	if player == null: return
	if tool_index >= 0 and tool_index < player.tools.size():
		var tool = player.tools[tool_index]
		if player.add_to_backpack(tool):
			player.tools.remove_at(tool_index)
			_refresh_all()
		else:
			FloatingTextScript.spawn(self, "背包已满！", get_global_mouse_position(), Color(1, 0.4, 0.4))

func _refresh_techniques():
	var player = GameManager.get_player(0)
	if player == null:
		return
	# Create technique display if not exists
	var tech_container: HBoxContainer = find_child("TechniqueBar", true, false) as HBoxContainer
	if tech_container == null:
		tech_container = HBoxContainer.new()
		tech_container.name = "TechniqueBar"
		tech_container.add_theme_constant_override("separation", 4)
		# Position it near the tool container area
		var board_area = _find_node([
			"RootHBox/MainLayout/BoardArea/Center",
			"MainLayout/BoardArea/Center"
		])
		if board_area:
			var wrapper = VBoxContainer.new()
			wrapper.name = "TechniqueWrapper"
			var label = Label.new()
			label.text = "技法槽"
			label.add_theme_font_size_override("font_size", 12)
			label.add_theme_color_override("font_color", Color(0.7, 0.6, 1.0))
			wrapper.add_child(label)
			wrapper.add_child(tech_container)
			board_area.add_child(wrapper)

	for child in tech_container.get_children():
		child.queue_free()

	for i in range(player.techniques.size()):
		var card = ItemCardScene.instantiate()
		tech_container.add_child(card)
		card.setup(player.techniques[i])
		card.set_meta("draggable", false)
		card.scale = Vector2(0.6, 0.6)
		card.card_right_clicked.connect(_inspect_card)

	# Empty slot placeholders
	for i in range(player.techniques.size(), GameConfig.MAX_TECHNIQUES):
		var placeholder = ColorRect.new()
		placeholder.custom_minimum_size = Vector2(96, 144) * 0.6
		placeholder.color = Color(0.15, 0.12, 0.2, 0.5)
		tech_container.add_child(placeholder)

func _refresh_status():
	var player = GameManager.get_player(0)
	if player == null:
		return
	var match_state = GameManager.get_match_state()
	
	if match_state:
		if day_label:
			day_label.text = "第 %d 天" % int(match_state.current_day)
		if judge_panel:
			judge_panel.update_judges(match_state.judges)
			# Auto-shrink height to fit content
			if _judge_slide_panel:
				_judge_slide_panel.reset_size()

	if prestige_label:
		prestige_label.text = "声望: %d" % player.prestige
	if gold_label:
		gold_label.text = "金币: %d" % player.gold

	# Level & XP display
	if _level_label:
		_level_label.text = "等级 %d" % player.level
	if _xp_bar:
		_xp_bar.max_value = GameConfig.XP_PER_LEVEL
		_xp_bar.value = player.xp
	var xp_text: Label = get_node_or_null("LeftSidebar/VBox/XpTextLabel") as Label
	if xp_text:
		xp_text.text = "%d / %d 经验" % [player.xp, GameConfig.XP_PER_LEVEL]
	var bp_label: Label = get_node_or_null("LeftSidebar/VBox/BackpackSizeLabel") as Label
	if bp_label:
		# 注释已修复
		var used_slots := 0
		for bp_item in player.backpack:
			used_slots += int(bp_item.get("size", 1))
		bp_label.text = "背包: %d/%d" % [used_slots, player.max_backpack]
	
	var chef = ChefDatabase.get_chef(player.chef_id)
	if chef_label:
		chef_label.text = _display_chef_name(player.chef_id, chef.get("name", "") if not chef.is_empty() else "")
	if chef_portrait and chef_portrait_frame:
		var tex = ArtDatabase.get_chef_portrait(player.chef_id)
		if tex:
			chef_portrait.texture = tex
			chef_portrait_frame.visible = true
			chef_portrait.visible = true
			# print("GameBoard: Set chef portrait for ", player.chef_id)
		else:
			print("GameBoard: No portrait found for ", player.chef_id)
			chef_portrait_frame.visible = false

	if _status_initialized:
		if player.gold != _last_gold and gold_label:
			var diff = player.gold - _last_gold
			_show_floating_text(gold_label, "%+d" % diff, Color(1, 0.9, 0.2) if diff > 0 else Color(1, 0.4, 0.4))
	else:
		_status_initialized = true
	
	_last_gold = player.gold
	_last_prestige = player.prestige
	_update_action_buttons()

func _on_shop_item_clicked(_item_data: Dictionary, shop_index: int):
	var player = GameManager.get_player(0)
	var bought = ShopManager.buy_item(player, _current_merchant, shop_index)
	if bought.is_empty():
		_shake_shop()
		return

	_handle_bought_item(player, bought)
	_refresh_all()

func _handle_bought_item(player: PlayerState, bought: Dictionary):
	var itype = bought.get("item_type", "")

	if itype == "dish":
		var bought_id = bought.get("id", "")
		var bought_star = int(bought.get("star_level", 1))

		# 已经3星的不能再升了
		if bought_star < 3:
			var upgraded := false

			for i in range(player.board.size()):
				var board_item = player.board[i]
				if board_item != null and not board_item.has("_ref_to"):
					if board_item.get("id", "") == bought_id and int(board_item.get("star_level", 1)) == bought_star:
						player.board[i] = null
						bought["star_level"] = bought_star + 1
						upgraded = true
						break

			if not upgraded:
				for i in range(player.backpack.size()):
					var bp_item = player.backpack[i]
					if bp_item.get("id", "") == bought_id and int(bp_item.get("star_level", 1)) == bought_star:
						player.backpack.remove_at(i)
						bought["star_level"] = bought_star + 1
						upgraded = true
						break

			if upgraded:
				var new_star = int(bought.get("star_level", 1))
				# 应用属性倍率
				var mult: float = GameConfig.STAR2_MULTIPLIER if new_star == 2 else GameConfig.STAR3_MULTIPLIER
				var base_flavor = float(bought.get("flavor", 0))
				bought["flavor"] = int(base_flavor * mult)
				if bought.has("base_stats"):
					var stats = bought["base_stats"]
					for attr in stats:
						stats[attr] = float(stats[attr]) * mult
				# 浮动文字反馈
				var star_text = GameConfig.STAR_NAMES.get(new_star, "★★")
				var star_color = GameConfig.STAR_COLORS.get(new_star, Color(1.0, 0.84, 0.0))
				var dish_name = str(bought.get("name", bought_id))
				FloatingTextScript.spawn(self, "%s 升至 %s" % [dish_name, star_text], get_viewport_rect().size * 0.5, star_color, 1.5, 60.0, 28)
				print("Star upgrade: ", bought_id, " -> ", new_star, " stars")

	if itype == "tool":
		if player.tools.size() < player.max_tools:
			player.tools.append(bought)
		else:
			player.add_gold(bought.get("price", 0))
	elif itype == "technique" or itype == "ingredient":
		if not player.add_to_backpack(bought):
			player.add_gold(bought.get("price", 0))
	else:
		var placed = BoardManager.auto_place_item(player, bought)
		if placed < 0:
			if not player.add_to_backpack(bought):
				player.add_gold(bought.get("price", 0))

func _handle_bought_item_to_board(player: PlayerState, bought: Dictionary, drop_slot: int) -> void:
	var itype = str(bought.get("item_type", ""))

	# 升星逻辑（与 _handle_bought_item 完全一致）
	if itype == "dish":
		var bought_id = bought.get("id", "")
		var bought_star = int(bought.get("star_level", 1))
		if bought_star < 3:
			var upgraded := false
			for i in range(player.board.size()):
				var board_item = player.board[i]
				if board_item != null and not board_item.has("_ref_to"):
					if board_item.get("id", "") == bought_id and int(board_item.get("star_level", 1)) == bought_star:
						player.board[i] = null
						bought["star_level"] = bought_star + 1
						upgraded = true
						break
			if not upgraded:
				for i in range(player.backpack.size()):
					var bp_item = player.backpack[i]
					if bp_item.get("id", "") == bought_id and int(bp_item.get("star_level", 1)) == bought_star:
						player.backpack.remove_at(i)
						bought["star_level"] = bought_star + 1
						upgraded = true
						break
			if upgraded:
				var new_star = int(bought.get("star_level", 1))
				var mult: float = GameConfig.STAR2_MULTIPLIER if new_star == 2 else GameConfig.STAR3_MULTIPLIER
				var base_flavor = float(bought.get("flavor", 0))
				bought["flavor"] = int(base_flavor * mult)
				if bought.has("base_stats"):
					var stats = bought["base_stats"]
					for attr in stats:
						stats[attr] = float(stats[attr]) * mult
				var star_text = GameConfig.STAR_NAMES.get(new_star, "★★")
				var star_color = GameConfig.STAR_COLORS.get(new_star, Color(1.0, 0.84, 0.0))
				var dish_name = str(bought.get("name", bought_id))
				FloatingTextScript.spawn(self, "%s 升至 %s" % [dish_name, star_text], get_viewport_rect().size * 0.5, star_color, 1.5, 60.0, 28)

	# 放置逻辑
	if itype == "tool":
		if player.tools.size() < player.max_tools:
			player.tools.append(bought)
		else:
			player.add_gold(int(bought.get("price", 0)))
	elif itype == "technique" or itype == "ingredient":
		if not player.add_to_backpack(bought):
			player.add_gold(int(bought.get("price", 0)))
	else:
		if not _try_place_item_on_board_with_candidates(player, bought, drop_slot):
			if not player.add_to_backpack(bought):
				player.add_gold(int(bought.get("price", 0)))

func _play_buy_fx(shop_index: int, bought: Dictionary):
	if shop_container == null:
		return
	if shop_index >= 0 and shop_index < shop_container.get_child_count():
		var card = shop_container.get_child(shop_index)
		var anims = get_node_or_null("/root/UIAnimations")
		var target_pos = global_position + size / 2
		if board_container:
			target_pos = board_container.global_position + board_container.size / 2
		if anims:
			anims.call("fly_arc", self, card.global_position + card.size / 2, target_pos, bought.get("name", ""), 0.4)
		
		card.modulate = Color(0.5, 0.5, 0.5, 0.5)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _shake_shop():
	var anims = get_node_or_null("/root/UIAnimations")
	if anims and shop_container:
		anims.call("shake", shop_container, 8.0, 0.3)

func _on_board_item_clicked(_item_data: Dictionary, slot_idx: int):
	if _ingredient_mode:
		_apply_ingredient_to_slot(slot_idx)
		return

	_selected_board_slot = slot_idx
	for i in range(_board_slots.size()):
		_board_slots[i].clear_highlight()

	if slot_idx >= 0 and slot_idx < _board_slots.size():
		_board_slots[slot_idx].highlight(Color(1, 0.9, 0.6, 0.4))
		_update_adjacency_visual(slot_idx)

	pass

func _on_backpack_item_clicked(bp_index: int):
	var player = GameManager.get_player(0)
	if player == null:
		return
	if bp_index < 0 or bp_index >= player.backpack.size():
		return
	var item = player.backpack[bp_index]
	var item_type: String = str(item.get("item_type", item.get("type", "")))

	if item_type == "technique":
		if TechniqueManager.equip_technique(player, item):
			player.remove_from_backpack(bp_index)
			_refresh_all()
		return

	if item_type == "ingredient":
		_enter_ingredient_mode(bp_index)
		return

	if item_type == "tool":
		if player.tools.size() < player.max_tools:
			player.tools.append(item)
			player.remove_from_backpack(bp_index)
			_refresh_all()
		else:
			FloatingTextScript.spawn(self, "厨具槽已满！", get_global_mouse_position(), Color(1, 0.4, 0.4))
		return

	var removed = player.remove_from_backpack(bp_index)
	if removed:
		var placed = BoardManager.auto_place_item(player, removed)
		if placed < 0:
			player.add_to_backpack(removed) # Return if board full
		_refresh_all()

func _enter_ingredient_mode(bp_index: int):
	if _ingredient_mode:
		_exit_ingredient_mode()
	_pending_ingredient_idx = bp_index
	_ingredient_mode = true

	var player = GameManager.get_player(0)
	if player == null:
		return

	var slot_count: int = mini(GameConfig.BOARD_SLOTS, _board_slots.size())
	for i in range(slot_count):
		var dish = player.get_item_at(i)
		if dish != null and not dish.has("_ref_to") and dish.get("item_type", "") != "tool":
			_board_slots[i].highlight(Color(0.3, 1.0, 0.5, 0.35))

	if board_container:
		FloatingTextScript.spawn(
			self,
			"选择一个菜品来使用食材",
			board_container.global_position + Vector2(board_container.size.x / 2, -20),
			Color(0.3, 1.0, 0.5),
			1.5,
			40.0,
			18
		)

func _exit_ingredient_mode():
	_pending_ingredient_idx = -1
	_ingredient_mode = false
	for slot in _board_slots:
		slot.clear_highlight()

func _apply_ingredient_to_slot(slot_idx: int):
	var player = GameManager.get_player(0)
	if player and slot_idx >= 0 and slot_idx < _board_slots.size() and IngredientManager.apply_from_backpack(player, _pending_ingredient_idx, slot_idx):
		var slot = _board_slots[slot_idx]

		if video_overlay:
			var success_cg = load("res://assets/cg/cooking_success.png")
			if success_cg:
				video_overlay.play_image(success_cg, 0.8)

		FloatingTextScript.spawn(
			self,
			"已添加调味",
			slot.global_position + slot.size / 2,
			Color(0.3, 1.0, 0.5)
		)

	_exit_ingredient_mode()
	_refresh_all()

func _on_item_dropped_on_slot(slot_idx: int, drag_data: Dictionary):
	var player: PlayerState = GameManager.get_player(0) as PlayerState
	if player == null:
		return

	var src_type: String = str(drag_data.get("source_type", ""))
	var src_idx: int = int(drag_data.get("source_index", -1))
	var drop_slot: int = int(slot_idx)

	if src_type == "board":
		if src_idx < 0 or src_idx >= player.board_size:
			return
		var from_slot := _resolve_item_start_slot(player, src_idx)
		_try_handle_board_to_board_drop(player, from_slot, drop_slot)
	elif src_type == "backpack":
		if src_idx < 0 or src_idx >= player.backpack.size():
			return
		var bp_item = player.backpack[src_idx]
		var bp_type: String = str(bp_item.get("item_type", bp_item.get("type", "")))
		if bp_type == "ingredient":
			var applied := IngredientManager.apply_from_backpack(player, src_idx, drop_slot)
			if applied:
				var slot = _board_slots[drop_slot]
				if video_overlay:
					var success_cg = load("res://assets/cg/cooking_success.png")
					if success_cg:
						video_overlay.play_image(success_cg, 0.8)
				FloatingTextScript.spawn(
					self,
					"已添加调味",
					slot.global_position + slot.size / 2,
					Color(0.3, 1.0, 0.5)
				)
			else:
				FloatingTextScript.spawn(
					self,
					"该食材无法用于这个目标",
					get_global_mouse_position(),
					Color(1.0, 0.45, 0.45)
				)
			_refresh_all()
			return
		var item = player.remove_from_backpack(src_idx)
		if item:
			if not _try_place_item_on_board_with_candidates(player, item, drop_slot):
				# 目标格被占用 → 尝试交换：把棋盘物品移到背包，再放入新物品
				var resolved_slot := _resolve_item_start_slot(player, drop_slot)
				var board_item = player.get_item_at(resolved_slot)
				if board_item != null and not board_item.has("_ref_to"):
					var removed_board = player.remove_item(resolved_slot)
					if removed_board:
						if BoardManager.place_item_on_board(player, item, resolved_slot):
							player.add_to_backpack(removed_board)
						else:
							# 放不下 → 还原
							player.place_item(resolved_slot, removed_board)
							player.add_to_backpack(item)
				else:
					player.add_to_backpack(item)
	elif src_type == "shop":
		var bought = ShopManager.buy_item(player, _current_merchant, src_idx)
		if not bought.is_empty():
			# 先执行升星逻辑（合并重复菜品、应用倍率、浮动文字）
			_handle_bought_item_to_board(player, bought, drop_slot)
	
	_refresh_all()

func _on_item_dropped_in_backpack(bp_slot_idx: int, drag_data: Dictionary) -> void:
	var player = GameManager.get_player(0)
	if player == null:
		return

	var src_type: String = str(drag_data.get("source_type", ""))
	var src_idx: int = int(drag_data.get("source_index", -1))
	var insert_pos: int = clampi(bp_slot_idx, 0, player.backpack.size())

	if src_type == "board":
		if src_idx < 0 or src_idx >= player.board.size():
			return
		var from_slot := _resolve_item_start_slot(player, src_idx)
		var item = player.remove_item(from_slot)
		if item == null:
			return
		if _insert_item_to_backpack_at(player, item, insert_pos):
			SignalBus.item_removed.emit(player.player_idx, from_slot, item)
		else:
			# Backpack is full: put it back to avoid item loss.
			player.place_item(from_slot, item)
	elif src_type == "shop":
		var bought = ShopManager.buy_item(player, _current_merchant, src_idx)
		if bought.is_empty():
			_shake_shop()
			return
		_handle_bought_item_to_backpack(player, bought, insert_pos)
		_play_buy_fx(src_idx, bought)
	else:
		return

	_refresh_all()

func _handle_bought_item_to_backpack(player: PlayerState, bought: Dictionary, insert_pos: int) -> void:
	var itype: String = str(bought.get("item_type", ""))

	# Keep dish star-up behavior consistent with normal click-to-buy flow.
	if itype == "dish":
		var bought_id = str(bought.get("id", ""))
		var bought_star = int(bought.get("star_level", 1))
		if bought_star < 3:
			var upgraded := false
			for i in range(player.board.size()):
				var board_item = player.board[i]
				if board_item != null and not board_item.has("_ref_to"):
					if board_item.get("id", "") == bought_id and int(board_item.get("star_level", 1)) == bought_star:
						player.board[i] = null
						bought["star_level"] = bought_star + 1
						upgraded = true
						break
			if not upgraded:
				for i in range(player.backpack.size()):
					var bp_item = player.backpack[i]
					if bp_item.get("id", "") == bought_id and int(bp_item.get("star_level", 1)) == bought_star:
						player.backpack.remove_at(i)
						bought["star_level"] = bought_star + 1
						upgraded = true
						break
			if upgraded:
				var new_star = int(bought.get("star_level", 1))
				var mult: float = GameConfig.STAR2_MULTIPLIER if new_star == 2 else GameConfig.STAR3_MULTIPLIER
				var base_flavor = float(bought.get("flavor", 0))
				bought["flavor"] = int(base_flavor * mult)
				if bought.has("base_stats"):
					var stats = bought["base_stats"]
					for attr in stats:
						stats[attr] = float(stats[attr]) * mult
				var star_text = GameConfig.STAR_NAMES.get(new_star, "★★")
				var star_color = GameConfig.STAR_COLORS.get(new_star, Color(1.0, 0.84, 0.0))
				var dish_name = str(bought.get("name", bought_id))
				FloatingTextScript.spawn(self, "%s 升至 %s" % [dish_name, star_text], get_viewport_rect().size * 0.5, star_color, 1.5, 60.0, 28)

	if itype == "tool":
		if player.tools.size() < player.max_tools:
			player.tools.append(bought)
		else:
			player.add_gold(int(bought.get("price", 0)))
		return

	if not _insert_item_to_backpack_at(player, bought, insert_pos):
		player.add_gold(int(bought.get("price", 0)))

func _insert_item_to_backpack_at(player: PlayerState, item: Dictionary, insert_pos: int) -> bool:
	var used_slots := 0
	for bp_item in player.backpack:
		used_slots += int(bp_item.get("size", 1))

	var item_size := int(item.get("size", 1))
	if used_slots + item_size > player.max_backpack:
		return false

	var clamped_pos: int = clampi(insert_pos, 0, player.backpack.size())
	player.backpack.insert(clamped_pos, item)
	return true

func _try_handle_board_to_board_drop(player: PlayerState, from_slot: int, drop_slot: int) -> bool:
	var source_item = player.get_item_at(from_slot)
	if source_item == null:
		return false

	var source_size: int = int(source_item.get("size", 1))
	var candidate_slots: Array = _get_drop_start_candidates(player.board_size, drop_slot, source_size)
	for candidate in candidate_slots:
		var to_slot: int = _resolve_item_start_slot(player, int(candidate))
		if from_slot == to_slot:
			continue

		var target_item = player.get_item_at(to_slot)
		if target_item == null:
			if BoardManager.move_item(player, from_slot, to_slot):
				return true
			continue

		if BoardManager.swap_items(player, from_slot, to_slot):
			return true
		if _try_swap_size2_with_adjacent_small_pair(player, from_slot, int(candidate)):
			return true
		if _try_swap_size2_with_adjacent_small_pair(player, to_slot, from_slot):
			return true
		if BoardManager.move_item(player, from_slot, to_slot):
			return true

	return false

func _try_place_item_on_board_with_candidates(player: PlayerState, item: Dictionary, drop_slot: int) -> bool:
	var item_size: int = int(item.get("size", 1))
	var candidate_slots: Array = _get_drop_start_candidates(player.board_size, drop_slot, item_size)
	for candidate in candidate_slots:
		if BoardManager.place_item_on_board(player, item, int(candidate)):
			return true
	return false

func _try_swap_size2_with_adjacent_small_pair(player: PlayerState, size2_slot: int, around_slot: int) -> bool:
	var pair_starts: Array = _get_drop_start_candidates(player.board_size, around_slot, 2)
	for pair_start in pair_starts:
		if BoardManager.try_swap_size2_with_two_size1(player, size2_slot, int(pair_start)):
			return true
	return false

func _get_drop_start_candidates(board_size: int, drop_slot: int, item_size: int) -> Array:
	var candidates: Array = []
	var normalized_size: int = maxi(1, item_size)
	for offset in range(normalized_size):
		var start_slot: int = drop_slot - offset
		if start_slot < 0:
			continue
		if start_slot + normalized_size > board_size:
			continue
		if candidates.has(start_slot):
			continue
		candidates.append(start_slot)
	return candidates

func _resolve_item_start_slot(player: PlayerState, slot_idx: int) -> int:
	if slot_idx < 0 or slot_idx >= player.board_size:
		return slot_idx
	var slot = player.board[slot_idx]
	if slot != null and slot.has("_ref_to"):
		return int(slot._ref_to)
	return slot_idx

func _on_slot_clicked(slot_idx: int):
	# 注释已修复
	var match_state := GameManager.get_match_state()
	if GameConfig.BATTLE_SYSTEM_V2 and match_state and match_state.current_phase == GameConfig.Phase.PREP:
		_on_slot_clicked_v2_queue(slot_idx)
	else:
		_on_board_item_clicked({}, slot_idx)

func _on_merchant_tab(merchant: String):
	_current_merchant = merchant
	_refresh_shop()

func _on_refresh():
	var player = GameManager.get_player(0)
	var match_state = GameManager.get_match_state()
	if player == null or match_state == null:
		return
	if match_state.current_phase != GameConfig.Phase.SHOP:
		return
	if GameConfig.BATTLE_SYSTEM_V2 and _current_merchant == "" and _event_resolved_action == int(match_state.current_action):
		FloatingTextScript.spawn(
			self,
			"本行动奇遇已完成，点击“进入下一行动”推进流程",
			get_viewport_rect().size * 0.5,
			Color(1.0, 0.78, 0.36),
			1.5,
			44.0,
			18
		)
		return

	var refreshed: bool = ShopManager.refresh_shop(player, match_state.current_day)
	if not refreshed:
		_shake_shop()
		_update_action_buttons()
		return

	if GameConfig.BATTLE_SYSTEM_V2:
		var is_temp_shop: bool = (
			_current_merchant == "_temp_encounter"
			and str(_current_encounter.get("type", "")) == "shop"
		)
		if is_temp_shop:
			var filter: Dictionary = _current_encounter.get("filter", {})
			var slots: int = int(_current_encounter.get("slots", 5))
			var price_mult: float = float(_current_encounter.get("price_mult", 1.0))
			var tier_offset: int = int(_current_encounter.get("tier_max_offset", 0))
			var shop_items: Array = ShopManager.generate_filtered_shop(
				filter, slots, match_state.current_day, price_mult, tier_offset
			)
			ShopManager.set_temp_shop(shop_items)
			_current_merchant = "_temp_encounter"
			var shop_row_temp = _find_node(["ContentLayer/MerchantZone/ShopRow"])
			if shop_row_temp:
				shop_row_temp.visible = true
			var container_temp = _find_node(["ContentLayer/MerchantZone/SelectionBubbleContainer"])
			if container_temp:
				container_temp.visible = false
		else:
			_current_merchant = ""
			_current_encounter_icon = ""
			_current_encounter = {}
			var shop_row = _find_node(["ContentLayer/MerchantZone/ShopRow"])
			if shop_row:
				shop_row.visible = false
			var container = _find_node(["ContentLayer/MerchantZone/SelectionBubbleContainer"])
			if container:
				container.visible = true

	_refresh_all()

func _on_ready():
	GameManager.advance_phase()

func _on_phase_changed(new_phase: int):
	var match_state = GameManager.get_match_state()
	print("GameBoard: phase changed to ", new_phase, " current_merchant=", _current_merchant, " current_action=", GameManager.current_action)
	if _phase_banner:
		_phase_banner.show_phase(new_phase)

	match new_phase:
		GameConfig.Phase.SHOP:
			visible = true
			if match_state and match_state.current_action != _last_action_seen:
				_last_action_seen = match_state.current_action
				_event_resolved_action = -1
				_current_merchant = ""
				_current_encounter_icon = ""
				_current_encounter = {}
				var container = _find_node(["ContentLayer/MerchantZone/SelectionBubbleContainer"])
				if container:
					for child in container.get_children():
						container.remove_child(child)
						child.queue_free()
					_selection_bubbles.clear()
					container.visible = true
			_refresh_all()
			if GameManager.pop_pending_level_up():
				call_deferred("_show_level_up_overlay")

		GameConfig.Phase.PVE_CHOICE:
			visible = true
			_refresh_all()
			call_deferred("_show_pve_choice_overlay")

		GameConfig.Phase.PVE_BATTLE:
			_transition_to("res://ui/EncounterView.tscn")

		GameConfig.Phase.PREP:
			visible = true
			_refresh_board()
			_refresh_tools()
			_refresh_status()

		GameConfig.Phase.PVP_BATTLE:
			visible = true
			_refresh_board()
			_refresh_tools()
			_refresh_status()

		GameConfig.Phase.SHOWDOWN:
			_transition_to("res://ui/VSTransition.tscn")

func _transition_to(scene: String):
	get_tree().change_scene_to_file(scene)

func _inspect_card(item_data: Dictionary):
	var inspector = CardInspectorScene.instantiate()
	var layer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	layer.add_child(inspector)
	inspector.inspect_item(item_data)
	inspector.close_requested.connect(func(): layer.queue_free())

func _update_adjacency_visual(slot_idx: int):
	if _adjacency_visualizer:
		var neighbors = []
		if slot_idx > 0: neighbors.append(slot_idx - 1)
		if slot_idx < _board_slots.size() - 1: neighbors.append(slot_idx + 1)
		_adjacency_visualizer.call("visualize_from_slots", _board_slots, slot_idx, neighbors, [])

func _clear_adjacency_visual():
	if _adjacency_visualizer:
		_adjacency_visualizer.call("clear_visuals")

func _show_floating_text(target, text, color):
	if target:
		FloatingTextScript.spawn(self, text, target.global_position, color)

# ============================================================
# 注释已修复

func _show_pve_choice_overlay() -> void:
	var old := get_node_or_null("PvEChoiceLayer")
	if old:
		old.queue_free()

	var match_state := GameManager.get_match_state()
	var choices: Array = []
	if match_state and match_state.has_meta("pve_choices"):
		choices = match_state.get_meta("pve_choices")
	if choices.is_empty() and match_state:
		choices = EncounterManager.generate_pve_choices(match_state.current_day)

	var layer := CanvasLayer.new()
	layer.name = "PvEChoiceLayer"
	layer.layer = 85
	add_child(layer)

	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.03, 0.1, 0.88)
	bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bg.anchor_bottom = 0.65
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_CENTER)
	root.custom_minimum_size = Vector2(920, 500)
	root.position = Vector2(-460, -310)
	root.add_theme_constant_override("separation", 18)
	layer.add_child(root)

	var title := Label.new()
	title.text = "选择挑战难度"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.92, 0.82, 0.55))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	var sub := Label.new()
	sub.text = "难度越高，奖励越多。"
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(0.68, 0.68, 0.8))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(sub)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 18)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(hbox)

	var diff_colors: Array[Color] = [Color(0.28, 0.85, 0.38), Color(1.0, 0.62, 0.08), Color(0.82, 0.18, 0.9)]
	var diff_labels: Array[String] = ["★ 简单", "★★ 普通", "★★★ 困难"]
	var xp_rewards: Array[int] = [GameConfig.XP_PER_PVE_BY_DIFF[1], GameConfig.XP_PER_PVE_BY_DIFF[2], GameConfig.XP_PER_PVE_BY_DIFF[3]]

	for i in range(mini(3, choices.size())):
		var opponent: Dictionary = choices[i]
		var diff: int = clampi(int(opponent.get("difficulty", 1)), 1, 3) - 1
		var col: Color = diff_colors[diff]
		var card := _create_pve_card(opponent, col, diff_labels[diff], xp_rewards[diff])
		card.pressed.connect(_on_pve_choice_selected.bind(opponent, layer))
		hbox.add_child(card)

	var toggle_btn := Button.new()
	toggle_btn.text = "隐藏"
	toggle_btn.add_theme_font_size_override("font_size", 16)
	var toggle_style := StyleBoxFlat.new()
	toggle_style.bg_color = Color(0.2, 0.15, 0.35, 0.9)
	toggle_style.corner_radius_top_left = 8
	toggle_style.corner_radius_top_right = 8
	toggle_style.corner_radius_bottom_left = 8
	toggle_style.corner_radius_bottom_right = 8
	toggle_style.content_margin_left = 16
	toggle_style.content_margin_right = 16
	toggle_style.content_margin_top = 8
	toggle_style.content_margin_bottom = 8
	toggle_btn.add_theme_stylebox_override("normal", toggle_style)
	toggle_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	root.add_child(toggle_btn)
	toggle_btn.pressed.connect(_toggle_pve_overlay.bind(layer, bg, root, toggle_btn))

	root.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(root, "modulate:a", 1.0, 0.2)

func _create_pve_card(opponent: Dictionary, border_color: Color, diff_label: String, xp_reward: int) -> Button:
	var card := Button.new()
	card.custom_minimum_size = Vector2(270, 350)
	card.flat = true

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.16, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = border_color.darkened(0.25)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.content_margin_left = 16
	style.content_margin_top = 16
	style.content_margin_right = 16
	style.content_margin_bottom = 16
	style.shadow_color = border_color * Color(1, 1, 1, 0.2)
	style.shadow_size = 8
	card.add_theme_stylebox_override("normal", style)

	var hover: StyleBoxFlat = style.duplicate() as StyleBoxFlat
	hover.border_color = border_color
	hover.bg_color = Color(0.15, 0.12, 0.22, 0.98)
	hover.shadow_size = 16
	hover.shadow_color = border_color * Color(1, 1, 1, 0.4)
	card.add_theme_stylebox_override("hover", hover)
	card.add_theme_stylebox_override("pressed", hover)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(vbox)

	var diff_lbl := Label.new()
	diff_lbl.text = diff_label
	diff_lbl.add_theme_font_size_override("font_size", 16)
	diff_lbl.add_theme_color_override("font_color", border_color.lightened(0.3))
	diff_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	diff_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(diff_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", border_color.darkened(0.35))
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(sep)

	var name_lbl := Label.new()
	name_lbl.text = opponent.get("name", "???")
	name_lbl.add_theme_font_size_override("font_size", 18)
	name_lbl.add_theme_color_override("font_color", Color(1, 0.96, 0.82))
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_lbl)

	var flavor_lbl := Label.new()
	flavor_lbl.text = opponent.get("flavor", "")
	flavor_lbl.add_theme_font_size_override("font_size", 13)
	flavor_lbl.add_theme_color_override("font_color", Color(0.72, 0.7, 0.84))
	flavor_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flavor_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(flavor_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = opponent.get("desc", opponent.get("description", ""))
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.add_theme_color_override("font_color", Color(0.82, 0.82, 0.88))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(desc_lbl)

	var rewards_box := HBoxContainer.new()
	rewards_box.alignment = BoxContainer.ALIGNMENT_CENTER
	rewards_box.add_theme_constant_override("separation", 14)
	rewards_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(rewards_box)

	var gold_lbl := Label.new()
	gold_lbl.text = "%d 金币" % int(opponent.get("reward_gold", 3))
	gold_lbl.add_theme_font_size_override("font_size", 15)
	gold_lbl.add_theme_color_override("font_color", Color(1.0, 0.84, 0.2))
	gold_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rewards_box.add_child(gold_lbl)

	var xp_lbl := Label.new()
	xp_lbl.text = "+%d 经验" % xp_reward
	xp_lbl.add_theme_font_size_override("font_size", 15)
	xp_lbl.add_theme_color_override("font_color", border_color.lightened(0.25))
	xp_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rewards_box.add_child(xp_lbl)

	return card

func _toggle_pve_overlay(layer: Node, bg: ColorRect, root: VBoxContainer, btn: Button) -> void:
	if root.visible:
		root.visible = false
		bg.visible = false
		btn.text = "显示"
		if btn.get_parent() == root:
			root.remove_child(btn)
			layer.add_child(btn)
			btn.set_anchors_preset(Control.PRESET_CENTER_TOP)
			btn.position = Vector2(-60, 8)
	else:
		root.visible = true
		bg.visible = true
		btn.text = "隐藏"
		if btn.get_parent() != root:
			btn.get_parent().remove_child(btn)
			root.add_child(btn)

func _on_pve_choice_selected(opponent: Dictionary, layer: Node) -> void:
	var match_state := GameManager.get_match_state()
	if match_state:
		match_state.current_encounter = opponent
	layer.queue_free()
	GameManager.advance_phase()  # PVE_CHOICE -> PVE_BATTLE

# ============================================================
# 注释已修复

func _show_level_up_overlay() -> void:
	var old := get_node_or_null("LevelUpLayer")
	if old:
		old.queue_free()

	var player := GameManager.get_player(0)
	if player == null:
		return

	var choices: Array = LevelUpManager.generate_choices(player)

	var layer := CanvasLayer.new()
	layer.name = "LevelUpLayer"
	layer.layer = 90
	add_child(layer)

	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.08, 0.92)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_CENTER)
	root.custom_minimum_size = Vector2(860, 460)
	root.position = Vector2(-430, -230)
	root.add_theme_constant_override("separation", 18)
	layer.add_child(root)

	var title := Label.new()
	title.text = "等级提升 %d 级" % player.level
	title.add_theme_font_size_override("font_size", 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	if player.level <= GameConfig.BOARD_EXPAND_LEVEL_CAP + 1:
		var board_lbl := Label.new()
		board_lbl.text = "料理台槽位 +%d（当前 %d）" % [GameConfig.BOARD_SLOTS_PER_LEVEL, player.board_size]
		board_lbl.add_theme_font_size_override("font_size", 16)
		board_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		root.add_child(board_lbl)

	var sub_text: String = "请选择一项升级奖励："
	if player.level == 2:
		sub_text = "首次升级：选择你的开局方向"

	var sub := Label.new()
	sub.text = sub_text
	sub.add_theme_font_size_override("font_size", 15)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(sub)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 18)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(hbox)

	for reward in choices:
		var card := _create_level_up_card(reward)
		card.pressed.connect(_on_level_up_reward_selected.bind(reward, layer))
		hbox.add_child(card)

	root.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(root, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _create_level_up_card(reward: Dictionary) -> Button:
	var reward_type: String = reward.get("_reward_type", "")
	var col: Color
	match reward_type:
		"technique": col = Color(0.5, 0.28, 1.0)
		"dish":      col = Color(1.0, 0.42, 0.2)
		"ingredient":col = Color(0.0, 0.88, 0.45)
		"gold":      col = Color(1.0, 0.84, 0.0)
		"upgrade_weakest": col = Color(0.9, 0.15, 0.6)
		_:           col = Color(0.65, 0.65, 0.7)

	var card := Button.new()
	card.custom_minimum_size = Vector2(240, 290)
	card.flat = true

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.16, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = col.darkened(0.28)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.content_margin_left = 16
	style.content_margin_top = 16
	style.content_margin_right = 16
	style.content_margin_bottom = 16
	card.add_theme_stylebox_override("normal", style)

	var hover: StyleBoxFlat = style.duplicate() as StyleBoxFlat
	hover.border_color = col
	hover.bg_color = Color(0.15, 0.12, 0.22, 0.98)
	hover.shadow_color = col * Color(1, 1, 1, 0.35)
	hover.shadow_size = 14
	card.add_theme_stylebox_override("hover", hover)
	card.add_theme_stylebox_override("pressed", hover)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(vbox)

	var type_names := {
		"technique": "技法",
		"dish": "菜品",
		"ingredient": "食材",
		"gold": "金币",
		"upgrade_weakest": "升级"
	}

	var type_lbl := Label.new()
	type_lbl.text = "[ %s ]" % type_names.get(reward_type, "奖励")
	type_lbl.add_theme_font_size_override("font_size", 14)
	type_lbl.add_theme_color_override("font_color", col.lightened(0.3))
	type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(type_lbl)

	var name_lbl := Label.new()
	name_lbl.text = str(reward.get("name_cn", reward.get("name", "???")))
	name_lbl.add_theme_font_size_override("font_size", 17)
	name_lbl.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_lbl)

	if str(reward.get("_enchanted_with", "")) != "":
		var ench_lbl := Label.new()
		ench_lbl.text = str(reward.get("_enchanted_with", ""))
		ench_lbl.add_theme_font_size_override("font_size", 13)
		ench_lbl.add_theme_color_override("font_color", Color(0.38, 0.92, 0.58))
		ench_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ench_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(ench_lbl)

	var flavor_str: String = str(reward.get("_reward_flavor", reward.get("description", "")))
	if flavor_str != "":
		var flavor_lbl := Label.new()
		flavor_lbl.text = flavor_str
		flavor_lbl.add_theme_font_size_override("font_size", 13)
		flavor_lbl.add_theme_color_override("font_color", Color(0.68, 0.68, 0.82))
		flavor_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		flavor_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		flavor_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(flavor_lbl)

	var stats: Dictionary = reward.get("base_stats", {})
	if not stats.is_empty():
		var stats_parts: Array[String] = []
		for key in ["flavor", "presentation", "technique", "aroma"]:
			var v: int = int(stats.get(key, 0))
			if v > 0:
				var stat_name: String = str(GameConfig.STAT_NAMES.get(key, key))
				stats_parts.append("%s+%d" % [stat_name, v])
		if not stats_parts.is_empty():
			var stats_lbl := Label.new()
			stats_lbl.text = "  ".join(stats_parts)
			stats_lbl.add_theme_font_size_override("font_size", 14)
			stats_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.7))
			stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			stats_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			vbox.add_child(stats_lbl)

	return card

func _on_level_up_reward_selected(reward: Dictionary, layer: Node) -> void:
	var player := GameManager.get_player(0)
	if player:
		LevelUpManager.apply_reward(player, reward)
	layer.queue_free()
	_rebuild_board()
	_refresh_all()
	if GameManager.pop_pending_level_up():
		call_deferred("_show_level_up_overlay")

func _rebuild_board() -> void:
	var player := GameManager.get_player(0)
	if player == null or board_container == null:
		return

	var current_count := _board_slots.size()
	var target_count := player.board_size
	if current_count == target_count:
		return

	if current_count > target_count:
		while _board_slots.size() > target_count:
			var slot = _board_slots.pop_back()
			if slot and is_instance_valid(slot):
				slot.queue_free()
		return

	for i in range(current_count, target_count):
		var slot = BoardSlotScene.instantiate()
		board_container.add_child(slot)
		slot.setup(i)
		slot.scale = Vector2(0.8, 0.8)
		slot.item_dropped.connect(_on_item_dropped_on_slot)
		slot.slot_clicked.connect(_on_slot_clicked)
		_board_slots.append(slot)

var _queue_swap_first: int = -1  # First selected slot in swap mode

func _set_slot_queue_number(slot, number: int):
	if not slot.has_method("set_queue_number"):
		var label: Label = slot.get_node_or_null("QueueNumber")
		if label == null:
			label = Label.new()
			label.name = "QueueNumber"
			label.add_theme_font_size_override("font_size", 20)
			label.add_theme_color_override("font_color", Color(1, 1, 0, 0.9))
			label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			label.add_theme_constant_override("outline_size", 2)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
			label.position = Vector2(0, 0)
			label.size = Vector2(60, 30)
			slot.add_child(label)
		label.text = str(number)
		label.visible = true
	else:
		slot.set_queue_number(number)

func _on_slot_clicked_v2_queue(slot_idx: int):
	var player: PlayerState = GameManager.get_player(0)
	if player == null or not "serve_queue" in player:
		return

	if _queue_swap_first == -1:
		_queue_swap_first = slot_idx
		if slot_idx >= 0 and slot_idx < _board_slots.size() and _board_slots[slot_idx]:
			_board_slots[slot_idx].modulate = Color(1, 1, 0.5)
	else:
		var pos_a: int = player.serve_queue.find(_queue_swap_first)
		var pos_b: int = player.serve_queue.find(slot_idx)
		if pos_a >= 0 and pos_b >= 0:
			var temp: int = player.serve_queue[pos_a]
			player.serve_queue[pos_a] = player.serve_queue[pos_b]
			player.serve_queue[pos_b] = temp
			_refresh_board()

		if _queue_swap_first >= 0 and _queue_swap_first < _board_slots.size() and _board_slots[_queue_swap_first]:
			_board_slots[_queue_swap_first].modulate = Color(1, 1, 1)
		_queue_swap_first = -1

func _input(event):
	if _ingredient_mode and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_exit_ingredient_mode()
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		if backpack_drawer and backpack_drawer.has_method("toggle"):
			backpack_drawer.toggle()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_H:
		if _help_panel:
			_help_panel.toggle()
	elif OS.has_feature("debug") and event is InputEventKey and event.pressed and event.keycode == KEY_P:
		var test_path: String = _find_first_test_video_path()
		if test_path == "":
			print("No test video found in res://assets/video/")
			return
		var stream := VideoStreamTheora.new()
		stream.file = test_path
		play_cutscene(stream)

func _find_first_test_video_path() -> String:
	var dir := DirAccess.open("res://assets/video")
	if dir == null:
		return ""
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var lower: String = file_name.to_lower()
			if lower.ends_with(".ogv"):
				dir.list_dir_end()
				return "res://assets/video/%s" % file_name
		file_name = dir.get_next()
	dir.list_dir_end()
	return ""

func _on_item_hovered(data: Dictionary) -> void:
	if _item_tooltip and not data.is_empty():
		_item_tooltip.show_item(data, get_global_mouse_position())

func _on_item_unhovered() -> void:
	if _item_tooltip:
		_item_tooltip.hide_tooltip()

func _on_backpack_toggled(is_open: bool) -> void:
	if chef_portrait_frame:
		chef_portrait_frame.modulate = Color(1, 1, 1, 0.45 if is_open else 0.72)

func _display_chef_name(chef_id: String, fallback: String) -> String:
	if CHEF_NAME_MAP.has(chef_id):
		return CHEF_NAME_MAP[chef_id]
	return fallback

# === Video Handling ===

func play_cutscene(stream: VideoStream):
	if video_overlay and video_overlay.has_method("play_video"):
		video_overlay.play_video(stream)

func _on_video_finished():
	print("Video finished!")

# === Bubble Shop Setup ===

func _setup_bubble_shop() -> void:
	var BubbleShopScript = load("res://ui/components/BubbleShop.gd")
	if BubbleShopScript == null:
		print("BubbleShop.gd not found, using fallback shop")
		return

	var canvas_layer := CanvasLayer.new()
	canvas_layer.name = "BubbleShopLayer"
	canvas_layer.layer = 10
	add_child(canvas_layer)

	bubble_shop = BubbleShopScript.new()
	bubble_shop.name = "BubbleShop"
	canvas_layer.add_child(bubble_shop)

	bubble_shop.set_anchors_preset(Control.PRESET_CENTER)
	bubble_shop.custom_minimum_size = Vector2(1000, 300)
	bubble_shop.position = Vector2(460, 400)
	bubble_shop.visible = true
	bubble_shop.mouse_filter = Control.MOUSE_FILTER_STOP

	if bubble_shop.has_signal("item_selected"):
		bubble_shop.item_selected.connect(_on_bubble_shop_item_selected)
	if bubble_shop.has_signal("refresh_requested"):
		bubble_shop.refresh_requested.connect(_on_refresh)

	print("BubbleShop initialized in CanvasLayer at position: ", bubble_shop.position)
	print("BubbleShop size: ", bubble_shop.custom_minimum_size)

func _on_bubble_shop_item_selected(item_data: Dictionary, bubble_index: int) -> void:
	_on_shop_item_clicked(item_data, bubble_index)
