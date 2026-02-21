$maps = @{
    "yakitori"    = "e:\TouhouBazaar\assets\ui\dishes\yakitori.png"
    "corn_potage" = "e:\TouhouBazaar\assets\ui\dishes\corn_potage.png"
    "beef_stew"   = "e:\TouhouBazaar\assets\ui\dishes\beef_stew.png"
    "scotch_egg"  = "e:\TouhouBazaar\assets\ui\dishes\scotch_egg.png"
}

$srcDir = "C:\Users\R\.gemini\antigravity\brain\5a27334b-aa07-48e7-b3f3-1a7dbf03bbe9"
$files = Get-ChildItem $srcDir -Filter "*.png"

foreach ($k in $maps.Keys) {
    # Match the specific keys precisely and only take ones recent to our second pass (or we just take the newest one)
    # The generated images have timestamps.
    $f = $files | Where-Object { $_.Name -match "^$k`_\d+\.png$" } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($f) {
        $img = New-Object -ComObject WIA.ImageFile
        try {
            # Ensure it actually exists to avoid lock issues? Let Magick do its job.
            $dst = $maps[$k]
            Write-Host "Processing $k -> $dst"
            magick $f.FullName -fuzz 10% -transparent "#00FF00" -trim +repage $dst
        }
        catch {}
    }
}
