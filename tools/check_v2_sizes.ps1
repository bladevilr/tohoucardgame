$dir = "C:\Users\R\.gemini\antigravity\brain\5a27334b-aa07-48e7-b3f3-1a7dbf03bbe9"
$files = Get-ChildItem -Path $dir -Filter "*_v2_*.png"

foreach ($f in $files) {
    Write-Host "$($f.Name): $($f.Length) bytes"
}
