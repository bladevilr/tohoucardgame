$dir = "e:\TouhouBazaar\assets\ui\dishes"
$files = Get-ChildItem -Path $dir -Filter "*.png"
$brokenCount = 0

foreach ($f in $files) {
    if ($f.Length -lt 800000) {
        Write-Host "FOUND SMALL FILE: $($f.Name) ($($f.Length) bytes)"
        $brokenCount++
    }
}

if ($brokenCount -eq 0) {
    Write-Host "SUCCESS: No broken/small files found!"
}
else {
    Write-Host "WARNING: Found $brokenCount small files."
}
