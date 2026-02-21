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
var _flavor_label: Label = null  # 风味值角标

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

	# 风味值角标（右下角）
	if get_node_or_null("FlavorLabel") == null:
		_flavor_label = Label.new()
		_flavor_label.name = "FlavorLabel"
		# 使用 PRESET_BOTTOM_RIGHT 锚点，脱离 PanelContainer 的布局约束
		_flavor_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		_flavor_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		_flavor_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
		_flavor_label.offset_right = -4.0
		_flavor_label.offset_bottom = -4.0
		_flavor_label.offset_left = -64.0
		_flavor_label.offset_top = -24.0
		_flavor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_flavor_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		_flavor_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_flavor_label.add_theme_font_size_override("font_size", 16)
		_flavor_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		_flavor_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		_flavor_label.add_theme_constant_override("shadow_offset_x", 1)
		_flavor_label.add_theme_constant_override("shadow_offset_y", 1)
		_flavor_label.z_index = 10
		_flavor_label.visible = false
		# 加到父级而非 PanelContainer 本身，避免被 Container 布局覆盖偏移
		var overlay := Control.new()
		overlay.name = "FlavorOverlay"
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.z_index = 9
		add_child(overlay)
		overlay.add_child(_flavor_label)
	else:
		var overlay = get_node_or_null("FlavorOverlay")
		if overlay:
			_flavor_label = overlay.get_node_or_null("FlavorLabel")
		if _flavor_label == null:
			_flavor_label = get_node("FlavorLabel")

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

	# 初始化风味角标（显示基础风味值）
	var base_flavor: int = int(item_data.get("flavor", 0))
	if base_flavor > 0:
		_set_flavor_label(base_flavor, false)

# 供战斗系统调用：更新角标显示，is_crit=true 时用暴击样式
func show_flavor_overlay(value: int, is_crit: bool = false) -> void:
	_set_flavor_label(value, is_crit)

func _set_flavor_label(value: int, is_crit: bool) -> void:
	if _flavor_label == null:
		var overlay = get_node_or_null("FlavorOverlay")
		if overlay:
			_flavor_label = overlay.get_node_or_null("FlavorLabel")
	if _flavor_label == null:
		_flavor_label = get_node_or_null("FlavorLabel")
	if _flavor_label == null:
		return
	_flavor_label.text = "🔥%d" % value
	_flavor_label.visible = true
	if is_crit:
		_flavor_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.1))
		_flavor_label.add_theme_font_size_override("font_size", 19)
	else:
		_flavor_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		_flavor_label.add_theme_font_size_override("font_size", 16)

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
