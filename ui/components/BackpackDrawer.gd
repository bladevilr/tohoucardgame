extends PanelContainer

const ItemCardScene = preload("res://ui/components/ItemCard.tscn")

signal item_clicked(index: int)
signal item_right_clicked(item_data: Dictionary)
signal item_dropped_in(slot_idx: int, drag_data: Dictionary)
signal drawer_toggled(is_open: bool)

@onready var grid: HBoxContainer = $Margin/Scroll/Grid
@onready var toggle_btn: Button = $TabContainer/ToggleButton
@onready var count_label: Label = $TabContainer/ToggleButton/HBox/CountLabel

var is_open: bool = false
var _player_ref = null
var _open_y: float = 0.0
var _closed_y: float = 0.0
var open_y_override: float = -1.0

# 和备菜区完全一致的尺寸参数
const BASE_SLOT_W: float = 160.0
const BASE_SLOT_H: float = 240.0
const SLOT_SCALE: float = 0.8  # 与备菜区 BoardSlot 相同

# ─────────────────────────────────────────────
#  BackpackSlotWrapper — 背包格子拖放目标
#  注册到 "backpack_slots" 组，供 DragManager 发现
# ─────────────────────────────────────────────
class BackpackSlotWrapper extends PanelContainer:
	var slot_index: int = -1
	var drawer_ref: WeakRef = null

	func _ready() -> void:
		add_to_group("backpack_slots")
		mouse_filter = Control.MOUSE_FILTER_PASS

	func try_accept_drop(item_data: Dictionary, source_card: Control) -> bool:
		var bp_drawer = drawer_ref.get_ref() if drawer_ref else null
		if bp_drawer == null:
			return false

		var src_type: String = str(source_card.get_meta("source_type", ""))
		var src_idx: int = int(source_card.get_meta("source_index", -1))

		if src_type == "backpack":
			# 背包内重排：根据落点 X 位置决定交换/挤压
			if src_idx < 0 or src_idx == slot_index:
				return false
			var player = GameManager.get_player(0)
			if player == null:
				return false
			var vp: Viewport = Engine.get_main_loop().root.get_viewport() if Engine.get_main_loop() else null
			var mouse_x: float = vp.get_mouse_position().x if vp else global_position.x
			var local_x: float = mouse_x - global_position.x
			var slot_w: float = size.x if size.x > 0 else 128.0
			var third: float = slot_w / 3.0
			if local_x < third:
				bp_drawer.reorder_backpack_insert(player, src_idx, slot_index)
			elif local_x > third * 2.0:
				bp_drawer.reorder_backpack_insert(player, src_idx, slot_index + 1)
			else:
				bp_drawer.reorder_backpack_swap(player, src_idx, slot_index)
			bp_drawer.refresh()
			return true
		else:
			# board / shop → 背包：交给 GameBoard 处理
			var drag_data: Dictionary = {
				"source_type": src_type,
				"source_index": src_idx,
				"item_data": item_data
			}
			bp_drawer.item_dropped_in.emit(slot_index, drag_data)
			return true

# ─────────────────────────────────────────────

func _ready() -> void:
	toggle_btn.pressed.connect(toggle)
	_update_style()
	call_deferred("_recalculate_positions")
	get_viewport().size_changed.connect(_on_viewport_resized)

func setup(player_data) -> void:
	_player_ref = player_data
	refresh()

func refresh() -> void:
	var player = _player_ref
	if player == null:
		if GameManager.has_method("get_player"):
			player = GameManager.get_player(0)
	if player == null:
		return

	var max_slots: int = 10
	if "max_backpack" in player:
		max_slots = player.max_backpack

	var items: Array = []
	if "backpack" in player:
		items = player.backpack

	var filled_count: int = items.size()
	count_label.text = "%d / %d" % [filled_count, max_slots]

	for child in grid.get_children():
		child.queue_free()

	for i in range(max_slots):
		var wrapper := BackpackSlotWrapper.new()
		wrapper.slot_index = i
		wrapper.drawer_ref = weakref(self)

		if i < filled_count:
			var item = items[i]
			var item_size: int = int(item.get("size", 1))

			# wrapper 尺寸 = 基础尺寸 × scale（和备菜区一样）
			wrapper.custom_minimum_size = Vector2(BASE_SLOT_W * item_size, BASE_SLOT_H)
			wrapper.scale = Vector2(SLOT_SCALE, SLOT_SCALE)
			_apply_slot_style(wrapper, true)
			grid.add_child(wrapper)

			# 卡牌放入居中容器，scale 0.9（和 BoardSlot.set_item_card 一致）
			var center := CenterContainer.new()
			center.set_anchors_preset(Control.PRESET_FULL_RECT)
			center.mouse_filter = Control.MOUSE_FILTER_IGNORE
			wrapper.add_child(center)

			var card = ItemCardScene.instantiate()
			card.setup(item)
			card.scale = Vector2(0.9, 0.9)
			card.set_meta("source_type", "backpack")
			card.set_meta("source_index", i)
			card.set_meta("draggable", true)
			center.add_child(card)

			var idx := i
			card.card_clicked.connect(func(_data): item_clicked.emit(idx))
			card.card_right_clicked.connect(func(data): item_right_clicked.emit(data))
		else:
			wrapper.custom_minimum_size = Vector2(BASE_SLOT_W, BASE_SLOT_H)
			wrapper.scale = Vector2(SLOT_SCALE, SLOT_SCALE)
			_apply_slot_style(wrapper, false)
			grid.add_child(wrapper)

			var lbl := Label.new()
			lbl.text = "+"
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
			lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6, 0.4))
			lbl.add_theme_font_size_override("font_size", 28)
			wrapper.add_child(lbl)

func _apply_slot_style(slot: PanelContainer, occupied: bool) -> void:
	var style := StyleBoxFlat.new()
	if occupied:
		style.bg_color = Color(0.08, 0.06, 0.1, 0.4)
	else:
		style.bg_color = Color(0.1, 0.08, 0.12, 0.5)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.3, 0.25, 0.35, 0.4)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	slot.add_theme_stylebox_override("panel", style)

# ─── 排序操作 ───

func reorder_backpack_swap(player, idx_a: int, idx_b: int) -> void:
	if idx_a < 0 or idx_b < 0:
		return
	if idx_a >= player.backpack.size() or idx_b >= player.backpack.size():
		return
	var tmp = player.backpack[idx_a]
	player.backpack[idx_a] = player.backpack[idx_b]
	player.backpack[idx_b] = tmp

func reorder_backpack_insert(player, src_idx: int, dest_idx: int) -> void:
	if src_idx < 0 or src_idx >= player.backpack.size():
		return
	var item = player.backpack[src_idx]
	player.backpack.remove_at(src_idx)
	var adj := dest_idx - (1 if src_idx < dest_idx else 0)
	adj = clampi(adj, 0, player.backpack.size())
	player.backpack.insert(adj, item)

# ─── 开关动画 ───

func toggle() -> void:
	if is_open:
		close()
	else:
		open()

func open() -> void:
	if is_open:
		return
	is_open = true
	_recalculate_positions()
	position.y = _closed_y
	var tween := create_tween()
	tween.tween_property(self, "position:y", _open_y, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	drawer_toggled.emit(true)

func close() -> void:
	if not is_open:
		return
	is_open = false
	_recalculate_positions()
	position.y = _open_y
	var tween := create_tween()
	tween.tween_property(self, "position:y", _closed_y, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	drawer_toggled.emit(false)

func _recalculate_positions() -> void:
	var parent_ctrl: Control = get_parent() as Control
	if parent_ctrl == null:
		return
	var parent_h: float = float(parent_ctrl.size.y)
	var tab_h: float = maxf(36.0, float($TabContainer.size.y))
	if open_y_override >= 0.0:
		_open_y = open_y_override
	else:
		_open_y = parent_h - size.y
	_closed_y = _open_y - (size.y if size.y > 0 else 260.0) - tab_h
	position.y = _open_y if is_open else _closed_y

func _on_viewport_resized() -> void:
	_recalculate_positions()
	if _player_ref != null:
		refresh()

func _update_style() -> void:
	var panel_tex = load("res://assets/ui/theme/panel_bg.png")
	if panel_tex:
		var style := StyleBoxTexture.new()
		style.texture = panel_tex
		style.texture_margin_left = 12
		style.texture_margin_top = 12
		style.texture_margin_right = 12
		style.texture_margin_bottom = 12
		style.content_margin_left = 8
		style.content_margin_top = 8
		style.content_margin_right = 8
		style.content_margin_bottom = 8
		add_theme_stylebox_override("panel", style)
	else:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.12, 0.10, 0.95)
		style.border_width_top = 4
		style.border_color = Color(0.4, 0.3, 0.2)
		style.shadow_color = Color(0, 0, 0, 0.5)
		style.shadow_size = 20
		add_theme_stylebox_override("panel", style)
