$maps = @{
    "pot_au_feu" = "e:\TouhouBazaar\assets\ui\dishes\pot_au_feu.png"
}

$srcDir = "C:\Users\R\.gemini\antigravity\brain\5a27334b-aa07-48e7-b3f3-1a7dbf03bbe9"
$files = Get-ChildItem $srcDir -Filter "*.png"

foreach ($k in $maps.Keys) {
    # Match the specific keys precisely and only take ones recent to our second pass (or we just take the newest one)
    $f = $files | Where-Object { $_.Name -match "^$k`_\d+\.png$" } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($f) {
        $img = New-Object -ComObject WIA.ImageFile
        try {
            $dst = $maps[$k]
            Write-Host "Processing $k -> $dst"
            magick $f.FullName -fuzz 10% -transparent "#00FF00" -trim +repage $dst
        }
        catch {}
    }
}
