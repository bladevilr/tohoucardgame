from PIL import Image
import colorsys, os

frames_dir = r"e:\TouhouBazaar\assets\ui\cards"
targets = [
    "card_frame_common.png",
    "card_frame_rare.png",
    "card_frame_epic.png",
    "card_frame_legendary.png",
]

for fname in targets:
    fpath = os.path.join(frames_dir, fname)
    if not os.path.exists(fpath):
        print(f"SKIP: {fname} not found")
        continue
    
    print(f"Processing {fname}...")
    img = Image.open(fpath).convert("RGBA")
    px = img.load()
    w, h = img.size
    
    changed = 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            rf, gf, bf = r/255.0, g/255.0, b/255.0
            hue, sat, val = colorsys.rgb_to_hsv(rf, gf, bf)
            hue_deg = hue * 360
            
            # Green screen: hue 80-160, sat > 0.3
            if 80 < hue_deg < 160 and sat > 0.3:
                if 100 < hue_deg < 140 and sat > 0.6:
                    px[x, y] = (0, 0, 0, 0)
                    changed += 1
                else:
                    green_strength = min(1.0, sat * 1.5)
                    new_alpha = int(a * (1.0 - green_strength * 0.8))
                    new_g = int(g * 0.5)
                    px[x, y] = (r, new_g, b, new_alpha)
                    changed += 1
    
    img.save(fpath, "PNG")
    print(f"  Done: {changed} pixels modified ({w}x{h})")

print("All frames processed!")
