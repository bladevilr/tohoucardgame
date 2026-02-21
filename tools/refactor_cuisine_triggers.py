import os
import re

CUISINES_DIR = r"e:\TouhouBazaar\data\cuisines"

def get_new_mechanic(dish_id, tags, tier, size, cooldown):
    mech = "none"
    if "fried" in tags or "meat" in tags or "grilled" in tags:
        if size >= 2: mech = "greasy"
        else: mech = "sizzling"
    elif "raw" in tags or "seafood" in tags or "soup" in tags:
        mech = "umami"
    elif "vegetable" in tags or "light" in tags or "sweet" in tags:
        if cooldown <= 3.0: mech = "crisp"
        else: mech = "refreshing"
    elif "spicy" in tags or "numbing" in tags or "curry" in tags or "strong" in tags:
        mech = "addictive"
    elif "fermented" in tags or "pickled" in tags:
        mech = "fermented"
    else:
        if cooldown <= 3.0: mech = "appetizing"
        elif size >= 2: mech = "umami"
        else: mech = "refreshing"

    trigger_str = '[]'
    desc_addon = ""
    
    if mech == "appetizing":
        trigger_str = '[\n\t\t\t\t{"event": "item_activated", "condition": "self", "effect": {"reduce_cooldown_adjacent": 1.0}}\n\t\t\t]'
        desc_addon = " [开胃引擎：每次激活使相邻菜品CD减少1秒]"
    elif mech == "addictive":
        val = 1 if tier == 0 else 2
        trigger_str = f'[\n\t\t\t\t{{"event": "item_activated", "condition": "self", "effect": {{"add_keyword": "addictive", "keyword_stacks": {val}}}}}\n\t\t\t]'
        desc_addon = f" [剧毒上瘾：每次激活给评委叠加 {val} 层永不衰减的上瘾分]"
    elif mech == "umami":
        mult = 1.3 if tier == 0 else (1.5 if tier == 1 else 2.0)
        trigger_str = f'[\n\t\t\t\t{{"event": "item_activated", "condition": "self", "effect": {{"flavor_mult": {mult}}}}}\n\t\t\t]'
        desc_addon = f" [提鲜催化：每次激活使当前得分 × {mult}]"
    elif mech == "sizzling":
        burst = 30 if tier == 0 else (80 if tier == 1 else 150)
        trigger_str = f'[\n\t\t\t\t{{"event": "item_activated", "condition": "self", "effect": {{"accumulate": {{"counter_id": "sizzle_{dish_id}", "increment": 1, "threshold": 3, "reset_counter": true, "on_threshold": {{"flavor": {burst}}}}}}}}}\n\t\t\t]'
        desc_addon = f" [猛火爆香：每激活3次，产生一次 {burst} 分的巨大爆分]"
    elif mech == "crisp":
        chance = 0.2 if tier == 0 else 0.4
        trigger_str = f'[\n\t\t\t\t{{"event": "item_activated", "condition": "self", "effect": {{"random_chance": {chance}, "on_success": {{"flavor_mult": 2.0}}}}}}\n\t\t\t]'
        desc_addon = f" [爽脆连击：有 {chance*100:.0f}% 的概率触发双倍计分]"
    elif mech == "refreshing":
        trigger_str = '[\n\t\t\t\t{"event": "item_activated", "condition": "self", "effect": {"clear_environment": "greasy", "clear_amount": 2, "bonus_on_clear": {"type": "stat_bonus", "flavor": 15}}}\n\t\t\t]'
        desc_addon = " [解腻清口：每次激活消除最多2层油腻减速，若成功消除则额外获得15风味]"
    elif mech == "greasy":
        trigger_str = '[\n\t\t\t\t{"event": "item_activated", "condition": "self", "effect": {"add_environment": "greasy", "environment_stacks": 1}}\n\t\t\t]'
        desc_addon = " [满腹油腻：每次激活给全场施加1层油腻（使所有菜品冷却速度变慢），需要清口类菜品配合]"
    elif mech == "fermented":
        trigger_str = '[\n\t\t\t\t{"event": "item_activated", "condition": "self", "effect": {"first_activate_bonus": {"flavor": 50}}}\n\t\t\t]'
        desc_addon = " [百年发酵：在每场对局中第一次激活时，瞬间爆出50点成熟风味]"

    return trigger_str, desc_addon

def process_file(filepath):
    print(f"Processing {filepath}...")
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We will regex split the file into chunks. 
    # A chunk is everything between `{` and `}` that looks like a dish dict.
    # regex for dish chunk: r'\{\s*"id":\s*"[^"]+".*?^\s*\}' with re.DOTALL and re.MULTILINE
    # This is safe because GDScript arrays are enclosed in [] and dictionaries in {}
    
    def replacer(match):
        chunk = match.group(0)
        
        # Extract properties
        dish_id = re.search(r'"id":\s*"([^"]+)"', chunk).group(1)
        
        tags = []
        tags_match = re.search(r'"tags":\s*\[(.*?)\]', chunk, re.DOTALL)
        if tags_match:
            tags = [t.strip().strip('"').strip("'") for t in tags_match.group(1).split(',')]
            
        tier = 0
        tier_match = re.search(r'"tier":\s*(\d+)', chunk)
        if tier_match: tier = int(tier_match.group(1))
            
        size = 1
        size_match = re.search(r'"size":\s*(\d+)', chunk)
        if size_match: size = int(size_match.group(1))
            
        cooldown = 3.0
        cd_match = re.search(r'"cooldown":\s*([\d\.]+)', chunk)
        if cd_match: cooldown = float(cd_match.group(1))
        
        new_triggers, desc_addon = get_new_mechanic(dish_id, tags, tier, size, cooldown)
        
        # Replace triggers block 
        # Replace from "triggers": [ ... ] to the NEXT property or end
        chunk = re.sub(r'"triggers":\s*\[.*?\],\s*(?="on_activate"|"description")', f'"triggers": {new_triggers},\n\t\t\t', chunk, flags=re.DOTALL)
        
        # Replace description
        # description ends with a quote, then (optional ,) and \n or }
        chunk = re.sub(r'("description":\s*".*?)("\s*,?\s*?\n?\s*?\})', f'\\1{desc_addon}\\2', chunk, flags=re.DOTALL)
        
        return chunk

    # Regex matches { containing "id": "..." and ending in } where } is on its own line or with comma
    new_content = re.sub(r'\{\s*"id":\s*"[^"]+".*?\n\s*\},?', replacer, content, flags=re.DOTALL | re.MULTILINE)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)

for root, _, files in os.walk(CUISINES_DIR):
    for f in files:
        if f.endswith(".gd"):
            process_file(os.path.join(root, f))

print("DONE")
