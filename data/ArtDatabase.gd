extends Node

## ArtDatabase - Centralized art asset loader.
## Convention: res://assets/ui/{category}/{id}.{ext}
## Web builds can use optimized copies under res://assets/web/ui/.

const DEFAULT_UI_ROOT := "res://assets/ui/"
const WEB_UI_ROOT := "res://assets/web/ui/"
const IMAGE_EXTENSIONS := [".png", ".webp", ".jpg", ".jpeg"]

const CHEF_CATEGORY := "chefs"
const DISH_CATEGORY := "dishes"
const INGREDIENT_CATEGORY := "ingredients"
const JUDGE_CATEGORY := "judges"
const TECHNIQUE_CATEGORY := "techniques"
const TOOL_CATEGORY := "tools"
const CARD_CATEGORY := "cards"

var _cache: Dictionary = {} # path -> Texture2D (lazy cache)
var _resolved_path_cache: Dictionary = {} # category/id/runtime -> resolved path

# === Chef Portraits ===

func get_chef_portrait(chef_id: String) -> Texture2D:
	return _load_ui_texture(CHEF_CATEGORY, chef_id)

func has_chef_portrait(chef_id: String) -> bool:
	return _has_ui_texture(CHEF_CATEGORY, chef_id)

# === Dish Icons ===

const DISH_ALIASES: Dictionary = {
	"yatai_yakitori": "yakitori",
	"yatai_takoyaki": "takoyaki",
	"taiyaki_kanmi": "taiyaki",
	"tsukune": "yakitori",
	"chateaubriand_rossini": "chateaubriand",
	"bamboo_shoot_elixir": "eirin_elixir",
	"cordyceps_broth": "tonic_soup",
	"chicken_fricassee": "pot_au_feu"
}

func get_dish_icon(dish_id: String) -> Texture2D:
	if DISH_ALIASES.has(dish_id):
		dish_id = DISH_ALIASES[dish_id]
	return _load_ui_texture(DISH_CATEGORY, dish_id)

func has_dish_icon(dish_id: String) -> bool:
	if DISH_ALIASES.has(dish_id):
		dish_id = DISH_ALIASES[dish_id]
	return _has_ui_texture(DISH_CATEGORY, dish_id)

# === Ingredient Icons ===

func get_ingredient_icon(ing_id: String) -> Texture2D:
	return _load_ui_texture(INGREDIENT_CATEGORY, ing_id)

func has_ingredient_icon(ing_id: String) -> bool:
	return _has_ui_texture(INGREDIENT_CATEGORY, ing_id)

# === Technique Icons ===

func get_technique_icon(tech_id: String) -> Texture2D:
	return _load_ui_texture(TECHNIQUE_CATEGORY, tech_id)

func has_technique_icon(tech_id: String) -> bool:
	return _has_ui_texture(TECHNIQUE_CATEGORY, tech_id)

# === Tool Icons ===

func get_tool_icon(tool_id: String) -> Texture2D:
	return _load_ui_texture(TOOL_CATEGORY, tool_id)

func has_tool_icon(tool_id: String) -> bool:
	return _has_ui_texture(TOOL_CATEGORY, tool_id)

# === Judge Portraits ===

func get_judge_portrait(judge_id: String) -> Texture2D:
	return _load_ui_texture(JUDGE_CATEGORY, judge_id)

func has_judge_portrait(judge_id: String) -> bool:
	return _has_ui_texture(JUDGE_CATEGORY, judge_id)

# === Card Art ===

func get_card_image(card_id: String) -> Texture2D:
	return _load_ui_texture(CARD_CATEGORY, card_id)

func has_card_image(card_id: String) -> bool:
	return _has_ui_texture(CARD_CATEGORY, card_id)

# Backward compatibility for older UI scripts that still call ArtDatabase.get_image(id).
func get_image(image_id: String) -> Texture2D:
	if image_id.is_empty():
		return null
	if has_card_image(image_id):
		return get_card_image(image_id)
	if has_dish_icon(image_id):
		return get_dish_icon(image_id)
	if has_ingredient_icon(image_id):
		return get_ingredient_icon(image_id)
	if has_tool_icon(image_id):
		return get_tool_icon(image_id)
	if has_technique_icon(image_id):
		return get_technique_icon(image_id)
	if has_chef_portrait(image_id):
		return get_chef_portrait(image_id)
	if has_judge_portrait(image_id):
		return get_judge_portrait(image_id)
	return null

# === Batch Queries ===

func get_all_chef_portraits() -> Dictionary:
	"""Returns {chef_id: Texture2D} for all chefs with available portraits."""
	var result: Dictionary = {}
	for chef in ChefDatabase.get_all():
		var id = chef.get("id", "")
		if id != "" and has_chef_portrait(id):
			result[id] = get_chef_portrait(id)
	return result

func get_missing_dish_icons() -> Array:
	"""Returns list of dish IDs that DON'T have art yet."""
	var missing: Array = []
	for dish in DishDatabase.get_all_dishes():
		var id = dish.get("id", "")
		if id != "" and not has_dish_icon(id):
			missing.append(id)
	return missing

func get_art_coverage() -> Dictionary:
	"""Returns art asset coverage stats."""
	var total_dishes := DishDatabase.get_dish_count()
	var total_chefs := ChefDatabase.get_all().size()
	var covered_dishes := 0
	var covered_chefs := 0

	for dish in DishDatabase.get_all_dishes():
		if has_dish_icon(dish.get("id", "")):
			covered_dishes += 1

	for chef in ChefDatabase.get_all():
		if has_chef_portrait(chef.get("id", "")):
			covered_chefs += 1

	return {
		"dishes_total": total_dishes,
		"dishes_covered": covered_dishes,
		"dishes_missing": total_dishes - covered_dishes,
		"chefs_total": total_chefs,
		"chefs_covered": covered_chefs,
	}

# === Internal ===

func _load_ui_texture(category: String, asset_id: String) -> Texture2D:
	var path := _resolve_ui_texture_path(category, asset_id)
	if path.is_empty():
		return null
	return _load_texture(path)

func _has_ui_texture(category: String, asset_id: String) -> bool:
	return not _resolve_ui_texture_path(category, asset_id).is_empty()

func _resolve_ui_texture_path(category: String, asset_id: String) -> String:
	if asset_id.is_empty():
		return ""

	var runtime_tag := "web" if OS.has_feature("web") else "native"
	var cache_key := "%s|%s|%s" % [category, asset_id, runtime_tag]
	if _resolved_path_cache.has(cache_key):
		return String(_resolved_path_cache[cache_key])

	for root in _get_ui_roots():
		var base_path := "%s%s/%s" % [root, category, asset_id]
		for ext in IMAGE_EXTENSIONS:
			var path: String = base_path + str(ext)
			if _texture_path_exists(path):
				_resolved_path_cache[cache_key] = path
				return path

	_resolved_path_cache[cache_key] = ""
	return ""

func _get_ui_roots() -> Array[String]:
	if OS.has_feature("web"):
		return [WEB_UI_ROOT, DEFAULT_UI_ROOT]
	return [DEFAULT_UI_ROOT]

func _texture_path_exists(path: String) -> bool:
	if _cache.has(path):
		return _cache[path] != null
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)

func _load_texture(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path]

	# Debug Priority: load directly from source when present.
	if OS.has_feature("debug") and FileAccess.file_exists(path):
		var source_tex := _load_source_image(path)
		if source_tex:
			_cache[path] = source_tex
			return source_tex

	# Standard load (for imported resources)
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex:
			_cache[path] = tex
			return tex

	# Fallback: load source image bytes directly.
	if FileAccess.file_exists(path):
		var source_tex := _load_source_image(path)
		if source_tex:
			_cache[path] = source_tex
			return source_tex

	# Cache misses too to avoid repeated lookups.
	_cache[path] = null
	return null

func _load_source_image(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null

	var buffer := FileAccess.get_file_as_bytes(path)
	if buffer.size() < 4:
		return null

	var image := Image.new()
	var err := Error.OK

	# Detect format via magic numbers to avoid noisy engine errors.
	var b0 = buffer[0]
	var b1 = buffer[1]
	var b2 = buffer[2]
	var b3 = buffer[3]

	if b0 == 0x89 and b1 == 0x50 and b2 == 0x4E and b3 == 0x47:
		err = image.load_png_from_buffer(buffer)
	elif b0 == 0xFF and b1 == 0xD8:
		err = image.load_jpg_from_buffer(buffer)
	elif b0 == 0x52 and b1 == 0x49 and b2 == 0x46 and b3 == 0x46:
		err = image.load_webp_from_buffer(buffer)
	else:
		return null

	if err != OK:
		return null

	return ImageTexture.create_from_image(image)
