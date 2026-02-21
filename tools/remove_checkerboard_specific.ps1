$files = @(
    "e:\TouhouBazaar\assets\ui\ingredients\mirin.png",
    "e:\TouhouBazaar\assets\ui\ingredients\butter.png",
    "e:\TouhouBazaar\assets\ui\ingredients\sugar.png"
)

foreach ($f in $files) {
    if (Test-Path $f) {
        Write-Host "Backing up and processing $f..."
        Copy-Item $f "$f.bak" -Force
        # Remove white, light grey (e6), slightly darker grey (cc)
        # Assuming standard checkerboard colors
        magick $f -fuzz 15% -transparent white -transparent "#e6e6e6" -transparent "#cccccc" -transparent "#d4d4d4" -trim +repage $f
    }
    else {
        Write-Host "File not found: $f"
    }
}
Write-Host "Done."
