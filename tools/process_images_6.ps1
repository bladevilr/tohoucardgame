$maps = @{
    "void_essence"     = "e:\TouhouBazaar\assets\ui\ingredients\void_essence.png"
    "lunar_dew"        = "e:\TouhouBazaar\assets\ui\ingredients\lunar_dew.png"
    "hourai_elixir"    = "e:\TouhouBazaar\assets\ui\ingredients\hourai_elixir.png"
    "yatagarasu_flame" = "e:\TouhouBazaar\assets\ui\ingredients\yatagarasu_flame.png"
}

$srcDir = "C:\Users\R\.gemini\antigravity\brain\5a27334b-aa07-48e7-b3f3-1a7dbf03bbe9"
$files = Get-ChildItem $srcDir -Filter "*.png"

foreach ($k in $maps.Keys) {
    if ((Test-Path $maps[$k])) { continue }
    $f = $files | Where-Object { $_.Name -match "^$k`_\d+\.png$" } | Select-Object -First 1
    if ($f) {
        $dst = $maps[$k]
        Write-Host "Processing $k -> $dst"
        magick $f.FullName -fuzz 10% -transparent "#00FF00" -trim +repage $dst
    }
}
