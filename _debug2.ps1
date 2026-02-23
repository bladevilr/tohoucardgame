[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$bytes = [System.IO.File]::ReadAllBytes('I:\TouhouBazaar\ui\UIHelper.gd')
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$lines = $text -split "`n"

# Show the current state of the keyword map
for ($i=98; $i -le 107; $i++) {
    Write-Output ("{0}: [{1}]" -f ($i+1), $lines[$i].TrimEnd())
}

# Check line 100 (was line 101 before, 0-indexed=100) hex
Write-Output ""
Write-Output "Line 101 hex:"
$lineBytes = [System.Text.Encoding]::UTF8.GetBytes($lines[100])
$hex = -join ($lineBytes | ForEach-Object { $_.ToString("x2") + " " })
Write-Output $hex

Write-Output ""
Write-Output "Line 101 chars:"
foreach ($c in $lines[100].ToCharArray()) {
    $code = [int]$c
    if ($code -gt 127 -or $code -eq 9) {
        Write-Output ("  U+{0:X4} = [{1}]" -f $code, $c)
    }
}

# Also check for knife_work anywhere
Write-Output ""
Write-Output "=== Lines containing knife_work ==="
for ($i=0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'knife_work') {
        Write-Output ("{0}: [{1}]" -f ($i+1), $lines[$i].TrimEnd())
        $lb = [System.Text.Encoding]::UTF8.GetBytes($lines[$i])
        $hx = -join ($lb | ForEach-Object { $_.ToString("x2") + " " })
        Write-Output ("HEX: {0}" -f $hx)
    }
}
