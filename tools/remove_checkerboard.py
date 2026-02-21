from PIL import Image
import os, glob

# Configuration
TARGET_DIRS = [
    r"e:\TouhouBazaar\assets\ui\ingredients",
    r"e:\TouhouBazaar\assets\ui\tools",
    r"e:\TouhouBazaar\assets\ui\techniques"
]

def is_background(r, g, b, a):
    # Check if pixel is white, light gray, or transparent
    # Semantic transparency (checkerboard) usually alternates white and light gray
    # Common gray is around 204 (0xCC) or 192 (0xC0)
    # So we treat anything "bright and gray" as background
    if a == 0: return True
    if r > 180 and g > 180 and b > 180:
        # Check for low saturation (gray-ish)
        if max(r,g,b) - min(r,g,b) < 30:
            return True
    return False

def process_file(filepath):
    try:
        img = Image.open(filepath).convert("RGBA")
        width, height = img.size
        pixels = img.load()
        
        # Use a set for visited pixels to avoid infinite loops
        visited = set()
        stack = []
        
        # Start floodfill from all 4 corners
        corners = [(0, 0), (width-1, 0), (0, height-1), (width-1, height-1)]
        for x, y in corners:
            if is_background(*pixels[x, y]):
                stack.append((x, y))
                visited.add((x, y))
        
        changes = 0
        while stack:
            x, y = stack.pop()
            # Set to transparent
            pixels[x, y] = (0, 0, 0, 0)
            changes += 1
            
            # Check neighbors
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < width and 0 <= ny < height:
                    if (nx, ny) not in visited:
                        r, g, b, a = pixels[nx, ny]
                        if is_background(r, g, b, a):
                            stack.append((nx, ny))
                            visited.add((nx, ny))

        if changes > 0:
            print(f"Processed {os.path.basename(filepath)}: Removed {changes} pixels")
            img.save(filepath, "PNG")
        else:
            print(f"Skipped {os.path.basename(filepath)}: No background start found")

    except Exception as e:
        print(f"Error checking {filepath}: {e}")

if __name__ == "__main__":
    for d in TARGET_DIRS:
        if not os.path.exists(d):
            print(f"Directory not found: {d}")
            continue
            
        print(f"Scanning {d}...")
        files = glob.glob(os.path.join(d, "*.png"))
        for f in files:
            process_file(f)
    print("Done.")
