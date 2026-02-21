extends Node

## 商店系统 — 东方料理对决
## 统一定价：菜品/厨具=3金币，食材=1-2金币，技法=3金币
## 按天锁阶：Day 1-3 铜银，Day 4-7 开放金，Day 8+ 开放钻石
## 新增食材商店栏位

# Shop inventories per merchant type
var _shops: Dictionary = {
	"dish": [],
	"chuuka": [],      # 中华料理
	"washoku": [],     # 和食
	"yatai": [],       # 夜市
	"youshoku": [],    # 洋食
	"kanmi": [],       # 甘味
	"yakuzen": [],     # 药膳
	"ingredient": [],
	"technique": [],
	"tool": [],
	"blackmarket": [],
}

var _frozen: Dictionary = {
	"dish": [],
	"chuuka": [],
	"washoku": [],
	"yatai": [],
	"youshoku": [],
	"kanmi": [],
	"yakuzen": [],
	"ingredient": [],
	"technique": [],
	"tool": [],
	"blackmarket": [],
}

var _blackmarket_available: bool = false

# === 商店栏位配置 ===
const SHOP_SLOTS_DISH := 5
const SHOP_SLOTS_INGREDIENT := 3
const SHOP_SLOTS_TECHNIQUE := 2
const SHOP_SLOTS_TOOL := 2
const SHOP_SLOTS_BLACKMARKET := 2

# === 统一定价 (白皮书设计) ===
const PRICE_DISH := 3        # 所有菜品/厨具统一3金币
const PRICE_TOOL := 3        # 厨具也是3金币
const PRICE_TECHNIQUE := 3   # 技法3金币
const PRICE_INGREDIENT_BRONZE := 1
const PRICE_INGREDIENT_SILVER := 1
const PRICE_INGREDIENT_GOLD := 2
const PRICE_INGREDIENT_DIAMOND := 2

# === 按天锁阶 ===
# Day 1-3: 只出铜/银  Day 4-7: 开放金  Day 8+: 开放钻石
static func get_max_tier_for_day(day: int) -> int:
	if day >= 8:
		return 3  # Diamond
	elif day >= 4:
		return 2  # Gold
	return 1  # Silver

# === 品阶概率 (硬性锁阶版) ===
const TIER_WEIGHTS_BY_DAY := {
	1: {0: 75, 1: 25, 2: 0, 3: 0},   # Day 1-3: 铜75% 银25%
	4: {0: 35, 1: 40, 2: 20, 3: 5},   # Day 4-6: 金开放
	7: {0: 15, 1: 30, 2: 35, 3: 20},  # Day 7-9: 金为主
	10: {0: 5, 1: 20, 2: 40, 3: 35},  # Day 10+: 钻石大量
}

func _get_tier_weights(day: int) -> Dictionary:
	var best_key := 1
	for key in TIER_WEIGHTS_BY_DAY:
		if day >= key and key >= best_key:
			best_key = key
	return TIER_WEIGHTS_BY_DAY[best_key]

func generate_shop(player: PlayerState, day: int):
	"""Generate all merchant inventories for the day."""
	_shops.dish = _generate_dish_shop(day)

	# 生成各菜系商店
	_shops.chuuka = _generate_cuisine_shop(day, "chuuka")
	_shops.washoku = _generate_cuisine_shop(day, "washoku")
	_shops.yatai = _generate_cuisine_shop(day, "yatai")
	_shops.youshoku = _generate_cuisine_shop(day, "youshoku")
	_shops.kanmi = _generate_cuisine_shop(day, "kanmi")
	_shops.yakuzen = _generate_cuisine_shop(day, "yakuzen")

	_shops.ingredient = _generate_ingredient_shop(day)
	_shops.technique = _generate_technique_shop(day)
	_shops.tool = _generate_tool_shop(day)

	# Black market: 25% chance, increases with day
	var bm_chance = 0.20 + day * 0.02
	_blackmarket_available = randf() < bm_chance
	if _blackmarket_available:
		_shops.blackmarket = _generate_blackmarket_shop(day)
	else:
		_shops.blackmarket = []

	# Apply event discount if active
	var discount = player.chef_skill_effect.get("_next_shop_discount", 0.0)
	if discount > 0:
		for merchant in _shops:
			for item in _shops[merchant]:
				item["price"] = maxi(1, int(item.get("price", 3) * (1.0 - discount)))
		player.chef_skill_effect.erase("_next_shop_discount")

	# Restore frozen items
	for merchant in _frozen:
		for item in _frozen[merchant]:
			if _shops[merchant].size() < _get_max_slots(merchant):
				_shops[merchant].append(item)
		_frozen[merchant].clear()

func _generate_dish_shop(day: int) -> Array:
	var items: Array = []
	var max_tier = get_max_tier_for_day(day)
	var tier_weights = _get_tier_weights(day)
	var all_dishes = DishDatabase.get_dishes()
	# Filter by max tier
	var eligible = all_dishes.filter(func(d): return d.get("tier", 0) <= max_tier)
	eligible.shuffle()

	for i in range(mini(SHOP_SLOTS_DISH, eligible.size())):
		var dish = eligible[i].duplicate(true)
		dish["price"] = PRICE_DISH
		dish["star_level"] = 1
		items.append(dish)
	return items

func _generate_cuisine_shop(day: int, cuisine: String) -> Array:
	"""按菜系生成商店（只包含该菜系的菜品）"""
	var items: Array = []
	var max_tier = get_max_tier_for_day(day)
	var all_dishes = DishDatabase.get_dishes()

	# 筛选该菜系的菜品
	var eligible = all_dishes.filter(func(d):
		return d.get("cuisine", "") == cuisine and d.get("tier", 0) <= max_tier
	)
	eligible.shuffle()

	for i in range(mini(SHOP_SLOTS_DISH, eligible.size())):
		var dish = eligible[i].duplicate(true)
		dish["price"] = PRICE_DISH
		dish["star_level"] = 1
		items.append(dish)

	return items

func _generate_ingredient_shop(day: int) -> Array:
	"""Generate ingredient shop — the core 'cooking feel' mechanic."""
	var items: Array = []
	var max_tier = get_max_tier_for_day(day)
	var tier_weights = _get_tier_weights(day)
	var all_ingredients = IngredientDatabase.get_all()
	var eligible = all_ingredients.filter(func(ing): return ing.get("tier", 0) <= max_tier)
	eligible.shuffle()

	for i in range(mini(SHOP_SLOTS_INGREDIENT, eligible.size())):
		var ing = eligible[i].duplicate(true)
		ing["price"] = _calc_ingredient_price(ing)
		items.append(ing)
	return items

func _generate_technique_shop(day: int) -> Array:
	var items: Array = []
	var all_techs = TechniqueDatabase.get_all()
	all_techs.shuffle()
	for i in range(mini(SHOP_SLOTS_TECHNIQUE, all_techs.size())):
		var tech = all_techs[i].duplicate(true)
		tech["item_type"] = "technique"
		tech["price"] = PRICE_TECHNIQUE
		items.append(tech)
	return items

func _generate_tool_shop(day: int) -> Array:
	var items: Array = []
	var all_tools = ToolDatabase.get_all()
	all_tools.shuffle()
	for i in range(mini(SHOP_SLOTS_TOOL, all_tools.size())):
		var tool_item = all_tools[i].duplicate(true)
		tool_item["item_type"] = "tool"
		tool_item["price"] = PRICE_TOOL
		items.append(tool_item)
	return items

func _generate_blackmarket_shop(day: int) -> Array:
	"""Black market: rare items at premium prices."""
	var items: Array = []
	var candidates: Array = []# High-tier dishes
	for d in DishDatabase.get_dishes():
		if d.get("tier", 0) >= 2:
			candidates.append(d.duplicate(true))
	# High-tier ingredients
	for ing in IngredientDatabase.get_all():
		if ing.get("tier", 0) >= 2:
			var ing_copy = ing.duplicate(true)
			candidates.append(ing_copy)
	# Rare tools
	for t in ToolDatabase.get_all():
		if t.get("tier", "bronze") in ["gold", "diamond"]:
			var tool_copy = t.duplicate(true)
			tool_copy["item_type"] = "tool"
			candidates.append(tool_copy)

	candidates.shuffle()
	for i in range(mini(SHOP_SLOTS_BLACKMARKET, candidates.size())):
		var item = candidates[i]
		# Black market: 1.5x price, minimum 4
		var base_price = PRICE_DISH
		if item.get("item_type", "") == "ingredient":
			base_price = _calc_ingredient_price(item)
		item["price"] = maxi(4, int(ceilf(base_price * 1.5)))
		item["blackmarket"] = true
		items.append(item)
	return items

func _calc_ingredient_price(ing: Dictionary) -> int:
	var tier = ing.get("tier", 0)
	match tier:
		0: return PRICE_INGREDIENT_BRONZE
		1: return PRICE_INGREDIENT_SILVER
		2: return PRICE_INGREDIENT_GOLD
		3: return PRICE_INGREDIENT_DIAMOND
	return 1

func generate_filtered_shop(filter: Dictionary, slots: int, day: int, price_mult: float = 1.0, tier_offset: int = 0) -> Array:
	"""根据filter配置生成商店物品"""
	var items: Array = []
	var max_tier = get_max_tier_for_day(day) + tier_offset
	max_tier = clampi(max_tier, 0, 3)

	var candidates: Array = []
	if filter.has("cuisine"):
		# 直接用DishDatabase的菜系方法
		var all = DishDatabase.get_dishes_by_cuisine(filter.cuisine)
		print("DEBUG ShopManager: cuisine=", filter.cuisine, " all dishes=", all.size())
		candidates = all.filter(func(d): return d.get("tier", 0) <= max_tier)
		print("DEBUG ShopManager: after tier filter (max_tier=", max_tier, ") candidates=", candidates.size())

	elif filter.has("tag"):
		# 直接用DishDatabase的标签方法
		var all = DishDatabase.get_dishes_by_tag(filter.tag)
		candidates = all.filter(func(d): return d.get("tier", 0) <= max_tier)

	elif filter.has("tier_range"):
		var min_t = filter.tier_range[0]
		var max_t = mini(filter.tier_range[1], max_tier)
		candidates = DishDatabase.get_dishes().filter(func(d):
			var t = d.get("tier", 0)
			return t >= min_t and t <= max_t
		)

	elif filter.has("item_type"):
		match filter.item_type:
			"ingredient":
				candidates = IngredientDatabase.get_all().filter(func(i): return i.get("tier", 0) <= max_tier)
			"technique":
				candidates = TechniqueDatabase.get_all()
			"tool":
				candidates = ToolDatabase.get_all()

	elif filter.has("blackmarket"):
		var dishes = DishDatabase.get_dishes().filter(func(d): return d.get("tier", 0) >= 2)
		var ings = IngredientDatabase.get_all().filter(func(i): return i.get("tier", 0) >= 2)
		candidates = dishes + ings

	elif filter.has("mixed"):
		var dishes = DishDatabase.get_dishes().filter(func(d): return d.get("tier", 0) <= max_tier)
		var ings = IngredientDatabase.get_all().filter(func(i): return i.get("tier", 0) <= max_tier)
		candidates = dishes + ings + TechniqueDatabase.get_all() + ToolDatabase.get_all()

	if candidates.is_empty():
		push_warning("generate_filtered_shop: no candidates for filter: %s" % str(filter))
		return []

	candidates.shuffle()

	for i in range(mini(slots, candidates.size())):
		var item = candidates[i].duplicate(true)
		var base_price = PRICE_DISH
		var itype = item.get("item_type", "dish")
		if itype == "ingredient":
			base_price = _calc_ingredient_price(item)
		elif itype == "technique":
			base_price = PRICE_TECHNIQUE
		elif itype == "tool":
			base_price = PRICE_TOOL
		item["price"] = maxi(1, int(base_price * price_mult))
		if itype == "dish":
			item["star_level"] = 1
		items.append(item)

	return items

func _get_max_slots(merchant: String) -> int:
	match merchant:
		"dish": return SHOP_SLOTS_DISH
		"ingredient": return SHOP_SLOTS_INGREDIENT
		"technique": return SHOP_SLOTS_TECHNIQUE
		"tool": return SHOP_SLOTS_TOOL
		"blackmarket": return SHOP_SLOTS_BLACKMARKET
	return 5

func buy_item(player: PlayerState, merchant: String, index: int) -> Dictionary:
	"""Buy item from shop. Returns the item or empty dict on failure."""
	var shop = _shops.get(merchant, [])
	if index < 0 or index >= shop.size():
		return {}
	var item = shop[index]
	var price = item.get("price", 0)
	if not player.spend_gold(price):
		return {}
	shop.remove_at(index)
	SignalBus.item_purchased.emit(player.player_idx, item)
	return item

func sell_item(player: PlayerState, item: Dictionary) -> int:
	"""Sell item back. Returns gold gained."""
	var item_type = item.get("item_type", "")
	var star = item.get("star_level", 1)
	# Technique: fixed 1 gold refund
	if item_type == "technique":
		player.add_gold(1)
		SignalBus.item_sold.emit(player.player_idx, item)
		return 1
	# Ingredient: fixed 1 gold refund
	if item_type == "ingredient":
		player.add_gold(1)
		SignalBus.item_sold.emit(player.player_idx, item)
		return 1
	# Dishes/Tools: 1 gold base, 3 gold for 2-star, 6 gold for 3-star
	var refund = 1
	if star >= 3:
		refund = 6
	elif star >= 2:
		refund = 3
	player.add_gold(refund)
	SignalBus.item_sold.emit(player.player_idx, item)
	return refund

func refresh_shop(player: PlayerState, day: int) -> bool:
	"""Refresh shop for 1 gold (reduced from 2). Reimu gets 1 free per day."""
	var chef = ChefDatabase.get_chef(player.chef_id)
	var free = false
	if not chef.is_empty() and chef.get("id", "") == "reimu" and not player.free_refresh_used:
		free = true
		player.free_refresh_used = true

	if not free:
		if not player.spend_gold(1):  # Reduced to 1 gold — encourage D牌
			return false

	generate_shop(player, day)
	SignalBus.shop_refreshed.emit(player.player_idx)
	return true

func freeze_item(merchant: String, index: int):
	var shop = _shops.get(merchant, [])
	if index < 0 or index >= shop.size():
		return
	var item = shop[index]
	item["frozen"] = true
	_frozen[merchant].append(item)
	shop.remove_at(index)

func get_shop(merchant: String) -> Array:
	return _shops.get(merchant, [])

func set_temp_shop(items: Array) -> void:
	"""设置临时商店（遭遇池生成的商店）"""
	_shops["_temp_encounter"] = items

func get_all_shops() -> Dictionary:
	return _shops

func is_blackmarket_available() -> bool:
	return _blackmarket_available
