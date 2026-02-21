from PIL import Image
import os
import shutil

# Source directory (brain)
source_dir = r"C:\Users\R\.gemini\antigravity\brain\4c7942db-1494-46c1-b4f7-ece01fd1a3f8"
# Target directory
target_dir = r"e:\TouhouBazaar\assets\ui\cards"

# Map v2 files to target names
file_map = {
    "card_frame_common_v2_1771473289827.png": "card_frame_common.png",
    "card_frame_rare_v2_1771473304397.png": "card_frame_rare.png",
    "card_frame_epic_v2_1771473320577.png": "card_frame_epic.png",
    "card_frame_legendary_v2_1771473334638.png": "card_frame_legendary.png"
}
# Note: filenames have timestamps, need to find them strictly

def find_latest_file(pattern):
    # Simple search in source dir
    candidates = [f for f in os.listdir(source_dir) if f.startswith(pattern)]
    if not candidates:
        return None
    candidates.sort() # Timestamp should sort correctly
    return candidates[-1]

def process_green_screen(src_path, dest_path):
    print(f"Processing {src_path} -> {dest_path}")
    img = Image.open(src_path).convert("RGBA")
    pixels = img.load()
    width, height = img.size
    
    # Simple chroma key: remove pure green and nearby shades
    # Target green: 0, 255, 0
    # Tolerance: let's say distance < 100
    
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            # Check for green screen (bright green)
            # R low, B low, G high
            if g > 200 and r < 100 and b < 100:
                # Turn transparent
                 pixels[x, y] = (0, 0, 0, 0)
            # Edge cleanup (anti-aliasing fringing) - simplified
            elif g > r + 50 and g > b + 50 and g > 100:
                 # Semi-transparent or remove? Remove for safety
                 pixels[x, y] = (0, 0, 0, 0)

    img.save(dest_path, "PNG")

# Execution
base_names = ["card_frame_common_v2", "card_frame_rare_v2", "card_frame_epic_v2", "card_frame_legendary_v2"]
target_names = ["card_frame_common.png", "card_frame_rare.png", "card_frame_epic.png", "card_frame_legendary.png"]

for i in range(4):
    src_file = find_latest_file(base_names[i])
    if src_file:
        src_path = os.path.join(source_dir, src_file)
        dest_path = os.path.join(target_dir, target_names[i])
        try:
            process_green_screen(src_path, dest_path)
            print(f"Successfully processed {target_names[i]}")
        except Exception as e:
            print(f"Error processing {target_names[i]}: {e}")
    else:
        print(f"Could not find source for {base_names[i]}")
