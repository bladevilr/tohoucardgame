import os
import re

cuisines = ['Washoku.gd', 'Chuuka.gd', 'Youshoku.gd', 'Kanmi.gd', 'Seafood.gd']
base_dir = r'e:\TouhouBazaar\data\cuisines'

for c in cuisines:
    path = os.path.join(base_dir, c)
    if not os.path.exists(path):
        continue
        
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Strip the DBG additions from the description
    # They look like: " [开胃引擎：每次激活使相邻菜品CD减少1秒]"
    content = re.sub(r' \[[^\]]*?引擎[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?上瘾[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?提鲜[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?爆香[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?爽脆[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?清口[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?发酵[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?油腻[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?时速开胃[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?极其浓郁的脂肪[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?时间凝固的风味[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?猛火爆香[^\]]*?\]', '', content)
    content = re.sub(r' \[[^\]]*?清脆连击[^\]]*?\]', '', content)
    
    # 2. Reset the triggers array to empty. 
    # Example to replace: "triggers": [{...}, {...}] to "triggers": []
    # This must be done carefully to not break the dictionary.
    
    # It replaces "triggers": [ followed by anything up to the matching ] 
    content = re.sub(r'\"triggers\":\s*\[[^\]]*\]', '"triggers": []', content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print(f"Reverted {c}")
