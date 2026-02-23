# Read the file as raw bytes, decode as UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$bytes = [System.IO.File]::ReadAllBytes('I:\TouhouBazaar\ui\UIHelper.gd')
$text = [System.Text.Encoding]::UTF8.GetString($bytes)

# Build search/replace strings from Unicode code points to avoid encoding issues

# "鲜美" = U+9C9C U+7F8E
$xianmei = [char]0x9C9C, [char]0x7F8E -join ''
# "提味" = U+63D0 U+5473
$tiwei = [char]0x63D0, [char]0x5473 -join ''
# "焦香" = U+7126 U+9999
$jiaoxiang = [char]0x7126, [char]0x9999 -join ''
# "摆盘" = U+6446 U+76D8
$baipan = [char]0x6446, [char]0x76D8 -join ''
# "增色" = U+589E U+8272
$zengse = [char]0x589E, [char]0x8272 -join ''
# "刀工" = U+5200 U+5DE5
$daogong = [char]0x5200, [char]0x5DE5 -join ''
# "精技" = U+7CBE U+6280
$jingji = [char]0x7CBE, [char]0x6280 -join ''
# "瞩目" = U+77A9 U+76EE
$zhumu = [char]0x77A9, [char]0x76EE -join ''
# "加速" = U+52A0 U+901F
$jiasu = [char]0x52A0, [char]0x901F -join ''
# "味觉疲劳" = U+5473 U+89C9 U+75B2 U+52B3
$weijuepilao = [char]0x5473, [char]0x89C9, [char]0x75B2, [char]0x52B3 -join ''
# "疲劳" = U+75B2 U+52B3
$pilao = [char]0x75B2, [char]0x52B3 -join ''
# "味道" = U+5473 U+9053
$weidao = [char]0x5473, [char]0x9053 -join ''
# "美味度" = U+7F8E U+5473 U+5EA6
$meiweidur = [char]0x7F8E, [char]0x5473, [char]0x5EA6 -join ''
# "香气" = U+9999 U+6C14
$xiangqi = [char]0x9999, [char]0x6C14 -join ''
# "char_aroma"
$char_aroma_key = '"char_aroma"'

# 1. Replace keyword map line: remove char_aroma entry, change umami/plating values
$old1 = "`t`t`"umami`": `"$xianmei`", `"char_aroma`": `"$jiaoxiang`", `"plating`": `"$baipan`","
$new1 = "`t`t`"umami`": `"$tiwei`", `"plating`": `"$zengse`","
Write-Output "Search1 exists: $($text.Contains($old1))"
$text = $text.Replace($old1, $new1)

# 2. Replace knife_work and spotlight values
$old2 = "`"knife_work`": `"$daogong`", `"spotlight`": `"$zhumu`","
$new2 = "`"knife_work`": `"$jingji`", `"spotlight`": `"$jiasu`","
Write-Output "Search2 exists: $($text.Contains($old2))"
$text = $text.Replace($old2, $new2)

# 3. Replace taste_fatigue value
$old3 = "`"taste_fatigue`": `"$weijuepilao`","
$new3 = "`"taste_fatigue`": `"$pilao`","
Write-Output "Search3 exists: $($text.Contains($old3))"
$text = $text.Replace($old3, $new3)

# 4. Replace "flavor": return "味道" with "flavor": return "美味度"
$old4 = "`"flavor`": return `"$weidao`""
$new4 = "`"flavor`": return `"$meiweidur`""
Write-Output "Search4 exists: $($text.Contains($old4))"
$text = $text.Replace($old4, $new4)

# 5. Remove aroma line in _attr_chinese
$old5 = "`t`t`"aroma`": return `"$xiangqi`"`r`n"
$old5b = "`t`t`"aroma`": return `"$xiangqi`"`n"
Write-Output "Search5a exists: $($text.Contains($old5))"
Write-Output "Search5b exists: $($text.Contains($old5b))"
if ($text.Contains($old5)) {
    $text = $text.Replace($old5, "")
} elseif ($text.Contains($old5b)) {
    $text = $text.Replace($old5b, "")
}

# Write back with UTF-8 BOM-less encoding
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText('I:\TouhouBazaar\ui\UIHelper.gd', $text, $utf8NoBom)
Write-Output "Done!"
