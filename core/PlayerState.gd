extends RefCounted
class_name PlayerState

var player_idx: int = 0
var chef_id: String = ""
var prestige: int = 5
var gold: int = 10
var day: int = 1

# 等级与经验
var level: int = 1
var xp: int = 0

# Board: array of slots, each null or item dict
# Items with size 2/3 occupy consecutive slots (first slot holds item, others hold reference)
var board: Array = []
var board_size: int = GameConfig.BOARD_SLOTS

# V2: 出菜队列（有序 slot_idx 列表）
var serve_queue: Array = []

# Tools: up to 3 (or 4 for 茨木华扇)
var tools: Array = []  # array of tool item dicts
var max_tools: int = 3

# Backpack: items not on board
var backpack: Array = []  # array of item dicts
var max_backpack: int = 10  # 初始10格，不再随升级扩展

# Keyword stacks (runtime, reset each showdown)
var keyword_stacks: Dictionary = {}  # keyword_id -> int

# Technique relics (global passives, not on board)
var techniques: Array = []  # array of technique dicts, max 4
var max_techniques: int = 4

# Frozen shop items
var frozen_items: Array = []

# Stats tracking
var wins: int = 0
var losses: int = 0
var streak: int = 0  # positive = win streak, negative = loss streak

# Per-run flags
var phoenix_used: bool = false  # 藤原妹红 passive
var free_refresh_used: bool = false  # 博丽灵梦 passive (resets each day)

var yatai_cd_reduction: float = 0.0  # Mystia passive multiplier
var chef_skill_effect: Dictionary = {}  # Cached chef skill effect for runtime checks

func _init(idx: int = 0):
	player_idx = idx
	board.resize(board_size)
	board.fill(null)
	init_serve_queue()

func init_serve_queue():
	"""V2: 初始化出菜队列为 board 顺序"""
	serve_queue.clear()
	for entry in get_board_items():
		serve_queue.append(entry.slot_idx)

func get_serve_queue_dishes() -> Array:
	"""V2: 返回 serve_queue 对应的菜品列表"""
	var result: Array = []
	for slot_idx in serve_queue:
		var item: Variant = get_item_at(slot_idx)
		if item != null:
			result.append(item)
	return result

func reset_for_showdown():
	keyword_stacks.clear()

func get_board_items() -> Array:
	"""Returns array of {item, slot_idx} for all unique items on board."""
	var items: Array = []
	var seen: Dictionary = {}
	for i in range(board_size):
		if board[i] != null and not seen.has(i):
			var item = board[i]
			if item.has("_ref_to"):
				continue  # skip reference slots
			items.append({"item": item, "slot_idx": i})
			# Mark occupied slots
			for j in range(item.get("size", 1)):
				seen[i + j] = true
	return items

func get_item_at(slot_idx: int) -> Variant:
	if slot_idx < 0 or slot_idx >= board_size:
		return null
	var item = board[slot_idx]
	if item != null and item.has("_ref_to"):
		return board[item._ref_to]
	return item

func can_place_item(slot_idx: int, item_size: int) -> bool:
	if slot_idx < 0 or slot_idx + item_size > board_size:
		return false
	for i in range(item_size):
		if board[slot_idx + i] != null:
			return false
	return true

func place_item(slot_idx: int, item: Dictionary) -> bool:
	var size = item.get("size", 1)
	if not can_place_item(slot_idx, size):
		return false
	board[slot_idx] = item
	for i in range(1, size):
		board[slot_idx + i] = {"_ref_to": slot_idx}
	return true

func remove_item(slot_idx: int) -> Variant:
	var item = get_item_at(slot_idx)
	if item == null:
		return null
	# Find the actual start slot
	var start = slot_idx
	if board[slot_idx] != null and board[slot_idx].has("_ref_to"):
		start = board[slot_idx]._ref_to
	var size = item.get("size", 1)
	for i in range(size):
		if start + i < board_size:
			board[start + i] = null
	return item

func get_left_neighbor(slot_idx: int) -> Variant:
	"""Get the item immediately to the left."""
	var actual_start = slot_idx
	if board[slot_idx] != null and board[slot_idx].has("_ref_to"):
		actual_start = board[slot_idx]._ref_to
	# Search left from actual_start
	for i in range(actual_start - 1, -1, -1):
		var item = board[i]
		if item != null and not item.has("_ref_to"):
			return item
		elif item != null and item.has("_ref_to"):
			return board[item._ref_to]
	return null

func get_right_neighbor(slot_idx: int) -> Variant:
	"""Get the item immediately to the right."""
	var item = get_item_at(slot_idx)
	if item == null:
		return null
	var actual_start = slot_idx
	if board[slot_idx] != null and board[slot_idx].has("_ref_to"):
		actual_start = board[slot_idx]._ref_to
	var end = actual_start + item.get("size", 1)
	if end < board_size and board[end] != null:
		if board[end].has("_ref_to"):
			return board[board[end]._ref_to]
		return board[end]
	return null

func get_adjacent(slot_idx: int) -> Array:
	"""Get both neighbors."""
	var result: Array = []
	var left = get_left_neighbor(slot_idx)
	var right = get_right_neighbor(slot_idx)
	if left != null:
		result.append(left)
	if right != null:
		result.append(right)
	return result

func get_all_left(slot_idx: int) -> Array:
	"""Get all items to the left."""
	var result: Array = []
	var actual_start = slot_idx
	if board[slot_idx] != null and board[slot_idx].has("_ref_to"):
		actual_start = board[slot_idx]._ref_to
	var seen: Dictionary = {}
	for i in range(actual_start - 1, -1, -1):
		var item = board[i]
		if item != null:
			var real_idx = i
			if item.has("_ref_to"):
				real_idx = item._ref_to
				item = board[real_idx]
			if not seen.has(real_idx):
				seen[real_idx] = true
				result.append(item)
	return result

func get_all_right(slot_idx: int) -> Array:
	"""Get all items to the right."""
	var result: Array = []
	var item_at = get_item_at(slot_idx)
	if item_at == null:
		return result
	var actual_start = slot_idx
	if board[slot_idx] != null and board[slot_idx].has("_ref_to"):
		actual_start = board[slot_idx]._ref_to
	var end = actual_start + item_at.get("size", 1)
	var seen: Dictionary = {}
	for i in range(end, board_size):
		var item = board[i]
		if item != null:
			var real_idx = i
			if item.has("_ref_to"):
				real_idx = item._ref_to
				item = board[real_idx]
			if not seen.has(real_idx):
				seen[real_idx] = true
				result.append(item)
	return result

func add_keyword(keyword_id: String, stacks: int = 1):
	keyword_stacks[keyword_id] = keyword_stacks.get(keyword_id, 0) + stacks

func consume_keyword(keyword_id: String, amount: int = -1) -> int:
	"""Consume stacks. amount=-1 means consume all. Returns amount consumed."""
	var current = keyword_stacks.get(keyword_id, 0)
	if current <= 0:
		return 0
	var to_consume = current if amount < 0 else mini(amount, current)
	keyword_stacks[keyword_id] = current - to_consume
	if keyword_stacks[keyword_id] <= 0:
		keyword_stacks.erase(keyword_id)
	return to_consume

func get_keyword_stacks(keyword_id: String) -> int:
	return keyword_stacks.get(keyword_id, 0)

func add_gold(amount: int):
	gold += amount

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		return true
	return false

func add_xp(amount: int) -> int:
	"""Add XP, handle level-ups. Returns number of level-ups that occurred."""
	xp += amount
	var levelups := 0
	while xp >= GameConfig.XP_PER_LEVEL:
		xp -= GameConfig.XP_PER_LEVEL
		level += 1
		# Lv.2/3/4：每次升级备菜台+2格（最多到10格）
		if level <= GameConfig.BOARD_EXPAND_LEVEL_CAP + 1:
			board_size += GameConfig.BOARD_SLOTS_PER_LEVEL
			board.resize(board_size)  # 扩展数组，新格子为null
		levelups += 1
	return levelups

func add_to_backpack(item: Dictionary) -> bool:
	# 计算当前背包占用的总格数
	var used_slots := 0
	for bp_item in backpack:
		used_slots += int(bp_item.get("size", 1))

	var item_size := int(item.get("size", 1))
	if used_slots + item_size > max_backpack:
		return false
	backpack.append(item)
	return true

func remove_from_backpack(index: int) -> Variant:
	if index < 0 or index >= backpack.size():
		return null
	return backpack.pop_at(index)

func get_total_attr(attr: String) -> float:
	"""Sum an attribute across all board items."""
	var total := 0.0
	for entry in get_board_items():
		var item = entry.item
		var stats = item.get("base_stats", {})
		total += stats.get(attr, 0.0)
	for tool in tools:
		var core = tool.get("core_effect", {})
		total += core.get(attr, 0.0)
	return total

func get_occupied_slots() -> int:
	var count := 0
	for slot in board:
		if slot != null:
			count += 1
	return count

func get_free_slots() -> int:
	return board_size - get_occupied_slots()
