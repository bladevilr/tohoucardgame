from PIL import Image, ImageDraw
import os
import shutil

# Source directory (brain)
source_dir = r"C:\Users\R\.gemini\antigravity\brain\4c7942db-1494-46c1-b4f7-ece01fd1a3f8"
# Target directory
target_dir = r"e:\TouhouBazaar\assets\events"

# Map source patterns to target filenames
# Note: filenames have timestamps, need to find latest
file_map = {
    "mystia_icon": "mystia.png",
    "marisa_icon": "marisa.png",
    "sakuya_icon": "sakuya.png",
    "bubble_bg": "bubble_bg.png"
}

def find_latest_file(pattern):
    # Search in source dir for files starting with pattern
    candidates = [f for f in os.listdir(source_dir) if f.startswith(pattern)]
    if not candidates:
        return None
    candidates.sort() # Timestamp sorting
    return candidates[-1]

def process_green_screen(src_path, dest_path):
    print(f"Processing {src_path} -> {dest_path}")
    img = Image.open(src_path).convert("RGBA")
    pixels = img.load()
    width, height = img.size
    
    # Chroma key: remove green (#00FF00)
    # Tolerance logic
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            # Green screen detection (High G, Low R/B)
            if g > 200 and r < 100 and b < 100:
                pixels[x, y] = (0, 0, 0, 0)
            # Edge cleanup (anti-aliasing)
            elif g > r + 50 and g > b + 50 and g > 100:
                pixels[x, y] = (0, 0, 0, 0)
    
    # For bubble_bg, we also want the CENTER to be transparent if it's white/green
    # But the prompt said "transparent center", usually DALL-E/Imagen fills it.
    # We'll assume the user wants the content *inside* the bubble, so the bubble image itself 
    # should be just the border + semi-transparent glow. 
    # If the center is opaque, we might need to clear it.
    # Let's inspect center pixel for bubble_bg specifically
    if "bubble_bg" in dest_path:
        center = (width // 2, height // 2)
        cr, cg, cb, ca = img.getpixel(center)
        # If center is solid color (not transparent), poke a hole
        if ca > 200:
             print("  Clearing center of bubble_bg...")
             ImageDraw.floodfill(img, center, (0, 0, 0, 0), thresh=50)

    img.save(dest_path, "PNG")

# Execution
if not os.path.exists(target_dir):
    os.makedirs(target_dir)

for pattern, target in file_map.items():
    src_file = find_latest_file(pattern)
    if src_file:
        src_path = os.path.join(source_dir, src_file)
        dest_path = os.path.join(target_dir, target)
        try:
            process_green_screen(src_path, dest_path)
            print(f"Successfully deployed {target}")
        except Exception as e:
            print(f"Error processing {target}: {e}")
    else:
        print(f"Source file for {pattern} not found (might be generation failure)")
