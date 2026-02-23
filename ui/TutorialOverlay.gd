extends CanvasLayer
## TutorialOverlay — 交互式首次引导教程
## 高亮实际UI区域，等待玩家执行操作后自动推进，引导跑完第一个完整循环。

signal tutorial_completed

var _step_idx := 0
var _cutout: Control = null
var _panel: PanelContainer = null
var _title_label: Label = null
var _desc_label: Label = null
var _step_label: Label = null
var _next_button: Button = null
var _game_board: Control = null
var _signal_connections: Array[Dictionary] = []

const STEPS := [
	{
		"id": "welcome",
		"title": "欢迎来到东方料理对决!",
		"desc": "这是你的第一场比赛！接下来我会一步步教你如何操作。\n准备好了就点击下方按钮开始吧！",
		"target": "",
		"wait_for": "click_next",
	},
	{
		"id": "status_intro",
		"title": "状态栏",
		"desc": "左侧显示你的关键信息：\n· 天数 — 当前是第几天\n· 声望 — 你的生命值，归零则游戏结束\n· 金币 — 用来购买菜品和刷新商店",
		"target": "LeftSidebar",
		"wait_for": "click_next",
	},
	{
		"id": "pick_bubble",
		"title": "选择奇遇",
		"desc": "眼前出现了三个气泡，每个代表不同的奇遇。\n有的是商店，有的是随机事件。\n点击任意一个气泡来选择你的第一次奇遇！",
		"target": "ContentLayer/MerchantZone/SelectionBubbleContainer",
		"wait_for": "bubble_clicked",
	},
	{
		"id": "buy_item",
		"title": "购买菜品",
		"desc": "商店已打开！点击一个菜品来购买它。\n菜品会自动放到你的备菜台上。\n金币不够？没关系，先买一个试试！",
		"target": "ContentLayer/MerchantZone/ShopRow",
		"wait_for": "item_purchased",
	},
	{
		"id": "check_board",
		"title": "你的备菜台",
		"desc": "买到的菜品已经放在备菜台上了！\n菜品在对决时会按冷却时间自动上菜，产出美味度得分。\n物品的位置很重要——相邻的菜品可以触发联动效果。",
		"target": "ContentLayer/PlayerZone/BoardArea/BoardContainer",
		"wait_for": "click_next",
	},
	{
		"id": "click_ready",
		"title": "推进流程",
		"desc": "准备好后，点击右下角的按钮推进到下一个行动。\n每天有6次行动机会，第3次是试营业(PvE)，第6次是正式对决(PvP)。\n现在点击它来继续！",
		"target": "ControlsLayer/ReadyButton",
		"wait_for": "phase_changed",
	},
	{
		"id": "showdown_intro",
		"title": "对决即将开始",
		"desc": "当进入对决时，你的菜品会按冷却时间自动上菜。\n评委会根据美味度、节奏、菜系搭配综合评分。\n评委有各自的口味偏好——投其所好能获得加分！\n\n对决持续30秒，全自动进行，观战即可。",
		"target": "",
		"wait_for": "click_next",
	},
	{
		"id": "done",
		"title": "教程完成！",
		"desc": "你已经掌握了基本操作！一些进阶技巧：\n· 购买3张同名菜品可升星，大幅提升属性\n· 食材可以附魔到菜品上增加美味度和标签\n· 注意评委偏好，投其所好能获得额外加分\n\n祝你好运，料理人！",
		"target": "",
		"wait_for": "click_finish",
	},
]

func _ready() -> void:
	layer = 200
	visible = false

# ── CutoutOverlay: dark mask with a transparent hole ──
class CutoutOverlay extends Control:
	var cutout_rect: Rect2 = Rect2()
	var overlay_color: Color = Color(0, 0, 0, 0.72)
	var cutout_padding: float = 10.0

	func _draw() -> void:
		var sz := size
		if cutout_rect.size == Vector2.ZERO:
			draw_rect(Rect2(Vector2.ZERO, sz), overlay_color)
			return
		var c := cutout_rect.grow(cutout_padding)
		# Top
		draw_rect(Rect2(0, 0, sz.x, maxf(c.position.y, 0)), overlay_color)
		# Bottom
		draw_rect(Rect2(0, c.end.y, sz.x, maxf(sz.y - c.end.y, 0)), overlay_color)
		# Left
		draw_rect(Rect2(0, c.position.y, maxf(c.position.x, 0), c.size.y), overlay_color)
		# Right
		draw_rect(Rect2(c.end.x, c.position.y, maxf(sz.x - c.end.x, 0), c.size.y), overlay_color)
		# Gold border
		draw_rect(c, Color(0.96, 0.82, 0.28, 0.85), false, 2.0)

	func set_cutout(rect: Rect2) -> void:
		cutout_rect = rect
		queue_redraw()

	func clear_cutout() -> void:
		cutout_rect = Rect2()
		queue_redraw()

	func _has_point(point: Vector2) -> bool:
		if cutout_rect.size != Vector2.ZERO:
			if cutout_rect.grow(cutout_padding).has_point(point):
				return false
		return true

# ── Build UI ──
func _build_ui() -> void:
	_cutout = CutoutOverlay.new()
	_cutout.name = "CutoutOverlay"
	_cutout.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cutout.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_cutout)

	_panel = PanelContainer.new()
	_panel.name = "InstructionPanel"
	_panel.custom_minimum_size = Vector2(480, 200)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.137, 0.110, 0.208, 0.96)
	style.border_width_left = 2; style.border_width_top = 2
	style.border_width_right = 2; style.border_width_bottom = 2
	style.border_color = Color(0.788, 0.643, 0.290)
	style.corner_radius_top_left = 8; style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8; style.corner_radius_bottom_right = 8
	style.content_margin_left = 24; style.content_margin_top = 18
	style.content_margin_right = 24; style.content_margin_bottom = 18
	_panel.add_theme_stylebox_override("panel", style)
	_cutout.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_panel.add_child(vbox)

	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 26)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	vbox.add_child(_title_label)

	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 1)
	sep.color = Color(0.788, 0.643, 0.29, 0.5)
	vbox.add_child(sep)

	_desc_label = Label.new()
	_desc_label.add_theme_font_size_override("font_size", 16)
	_desc_label.add_theme_color_override("font_color", Color(0.941, 0.902, 0.827))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_desc_label)

	_step_label = Label.new()
	_step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_step_label.add_theme_font_size_override("font_size", 13)
	_step_label.add_theme_color_override("font_color", Color(0.62, 0.584, 0.69))
	vbox.add_child(_step_label)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)

	_next_button = Button.new()
	_next_button.text = "下一步 >"
	_next_button.custom_minimum_size = Vector2(110, 34)
	_next_button.pressed.connect(_on_next_pressed)
	_apply_btn_style(_next_button, true)
	btn_row.add_child(_next_button)

func _apply_btn_style(btn: Button, is_primary: bool) -> void:
	var s := StyleBoxFlat.new()
	if is_primary:
		s.bg_color = Color(0.24, 0.18, 0.08, 0.95)
		s.border_color = Color(0.96, 0.82, 0.28)
	else:
		s.bg_color = Color(0.227, 0.176, 0.314, 0.95)
		s.border_color = Color(0.62, 0.584, 0.69)
	s.border_width_left = 1; s.border_width_top = 1
	s.border_width_right = 1; s.border_width_bottom = 1
	s.corner_radius_top_left = 6; s.corner_radius_top_right = 6
	s.corner_radius_bottom_left = 6; s.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", s)
	btn.add_theme_stylebox_override("hover", s)
	btn.add_theme_stylebox_override("pressed", s)

# ── Tutorial lifecycle ──
func start_tutorial() -> void:
	_game_board = get_parent()
	_build_ui()
	_step_idx = 0
	visible = true
	_show_step()

func _show_step() -> void:
	_disconnect_all()
	if _step_idx >= STEPS.size():
		_finish()
		return

	var step: Dictionary = STEPS[_step_idx]
	_title_label.text = step.title
	_desc_label.text = step.desc
	_step_label.text = "%d / %d" % [_step_idx + 1, STEPS.size()]

	# Button text
	var wait: String = step.wait_for
	if wait == "click_finish":
		_next_button.text = "开始游戏!"
		_next_button.visible = true
	elif wait == "click_next":
		_next_button.text = "下一步 >"
		_next_button.visible = true
	else:
		_next_button.visible = false

	# Highlight target
	_update_cutout(step.target)

	# Position panel relative to cutout
	_position_panel()

	# Connect signals for auto-advance
	_connect_step_signals(step)

	# Animate panel in
	_panel.scale = Vector2(0.88, 0.88)
	_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_panel, "modulate:a", 1.0, 0.18)
## PLACEHOLDER_FUNCS2

func _update_cutout(target_path: String) -> void:
	if target_path == "" or _game_board == null:
		_cutout.clear_cutout()
		return
	var target := _game_board.get_node_or_null(target_path)
	if target == null or not target is Control:
		_cutout.clear_cutout()
		return
	_cutout.set_cutout(target.get_global_rect())

func _position_panel() -> void:
	if _cutout == null or _panel == null:
		return
	var vp_size := get_viewport().get_visible_rect().size
	var panel_size := _panel.custom_minimum_size
	var cr: Rect2 = _cutout.cutout_rect

	if cr.size == Vector2.ZERO:
		# Center on screen
		_panel.position = (vp_size - panel_size) * 0.5
		return

	# Try placing below the cutout
	var below_y := cr.end.y + 20.0
	if below_y + panel_size.y < vp_size.y - 20.0:
		_panel.position = Vector2((vp_size.x - panel_size.x) * 0.5, below_y)
		return

	# Try above
	var above_y := cr.position.y - panel_size.y - 20.0
	if above_y > 20.0:
		_panel.position = Vector2((vp_size.x - panel_size.x) * 0.5, above_y)
		return

	# Fallback: center
	_panel.position = (vp_size - panel_size) * 0.5

# ── Signal-driven step advancement ──
func _connect_step_signals(step: Dictionary) -> void:
	var wait: String = step.wait_for
	match wait:
		"bubble_clicked":
			# Connect to all existing bubble children
			_connect_bubble_signals()
		"item_purchased":
			var cb := func(_pi, _id): _advance_step()
			SignalBus.item_purchased.connect(cb)
			_signal_connections.append({"signal": SignalBus.item_purchased, "callable": cb})
		"phase_changed":
			var cb := func(_p): _advance_step()
			SignalBus.phase_changed.connect(cb)
			_signal_connections.append({"signal": SignalBus.phase_changed, "callable": cb})

func _connect_bubble_signals() -> void:
	if _game_board == null:
		return
	var container = _game_board.get_node_or_null("ContentLayer/MerchantZone/SelectionBubbleContainer")
	if container == null:
		return
	for wrapper in container.get_children():
		var bubble = wrapper
		if wrapper is MarginContainer and wrapper.get_child_count() > 0:
			bubble = wrapper.get_child(0)
		if bubble.has_signal("bubble_clicked"):
			var cb := func(): _on_bubble_picked()
			bubble.bubble_clicked.connect(cb)
			_signal_connections.append({"signal": bubble.bubble_clicked, "callable": cb})

func _on_bubble_picked() -> void:
	# After bubble click, check if it opened a shop or an event
	# Delay one frame so the game processes the click first
	await get_tree().process_frame
	await get_tree().process_frame
	var shop_row = _game_board.get_node_or_null("ContentLayer/MerchantZone/ShopRow") if _game_board else null
	if shop_row and shop_row.visible:
		# Shop opened — advance to buy_item step
		_advance_step()
	else:
		# Event (not a shop) — skip buy_item, go straight to check_board
		_step_idx += 1  # skip buy_item
		_advance_step()

func _advance_step() -> void:
	_step_idx += 1
	_show_step()

func _on_next_pressed() -> void:
	_advance_step()

func _disconnect_all() -> void:
	for conn in _signal_connections:
		var sig = conn.get("signal")
		var cb = conn.get("callable")
		if sig is Signal and sig.is_connected(cb):
			sig.disconnect(cb)
	_signal_connections.clear()

func _finish() -> void:
	_disconnect_all()
	SaveManager.set_tutorial_done()
	var tw := create_tween()
	tw.tween_property(_cutout, "modulate:a", 0.0, 0.3)
	tw.finished.connect(func():
		visible = false
		tutorial_completed.emit()
		queue_free()
	)
