$dirs = @(
    "e:\TouhouBazaar\assets\ui\ingredients",
    "e:\TouhouBazaar\assets\ui\techniques",
    "e:\TouhouBazaar\assets\ui\tools"
)

foreach ($src in $dirs) {
    if (!(Test-Path $src)) { 
        Write-Host "Directory not found: $src"
        continue 
    }

    Write-Host "Scanning $src..."
    $backup = "$src\backup"
    if (!(Test-Path $backup)) { New-Item -ItemType Directory -Path $backup -Force }

    $files = Get-ChildItem $src -Filter "*.png"
    foreach ($f in $files) {
        # Skip backups, tests, and properly transparent files if we could detect them, 
        # but for now we rely on the backup existence to avoid double-processing if run multiple times?
        # No, magick is idempotent-ish if floodfill hits transparent pixels (it does nothing).
        
        if ($f.Name.EndsWith("_test.png") -or $f.Name.EndsWith("_backup.png")) { continue }
        
        $bfile = Join-Path $backup $f.Name
        # Only backup if not already backed up (preserves original)
        if (!(Test-Path $bfile)) { Copy-Item $f.FullName $bfile }
        
        Write-Host "Processing $($f.Name)..."
        # Fuzz 20% covers typical AI off-white backgrounds.
        # -trim removes the empty space after floodfill
        magick $f.FullName -fuzz 20% -fill none -draw "color 0,0 floodfill" -trim +repage $f.FullName
    }
}
Write-Host "All directories processed."
