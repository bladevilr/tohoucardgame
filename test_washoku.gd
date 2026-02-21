extends SceneTree

func _init():
	print("=== Testing Washoku Filtering ===")
	
	# Test 1: DishDatabase.get_dishes_by_cuisine
	print("\n1. Testing DishDatabase.get_dishes_by_cuisine('washoku'):")
	var dishes = DishDatabase.get_dishes_by_cuisine("washoku")
	print("  Count: ", dishes.size())
	if dishes.size() > 0:
		print("  First 3 dishes:")
		for i in range(min(3, dishes.size())):
			print("    - ", dishes[i].name)
	else:
		print("  WARNING: No dishes found!")
	
	# Test 2: ShopManager.generate_filtered_shop
	print("\n2. Testing ShopManager.generate_filtered_shop with washoku:")
	var result = ShopManager.generate_filtered_shop({"cuisine": "washoku"}, 5, 1, 1.0, 0)
	print("  Result count: ", result.size())
	if result.size() > 0:
		print("  Items:")
		for item in result:
			print("    - ", item.name)
	else:
		print("  WARNING: No items generated!")
	
	print("\n=== Test Complete ===")
	quit()
