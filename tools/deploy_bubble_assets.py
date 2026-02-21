from PIL import Image, ImageDraw
import os
import shutil

source_dir = r"C:\Users\R\.gemini\antigravity\brain\4c7942db-1494-46c1-b4f7-ece01fd1a3f8"
target_merchants = r"e:\TouhouBazaar\assets\merchants"
target_ui = r"e:\TouhouBazaar\assets\ui\bubble"

# Ensure dirs exist
for d in [target_merchants, target_ui]:
    if not os.path.exists(d):
        os.makedirs(d)

# Map: simple name -> destination dir
data = [
    ("merchant_mystia", "mystia.png", target_merchants, "white"),
    ("merchant_marisa", "marisa.png", target_merchants, "white"),
    ("merchant_sakuya", "sakuya.png", target_merchants, "white"),
    ("bubble_frame", "bubble_frame.png", target_ui, "center")
]

def find_latest(pattern):
    # Find file starting with pattern
    files = [f for f in os.listdir(source_dir) if f.startswith(pattern)]
    if not files: return None
    files.sort()
    return os.path.join(source_dir, files[-1])

def process_white_bg(img):
    # Remove white background
    img = img.convert("RGBA")
    new_data = []
    for item in img.getdata():
        # Check for white (R,G,B > 240)
        if item[0] > 240 and item[1] > 240 and item[2] > 240:
            new_data.append((255, 255, 255, 0)) # Transparent
        else:
            new_data.append(item)
    img.putdata(new_data)
    return img

def process_bubble_center(img):
    # Remove center of bubble frame
    img = img.convert("RGBA")
    width, height = img.size
    # Flood fill transparent from center
    center = (width // 2, height // 2)
    ImageDraw.floodfill(img, center, (0, 0, 0, 0), thresh=50)
    
    # Also remove pure green from outside if present (from prompt #00FF00)
    # Check corners
    corners = [(0, 0), (width-1, 0), (0, height-1), (width-1, height-1)]
    for c in corners:
        r,g,b,a = img.getpixel(c)
        # If corner is green or black/dark, flood fill
        if (g > 200 and r < 100) or (r<50 and g<50 and b<50):
             ImageDraw.floodfill(img, c, (0, 0, 0, 0), thresh=50)
             
    return img

for pattern, filename, dest_dir, mode in data:
    src = find_latest(pattern)
    if not src:
        print(f"Docs not found for {pattern}")
        continue
        
    print(f"Processing {src}...")
    try:
        img = Image.open(src)
        if mode == "white":
            img = process_white_bg(img)
        elif mode == "center":
            img = process_bubble_center(img)
            
        dest_path = os.path.join(dest_dir, filename)
        img.save(dest_path, "PNG")
        print(f"Saved to {dest_path}")
    except Exception as e:
        print(f"Error processing {pattern}: {e}")
