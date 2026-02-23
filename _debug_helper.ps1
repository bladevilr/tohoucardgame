[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$bytes = [System.IO.File]::ReadAllBytes('I:\TouhouBazaar\ui\UIHelper.gd')
$text = [System.Text.Encoding]::UTF8.GetString($bytes)

# Check if the strings actually exist
$targets = @(
    '"umami": "鲜美", "char_aroma": "焦香", "plating": "摆盘",'
    '"knife_work": "刀工", "spotlight": "瞩目",'
    '"taste_fatigue": "味觉疲劳",'
    '"flavor": return "味道"'
    '"aroma": return "香气"'
)

foreach ($t in $targets) {
    $found = $text.Contains($t)
    Write-Output ("Contains [{0}]: {1}" -f $t, $found)
}

# Show hex around line 100 more broadly
$lines = $text -split "`n"
$lineBytes = [System.Text.Encoding]::UTF8.GetBytes($lines[99])
Write-Output ""
Write-Output "Line 100 hex:"
$hex = -join ($lineBytes | ForEach-Object { $_.ToString("x2") + " " })
Write-Output $hex

# Line 100 char by char
Write-Output ""
Write-Output "Line 100 char by char:"
foreach ($c in $lines[99].ToCharArray()) {
    $code = [int]$c
    if ($code -gt 127) {
        Write-Output ("  U+{0:X4} = {1}" -f $code, $c)
    }
}
