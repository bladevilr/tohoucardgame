extends PanelContainer

signal slot_clicked(slot_idx: int)
signal item_dropped(slot_idx: int, drag_data: Dictionary)

var slot_idx: int = 0
var _occupied: bool = false
var _is_reference: bool = false
var _item_card: Control = null

const TextureGeneratorScript = preload("res://tools/TextureGenerator.gd")

@onready var center_container: CenterContainer = $CenterContainer
@onready var slot_label: Label = $CenterContainer/SlotLabel
@onready var pulse_overlay: ColorRect = $PulseOverlay

var _bg_texture_rect: TextureRect

func setup(idx: int):
	slot_idx = idx
	if is_inside_tree():
		_update_display()

func _ready():
	add_to_group("board_slots")
	
	if pulse_overlay and pulse_overlay.material == null:
		var shader = load("res://ui/shaders/slot_pulse.gdshader")
		if shader:
			var mat = ShaderMaterial.new()
			mat.shader = shader
			pulse_overlay.material = mat
	
	# Create background texture rect if not exists
	if _bg_texture_rect == null:
		_bg_texture_rect = TextureRect.new()
		_bg_texture_rect.name = "BackgroundTexture"
		_bg_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_bg_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_bg_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		# Insert behind CenterContainer
		add_child(_bg_texture_rect)
		move_child(_bg_texture_rect, 0)
		
	_update_display()

func set_occupied(occupied: bool, is_ref: bool = false):
	_occupied = occupied
	_is_reference = is_ref
	if is_inside_tree():
		_update_display()

func set_item_card(card: Control):
	if _item_card != null and _item_card.get_parent() == center_container:
		_item_card.queue_free()
	_item_card = card
	if card != null:
		center_container.add_child(card)
		slot_label.visible = false
		card.scale = Vector2(0.9, 0.9)
		var anims = get_node_or_null("/root/UIAnimations")
		if anims and anims.has_method("pop_in"):
			anims.call("pop_in", card, 0.24, Vector2(0.9, 0.9), 0.0)
	else:
		slot_label.visible = true
	if is_inside_tree():
		_update_display()

func _update_display():
	if slot_label == null:
		return
		
	# Try to load procedural textures
	var plate_tex = TextureGeneratorScript.load_texture("slot_plate.png")
	var board_tex = TextureGeneratorScript.load_texture("slot_board.png")
	
	if _bg_texture_rect:
		if _occupied and not _is_reference:
			_bg_texture_rect.texture = plate_tex
			_bg_texture_rect.modulate = Color(1, 1, 1, 1)
		else:
			_bg_texture_rect.texture = board_tex
			_bg_texture_rect.modulate = Color(1, 1, 1, 0.8)
	
	# StyleBox for border/highlight (keep existing logic but transparent bg)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0) # Transparent, rely on texture
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	if _is_reference:
		slot_label.text = "..."
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.35, 0.35, 0.42, 0.6)
	elif _occupied:
		slot_label.text = ""
	else:
		slot_label.text = "+"
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.42, 0.42, 0.5, 0.3)

	add_theme_stylebox_override("panel", style)

# Custom Drag System Handler
func try_accept_drop(item_data: Dictionary, source_card: Control) -> bool:
	var source_type = ""
	var source_index = -1
	if source_card:
		source_type = str(source_card.get_meta("source_type", ""))
		source_index = int(source_card.get_meta("source_index", -1))
		
	var item_type = str(item_data.get("item_type", ""))
	if item_type == "tool":
		_shake_reject()
		return false
	if item_type == "ingredient":
		# 食材只允许从背包拖到棋盘上的真实菜品格进行附魔
		if source_type != "backpack" or (not _occupied) or _is_reference:
			_shake_reject()
			return false
		var drag_data_ing = {
			"type": "item_card",
			"item_data": item_data,
			"source_type": source_type,
			"source_index": source_index
		}
		item_dropped.emit(slot_idx, drag_data_ing)
		return true

	# Only board-to-board moves can target occupied slots (for swap/move resolution).
	if (_occupied or _is_reference) and source_type != "board":
		_shake_reject()
		return false
		
	# Notify GameBoard to handle logic
	# We construct a data dict similar to old drag_data
	var drag_data = {
		"type": "item_card",
		"item_data": item_data,
		"source_type": source_type,
		"source_index": source_index
	}
	item_dropped.emit(slot_idx, drag_data)
	return true

func _shake_reject():
	var anims = get_node_or_null("/root/UIAnimations")
	if anims: anims.call("shake", self, 4.0, 0.2)

# Removed Godot native drag methods (_can_drop_data, _drop_data) as they are replaced by DragManager


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		slot_clicked.emit(slot_idx)
		SignalBus.board_slot_clicked.emit(slot_idx)
	elif event is InputEventScreenTouch and event.pressed:
		slot_clicked.emit(slot_idx)
		SignalBus.board_slot_clicked.emit(slot_idx)

func highlight(color: Color = Color(0.95, 0.78, 0.25, 0.35)):
	var style = get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		var duplicated = (style as StyleBoxFlat).duplicate() as StyleBoxFlat
		duplicated.bg_color = color
		duplicated.border_color = Color(1.0, 0.85, 0.35, 0.95)
		duplicated.shadow_size = 8
		duplicated.shadow_color = Color(1.0, 0.86, 0.25, 0.28)
		add_theme_stylebox_override("panel", duplicated)

func clear_highlight():
	_update_display()

func _set_pulse(amount: float) -> void:
	if pulse_overlay and pulse_overlay.material is ShaderMaterial:
		(pulse_overlay.material as ShaderMaterial).set_shader_parameter("pulse_strength", amount)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_set_pulse(0.0)
