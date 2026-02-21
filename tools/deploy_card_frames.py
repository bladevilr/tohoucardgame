from PIL import Image
import colorsys, os

src_dir = r"C:\Users\R\.gemini\antigravity\brain\4c7942db-1494-46c1-b4f7-ece01fd1a3f8"
dst_dir = r"e:\TouhouBazaar\assets\ui\cards"
os.makedirs(dst_dir, exist_ok=True)

# Map: bamboo=common, parchment+silver=rare, black lacquer+gold=epic, red+gold+gems=legendary
frames = {
    "card_frame_common.png":    "uploaded_media_0_1771495997940.jpg",  # Bamboo
    "card_frame_epic.png":      "uploaded_media_1_1771495997940.jpg",  # Black lacquer + gold
    "card_frame_legendary.png": "uploaded_media_2_1771495997940.jpg",  # Red + gold + green gems
    "card_frame_rare.png":      "uploaded_media_3_1771495997940.jpg",  # Parchment + silver
}

for dst_name, src_name in frames.items():
    src_path = os.path.join(src_dir, src_name)
    dst_path = os.path.join(dst_dir, dst_name)
    
    if not os.path.exists(src_path):
        print(f"SKIP: {src_name} not found")
        continue
    
    print(f"Processing {src_name} -> {dst_name}")
    img = Image.open(src_path).convert("RGBA")
    px = img.load()
    w, h = img.size
    
    # These images have a muted/olive green background, not pure #00FF00
    # Need broader green detection
    changed = 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            rf, gf, bf = r/255.0, g/255.0, b/255.0
            hue, sat, val = colorsys.rgb_to_hsv(rf, gf, bf)
            hue_deg = hue * 360
            
            # Broader green detection for olive/muted greens
            # Hue 60-170, Sat > 0.15 (lower threshold for muted greens)
            is_green = False
            if 60 < hue_deg < 170:
                if sat > 0.2 and g > r and g > b * 0.8:
                    is_green = True
                # Pure green areas
                if sat > 0.4 and 80 < hue_deg < 150:
                    is_green = True
            
            if is_green:
                # Strong green = fully transparent
                if sat > 0.3 and 70 < hue_deg < 160:
                    px[x, y] = (0, 0, 0, 0)
                    changed += 1
                else:
                    # Edge blending
                    green_strength = min(1.0, sat * 2.0)
                    new_alpha = int(a * (1.0 - green_strength * 0.7))
                    new_g = int(g * 0.6)
                    px[x, y] = (r, new_g, b, max(0, new_alpha))
                    changed += 1
    
    img.save(dst_path, "PNG")
    print(f"  Done: {changed} pixels removed, {w}x{h}")

# Clean up .import files
import glob
for f in glob.glob(os.path.join(dst_dir, "*.import")):
    os.remove(f)
    print(f"  Removed cache: {os.path.basename(f)}")

print("\nAll frames processed and deployed!")
