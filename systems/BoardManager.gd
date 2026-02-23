extends Node

# Board operations that work on PlayerState
# This manager provides higher-level board operations and validation

func place_item_on_board(player: PlayerState, item: Dictionary, slot_idx: int) -> bool:
	var size = item.get("size", 1)
	if not player.can_place_item(slot_idx, size):
		return false
	if player.place_item(slot_idx, item):
		SignalBus.item_placed.emit(player.player_idx, slot_idx, item)
		return true
	return false

func remove_item_from_board(player: PlayerState, slot_idx: int) -> Variant:
	var item = player.remove_item(slot_idx)
	if item != null:
		SignalBus.item_removed.emit(player.player_idx, slot_idx, item)
	return item

func move_item(player: PlayerState, from_slot: int, to_slot: int) -> bool:
	var item = player.get_item_at(from_slot)
	if item == null:
		return false
	# Find actual start of the item
	var actual_from = from_slot
	if player.board[from_slot] != null and player.board[from_slot].has("_ref_to"):
		actual_from = player.board[from_slot]._ref_to
	var size = item.get("size", 1)
	
	# Temporarily remove
	player.remove_item(actual_from)
	
	# Try to place at new position
	if player.can_place_item(to_slot, size):
		player.place_item(to_slot, item)
		return true
	else:
		# Put it back
		player.place_item(actual_from, item)
		return false

func swap_items(player: PlayerState, slot_a: int, slot_b: int) -> bool:
	var item_a = player.get_item_at(slot_a)
	var item_b = player.get_item_at(slot_b)
	if item_a == null or item_b == null:
		return false
	
	var start_a = slot_a
	var start_b = slot_b
	if player.board[slot_a] != null and player.board[slot_a].has("_ref_to"):
		start_a = player.board[slot_a]._ref_to
	if player.board[slot_b] != null and player.board[slot_b].has("_ref_to"):
		start_b = player.board[slot_b]._ref_to
	
	# Remove both
	player.remove_item(start_a)
	player.remove_item(start_b)
	
	# Try to place swapped
	if player.can_place_item(start_b, item_a.get("size", 1)) and player.can_place_item(start_a, item_b.get("size", 1)):
		# Check if they don't overlap after swap
		player.place_item(start_b, item_a)
		if player.can_place_item(start_a, item_b.get("size", 1)):
			player.place_item(start_a, item_b)
			return true
		else:
			player.remove_item(start_b)
	
	# Revert
	player.place_item(start_a, item_a)
	player.place_item(start_b, item_b)
	return false

func try_swap_size2_with_two_size1(player: PlayerState, size2_slot: int, target_slot: int) -> bool:
	"""尝试将 size=2 的菜品与两个相邻 size=1 菜品互换位置。
	size2_slot: size=2 菜品的起始格（已解析）
	target_slot: 两个 size=1 菜品的第一格起始位置
	"""
	# 校验 size2_slot 处有 size=2 菜品
	if size2_slot < 0 or size2_slot + 1 >= player.board_size:
		return false
	var raw_a = player.board[size2_slot]
	if raw_a == null or not (raw_a is Dictionary) or raw_a.has("_ref_to"):
		return false
	if int(raw_a.get("size", 1)) != 2:
		return false

	# 校验 target_slot 和 target_slot+1 处各有 size=1 菜品
	if target_slot < 0 or target_slot + 1 >= player.board_size:
		return false
	var raw_b1 = player.board[target_slot]
	var raw_b2 = player.board[target_slot + 1]
	if raw_b1 == null or raw_b2 == null:
		return false
	if not (raw_b1 is Dictionary) or not (raw_b2 is Dictionary):
		return false
	if raw_b1.has("_ref_to") or raw_b2.has("_ref_to"):
		return false
	if int(raw_b1.get("size", 1)) != 1 or int(raw_b2.get("size", 1)) != 1:
		return false

	# 两段范围不能重叠
	if size2_slot <= target_slot + 1 and target_slot <= size2_slot + 1:
		return false

	# 执行互换：先全部移除，再重新放置
	player.remove_item(size2_slot)
	player.remove_item(target_slot)
	player.remove_item(target_slot + 1)

	if not player.can_place_item(target_slot, 2):
		# 回滚
		player.place_item(size2_slot, raw_a)
		player.place_item(target_slot, raw_b1)
		player.place_item(target_slot + 1, raw_b2)
		return false

	player.place_item(target_slot, raw_a)

	if not player.can_place_item(size2_slot, 1) or not player.can_place_item(size2_slot + 1, 1):
		# 回滚
		player.remove_item(target_slot)
		player.place_item(size2_slot, raw_a)
		player.place_item(target_slot, raw_b1)
		player.place_item(target_slot + 1, raw_b2)
		return false

	player.place_item(size2_slot, raw_b1)
	player.place_item(size2_slot + 1, raw_b2)
	return true

func auto_place_item(player: PlayerState, item: Dictionary) -> int:
	"""Find first available slot and place item. Returns slot index or -1."""
	var size = item.get("size", 1)
	for i in range(player.board_size):
		if player.can_place_item(i, size):
			player.place_item(i, item)
			SignalBus.item_placed.emit(player.player_idx, i, item)
			return i
	return -1

func get_items_by_tag(player: PlayerState, tag: String) -> Array:
	var result: Array = []
	for entry in player.get_board_items():
		if tag in entry.item.get("tags", []):
			result.append(entry)
	return result

func get_items_by_cuisine(player: PlayerState, cuisine: String) -> Array:
	var result: Array = []
	for entry in player.get_board_items():
		if entry.item.get("cuisine", "") == cuisine:
			result.append(entry)
	return result

func get_items_by_size(player: PlayerState, size: int) -> Array:
	var result: Array = []
	for entry in player.get_board_items():
		if entry.item.get("size", 1) == size:
			result.append(entry)
	return result

func count_cuisines(player: PlayerState) -> Dictionary:
	var counts: Dictionary = {}
	for entry in player.get_board_items():
		var cuisine = entry.item.get("cuisine", "")
		if cuisine != "":
			counts[cuisine] = counts.get(cuisine, 0) + 1
	return counts

func count_tags(player: PlayerState) -> Dictionary:
	var counts: Dictionary = {}
	for entry in player.get_board_items():
		for tag in entry.item.get("tags", []):
			counts[tag] = counts.get(tag, 0) + 1
	return counts

func get_leftmost_item(player: PlayerState) -> Variant:
	for i in range(player.board_size):
		var item = player.get_item_at(i)
		if item != null and not (player.board[i] is Dictionary and player.board[i].has("_ref_to")):
			return item
	return null

func get_rightmost_item(player: PlayerState) -> Variant:
	for i in range(player.board_size - 1, -1, -1):
		var item = player.get_item_at(i)
		if item != null and not (player.board[i] is Dictionary and player.board[i].has("_ref_to")):
			return item
	return null


# --- Combat stat helpers (called by CombatResolver) ---

static func get_damage_multiplier(player: RefCounted) -> float:
	var total := 0.0
	for entry in player.get_board_items():
		total += entry.item.get("base_stats", {}).get("flavor", 0.0)
	return 1.0 + total * 0.02

static func get_damage_reduction(player: RefCounted) -> float:
	var total := 0.0
	for entry in player.get_board_items():
		total += entry.item.get("base_stats", {}).get("presentation", 0.0)
	return minf(total * 0.005, 0.50)

static func get_initiative_multiplier(player: RefCounted) -> float:
	var total := 0.0
	for entry in player.get_board_items():
		total += entry.item.get("base_stats", {}).get("technique", 0.0)
	return 1.0 + total * 0.02
