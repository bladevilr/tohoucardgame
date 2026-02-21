from PIL import Image, ImageDraw
import os

cards_dir = r"e:\TouhouBazaar\assets\ui\cards"

# Target card size (3:4 ratio, high enough res for quality)
CARD_W = 480
CARD_H = 720

# Parchment colors per rarity
parchment_colors = {
    "common":    (245, 235, 220),    # Warm cream
    "rare":      (235, 230, 225),    # Cool parchment
    "epic":      (35, 30, 28),       # Dark (for black lacquer)
    "legendary": (250, 240, 225),    # Rich cream
}

for rarity, bg_color in parchment_colors.items():
    frame_path = os.path.join(cards_dir, f"card_frame_{rarity}.png")
    output_path = os.path.join(cards_dir, f"card_base_{rarity}.png")
    
    # Create base image with parchment color
    base = Image.new("RGBA", (CARD_W, CARD_H), bg_color + (255,))
    
    if os.path.exists(frame_path):
        # Load frame (transparent center, opaque border)
        frame = Image.open(frame_path).convert("RGBA")
        # Resize frame to exactly match card size
        frame_resized = frame.resize((CARD_W, CARD_H), Image.LANCZOS)
        # Composite: parchment bg + frame on top
        base = Image.alpha_composite(base, frame_resized)
        print(f"Created {rarity}: parchment {bg_color} + frame overlay -> {output_path}")
    else:
        # No frame file, just add a simple border
        draw = ImageDraw.Draw(base)
        border = 8
        # Brown border
        for i in range(border):
            draw.rectangle([i, i, CARD_W-1-i, CARD_H-1-i], outline=(120, 90, 60, 255))
        print(f"Created {rarity}: parchment {bg_color} + code border (no frame file) -> {output_path}")
    
    # Save as opaque PNG
    base.save(output_path, "PNG")

print("\nAll card bases created!")
print("Files:")
for r in parchment_colors:
    p = os.path.join(cards_dir, f"card_base_{r}.png")
    if os.path.exists(p):
        print(f"  card_base_{r}.png ({os.path.getsize(p) // 1024} KB)")
