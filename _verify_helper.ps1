[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$bytes = [System.IO.File]::ReadAllBytes('I:\TouhouBazaar\ui\UIHelper.gd')
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$lines = $text -split "`n"

Write-Output "=== Keyword map (around line 99-107) ==="
for ($i=98; $i -le 107; $i++) {
    Write-Output ("{0}: {1}" -f ($i+1), $lines[$i])
}
Write-Output ""
Write-Output "=== _attr_chinese (around line 462-469) ==="
for ($i=461; $i -le 470; $i++) {
    if ($i -lt $lines.Count) {
        Write-Output ("{0}: {1}" -f ($i+1), $lines[$i])
    }
}
Write-Output ""
Write-Output "=== stat arrays (line 168, 187, 265) ==="
for ($i=167; $i -le 169; $i++) {
    Write-Output ("{0}: {1}" -f ($i+1), $lines[$i].Trim())
}
Write-Output "---"
for ($i=186; $i -le 188; $i++) {
    Write-Output ("{0}: {1}" -f ($i+1), $lines[$i].Trim())
}
Write-Output "---"
for ($i=264; $i -le 266; $i++) {
    if ($i -lt $lines.Count) {
        Write-Output ("{0}: {1}" -f ($i+1), $lines[$i].Trim())
    }
}

# Check if "aroma" still exists
Write-Output ""
Write-Output "=== Remaining 'aroma' occurrences ==="
for ($i=0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'aroma') {
        Write-Output ("{0}: {1}" -f ($i+1), $lines[$i].Trim())
    }
}
