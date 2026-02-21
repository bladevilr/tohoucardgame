from PIL import Image, ImageDraw
import random
import os

# Target: e:\TouhouBazaar\assets\ui\cards\card_base.png
# Size: 480x720 (High res for scaling)
W, H = 480, 720

# Warm wood brown base
BASE_COLOR = (140, 100, 70) 

img = Image.new("RGB", (W, H), BASE_COLOR)
pixels = img.load()

# Add simple noise/grain for wood texture
for y in range(H):
    for x in range(W):
        # Noise variation
        noise = random.randint(-15, 15)
        r = max(0, min(255, BASE_COLOR[0] + noise))
        g = max(0, min(255, BASE_COLOR[1] + noise))
        b = max(0, min(255, BASE_COLOR[2] + noise))
        
        # Vertical streak (wood grain)
        if random.random() < 0.05:
            streak = random.randint(-10, 10)
            r = max(0, min(255, r - 10))
            g = max(0, min(255, g - 10))
            b = max(0, min(255, b - 10))
            
        pixels[x, y] = (r, g, b)

# Add a faint inner shadow/border (just darker edges, 2px) for depth
draw = ImageDraw.Draw(img)
draw.rectangle([0, 0, W-1, H-1], outline=(80, 50, 30), width=2)

output_path = r"e:\TouhouBazaar\assets\ui\cards\card_base.png"
img.save(output_path)
print(f"Generated clean wood base at {output_path}")
