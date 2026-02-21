extends Node
## AI Controller for opponent player.
## Makes decisions during shop/prep phases for player index 1.

var _player: PlayerState = null
var _match_state: MatchState = null

func setup(match_state: MatchState):
	_match_state = match_state
	_player = match_state.get_player(1)

func do_shop_phase():
	"""AI buys items during shop phase."""
	if _player == null:
		return

	# AI uses a virtual shop pool so it doesn't consume player-facing inventory.
	var candidates: Array = []
	for d in DishDatabase.get_dishes():
		var item = d.duplicate(true)
		item["price"] = max(2, int(item.get("cost", 3)))
		candidates.append(item)
	for i in DishDatabase.get_ingredients():
		var ing = i.duplicate(true)
		ing["price"] = max(1, int(ing.get("cost", 2)))
		candidates.append(ing)
	candidates.shuffle()

	for item in candidates:
		if _player.gold < item.get("price", 999):
			continue
		if _player.get_free_slots() <= 0 and _player.backpack.size() >= _player.max_backpack:
			break
		if not _player.spend_gold(item.get("price", 0)):
			continue
		var placed = BoardManager.auto_place_item(_player, item)
		if placed < 0:
			_player.add_to_backpack(item)
		# Avoid overfilling: keep AI board manageable.
		if _player.get_board_items().size() >= 6:
			break

func do_prep_phase():
	"""AI arranges board during prep phase."""
	if _player == null:
		return
	# Move backpack items to board if space
	while not _player.backpack.is_empty() and _player.get_free_slots() > 0:
		var item = _player.backpack[0]
		var placed = BoardManager.auto_place_item(_player, item)
		if placed >= 0:
			_player.backpack.remove_at(0)
		else:
			break

func setup_pve_opponent(difficulty: int, day: int):
	"""Populate player[1]'s board with PvE dishes based on difficulty and day.
	Clears existing board first, then places 3-5 dishes of appropriate tier."""
	if _player == null:
		return

	# Clear player[1]'s board and backpack for PvE
	for i in range(_player.board_size):
		_player.board[i] = null
	_player.backpack.clear()

	# Determine dish count by difficulty: easy=3, medium=4, hard=5
	var dish_count: int = clampi(difficulty + 2, 3, 5)

	# Determine max tier by day progression
	var max_tier: int = 0
	if day >= 5:
		max_tier = 2
	elif day >= 3:
		max_tier = 1

	# Gather candidate dishes within allowed tiers
	var candidates: Array = []
	for tier in range(max_tier + 1):
		candidates.append_array(DishDatabase.get_dishes_by_tier(tier))

	# Fallback: if no tier-filtered dishes, use all dishes
	if candidates.is_empty():
		candidates = DishDatabase.get_dishes()

	candidates.shuffle()

	# Place dishes on the board
	var placed_count := 0
	for dish in candidates:
		if placed_count >= dish_count:
			break
		var item = dish.duplicate(true)
		var slot = BoardManager.auto_place_item(_player, item)
		if slot >= 0:
			placed_count += 1

func setup_shadow_opponent(shadow: Dictionary) -> void:
	"""Load a shadow opponent's board onto player[1]."""
	if _player == null:
		return

	# Clear player[1]'s board and backpack
	for i in range(_player.board_size):
		_player.board[i] = null
	_player.backpack.clear()
	_player.tools.clear()
	_player.techniques.clear()

	# Set chef
	var chef_id: String = shadow.get("chef_id", "")
	if chef_id != "":
		_player.chef_id = chef_id

	# Place board items
	var board_items: Array = shadow.get("board", [])
	for i in range(mini(board_items.size(), _player.board_size)):
		if board_items[i] != null and board_items[i] is Dictionary and not board_items[i].is_empty():
			_player.board[i] = board_items[i].duplicate(true)

	# Load tools
	var shadow_tools: Array = shadow.get("tools", [])
	for t in shadow_tools:
		if t is Dictionary and not t.is_empty():
			_player.tools.append(t.duplicate(true))

	# Load techniques
	var shadow_techniques: Array = shadow.get("techniques", [])
	for tech in shadow_techniques:
		if tech is Dictionary and not tech.is_empty():
			_player.techniques.append(tech.duplicate(true))
