from PIL import Image
import colorsys, os, glob

src_dir = r"C:\Users\R\.gemini\antigravity\brain\4c7942db-1494-46c1-b4f7-ece01fd1a3f8"
dst_dir = r"e:\TouhouBazaar\assets\ui\chefs"
os.makedirs(dst_dir, exist_ok=True)

# Add nitori to list
targets = ["nitori_green"]

for pattern in targets:
    files = glob.glob(os.path.join(src_dir, pattern + "*.png"))
    if not files:
        print(f"Skipping {pattern}, not found")
        continue
    
    # Take the latest one
    files.sort(key=os.path.getmtime)
    src_file = files[-1]
    dst_name = pattern.replace("_green", "") + ".png"
    dst_path = os.path.join(dst_dir, dst_name)
    
    print(f"Processing {src_file} -> {dst_path}")
    
    img = Image.open(src_file).convert("RGBA")
    px = img.load()
    w, h = img.size

    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            rf, gf, bf = r/255.0, g/255.0, b/255.0
            hue, sat, val = colorsys.rgb_to_hsv(rf, gf, bf)
            hue_deg = hue * 360

            # Green removal (Hue 80-160, Sat > 0.3)
            if 80 < hue_deg < 160 and sat > 0.3:
                green_strength = min(1.0, sat * 1.5)
                if 100 < hue_deg < 140 and sat > 0.6:
                     px[x, y] = (0, 0, 0, 0)
                else:
                     new_alpha = int(a * (1.0 - green_strength * 0.8))
                     new_g = int(g * 0.5)
                     px[x, y] = (r, new_g, b, new_alpha)

    img.save(dst_path, "PNG")
    print(f"Saved {dst_path}")
