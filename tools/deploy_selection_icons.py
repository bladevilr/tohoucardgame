from PIL import Image
import os

# Source: Brain directory
source_dir = r"C:\Users\R\.gemini\antigravity\brain\4c7942db-1494-46c1-b4f7-ece01fd1a3f8"
target_dir = r"e:\TouhouBazaar\assets\events"

if not os.path.exists(target_dir):
    os.makedirs(target_dir)

# Map: Partial filename in brain -> Target filename in assets
assets = {
    "mystia_icon": "mystia.png",
    "marisa_icon": "marisa.png",
    "sakuya_icon": "sakuya.png"
}

def find_latest(pattern):
    files = [f for f in os.listdir(source_dir) if pattern in f and f.endswith(".png")]
    if not files: return None
    files.sort()
    return os.path.join(source_dir, files[-1])

def process_and_save(src, dest):
    print(f"Processing {src} -> {dest}")
    img = Image.open(src).convert("RGBA")
    data = img.getdata()
    new_data = []
    
    # Chroma key Green (#00FF00)
    for item in data:
        # (R, G, B, A)
        # Green is high G, low R, low B
        if item[1] > 200 and item[0] < 100 and item[2] < 100:
            new_data.append((0, 0, 0, 0)) # Transparent
        else:
            new_data.append(item)
            
    img.putdata(new_data)
    img.save(dest, "PNG")

for pattern, target_name in assets.items():
    src = find_latest(pattern)
    if src:
        dest = os.path.join(target_dir, target_name)
        process_and_save(src, dest)
    else:
        print(f"Missing source for {target_name}")
