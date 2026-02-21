$file = "e:\TouhouBazaar\assets\ui\ingredients\sugar.png"
$backup = "e:\TouhouBazaar\assets\ui\ingredients\sugar_backup.png"
Copy-Item $file $backup

Write-Host "Testing transparency removal on sugar.png..."
# Attempt 1: Floodfill from top-left corner with high fuzz
# We trim the result to remove excess empty space
magick $file -fuzz 20% -fill none -draw "color 0,0 floodfill" -trim +repage "e:\TouhouBazaar\assets\ui\ingredients\sugar_test.png"

Write-Host "Done. Check sugar_test.png"
