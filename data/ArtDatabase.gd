extends Node

## ArtDatabase — Centralized art asset loader
## Convention: res://assets/ui/{category}/{id}.png
## Categories: chefs, dishes, judges, ingredients

const CHEF_PATH := "res://assets/ui/chefs/"
const DISH_PATH := "res://assets/ui/dishes/"
const INGREDIENT_PATH := "res://assets/ui/ingredients/"
const JUDGE_PATH := "res://assets/ui/judges/"
const TECHNIQUE_PATH := "res://assets/ui/techniques/"
const TOOL_PATH := "res://assets/ui/tools/"

var _cache: Dictionary = {}# path -> Texture2D (lazy cache)

# === Chef Portraits ===

func get_chef_portrait(chef_id: String) -> Texture2D:
	return _load_texture(CHEF_PATH + chef_id + ".png")

func has_chef_portrait(chef_id: String) -> bool:
	return ResourceLoader.exists(CHEF_PATH + chef_id + ".png")

# === Dish Icons ===

func get_dish_icon(dish_id: String) -> Texture2D:
	return _load_texture(DISH_PATH + dish_id + ".png")

func has_dish_icon(dish_id: String) -> bool:
	return ResourceLoader.exists(DISH_PATH + dish_id + ".png")

# === Ingredient Icons ===

func get_ingredient_icon(ing_id: String) -> Texture2D:
	return _load_texture(INGREDIENT_PATH + ing_id + ".png")

func has_ingredient_icon(ing_id: String) -> bool:
	var path = INGREDIENT_PATH + ing_id + ".png"
	# Check cache first
	if _cache.has(path):
		return _cache[path] != null
	
	# Use same logic as _load_texture to determine existence safely
	if OS.has_feature("debug") and FileAccess.file_exists(path) and not FileAccess.file_exists(path + ".import"):
		return true # Source exists, loadable via fallback
		
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)

# === Technique Icons ===

func get_technique_icon(tech_id: String) -> Texture2D:
	return _load_texture(TECHNIQUE_PATH + tech_id + ".png")

func has_technique_icon(tech_id: String) -> bool:
	var path = TECHNIQUE_PATH + tech_id + ".png"
	if _cache.has(path): return _cache[path] != null
	if OS.has_feature("debug") and FileAccess.file_exists(path) and not FileAccess.file_exists(path + ".import"):
		return true
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)

# === Tool Icons ===

func get_tool_icon(tool_id: String) -> Texture2D:
	return _load_texture(TOOL_PATH + tool_id + ".png")

func has_tool_icon(tool_id: String) -> bool:
	var path = TOOL_PATH + tool_id + ".png"
	if _cache.has(path): return _cache[path] != null
	if OS.has_feature("debug") and FileAccess.file_exists(path) and not FileAccess.file_exists(path + ".import"):
		return true
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)

# === Judge Portraits ===

func get_judge_portrait(judge_id: String) -> Texture2D:
	return _load_texture(JUDGE_PATH + judge_id + ".png")

func has_judge_portrait(judge_id: String) -> bool:
	return ResourceLoader.exists(JUDGE_PATH + judge_id + ".png")

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

func _load_texture(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path]

	# Debug Priority: Load directly from source file if it exists.
	# This bypasses the import system lag/errors completely in the editor.
	# In exported builds (even debug ones), source files representatively don't exist, so this is skipped.
	if OS.has_feature("debug") and FileAccess.file_exists(path):
		var source_tex := _load_source_image(path)
		if source_tex:
			_cache[path] = source_tex
			return source_tex

	# Standard Load (for exported builds or imported resources)
	if ResourceLoader.exists(path):
		var tex = load(path) as Texture2D
		if tex:
			_cache[path] = tex
			return tex

	# Fallback: Load directly from file (useful for new assets not yet imported)
	# This works in editor and debug builds where source files are present.
	if FileAccess.file_exists(path):
		var source_tex := _load_source_image(path)
		if source_tex:
			_cache[path] = source_tex
			return source_tex

	# Cache failed lookups too, so we don't retry and spam logs every frame.
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
	
	# Detect format via magic numbers to avoid engine errors
	var b0 = buffer[0]
	var b1 = buffer[1]
	var b2 = buffer[2]
	var b3 = buffer[3]
	
	if b0 == 0x89 and b1 == 0x50 and b2 == 0x4E and b3 == 0x47:
		# PNG
		err = image.load_png_from_buffer(buffer)
	elif b0 == 0xFF and b1 == 0xD8:
		# JPG (starts with FF D8)
		err = image.load_jpg_from_buffer(buffer)
	elif b0 == 0x52 and b1 == 0x49 and b2 == 0x46 and b3 == 0x46:
		# RIFF (likely WEBP)
		# Check indices 8..11 for "WEBP" if needed, but safe to assume for now or let loader fail cleanly
		err = image.load_webp_from_buffer(buffer)
	else:
		return null # Unknown format
		
	if err != OK:
		return null
		
	return ImageTexture.create_from_image(image)
