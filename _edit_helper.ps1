[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$bytes = [System.IO.File]::ReadAllBytes('I:\TouhouBazaar\ui\UIHelper.gd')
$text = [System.Text.Encoding]::UTF8.GetString($bytes)

# 1. Replace keyword map entries
$text = $text.Replace('"umami": "鲜美", "char_aroma": "焦香", "plating": "摆盘",', '"umami": "提味", "plating": "增色",')
$text = $text.Replace('"knife_work": "刀工", "spotlight": "瞩目",', '"knife_work": "精技", "spotlight": "加速",')
$text = $text.Replace('"taste_fatigue": "味觉疲劳",', '"taste_fatigue": "疲劳",')

# 2. Remove "aroma" case in _attr_chinese, change "flavor" to "美味度"
$text = $text.Replace('"flavor": return "味道"', '"flavor": return "美味度"')
$text = $text.Replace("`t`t`"aroma`": return `"香气`"`n", "")

# 3. Remove "aroma" from stat iteration arrays
$text = $text.Replace('"flavor", "presentation", "technique", "aroma"', '"flavor", "presentation", "technique"')

# Write back
$newBytes = [System.Text.Encoding]::UTF8.GetBytes($text)
[System.IO.File]::WriteAllBytes('I:\TouhouBazaar\ui\UIHelper.gd', $newBytes)
Write-Output "Done!"
