@tool
extends PanelContainer

signal card_clicked(item_data)
signal card_right_clicked(item_data)
signal card_hovered(item_data)
signal card_unhovered()

@onready var icon_rect: TextureRect = %Icon
@onready var cd_bar: ProgressBar = %CDBar
@onready var selection_overlay: ColorRect = %SelectionOverlay
# 移除所有文本Label的引用

var item_data: Dictionary = {}
var _is_pressing := false
var _drag_start_pos: Vector2

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_setup_style()
	if not item_data.is_empty():
		_update_view()

func setup(data: Dictionary) -> void:
	item_data = data
	if is_node_ready():
		_update_view()

func _setup_style() -> void:
	# 设置基础背景板
	var bg = load("res://assets/ui/theme/panel_bg.png")
	if bg:
		var style = StyleBoxTexture.new()
		style.texture = bg
		style.texture_margin_left = 12
		style.texture_margin_top = 12
		style.texture_margin_right = 12
		style.texture_margin_bottom = 12
		add_theme_stylebox_override("panel", style)
	# 底部光晕叠层（等级光效，默认隐藏）
	if get_node_or_null("TierGlow") == null:
		var glow := ColorRect.new()
		glow.name = "TierGlow"
		glow.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		glow.offset_top = -60.0
		glow.offset_bottom = 4.0
		glow.color = Color(1.0, 0.85, 0.2, 0.0)
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(glow)
		move_child(glow, 0)

func _update_view() -> void:
	if item_data.is_empty():
		visible = false
		return
	visible = true

	# 根据菜品 size 调整卡片宽度
	var dish_size = int(item_data.get("size", 1))
	var base_width = 160.0
	var base_height = 240.0
	custom_minimum_size = Vector2(base_width * dish_size, base_height)

	# 下面这些文本更新的代码全部移除，因为界面上已经不想看到它们了
	# name_label... price_label...

	# 冷却条
	var cd = float(item_data.get("cooldown", 0.0))
	if cd_bar:
		cd_bar.visible = cd > 0
		cd_bar.max_value = max(0.1, cd)
		cd_bar.value = cd

	# 图标加载
	_load_icon()

	# 稀有度颜色 + 边框 + 光晕
	var tier = _get_tier_level()
	_apply_tier_style(tier)

func _load_icon() -> void:
	var id: String = str(item_data.get("id", ""))
	var item_type: String = str(item_data.get("item_type", item_data.get("type", "dish")))
	var tex: Texture2D = null

	if id == "":
		icon_rect.texture = null
		return

	match item_type:
		"ingredient":
			tex = ArtDatabase.get_ingredient_icon(id)
		"tool":
			tex = ArtDatabase.get_tool_icon(id)
		"technique":
			tex = ArtDatabase.get_technique_icon(id)
		"dish":
			tex = ArtDatabase.get_dish_icon(id)
		_:
			# Fallback detection for data with missing item_type.
			if ArtDatabase.has_dish_icon(id):
				tex = ArtDatabase.get_dish_icon(id)
			elif ArtDatabase.has_ingredient_icon(id):
				tex = ArtDatabase.get_ingredient_icon(id)
			elif ArtDatabase.has_tool_icon(id):
				tex = ArtDatabase.get_tool_icon(id)
			elif ArtDatabase.has_technique_icon(id):
				tex = ArtDatabase.get_technique_icon(id)
			
	if tex:
		icon_rect.texture = tex
		# 这里的核心逻辑：根据图片调整卡片高度，消除上下黑边
		# 恢复原始逻辑，不做强制压缩，保持卡片原有尺寸感
		# 2.5倍放大是通过 tscn 里的 Anchor 实现的，这里不需要修改 container 尺寸
		
		# 如果需要让卡片高度适应内容（可选，目前按照"恢复一开始状态"理解为固定/最小尺寸）
		# 既然 tscn 里设回了 160x240，这里就不需要再动态改 custom_minimum_size.y 了
		# 除非你想让卡片变短。
		pass 
	else:
		icon_rect.texture = null

func _get_tier_level() -> int:
	var tier = str(item_data.get("tier", "0")).to_lower()
	match tier:
		"bronze", "0": return 0
		"silver", "1": return 1
		"gold", "2": return 2
		"diamond", "3": return 3
		"legendary", "4": return 4
		"5": return 5
	return 0

func _apply_tier_style(level: int) -> void:
	# 等级颜色配置：[modulate, border_color, glow_color, glow_alpha]
	const TIER_DATA := [
		# 0 普通 — 无特效
		[Color(1.0, 1.0, 1.0),      Color(0.35, 0.30, 0.40, 0.0),  Color(0.6, 0.6, 0.6),   0.0],
		# 1 银   — 淡蓝边框，微光
		[Color(0.92, 0.94, 1.0),    Color(0.70, 0.78, 1.00, 0.9),  Color(0.7, 0.8, 1.0),   0.18],
		# 2 金   — 金色边框，金光
		[Color(1.0, 0.96, 0.82),    Color(1.00, 0.82, 0.20, 1.0),  Color(1.0, 0.85, 0.2),  0.30],
		# 3 钻   — 青紫边框，紫光
		[Color(0.90, 0.95, 1.0),    Color(0.65, 0.40, 1.00, 1.0),  Color(0.7, 0.4, 1.0),   0.35],
		# 4 传说 — 橙红边框，橙红光
		[Color(1.0, 0.90, 0.88),    Color(1.00, 0.45, 0.25, 1.0),  Color(1.0, 0.5, 0.2),   0.42],
	]
	var d: Array = TIER_DATA[clampi(level, 0, TIER_DATA.size() - 1)]
	self.modulate = d[0]

	# 边框：用 StyleBoxFlat 叠在 StyleBoxTexture 上方（通过 focus 槽或直接覆盖）
	var border_style := StyleBoxFlat.new()
	border_style.bg_color = Color(0, 0, 0, 0)  # 透明背景
	border_style.border_width_left = 2 if level > 0 else 0
	border_style.border_width_top = 2 if level > 0 else 0
	border_style.border_width_right = 2 if level > 0 else 0
	border_style.border_width_bottom = 2 if level > 0 else 0
	border_style.border_color = d[1]
	border_style.corner_radius_top_left = 8
	border_style.corner_radius_top_right = 8
	border_style.corner_radius_bottom_left = 8
	border_style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("focus", border_style)

	# 底部光晕
	var glow := get_node_or_null("TierGlow") as ColorRect
	if glow:
		if level > 0:
			glow.color = Color(d[2][0], d[2][1], d[2][2], d[3])
		else:
			glow.color = Color(0, 0, 0, 0)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_pressing = true
				_drag_start_pos = event.global_position
			else:
				if _is_pressing:
					card_clicked.emit(item_data)
					SignalBus.item_clicked.emit(item_data)
				_is_pressing = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			card_right_clicked.emit(item_data)
	elif event is InputEventMouseMotion:
		if _is_pressing and event.global_position.distance_to(_drag_start_pos) > 10.0:
			_is_pressing = false
			_try_drag(event.global_position)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_is_pressing = true
			_drag_start_pos = event.position
		else:
			if _is_pressing:
				card_clicked.emit(item_data)
				SignalBus.item_clicked.emit(item_data)
			_is_pressing = false
	elif event is InputEventScreenDrag:
		if _is_pressing and event.position.distance_to(_drag_start_pos) > 10.0:
			_is_pressing = false
			_try_drag(event.position)

func _try_drag(pointer_pos: Vector2 = Vector2(-1, -1)) -> void:
	var dm = get_tree().get_first_node_in_group("drag_manager")
	if dm:
		dm.start_drag(self, item_data, pointer_pos)

func _on_mouse_entered() -> void:
	if selection_overlay: selection_overlay.visible = true
	scale = Vector2(1.05, 1.05)
	z_index = 10
	card_hovered.emit(item_data)
	SignalBus.item_hovered.emit(item_data)

func _on_mouse_exited() -> void:
	if selection_overlay: selection_overlay.visible = false
	scale = Vector2(1.0, 1.0)
	z_index = 0
	card_unhovered.emit()
	SignalBus.item_unhovered.emit()

func update_cd(val: float) -> void:
	if cd_bar: cd_bar.value = val
