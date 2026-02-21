$maps = @{
    "yakitori"      = "e:\TouhouBazaar\assets\ui\dishes\yakitori.png"
    "hashimaki"     = "e:\TouhouBazaar\assets\ui\dishes\hashimaki.png"
    "corn_potage"   = "e:\TouhouBazaar\assets\ui\dishes\corn_potage.png"
    "omurice"       = "e:\TouhouBazaar\assets\ui\dishes\omurice.png"
    "beef_stew"     = "e:\TouhouBazaar\assets\ui\dishes\beef_stew.png"
    "scotch_egg"    = "e:\TouhouBazaar\assets\ui\dishes\scotch_egg.png"
    "napolitan"     = "e:\TouhouBazaar\assets\ui\dishes\napolitan.png"
    "cabbage_roll"  = "e:\TouhouBazaar\assets\ui\dishes\cabbage_roll.png"
    "ratatouille"   = "e:\TouhouBazaar\assets\ui\dishes\ratatouille.png"
    "pot_au_feu"    = "e:\TouhouBazaar\assets\ui\dishes\pot_au_feu.png"
    "chateaubriand" = "e:\TouhouBazaar\assets\ui\dishes\chateaubriand.png"
}

$srcDir = "C:\Users\R\.gemini\antigravity\brain\5a27334b-aa07-48e7-b3f3-1a7dbf03bbe9"
$files = Get-ChildItem $srcDir -Filter "*.png"

foreach ($k in $maps.Keys) {
    # Look for the "_v2_" files we just successfully generated
    $f = $files | Where-Object { $_.Name -match "^$k`_v2_\d+\.png$" } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($f) {
        $dst = $maps[$k]
        Write-Host "Copying $k -> $dst"
        Copy-Item $f.FullName -Destination $dst -Force
    }
}
