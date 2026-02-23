[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$bytes = [System.IO.File]::ReadAllBytes('I:\TouhouBazaar\ui\UIHelper.gd')
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$lines = $text -split "`n"
# Line 100 (0-indexed = 99) and line 101 (0-indexed = 100)
Write-Output ("Line100: [{0}]" -f $lines[99].Trim())
Write-Output ("Line101: [{0}]" -f $lines[100].Trim())
Write-Output ("Line466: [{0}]" -f $lines[465].Trim())
Write-Output ("Line467: [{0}]" -f $lines[466].Trim())
Write-Output ("Line468: [{0}]" -f $lines[467].Trim())

# Also show hex for line 100
$lineBytes = [System.Text.Encoding]::UTF8.GetBytes($lines[99])
$hexLine = ($lineBytes | ForEach-Object { $_.ToString("x2") }) -join " "
Write-Output ("HEX100: {0}" -f $hexLine)

# Also check lines 167-170 for stat_bonus arrays
for ($i=167; $i -le 170; $i++) {
    Write-Output ("{0}: {1}" -f $i, $lines[$i].Trim())
}
Write-Output "---"
for ($i=186; $i -le 190; $i++) {
    Write-Output ("{0}: {1}" -f $i, $lines[$i].Trim())
}
Write-Output "---"
for ($i=264; $i -le 268; $i++) {
    Write-Output ("{0}: {1}" -f $i, $lines[$i].Trim())
}
