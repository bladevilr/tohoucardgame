extends Node

signal drag_started(item_data: Dictionary)
signal drag_ended(success: bool)

const FloatingTextScript = preload("res://ui/effects/FloatingText.gd")

var _dragging: bool = false
var _source_card: Control = null
var _proxy_card: Control = null
var _item_data: Dictionary = {}

var _velocity: Vector2 = Vector2.ZERO
var _pointer_pos: Vector2 = Vector2.ZERO
var _has_pointer_pos: bool = false

const FOLLOW_SPEED: float = 25.0
const TILT_FACTOR: float = 0.05
const MAX_TILT: float = 15.0
const SLOT_HIT_PADDING: float = 24.0
const SLOT_SNAP_RADIUS_MIN: float = 52.0
const SLOT_SNAP_RADIUS_FACTOR: float = 0.45

func _ready():
	add_to_group("drag_manager")
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)

func start_drag(card: Control, data: Dictionary, pointer_pos: Vector2 = Vector2(-1, -1)):
	if _dragging:
		return

	_dragging = true
	_source_card = card
	_item_data = data
	if pointer_pos.x >= 0.0 and pointer_pos.y >= 0.0:
		_pointer_pos = pointer_pos
		_has_pointer_pos = true
	else:
		_pointer_pos = get_viewport().get_mouse_position()
		_has_pointer_pos = true

	_source_card.modulate.a = 0.0

	var scene = load("res://ui/components/ItemCard.tscn")
	if scene == null:
		_cleanup()
		return
	_proxy_card = scene.instantiate()

	var layer = CanvasLayer.new()
	layer.name = "DragLayer"
	layer.layer = 200
	get_tree().root.add_child(layer)
	layer.add_child(_proxy_card)

	_proxy_card.setup(data)
	_proxy_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_proxy_card.global_position = _source_card.get_global_rect().position
	_proxy_card.scale = _source_card.scale

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_proxy_card, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_proxy_card, "rotation_degrees", 5.0, 0.2)

	set_process(true)
	drag_started.emit(data)

func _process(delta):
	if not _dragging or not is_instance_valid(_proxy_card):
		set_process(false)
		return

	var pointer = _pointer_pos if _has_pointer_pos else _proxy_card.get_global_mouse_position()
	var target_pos = pointer - _proxy_card.size * 0.5
	var new_pos = _proxy_card.global_position.lerp(target_pos, delta * FOLLOW_SPEED)
	_velocity = (new_pos - _proxy_card.global_position) / delta
	_proxy_card.global_position = new_pos

	var target_rot = clamp(_velocity.x * TILT_FACTOR, -MAX_TILT, MAX_TILT)
	_proxy_card.rotation_degrees = lerp(_proxy_card.rotation_degrees, target_rot, delta * 10.0)

func _input(event):
	if not _dragging:
		return

	if event is InputEventMouseMotion:
		_pointer_pos = event.position
		_has_pointer_pos = true
	elif event is InputEventScreenDrag:
		_pointer_pos = event.position
		_has_pointer_pos = true
	elif event is InputEventScreenTouch:
		_pointer_pos = event.position
		_has_pointer_pos = true
		if not event.pressed:
			_end_drag()
		return

	if event is InputEventMouseButton:
		_pointer_pos = event.position
		_has_pointer_pos = true
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_end_drag()

func _end_drag():
	_dragging = false
	set_process(false)

	var sell_zone = _find_sell_zone_under_mouse()
	if sell_zone:
		_animate_sell()
		return

	var target_slot = _find_slot_under_mouse()
	if target_slot and target_slot.has_method("try_accept_drop"):
		if target_slot.try_accept_drop(_item_data, _source_card):
			_animate_drop_success(target_slot)
			return

	_animate_return()

func _find_slot_under_mouse() -> Control:
	var mouse_pos = _pointer_pos if _has_pointer_pos else _proxy_card.get_global_mouse_position()
	var inside_slot: Control = null
	var inside_dist_sq: float = INF
	var snap_slot: Control = null
	var snap_dist_sq: float = INF

	var slot_groups: Array = ["board_slots", "backpack_slots"]
	for group_name in slot_groups:
		var slots = get_tree().get_nodes_in_group(group_name)
		for slot in slots:
			if not (slot is Control and slot.is_visible_in_tree()):
				continue
			var ctrl := slot as Control
			var rect: Rect2 = ctrl.get_global_rect()
			var center: Vector2 = rect.get_center()
			var dist_sq: float = center.distance_squared_to(mouse_pos)

			if rect.grow(SLOT_HIT_PADDING).has_point(mouse_pos):
				if inside_slot == null or dist_sq < inside_dist_sq:
					inside_slot = ctrl
					inside_dist_sq = dist_sq
				continue

			var snap_radius: float = maxf(
				SLOT_SNAP_RADIUS_MIN,
				maxf(rect.size.x, rect.size.y) * SLOT_SNAP_RADIUS_FACTOR
			)
			if dist_sq <= snap_radius * snap_radius:
				if snap_slot == null or dist_sq < snap_dist_sq:
					snap_slot = ctrl
					snap_dist_sq = dist_sq

	if inside_slot != null:
		return inside_slot
	return snap_slot

func _find_sell_zone_under_mouse() -> Control:
	var mouse_pos = _pointer_pos if _has_pointer_pos else _proxy_card.get_global_mouse_position()
	var zones = get_tree().get_nodes_in_group("sell_zone")
	for zone in zones:
		if zone is Control and zone.is_visible_in_tree():
			if zone.get_global_rect().has_point(mouse_pos):
				return zone
	return null

func _animate_sell():
	if not is_instance_valid(_proxy_card):
		_cleanup()
		return

	var player: PlayerState = GameManager.get_player(0) as PlayerState
	if player and not _item_data.is_empty():
		var source_type: String = ""
		var source_idx: int = -1
		if _source_card:
			source_type = str(_source_card.get_meta("source_type", ""))
			source_idx = int(_source_card.get_meta("source_index", -1))

		# Shop items are not owned yet; dragging them to sell zone should do nothing.
		if source_type == "shop":
			_animate_return()
			return

		var sell_price: int = maxi(1, int(_item_data.get("price", 0)) / 2)
		player.add_gold(sell_price)

		if source_type == "board" and source_idx >= 0 and source_idx < player.board.size():
			player.board[source_idx] = null
		elif source_type == "backpack" and source_idx >= 0 and source_idx < player.backpack.size():
			player.backpack.remove_at(source_idx)

		SignalBus.item_sold.emit(player.player_idx, _item_data)

		var floating_text: String = "+%d 金币" % sell_price
		FloatingTextScript.spawn(self, floating_text, _proxy_card.global_position, Color(1, 0.85, 0.3), 1.0, 56.0, 18)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_proxy_card, "global_position:y", -200.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(_proxy_card, "modulate:a", 0.0, 0.25)
	tween.tween_property(_proxy_card, "scale", Vector2(0.3, 0.3), 0.3)
	tween.chain().tween_callback(func():
		_cleanup()
		drag_ended.emit(true)
	)

func _animate_return():
	if not is_instance_valid(_proxy_card) or not is_instance_valid(_source_card):
		_cleanup()
		return

	var tween = create_tween()
	var target = _source_card.get_global_rect().position
	tween.set_parallel(true)
	tween.tween_property(_proxy_card, "global_position", target, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_proxy_card, "rotation", 0.0, 0.25)
	tween.tween_property(_proxy_card, "scale", _source_card.scale, 0.25)
	tween.chain().tween_callback(func():
		_source_card.modulate.a = 1.0
		_cleanup()
		drag_ended.emit(false)
	)

func _animate_drop_success(target_slot):
	var tween = create_tween()
	var target_pos = target_slot.global_position + target_slot.size * 0.5 - _proxy_card.size * 0.5
	tween.set_parallel(true)
	tween.tween_property(_proxy_card, "global_position", target_pos, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_proxy_card, "rotation", 0.0, 0.15)
	tween.tween_property(_proxy_card, "scale", Vector2(0.9, 0.9), 0.15)
	tween.chain().tween_callback(func():
		_cleanup()
		drag_ended.emit(true)
	)

func _cleanup():
	if is_instance_valid(_proxy_card):
		var layer = _proxy_card.get_parent()
		_proxy_card.queue_free()
		if layer:
			layer.queue_free()
	_proxy_card = null
	_source_card = null
	_has_pointer_pos = false
