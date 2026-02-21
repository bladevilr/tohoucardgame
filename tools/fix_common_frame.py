from PIL import Image, ImageDraw
import os

# The common frame is 1024x1024 with a thick wood border.
# We need to make the CENTER transparent so card content shows through.
# The border is roughly 120-140px thick on each side.

fpath = r"e:\TouhouBazaar\assets\ui\cards\card_frame_common.png"
img = Image.open(fpath).convert("RGBA")
w, h = img.size
print(f"Image size: {w}x{h}")

# Create an alpha mask - start fully opaque, then clear the center
# Border thickness: approximately 13% of image width on each side
border_pct = 0.13
left = int(w * border_pct)
top = int(h * border_pct)
right = w - left
bottom = h - top

print(f"Clearing center: ({left},{top}) to ({right},{bottom})")

px = img.load()
for y in range(top, bottom):
    for x in range(left, right):
        px[x, y] = (0, 0, 0, 0)

# Feather the inner edge slightly for smoother transition
feather = 8
for y in range(top - feather, bottom + feather):
    for x in range(left - feather, right + feather):
        if x < 0 or x >= w or y < 0 or y >= h:
            continue
        # Check if we're in the feather zone (between border and center)
        dx = 0
        dy = 0
        if x < left:
            dx = left - x
        elif x >= right:
            dx = x - right + 1
        if y < top:
            dy = top - y
        elif y >= bottom:
            dy = y - bottom + 1
        
        if dx > 0 or dy > 0:
            dist = max(dx, dy)
            if dist <= feather:
                r, g, b, a = px[x, y]
                # Gradually reduce alpha near the inner edge
                factor = dist / feather  # 0 at edge, 1 at full border
                new_alpha = int(a * factor)
                px[x, y] = (r, g, b, new_alpha)

img.save(fpath, "PNG")
print(f"Done! Center cleared with {feather}px feather.")
