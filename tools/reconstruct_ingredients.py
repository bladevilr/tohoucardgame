import re
import json

md_path = r'e:\TouhouBazaar\docs\BattleSystem_CardEffect_FullTable.md'
out_path = r'e:\TouhouBazaar\data\IngredientDatabase.gd'

gdscript_header = """extends Node

var ingredients: Dictionary = {}

func _ready():
\t_init_ingredients()

func can_apply_to(ingredient: Dictionary, dish: Dictionary) -> bool:
\tvar dish_tags: Array = dish.get("tags", [])
\tfor req in ingredient.get("requires_tags", []):
\t\tif req not in dish_tags:
\t\t\treturn false
\tfor forbid in ingredient.get("forbidden_tags", []):
\t\tif forbid in dish_tags:
\t\t\treturn false
\treturn true

func get_ingredient(id: String) -> Dictionary:
\treturn ingredients.get(id, {})

func get_all() -> Array:
\treturn ingredients.values()

func get_by_tier(tier: int) -> Array:
\tvar result: Array = []
\tfor t in ingredients.values():
\t\tif int(t.tier) == tier:
\t\t\tresult.append(t)
\treturn result

func _add(id: String, display_name: String, tier: int, cost: int, stats: Dictionary, tags_mod: Dictionary, special_effect: String, cuisine: String):
\tingredients[id] = {
\t\t"id": id,
\t\t"name": display_name,
\t\t"tier": tier,
\t\t"cost": cost,
\t\t"item_type": "ingredient",
\t\t"stat_modifiers": stats,
\t\t"added_tags": tags_mod.get("add", []),
\t\t"removed_tags": tags_mod.get("remove", []),
\t\t"requires_tags": tags_mod.get("require", []),
\t\t"forbidden_tags": tags_mod.get("forbid", []),
\t\t"special_effect": special_effect,
\t\t"cuisine_affinity": cuisine,
\t\t"affinity_bonus": 1.5,
\t\t"description": _build_desc(stats, tags_mod, special_effect, cuisine)
\t}

func _build_desc(stats: Dictionary, tags: Dictionary, effect: String, cuisine: String) -> String:
\tvar d = ""
\tfor k in stats:
\t\td += "%s+%s " % [k.capitalize(), stats[k]]
\tif cuisine != "" and cuisine != "无":
\t\td += " | 对%s亲和" % cuisine
\treturn d

func _init_ingredients():
"""

with open(md_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

in_ingredients = False
gdscript_body = ""

for line in lines:
    if line.startswith('## 食材全量效果表'):
        in_ingredients = True
        continue
    if in_ingredients and line.startswith('## '):
        break # reached next section
        
    if in_ingredients and line.startswith('| 食材 |'):
        # Parse columns
        cols = [c.strip() for c in line.split('|')][1:-1]
        if len(cols) < 9: continue
        
        _, id_val, name, tier, cost, stats_str, tags_str, effect_str, cuisine = cols
        
        # tags logic: add=["rich"]; require=["light"]
        tags_mod = {}
        if tags_str and tags_str != '无':
            parts = tags_str.split(';')
            for p in parts:
                p = p.strip()
                if '=' in p:
                    k, v = p.split('=')
                    try:
                        tags_mod[k] = json.loads(v)
                    except:
                        tags_mod[k] = []
        
        # special effect mapping to ID
        special_effect = ""
        if '清除 1 层【油腻】' in effect_str: special_effect = "clear_greasy_1"
        if '添加 2 层【油腻】' in effect_str: special_effect = "add_env_greasy_2"
        if '各清 1 层' in effect_str: special_effect = "clear_all_env_1"
        if 'x2' in effect_str or '风味分数' in effect_str: special_effect = "double_next_activate"
        if '【秘方】' in effect_str: special_effect = "grant_secret_recipe"
        if '【焦香】' in effect_str: special_effect = "grant_char_aroma_3"
        
        cui = cuisine if cuisine != '无' else ''
        
        gdscript_body += f'\t_add("{id_val}", "{name}", {tier}, {cost}, {stats_str}, {json.dumps(tags_mod)}, "{special_effect}", "{cui}")\n'

with open(out_path, 'w', encoding='utf-8') as f:
    f.write(gdscript_header + gdscript_body)

print("Generated IngredientDatabase.gd successfully")
