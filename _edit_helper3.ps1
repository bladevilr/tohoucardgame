[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$bytes = [System.IO.File]::ReadAllBytes('I:\TouhouBazaar\ui\UIHelper.gd')
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$lines = $text -split "`n"

# The knife_work line has corrupted "刀工" - it shows as U+5200 U+FFFD ?
# We need to replace the entire line content
# Current line 100 (0-indexed): 		"knife_work": "刀�?, "spotlight": "瞩目",
# The actual content after "knife_work": " is: 刀 + replacement char + ? + , + space + ...

# Build the current broken string
$dao = [char]0x5200  # 刀
$replacement = [char]0xFFFD  # replacement character
$zhumu_str = ([char]0x77A9).ToString() + ([char]0x76EE).ToString()  # 瞩目

# Build replacement values
$jingji = ([char]0x7CBE).ToString() + ([char]0x6280).ToString()  # 精技
$jiasu = ([char]0x52A0).ToString() + ([char]0x901F).ToString()   # 加速

# Replace the whole line
$oldLine = "`t`t`"knife_work`": `"$dao$replacement`?`", `"spotlight`": `"$zhumu_str`","
Write-Output "Search exists: $($text.Contains($oldLine))"

$newLine = "`t`t`"knife_work`": `"$jingji`", `"spotlight`": `"$jiasu`","
$text = $text.Replace($oldLine, $newLine)

# Also check and fix _attr_chinese - technique line might have similar corruption
Write-Output ""
Write-Output "=== _attr_chinese area ==="
$lines2 = $text -split "`n"
for ($i=461; $i -le 470; $i++) {
    if ($i -lt $lines2.Count) {
        Write-Output ("{0}: [{1}]" -f ($i+1), $lines2[$i].TrimEnd())
        if ($lines2[$i] -match 'technique') {
            $lb = [System.Text.Encoding]::UTF8.GetBytes($lines2[$i])
            $hx = -join ($lb | ForEach-Object { $_.ToString("x2") + " " })
            Write-Output ("  HEX: {0}" -f $hx)
        }
    }
}

# Write back
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText('I:\TouhouBazaar\ui\UIHelper.gd', $text, $utf8NoBom)
Write-Output ""
Write-Output "Done!"
