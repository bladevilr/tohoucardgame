extends SceneTree

func _init():
	print("Starting Asset Debug...")
	
	# Autoloads are not automatically available in this standalone script unless we load them or they are part of the scene tree.
	# However, since we are running this as a script, we might need to load the singletons manually or mock them.
	# Actually, to properly test this in Godot environment, we should use a scene or a proper runner.
	# But let's try to load ArtDatabase and DishDatabase directly.
	
	var ArtDatabase = load("res://data/ArtDatabase.gd").new()
	var DishDatabase = load("res://data/DishDatabase.gd").new()
	var IngredientDatabase = load("res://data/IngredientDatabase.gd").new()
	
	# We need to initialize them if they have _ready
	if DishDatabase.has_method("_ready"):
		DishDatabase._ready()
	
	print("DishDatabase Count: ", DishDatabase.get_dish_count())
	var missing_icons = []
	var found_icons = 0
	
	for dish in DishDatabase.get_all_dishes():
		var id = dish.get("id", "")
		if id == "": continue
		
		# ArtDatabase.has_dish_icon uses ResourceLoader
		if ArtDatabase.has_dish_icon(id):
			found_icons += 1
		else:
			missing_icons.append(id)
			
	print("Found Icons: ", found_icons)
	print("Missing Icons: ", missing_icons.size())
	if missing_icons.size() > 0:
		print("First 10 missing: ", missing_icons.slice(0, 10))

	# Check Ingredients
	var ingredients = IngredientDatabase.get_all()
	print("Ingredient Count: ", ingredients.size())
	var missing_ing = []
	for ing in ingredients:
		var id = ing.get("id", "")
		if ArtDatabase.has_ingredient_icon(id):
			pass
		else:
			missing_ing.append(id)
	print("Missing Ingredients: ", missing_ing.size())
	if missing_ing.size() > 0:
		print("First 10 missing ingredients: ", missing_ing.slice(0, 10))

	quit()
