$src = Get-ChildItem "C:\Users\R\.gemini\antigravity\brain\5a27334b-aa07-48e7-b3f3-1a7dbf03bbe9" -Filter "reimu_v3_*.png" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($src) {
    $dst = "e:\TouhouBazaar\assets\ui\chefs\reimu.png"
    Copy-Item $src.FullName -Destination $dst -Force
    Write-Host "Copied $($src.Name) to $dst"
}
