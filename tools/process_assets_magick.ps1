
$files = @(
    @{"in" = "e:\TouhouBazaar\assets\ui\theme\button_green.png"; "out" = "e:\TouhouBazaar\assets\ui\theme\button_normal.png"; "fuzz" = "20%" },
    @{"in" = "e:\TouhouBazaar\assets\ui\theme\panel_green.png"; "out" = "e:\TouhouBazaar\assets\ui\theme\panel_bg.png"; "fuzz" = "20%" },
    @{"in" = "e:\TouhouBazaar\assets\ui\cards\frame_green.png"; "out" = "e:\TouhouBazaar\assets\ui\cards\card_frame.png"; "fuzz" = "30%" },
    @{"in" = "C:\Users\R\.gemini\antigravity\brain\2a92c8cd-6c7e-4628-82ae-a2f037d30739\yuyuko_clean_1771306513117.png"; "out" = "e:\TouhouBazaar\assets\ui\judges\yuyuko.png"; "fuzz" = "15%" },
    @{"in" = "C:\Users\R\.gemini\antigravity\brain\2a92c8cd-6c7e-4628-82ae-a2f037d30739\remilia_clean_1771306527342.png"; "out" = "e:\TouhouBazaar\assets\ui\judges\remilia.png"; "fuzz" = "15%" }
)

foreach ($item in $files) {
    if (Test-Path $item.in) {
        Write-Host "Processing $($item.in) -> $($item.out)..."
        # 1. Convert to PNG just in case
        # 2. Flood fill transparency from top-left (0,0) with green
        # Note: We use -fill none -draw "color 0,0 floodfill" to remove the green background connected to the corner
        # Using pure green from prompt is safer. 
        # But `magick` requires specifying the target color. We can pick pixel at 0,0.
        
        # We use a simpler approach: -transparent to replace specific color, with fuzz.
        # But floodfill is safer for internal parts.
        
        # Command: magick input -fuzz X% -fill none -draw "alpha 0,0 floodfill" output
        # Wait, alpha floodfill syntax: -fill none -draw "matte 0,0 floodfill" (older) or -alpha set -channel RGBA -fill none -floodfill +0+0 green (newer)
        
        # Let's use reliable: -fuzz XX% -transparent "rgb(0,255,0)" if the prompt worked perfectly.
        # But the prompt said "pure green". Let's assume it is close to green.
        # We will pick the color from 0,0 to be safe.
        
        # Get color at 0,0
        $color = magick $item.in -format "%[pixel:p{0,0}]\n" info:
        Write-Host "Detected background color: $color"
        
        # Process
        magick $item.in -fuzz $item.fuzz -transparent "$color" -define png:color-type=6 $item.out
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Success."
        }
        else {
            Write-Host "Failed."
        }
    }
    else {
        Write-Host "Input not found: $($item.in)"
    }
}
