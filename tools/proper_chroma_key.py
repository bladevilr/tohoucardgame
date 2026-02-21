from PIL import Image
import colorsys, os

src = r"C:\Users\R\.gemini\antigravity\brain\4c7942db-1494-46c1-b4f7-ece01fd1a3f8\uploaded_media_1771486799115.png"
dst = r"e:\TouhouBazaar\assets\ui\bubble\bubble_frame.png"
os.makedirs(os.path.dirname(dst), exist_ok=True)

img = Image.open(src).convert("RGBA")
px = img.load()
w, h = img.size

for y in range(h):
    for x in range(w):
        r, g, b, a = px[x, y]
        rf, gf, bf = r/255.0, g/255.0, b/255.0
        hue, sat, val = colorsys.rgb_to_hsv(rf, gf, bf)
        hue_deg = hue * 360

        # 绿色：色相 80-160, 饱和度 > 0.3
        if 80 < hue_deg < 160 and sat > 0.3:
            px[x, y] = (0, 0, 0, 0)

img.save(dst, "PNG")
print(f"Done! {w}x{h}, saved to {dst}")
