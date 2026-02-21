extends Node

## DishDatabase: load modular cuisine pools and normalize localized names.

var dishes: Dictionary = {}
var cuisine_pools: Dictionary = {}
var hero_pools: Dictionary = {}
var _loaded: bool = false
const REPLACEMENT_CHAR := "\uFFFD"

var _text_replacements := {
	"上生\uFFFD的子拼盘": "和果子拼盘",
	"冷\uFFFD的面": "冷荞麦面",
	"烤\uFFFD的鱼": "烤鳗鱼",
	"海\uFFFD的拼盘": "海鲜拼盘",
}

var _name_fallback_by_id := {
	"nikujaga": "土豆炖肉",
	"tai_no_sugata": "鲷鱼姿造",
	"wagashi_assort": "和果子拼盘",
	"soba_tsuyu": "冷荞麦面",
}

func _ready() -> void:
	_ensure_loaded()

func _ensure_loaded() -> void:
	if _loaded:
		if hero_pools.is_empty():
			_build_hero_pools()
		return

	dishes.clear()
	cuisine_pools.clear()
	hero_pools.clear()
	_load_all_pools()
	_build_hero_pools()
	_loaded = true

func _load_all_pools() -> void:
	_load_pool("washoku", WashokuPool.get_dishes())
	_load_pool("chuuka", ChuukaPool.get_dishes())
	_load_pool("youshoku", YoushokuPool.get_dishes())
	_load_pool("yatai", YataiPool.get_dishes())
	_load_pool("kanmi", KanmiPool.get_dishes())
	_load_pool("yakuzen", YakuzenPool.get_dishes())

func _load_pool(cuisine_id: String, pool_dishes: Array) -> void:
	cuisine_pools[cuisine_id] = []
	for dish in pool_dishes:
		var id := str(dish.get("id", ""))
		if id == "":
			continue
		dishes[id] = _localize_dish_entry(dish.duplicate(true))
		cuisine_pools[cuisine_id].append(id)

func _localize_dish_entry(dish: Dictionary) -> Dictionary:
	var id := str(dish.get("id", ""))
	var cn_name := str(dish.get("name_cn", "")).strip_edges()
	if cn_name != "":
		dish["name"] = _normalize_display_name(id, cn_name)
	else:
		dish["name"] = _normalize_display_name(id, str(dish.get("name", "")))

	if dish.has("name_cn"):
		dish["name_cn"] = _normalize_display_name(id, str(dish.get("name_cn", dish.get("name", ""))))
	if dish.has("description"):
		dish["description"] = _normalize_text(str(dish.get("description", "")))

	# Wrap top-level flavor into base_stats so ItemTooltip can display it
	if not dish.has("base_stats") and dish.has("flavor"):
		dish["base_stats"] = {"flavor": int(dish.get("flavor", 0))}

	return dish

func _normalize_display_name(id: String, raw_text: String) -> String:
	var out := _normalize_text(raw_text)
	if out.find(REPLACEMENT_CHAR) >= 0:
		if _name_fallback_by_id.has(id):
			out = _name_fallback_by_id[id]
		else:
			out = out.replace(REPLACEMENT_CHAR, "")
	if _contains_japanese(out):
		if _name_fallback_by_id.has(id):
			out = _name_fallback_by_id[id]
		else:
			out = _strip_japanese(out)
	out = out.strip_edges()
	if out == "":
		out = _humanize_id(id)
	return out

func _normalize_text(text: String) -> String:
	var out := text
	for key in _text_replacements:
		out = out.replace(key, _text_replacements[key])
	return out

func _contains_japanese(text: String) -> bool:
	for i in range(text.length()):
		var code := text.unicode_at(i)
		if (code >= 0x3040 and code <= 0x30ff) or (code >= 0x31f0 and code <= 0x31ff):
			return true
	return false

func _strip_japanese(text: String) -> String:
	var out := ""
	for i in range(text.length()):
		var c := text.substr(i, 1)
		var code := c.unicode_at(0)
		if (code >= 0x3040 and code <= 0x30ff) or (code >= 0x31f0 and code <= 0x31ff):
			continue
		out += c
	return out

func _humanize_id(id: String) -> String:
	if id == "":
		return "未知菜品"
	return id.replace("_", " ")

func _build_hero_pools() -> void:
	hero_pools.clear()
	for chef in ChefDatabase.get_all():
		var chef_id := str(chef.get("id", ""))
		if chef_id == "":
			continue
		var cuisines: Array = chef.get("cuisines", [])
		var ids: Array = []
		var seen: Dictionary = {}
		for cuisine_id in cuisines:
			for dish_id in cuisine_pools.get(cuisine_id, []):
				if not seen.has(dish_id):
					seen[dish_id] = true
					ids.append(dish_id)
		hero_pools[chef_id] = ids

func get_dish(id: String) -> Dictionary:
	_ensure_loaded()
	return dishes.get(id, {})

func get_all_dishes() -> Array:
	_ensure_loaded()
	return dishes.values()

func get_dishes() -> Array:
	_ensure_loaded()
	return dishes.values()

func get_cuisine_pool(cuisine_id: String) -> Array:
	_ensure_loaded()
	var ids = cuisine_pools.get(cuisine_id, [])
	var result: Array = []
	for id in ids:
		result.append(dishes[id])
	return result

func get_hero_pool(chef_id: String) -> Array:
	_ensure_loaded()
	if hero_pools.is_empty():
		_build_hero_pools()
	var ids: Array = hero_pools.get(chef_id, [])
	var result: Array = []
	for dish_id in ids:
		var dish = dishes.get(dish_id, {})
		if not dish.is_empty():
			result.append(dish)
	return result

func get_hero_pool_by_tier(chef_id: String, tier: int) -> Array:
	var pool = get_hero_pool(chef_id)
	return pool.filter(func(d): return d.get("tier", 0) == tier)

func get_cuisine_ids() -> Array:
	_ensure_loaded()
	return cuisine_pools.keys()

func get_dishes_by_cuisine(cuisine_id: String) -> Array:
	return get_cuisine_pool(cuisine_id)

func get_dishes_by_tier(tier: int) -> Array:
	_ensure_loaded()
	var result: Array = []
	for dish in dishes.values():
		if dish.get("tier", 0) == tier:
			result.append(dish)
	return result

func get_dishes_by_tag(tag: String) -> Array:
	_ensure_loaded()
	var result: Array = []
	for dish in dishes.values():
		if tag in dish.get("tags", []):
			result.append(dish)
	return result

func get_ingredients() -> Array:
	_ensure_loaded()
	var result: Array = []
	for item in dishes.values():
		var item_type = item.get("item_type", "dish")
		if item_type == "ingredient" or ("ingredient" in item.get("tags", [])):
			result.append(item)
	return result

func get_item(id: String) -> Dictionary:
	return get_dish(id)

func get_dish_count() -> int:
	_ensure_loaded()
	return dishes.size()

func get_cuisine_dish_count(cuisine_id: String) -> int:
	_ensure_loaded()
	return cuisine_pools.get(cuisine_id, []).size()
