$maps = @{
    "mirin"       = "e:\TouhouBazaar\assets\ui\ingredients\mirin.png"
    "sugar"       = "e:\TouhouBazaar\assets\ui\ingredients\sugar.png"
    "butter"      = "e:\TouhouBazaar\assets\ui\ingredients\butter.png"
    "donabe"      = "e:\TouhouBazaar\assets\ui\tools\donabe.png"
    "yakitori"    = "e:\TouhouBazaar\assets\ui\dishes\yakitori.png"
    "corn_potage" = "e:\TouhouBazaar\assets\ui\dishes\corn_potage.png"
    "omurice"     = "e:\TouhouBazaar\assets\ui\dishes\omurice.png"
    "beef_stew"   = "e:\TouhouBazaar\assets\ui\dishes\beef_stew.png"
    "scotch_egg"  = "e:\TouhouBazaar\assets\ui\dishes\scotch_egg.png"
}

$srcDir = "C:\Users\R\.gemini\antigravity\brain\5a27334b-aa07-48e7-b3f3-1a7dbf03bbe9"
$files = Get-ChildItem $srcDir -Filter "*.png"

foreach ($k in $maps.Keys) {
    # Match the specific keys precisely since some keys might be substrings of others, but ours are distinct enough
    $f = $files | Where-Object { $_.Name -match "^$k`_\d+\.png$" } | Select-Object -First 1
    if ($f) {
        $dst = $maps[$k]
        $dirDst = Split-Path $dst
        if (!(Test-Path $dirDst)) { New-Item -ItemType Directory -Force -Path $dirDst }
        Write-Host "Processing $k -> $dst"
        # use magick to remove pure green background
        magick $f.FullName -fuzz 10% -transparent "#00FF00" -trim +repage $dst
    }
}
