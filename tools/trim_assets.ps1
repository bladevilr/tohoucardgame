
$files = @(
    "e:\TouhouBazaar\assets\ui\theme\button_normal.png",
    "e:\TouhouBazaar\assets\ui\theme\panel_bg.png",
    "e:\TouhouBazaar\assets\ui\cards\card_frame.png"
)

foreach ($f in $files) {
    if (Test-Path $f) {
        Write-Host "Trimming $f..."
        # -trim removes transparent border
        # +repage resets the canvas offset (important for game engines)
        magick $f -trim +repage $f
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Success."
        }
        else {
            Write-Host "Failed."
        }
    }
}
