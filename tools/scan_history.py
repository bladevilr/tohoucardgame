import os
import time

history_dir = r"C:\Users\R\AppData\Roaming\Code\User\History"
print(f"Scanning {history_dir} for recent backups...")

# Look for files modified within the last 48 hours
max_age = 48 * 3600
now = time.time()

targets = {
    "IngredientDatabase.gd": "var ingredients: Dictionary = {}",
    "Washoku.gd": "var dishes: Dictionary = {}",
    "Chuuka.gd": "var dishes: Dictionary = {}",
    "Youshoku.gd": "var dishes: Dictionary = {}",
    "Kanmi.gd": "var dishes: Dictionary = {}",
    "Seafood.gd": "var dishes: Dictionary = {}",
    "ToolDatabase.gd": "var tools: Dictionary = {}"
}

found_files = {}

for root, dirs, files in os.walk(history_dir):
    for f in files:
        path = os.path.join(root, f)
        try:
            mtime = os.path.getmtime(path)
            if now - mtime < max_age:
                with open(path, 'r', encoding='utf-8') as file:
                    content = file.read()
                    
                    for target_name, target_content in targets.items():
                        if target_content in content:
                            # Use a heuristic to ensure it's the right file and from BEFORE my changes
                            if target_name == "IngredientDatabase.gd" and "虚空椒" not in content and "old_chili" not in content:
                                # We want the version with 50+ ingredients, not the 16 engine builder ones
                                # Let's check for "soy_sauce", "mirin", etc.
                                if "mirin" in content or "salt" in content:
                                    if target_name not in found_files or mtime < found_files[target_name][1]: 
                                        # actually we want the OLDEST file in the last 48 hours or something just before my edits
                                        found_files[target_name] = (path, mtime)
                            
                            elif target_name.endswith(".gd") and target_name != "IngredientDatabase.gd" and target_name != "ToolDatabase.gd":
                                # Cuisines: want the version without the fake DBG descriptions
                                if "开胃引擎" not in content and "剧毒上瘾" not in content:
                                    if target_name not in found_files or mtime > found_files[target_name][1]:
                                        # Get the most recent one that doesn't have the broken triggers
                                        found_files[target_name] = (path, mtime)
                                        
                            elif target_name == "ToolDatabase.gd":
                                if "cast_iron_pot" in content and "蓄热均匀" in content and "爆香流增强" not in content:
                                    if target_name not in found_files or mtime > found_files[target_name][1]:
                                        found_files[target_name] = (path, mtime)
        except Exception as e:
            pass

for name, info in found_files.items():
    print(f"Found {name} backup: {info[0]} (Modified: {time.ctime(info[1])})")
    
    # Let's save them as recovered_xxx.gd so we can inspect them
    with open(f"recover_{name}", "w", encoding='utf-8') as out:
        with open(info[0], 'r', encoding='utf-8') as src:
            out.write(src.read())
