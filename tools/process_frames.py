from PIL import Image, ImageDraw
import os

# Directory containing the images
directory = r"e:\TouhouBazaar\assets\ui\cards"
files = [
    "card_frame_common.png",
    "card_frame_rare.png",
    "card_frame_epic.png",
    "card_frame_legendary.png"
]

def process_image(filename):
    path = os.path.join(directory, filename)
    if not os.path.exists(path):
        print(f"File not found: {path} - Skipping")
        return

    print(f"Processing {filename}...")
    img = Image.open(path).convert("RGBA")
    
    # Use ImageDraw.floodfill
    # Tolerance is 50 to catch compression artifacts
    # Replace white/grey center with transparent
    center = (img.width // 2, img.height // 2)
    # Check if center is white-ish
    r,g,b,a = img.getpixel(center)
    if r > 200 and g > 200 and b > 200:
        print(f"  Flood filling center {center} (Color: {r},{g},{b})...")
        ImageDraw.floodfill(img, center, (0, 0, 0, 0), thresh=50)
    else:
        print(f"  Center pixel {r},{g},{b} not white-ish. Skipping center fill.")

    # Flood fill corners (black)
    corners = [(0, 0), (img.width-1, 0), (0, img.height-1), (img.width-1, img.height-1)]
    for c in corners:
        r,g,b,a = img.getpixel(c)
        if r < 50 and g < 50 and b < 50:
             print(f"  Flood filling corner {c} (Color: {r},{g},{b})...")
             ImageDraw.floodfill(img, c, (0, 0, 0, 0), thresh=50)

    img.save(path, "PNG")
    print(f"Saved {filename}")

for f in files:
    try:
        process_image(f)
    except Exception as e:
        print(f"Error: {e}")
