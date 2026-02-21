$maps = @{
    "hashimaki"     = "e:\TouhouBazaar\assets\ui\dishes\hashimaki.png"
    "napolitan"     = "e:\TouhouBazaar\assets\ui\dishes\napolitan.png"
    "cabbage_roll"  = "e:\TouhouBazaar\assets\ui\dishes\cabbage_roll.png"
    "ratatouille"   = "e:\TouhouBazaar\assets\ui\dishes\ratatouille.png"
    "pot_au_feu"    = "e:\TouhouBazaar\assets\ui\dishes\pot_au_feu.png"
    "chateaubriand" = "e:\TouhouBazaar\assets\ui\dishes\chateaubriand.png"
}

$srcDir = "C:\Users\R\.gemini\antigravity\brain\5a27334b-aa07-48e7-b3f3-1a7dbf03bbe9"
$files = Get-ChildItem $srcDir -Filter "*.png"

foreach ($k in $maps.Keys) {
    $f = $files | Where-Object { $_.Name -match "^$k`_\d+\.png$" } | Select-Object -First 1
    if ($f) {
        $dst = $maps[$k]
        Write-Host "Processing $k -> $dst"
        magick $f.FullName -fuzz 10% -transparent "#00FF00" -trim +repage $dst
    }
}
