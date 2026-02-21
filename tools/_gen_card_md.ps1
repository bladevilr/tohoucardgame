$ErrorActionPreference = 'Stop'

function Find-Matching {
  param([string]$Text,[int]$StartIndex,[char]$OpenChar,[char]$CloseChar)
  $inStr = $false; $escape = $false; $depth = 0
  for ($i = $StartIndex; $i -lt $Text.Length; $i++) {
    $ch = $Text[$i]
    if ($inStr) {
      if ($escape) { $escape = $false; continue }
      if ($ch -eq '\\') { $escape = $true; continue }
      if ($ch -eq '"') { $inStr = $false; continue }
      continue
    }
    if ($ch -eq '"') { $inStr = $true; continue }
    if ($ch -eq $OpenChar) { $depth++; continue }
    if ($ch -eq $CloseChar) {
      $depth--
      if ($depth -eq 0) { return $i }
      continue
    }
  }
  throw "No matching '$CloseChar' for '$OpenChar' from $StartIndex"
}

function Extract-TopLevelDictionariesFromReturnArray {
  param([string]$Text)
  $retIdx = $Text.IndexOf('return [')
  if ($retIdx -lt 0) { throw 'return [ not found' }
  $arrStart = $Text.IndexOf('[', $retIdx)
  $arrEnd = Find-Matching -Text $Text -StartIndex $arrStart -OpenChar '[' -CloseChar ']'

  $entries = @()
  $inStr = $false; $escape = $false
  $arrDepth = 0; $objDepth = 0; $objStart = -1

  for ($i = $arrStart; $i -le $arrEnd; $i++) {
    $ch = $Text[$i]
    if ($inStr) {
      if ($escape) { $escape = $false; continue }
      if ($ch -eq '\\') { $escape = $true; continue }
      if ($ch -eq '"') { $inStr = $false; continue }
      continue
    }
    if ($ch -eq '"') { $inStr = $true; continue }

    if ($ch -eq '[') { $arrDepth++; continue }
    if ($ch -eq ']') { $arrDepth--; continue }

    if ($ch -eq '{') {
      if ($arrDepth -ge 1) {
        $objDepth++
        if ($objDepth -eq 1) { $objStart = $i }
      }
      continue
    }

    if ($ch -eq '}') {
      if ($objDepth -gt 0) {
        $objDepth--
        if ($objDepth -eq 0 -and $objStart -ge 0) {
          $entries += $Text.Substring($objStart, $i - $objStart + 1)
          $objStart = -1
        }
      }
      continue
    }
  }

  return ,$entries
}

function Get-StringField {
  param([string]$Obj,[string]$Key)
  $pattern = '"' + [regex]::Escape($Key) + '"\s*:\s*"([^"]*)"'
  $m = [regex]::Match($Obj, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($m.Success) { return $m.Groups[1].Value }
  return ''
}

function Get-NumberField {
  param([string]$Obj,[string]$Key)
  $pattern = '"' + [regex]::Escape($Key) + '"\s*:\s*([-0-9.]+)'
  $m = [regex]::Match($Obj, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($m.Success) { return $m.Groups[1].Value }
  return ''
}

function Extract-LiteralByKey {
  param([string]$Obj,[string]$Key)
  $pattern = '"' + [regex]::Escape($Key) + '"\s*:\s*'
  $m = [regex]::Match($Obj, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $m.Success) { return '' }

  $i = $m.Index + $m.Length
  while ($i -lt $Obj.Length -and [char]::IsWhiteSpace($Obj[$i])) { $i++ }
  if ($i -ge $Obj.Length) { return '' }

  $ch = $Obj[$i]
  if ($ch -eq '{') {
    $end = Find-Matching -Text $Obj -StartIndex $i -OpenChar '{' -CloseChar '}'
    return $Obj.Substring($i, $end - $i + 1)
  }
  if ($ch -eq '[') {
    $end = Find-Matching -Text $Obj -StartIndex $i -OpenChar '[' -CloseChar ']'
    return $Obj.Substring($i, $end - $i + 1)
  }
  if ($ch -eq '"') {
    $j = $i + 1; $esc = $false
    while ($j -lt $Obj.Length) {
      $c = $Obj[$j]
      if ($esc) { $esc = $false; $j++; continue }
      if ($c -eq '\\') { $esc = $true; $j++; continue }
      if ($c -eq '"') { break }
      $j++
    }
    return $Obj.Substring($i, $j - $i + 1)
  }

  $j2 = $i
  while ($j2 -lt $Obj.Length -and $Obj[$j2] -ne ',' -and $Obj[$j2] -ne "`n" -and $Obj[$j2] -ne "`r") { $j2++ }
  return $Obj.Substring($i, $j2 - $i).Trim()
}

function Normalize-Literal {
  param([string]$S)
  if ([string]::IsNullOrWhiteSpace($S)) { return '' }
  return (($S -replace '\s+', ' ').Trim())
}

function Get-AddCalls {
  param([string]$Text)
  $calls = @(); $search = 0
  while ($true) {
    $idx = $Text.IndexOf('_add(', $search)
    if ($idx -lt 0) { break }
    $open = $Text.IndexOf('(', $idx)
    $close = Find-Matching -Text $Text -StartIndex $open -OpenChar '(' -CloseChar ')'
    $calls += $Text.Substring($open + 1, $close - $open - 1)
    $search = $close + 1
  }
  return ,$calls
}

function Split-TopLevelArgs {
  param([string]$S)
  $args = New-Object System.Collections.Generic.List[string]
  $inStr = $false; $escape = $false
  $paren = 0; $brace = 0; $bracket = 0
  $start = 0

  for ($i = 0; $i -lt $S.Length; $i++) {
    $ch = $S[$i]
    if ($inStr) {
      if ($escape) { $escape = $false; continue }
      if ($ch -eq '\\') { $escape = $true; continue }
      if ($ch -eq '"') { $inStr = $false; continue }
      continue
    }

    if ($ch -eq '"') { $inStr = $true; continue }

    switch ($ch) {
      '(' { $paren++; continue }
      ')' { $paren--; continue }
      '{' { $brace++; continue }
      '}' { $brace--; continue }
      '[' { $bracket++; continue }
      ']' { $bracket--; continue }
      ',' {
        if ($paren -eq 0 -and $brace -eq 0 -and $bracket -eq 0) {
          $args.Add($S.Substring($start, $i - $start).Trim())
          $start = $i + 1
        }
        continue
      }
    }
  }

  if ($start -lt $S.Length) { $args.Add($S.Substring($start).Trim()) }
  return ,$args.ToArray()
}

function Unquote {
  param([string]$S)
  if ($null -eq $S) { return '' }
  $t = $S.Trim()
  if ($t.StartsWith('"') -and $t.EndsWith('"') -and $t.Length -ge 2) {
    return $t.Substring(1, $t.Length - 2)
  }
  return $t
}

function Escape-Md {
  param([string]$S)
  if ($null -eq $S) { return '' }
  $x = $S -replace '\|', '\\|'
  $x = $x -replace "`r`n|`n|`r", '<br>'
  return $x
}

function Keyword-Zh {
  param([string]$K)
  switch ($K) {
    'umami' { return '鲜美' }
    'char_aroma' { return '焦香' }
    'plating' { return '摆盘' }
    'knife_work' { return '刀工' }
    'spotlight' { return '高光' }
    'aftertaste' { return '回味' }
    'secret_recipe' { return '秘方' }
    'greasy' { return '油腻' }
    'messy' { return '凌乱' }
    'taste_fatigue' { return '味觉疲劳' }
    'dull' { return '迟钝' }
    default { return $K }
  }
}

function Cuisine-Zh {
  param([string]$C)
  if ($null -eq $C) { return '' }
  $k = $C.Trim().ToLowerInvariant()
  switch ($k) {
    'washoku' { return '和食' }
    'chuuka' { return '中华' }
    'youshoku' { return '洋食' }
    'yatai' { return '屋台' }
    'kanmi' { return '甘味' }
    'yakuzen' { return '药膳' }
    default { return $C }
  }
}

function Stat-Zh {
  param([string]$S)
  switch ($S) {
    'flavor' { return '风味' }
    'presentation' { return '卖相' }
    'technique' { return '技法' }
    'aroma' { return '香气' }
    default { return $S }
  }
}

function To-Array {
  param($v)
  if ($null -eq $v) { return @() }
  if ($v -is [System.Array]) { return $v }
  return @($v)
}

function Get-Prop {
  param($obj,[string]$name)
  if ($null -eq $obj) { return $null }
  if ($obj -is [System.Collections.IDictionary] -and $obj.Contains($name)) { return $obj[$name] }
  $p = $obj.PSObject.Properties[$name]
  if ($null -ne $p) { return $p.Value }
  return $null
}

function Has-Prop {
  param($obj,[string]$name)
  return $null -ne (Get-Prop $obj $name)
}

function Join-Text {
  param([string[]]$arr)
  $x = @($arr | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  if ($x.Count -eq 0) { return '无' }
  return ($x -join '；')
}

function To-Percent {
  param($v)
  try {
    return [int]([Math]::Round([double]$v * 100.0))
  } catch {
    return 0
  }
}

function Summarize-EffectObject {
  param($e)
  if ($null -eq $e) { return '无' }

  if ($e -is [System.Array]) {
    $arr = @()
    foreach ($it in $e) { $arr += (Summarize-EffectObject $it) }
    return Join-Text $arr
  }

  if ($e -isnot [System.Collections.IDictionary] -and $e.PSObject.TypeNames -notcontains 'System.Management.Automation.PSCustomObject') {
    return [string]$e
  }

  $parts = @()

  if (Has-Prop $e 'if_position') {
    $pos = [string](Get-Prop $e 'if_position')
    $posZh = if ($pos -eq 'leftmost') { '最左位' } elseif ($pos -eq 'rightmost') { '最右位' } else { $pos }
    $thenObj = Get-Prop $e 'then'
    if ($null -eq $thenObj) { $thenObj = Get-Prop $e 'then_bonus' }
    $elseObj = Get-Prop $e 'else'
    $txt = "若在${posZh}：$(Summarize-EffectObject $thenObj)"
    if ($null -ne $elseObj) { $txt += "；否则：$(Summarize-EffectObject $elseObj)" }
    $parts += $txt
  }

  if (Has-Prop $e 'if_adjacent_has_tag') {
    $tag = [string](Get-Prop $e 'if_adjacent_has_tag')
    $thenObj = Get-Prop $e 'then'
    if ($null -eq $thenObj) { $thenObj = Get-Prop $e 'then_bonus' }
    $elseObj = Get-Prop $e 'else'
    $txt = "若相邻有[$tag]：$(Summarize-EffectObject $thenObj)"
    if ($null -ne $elseObj) { $txt += "；否则：$(Summarize-EffectObject $elseObj)" }
    $parts += $txt
  }

  if (Has-Prop $e 'if_adjacent_count_gte') {
    $cnt = [string](Get-Prop $e 'if_adjacent_count_gte')
    $txt = "若相邻菜品数≥${cnt}：$(Summarize-EffectObject (Get-Prop $e 'then'))"
    $elseObj = Get-Prop $e 'else'
    if ($null -ne $elseObj) { $txt += "；否则：$(Summarize-EffectObject $elseObj)" }
    $parts += $txt
  }

  if (Has-Prop $e 'if_keyword_gte') {
    $cond = Get-Prop $e 'if_keyword_gte'
    $kw = Keyword-Zh ([string](Get-Prop $cond 'keyword'))
    $st = [string](Get-Prop $cond 'stacks')
    $txt = "若【${kw}】层数≥${st}：$(Summarize-EffectObject (Get-Prop $e 'then'))"
    $elseObj = Get-Prop $e 'else'
    if ($null -ne $elseObj) { $txt += "；否则：$(Summarize-EffectObject $elseObj)" }
    $parts += $txt
  }

  if (Has-Prop $e 'random_chance') {
    $pct = To-Percent (Get-Prop $e 'random_chance')
    $parts += "有$pct%概率：$(Summarize-EffectObject (Get-Prop $e 'on_success'))"
  }

  if (Has-Prop $e 'delayed_trigger') {
    $d = Get-Prop $e 'delayed_trigger'
    $parts += "延迟$([string](Get-Prop $d 'delay_ticks'))回合后：$(Summarize-EffectObject (Get-Prop $d 'effect'))"
  }

  if (Has-Prop $e 'chain_right') {
    $c = Get-Prop $e 'chain_right'
    $parts += "连锁到右侧$([string](Get-Prop $c 'range'))格：$(Summarize-EffectObject (Get-Prop $c 'effect'))"
  }

  if (Has-Prop $e 'accumulate') {
    $a = Get-Prop $e 'accumulate'
    $cid = [string](Get-Prop $a 'counter_id')
    $inc = [string](Get-Prop $a 'increment')
    $th = [string](Get-Prop $a 'threshold')
    $parts += "累计[${cid}]每次+${inc}，达到${th}时：$(Summarize-EffectObject (Get-Prop $a 'on_threshold'))"
  }

  if (Has-Prop $e 'copy_adjacent_keyword') {
    $c = Get-Prop $e 'copy_adjacent_keyword'
    $target = [string](Get-Prop $c 'target')
    $targetZh = if ($target -eq 'left') { '左侧' } elseif ($target -eq 'right') { '右侧' } else { $target }
    $kw = [string](Get-Prop $c 'keyword')
    $kwZh = if ($kw -eq 'any') { '任意关键词' } else { Keyword-Zh $kw }
    $parts += "复制${targetZh}菜品$([string](Get-Prop $c 'stacks'))层【${kwZh}】"
  }

  if (Has-Prop $e 'convert_keyword') {
    $c = Get-Prop $e 'convert_keyword'
    $from = Keyword-Zh ([string](Get-Prop $c 'from'))
    $to = Keyword-Zh ([string](Get-Prop $c 'to'))
    $ratio = [string](Get-Prop $c 'ratio')
    $parts += "将【${from}】按${ratio}:1转为【${to}】"
  }

  if (Has-Prop $e 'random_keyword') {
    $pool = @()
    foreach ($k in (To-Array (Get-Prop $e 'keyword_pool'))) { $pool += (Keyword-Zh ([string]$k)) }
    $st = [string](Get-Prop $e 'keyword_stacks')
    if ($pool.Count -gt 0) { $parts += "随机获得${st}层关键词（$($pool -join '、')）" } else { $parts += "随机获得${st}层关键词" }
  }

  foreach ($suffix in @('','_2','_3')) {
    $kName = "add_keyword$suffix"
    $sName = "keyword_stacks$suffix"
    if (Has-Prop $e $kName) {
      $kw = Keyword-Zh ([string](Get-Prop $e $kName))
      $st = Get-Prop $e $sName
      if ($null -eq $st) { $st = 1 }
      $parts += "获得${st}层【${kw}】"
    }
  }

  if (Has-Prop $e 'consume_keyword') {
    $kw = Keyword-Zh ([string](Get-Prop $e 'consume_keyword'))
    $p = @()
    if (Has-Prop $e 'per_stack_flavor_bonus') { $p += "每层风味+$([string](Get-Prop $e 'per_stack_flavor_bonus'))" }
    if (Has-Prop $e 'per_stack_presentation_bonus') { $p += "每层卖相+$([string](Get-Prop $e 'per_stack_presentation_bonus'))" }
    if ($p.Count -gt 0) { $parts += "消耗【${kw}】并转化：$($p -join '，')" } else { $parts += "消耗【${kw}】" }
  }

  if (Has-Prop $e 'add_env_keyword') {
    $kw = Keyword-Zh ([string](Get-Prop $e 'add_env_keyword'))
    $st = Get-Prop $e 'env_stacks'
    if ($null -eq $st) { $st = Get-Prop $e 'stacks' }
    if ($null -eq $st) { $st = 1 }
    $parts += "施加${st}层环境【${kw}】"
  }

  if (Has-Prop $e 'clear_env_keyword') {
    $kw = Keyword-Zh ([string](Get-Prop $e 'clear_env_keyword'))
    $st = Get-Prop $e 'clear_stacks'
    if ($null -eq $st) { $st = Get-Prop $e 'stacks' }
    if ($null -eq $st) { $st = 1 }
    $parts += "清除${st}层环境【${kw}】"
  }

  if (Has-Prop $e 'clear_light_keyword') { $parts += "清除$([string](Get-Prop $e 'stacks'))层轻度负面【$([string](Get-Prop $e 'clear_light_keyword'))】" }
  if (Has-Prop $e 'clear_all_env_debuffs') { $parts += '清除所有环境Debuff' }
  if (Has-Prop $e 'clear_all_light_keywords') { $parts += "清除轻度负面：$([string](Get-Prop $e 'clear_all_light_keywords'))" }
  if (Has-Prop $e 'transmute_all_debuffs') { $parts += "将全部Debuff转化为风味（每层+$([string](Get-Prop $e 'per_debuff_stack_flavor'))）" }
  if (Has-Prop $e 'grant_gold') { $parts += "金币+$([string](Get-Prop $e 'grant_gold'))" }
  if (Has-Prop $e 'heal_prestige') { $parts += "声望+$([string](Get-Prop $e 'heal_prestige'))" }
  if (Has-Prop $e 'heal_hp') { $parts += "生命+$([string](Get-Prop $e 'heal_hp'))" }
  if (Has-Prop $e 'reduce_cooldown_self') { $parts += "自身冷却-$([string](Get-Prop $e 'reduce_cooldown_self'))秒" }
  if (Has-Prop $e 'revive_on_death') { $parts += '本回合首次退场后复活' }

  foreach ($set in @(
    @{k='washoku'; zh='和食'}, @{k='chuuka'; zh='中华'}, @{k='youshoku'; zh='洋食'},
    @{k='yatai'; zh='屋台'}, @{k='kanmi'; zh='甘味'}, @{k='yakuzen'; zh='药膳'}
  )) {
    $pf = Get-Prop $e ("per_" + $set.k + "_flavor")
    $pp = Get-Prop $e ("per_" + $set.k + "_presentation")
    $pa = Get-Prop $e ("per_" + $set.k + "_aroma")
    if ($null -ne $pf -or $null -ne $pp -or $null -ne $pa) {
      $x = @()
      if ($null -ne $pf) { $x += "风味+$pf" }
      if ($null -ne $pp) { $x += "卖相+$pp" }
      if ($null -ne $pa) { $x += "香气+$pa" }
      $parts += "每有1道$($set.zh)菜：$($x -join '，')"
    }
  }

  foreach ($s in @('flavor','presentation','technique','aroma')) {
    if (Has-Prop $e $s) {
      $v = [string](Get-Prop $e $s)
      if ($v -match '^-') { $parts += "$(Stat-Zh $s)$v" } else { $parts += "$(Stat-Zh $s)+$v" }
    }
  }

  return Join-Text $parts
}

function Humanize-DishEffect {
  param([string]$raw)
  if ([string]::IsNullOrWhiteSpace($raw) -or $raw -eq '[]') { return '无' }
  try {
    $triggers = $raw | ConvertFrom-Json
    $parts = @()
    foreach ($t in (To-Array $triggers)) {
      $event = [string](Get-Prop $t 'event')
      $eff = Summarize-EffectObject (Get-Prop $t 'effect')
      $prefix = if ($event -eq 'item_activated') { '出菜时' } elseif ($event -ne '') { $event } else { '触发时' }
      $parts += "$prefix：$eff"
    }
    return Join-Text $parts
  } catch {
    return $raw
  }
}

function Humanize-StatMods {
  param([string]$raw)
  if ([string]::IsNullOrWhiteSpace($raw) -or $raw -eq '{}') { return '无属性加成' }
  try {
    $o = $raw | ConvertFrom-Json
    $parts = @()
    foreach ($s in @('flavor','presentation','technique','aroma')) {
      $v = Get-Prop $o $s
      if ($null -ne $v) {
        if ([string]$v -match '^-') { $parts += "$(Stat-Zh $s)$v" } else { $parts += "$(Stat-Zh $s)+$v" }
      }
    }
    return Join-Text $parts
  } catch {
    return $raw
  }
}

function Humanize-TagLiteral {
  param([string]$lit,[string]$prefix)
  if ([string]::IsNullOrWhiteSpace($lit) -or $lit -eq '[]') { return '' }
  try {
    $tmp = $lit | ConvertFrom-Json
    $arr = @()
    foreach ($x in (To-Array $tmp)) { $arr += [string]$x }
    if ($arr.Count -eq 0) { return '' }
    return "$prefix：$($arr -join '、')"
  } catch {
    return "$prefix：$lit"
  }
}

function Humanize-IngredientEffect {
  param($i)
  $parts = @()
  $parts += Humanize-StatMods $i.stat_mods
  $a = Humanize-TagLiteral $i.tag_add '添加标签'
  if ($a -ne '') { $parts += $a }
  $r = Humanize-TagLiteral $i.tag_remove '移除标签'
  if ($r -ne '') { $parts += $r }
  $q = Humanize-TagLiteral $i.tag_require '需包含标签'
  if ($q -ne '') { $parts += $q }
  $f = Humanize-TagLiteral $i.tag_forbid '禁止标签'
  if ($f -ne '') { $parts += $f }
  if (-not [string]::IsNullOrWhiteSpace($i.special) -and $i.special -ne '无') { $parts += $i.special }
  if (-not [string]::IsNullOrWhiteSpace($i.affinity)) { $parts += ('亲和菜系：' + (Cuisine-Zh $i.affinity)) }
  return Join-Text $parts
}

function Humanize-ToolEffect {
  param([string]$raw)
  if ([string]::IsNullOrWhiteSpace($raw) -or $raw -eq '[]') { return '无' }
  $m = [regex]::Matches($raw, 'desc\s*=\s*"([^"]+)"')
  if ($m.Count -gt 0) {
    $parts = @()
    foreach ($x in $m) { $parts += $x.Groups[1].Value }
    return Join-Text $parts
  }
  return $raw
}

$dishFiles = @(
  'data/cuisines/Washoku.gd',
  'data/cuisines/Chuuka.gd',
  'data/cuisines/Youshoku.gd',
  'data/cuisines/Yatai.gd',
  'data/cuisines/Kanmi.gd',
  'data/cuisines/Yakuzen.gd'
)

$dishes = @()
foreach ($f in $dishFiles) {
  $text = Get-Content $f -Raw -Encoding UTF8
  $objs = Extract-TopLevelDictionariesFromReturnArray -Text $text
  foreach ($o in $objs) {
    $id = Get-StringField -Obj $o -Key 'id'
    if ([string]::IsNullOrWhiteSpace($id)) { continue }
    $nameCn = Get-StringField -Obj $o -Key 'name_cn'
    if ([string]::IsNullOrWhiteSpace($nameCn)) { $nameCn = Get-StringField -Obj $o -Key 'name' }
    $dishes += [pscustomobject]@{
      type = '菜品'
      id = $id
      name = $nameCn
      cuisine = Get-StringField -Obj $o -Key 'cuisine'
      tier = Get-NumberField -Obj $o -Key 'tier'
      size = Get-NumberField -Obj $o -Key 'size'
      cooldown = Get-NumberField -Obj $o -Key 'cooldown'
      base_stats = Normalize-Literal (Extract-LiteralByKey -Obj $o -Key 'base_stats')
      tags = Normalize-Literal (Extract-LiteralByKey -Obj $o -Key 'tags')
      effect = Normalize-Literal (Extract-LiteralByKey -Obj $o -Key 'triggers')
    }
  }
}

$specialMap = @{
  '' = '无'
  'clear_greasy_1' = '对决开始时：清除 1 层【油腻】'
  'add_env_greasy_2' = '首次激活时：添加 2 层【油腻】'
  'clear_all_env_1' = '对决开始时：每种环境 Debuff 各清 1 层'
  'double_next_activate' = '首次激活：风味分数 x2'
  'grant_secret_recipe' = '对决开始时：获得 1 层【秘方】'
  'grant_char_aroma_3' = '对决开始时：获得 3 层【焦香】'
}

$ingText = Get-Content 'data/IngredientDatabase.gd' -Raw -Encoding UTF8
$ingCalls = Get-AddCalls -Text $ingText
$ingredients = @()

foreach ($call in $ingCalls) {
  $a = Split-TopLevelArgs -S $call
  if ($a.Length -lt 13) { continue }
  if (-not $a[0].Trim().StartsWith('"')) { continue }

  $specialKey = Unquote $a[10]
  $specialDesc = if ($specialMap.ContainsKey($specialKey)) { $specialMap[$specialKey] } else { $specialKey }

  $tagSummary = @()
  $add = Normalize-Literal $a[6]
  $remove = Normalize-Literal $a[7]
  $req = Normalize-Literal $a[8]
  $forbid = Normalize-Literal $a[9]
  if ($add -ne '[]') { $tagSummary += "add=$add" }
  if ($remove -ne '[]') { $tagSummary += "remove=$remove" }
  if ($req -ne '[]') { $tagSummary += "require=$req" }
  if ($forbid -ne '[]') { $tagSummary += "forbid=$forbid" }
  if (@($tagSummary).Count -eq 0) { $tagSummary += '无' }

  $ingredients += [pscustomobject]@{
    type = '食材'
    id = Unquote $a[0]
    name = Unquote $a[1]
    tier = $a[3].Trim()
    cost = $a[4].Trim()
    stat_mods = Normalize-Literal $a[5]
    tag_add = $add
    tag_remove = $remove
    tag_require = $req
    tag_forbid = $forbid
    tag_rules = ($tagSummary -join '; ')
    special = $specialDesc
    affinity = Unquote $a[11]
  }
}

$toolText = Get-Content 'data/ToolDatabase.gd' -Raw -Encoding UTF8
$toolCalls = Get-AddCalls -Text $toolText
$tools = @()

foreach ($call in $toolCalls) {
  $a = Split-TopLevelArgs -S $call
  if ($a.Length -lt 7) { continue }
  if (-not $a[0].Trim().StartsWith('"')) { continue }

  $tools += [pscustomobject]@{
    type = '厨具'
    id = Unquote $a[0]
    name = Unquote $a[1]
    tier = Unquote $a[2]
    category = Unquote $a[3]
    core = Normalize-Literal $a[4]
    effect = Normalize-Literal $a[5]
  }
}

$tierOrder = @{ '0' = 0; '1' = 1; '2' = 2; '3' = 3; 'bronze' = 0; 'silver' = 1; 'gold' = 2; 'diamond' = 3 }
$dishes = @($dishes | Sort-Object @{Expression={ [int]$_.tier }}, cuisine, id)
$ingredients = @($ingredients | Sort-Object @{Expression={ if ($tierOrder.ContainsKey([string]$_.tier)) { $tierOrder[[string]$_.tier] } else { 999 } }}, id)
$tools = @($tools | Sort-Object @{Expression={ if ($tierOrder.ContainsKey([string]$_.tier)) { $tierOrder[[string]$_.tier] } else { 999 } }}, id)

$sb = New-Object System.Text.StringBuilder
$null = $sb.AppendLine('# 战斗系统与卡牌效果总表（全量）')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('- 生成方式：基于仓库脚本数据自动提取（非手填）')
$null = $sb.AppendLine("- 统计：菜品 $(@($dishes).Count) / 食材 $(@($ingredients).Count) / 厨具 $(@($tools).Count)")
$null = $sb.AppendLine('- 主要数据源：`data/GameConfig.gd`、`systems/ShowdownManager.gd`、`systems/ShowdownResolverV2.gd`、`systems/ShowdownResolver.gd`、`systems/KeywordManager.gd`、`systems/TriggerSystem.gd`、`systems/IngredientManager.gd`、`data/cuisines/*.gd`、`data/IngredientDatabase.gd`、`data/ToolDatabase.gd`')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('## 战斗系统总览（当前实现）')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('| 模块 | 当前规则 | 代码来源 |')
$null = $sb.AppendLine('|---|---|---|')
$null = $sb.AppendLine('| 主战斗模式 | `BATTLE_SYSTEM_V2 = true`，默认走 V2 | `data/GameConfig.gd` `systems/ShowdownManager.gd` |')
$null = $sb.AppendLine('| 对决时长 | 30 秒 | `data/GameConfig.gd` `systems/ShowdownResolverV2.gd` |')
$null = $sb.AppendLine('| 出菜顺序 | 双方按“完成时间（当前时间 + 冷却）”竞争出菜；同帧按香气高者先出 | `systems/ShowdownResolverV2.gd` |')
$null = $sb.AppendLine('| 评分核心 | 基础分 = 风味 × 技法系数，再叠加疲劳、尺寸归一、阈值衰减、需求满足、偏好/厌恶、饱腹惩罚、菜系连段等 | `systems/ShowdownResolverV2.gd` |')
$null = $sb.AppendLine('| 双评委 | 每道菜分别对两位评委打分，取平均计入选手总分 | `systems/ShowdownResolverV2.gd` `core/resources/JudgeStateV2.gd` |')
$null = $sb.AppendLine('| V1兼容 | 仍保留 V1 结算链（关键词、触发器、DOT、撞菜惩罚）作为兼容逻辑 | `systems/ShowdownResolver.gd` |')
$null = $sb.AppendLine('| 触发系统 | 支持 `item_activated` / `on_showdown_start` / `on_showdown_end` / `on_tick` / 条件分支/链式/延迟 等 | `systems/TriggerSystem.gd` |')
$null = $sb.AppendLine('| 食材附魔 | 食材可改 `base_stats`、增删标签、并注入特殊触发器到目标菜品 | `systems/IngredientManager.gd` |')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('## 关键词数值（V1数值层）')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('| 关键词 | 作用 |')
$null = $sb.AppendLine('|---|---|')
$null = $sb.AppendLine('| `umami` | 每层 `+3 flavor` |')
$null = $sb.AppendLine('| `char_aroma` | 每层 `+2 flavor` |')
$null = $sb.AppendLine('| `plating` | 每层 `+3 presentation` |')
$null = $sb.AppendLine('| `knife_work` | 每层 `+2 technique` |')
$null = $sb.AppendLine('| `spotlight` | 每层使当前冷却额外 `-1.0s`（消耗） |')
$null = $sb.AppendLine('| `aftertaste` | 每层使 flavor 乘 `1 + 0.30` |')
$null = $sb.AppendLine('| `secret_recipe` | 每层使 flavor 乘 `1 + 0.50`（消耗） |')
$null = $sb.AppendLine('| `greasy` | 每层 `-2 flavor`（环境Debuff） |')
$null = $sb.AppendLine('| `messy` | 每层 `-2 presentation`（环境Debuff） |')
$null = $sb.AppendLine('| `taste_fatigue` | 每层 flavor 额外乘 `0.85`（最低保底） |')
$null = $sb.AppendLine('| `dull` | 每层额外 `+0.3s` 冷却惩罚（环境Debuff） |')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('## 菜品全量效果表')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('| 类型 | ID | 名称 | 菜系 | Tier | 尺寸 | 冷却 | 基础属性 | 标签 | 触发效果（原始） |')
$null = $sb.AppendLine('|---|---|---|---|---:|---:|---:|---|---|---|')
foreach ($d in $dishes) {
  $effect = if ([string]::IsNullOrWhiteSpace($d.effect) -or $d.effect -eq '[]') { '无' } else { $d.effect }
  $null = $sb.AppendLine('| 菜品 | ' + (Escape-Md $d.id) + ' | ' + (Escape-Md $d.name) + ' | ' + (Escape-Md $d.cuisine) + ' | ' + (Escape-Md $d.tier) + ' | ' + (Escape-Md $d.size) + ' | ' + (Escape-Md $d.cooldown) + ' | ' + (Escape-Md $d.base_stats) + ' | ' + (Escape-Md $d.tags) + ' | ' + (Escape-Md $effect) + ' |')
}
$null = $sb.AppendLine('')
$null = $sb.AppendLine('## 食材全量效果表')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('| 类型 | ID | 名称 | Tier | 价格 | 属性修正 | 标签规则 | 特殊效果 | 亲和菜系 |')
$null = $sb.AppendLine('|---|---|---|---:|---:|---|---|---|---|')
foreach ($i in $ingredients) {
  $aff = if ([string]::IsNullOrWhiteSpace($i.affinity)) { '无' } else { $i.affinity }
  $null = $sb.AppendLine('| 食材 | ' + (Escape-Md $i.id) + ' | ' + (Escape-Md $i.name) + ' | ' + (Escape-Md $i.tier) + ' | ' + (Escape-Md $i.cost) + ' | ' + (Escape-Md $i.stat_mods) + ' | ' + (Escape-Md $i.tag_rules) + ' | ' + (Escape-Md $i.special) + ' | ' + (Escape-Md $aff) + ' |')
}
$null = $sb.AppendLine('')
$null = $sb.AppendLine('## 厨具全量效果表')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('| 类型 | ID | 名称 | Tier | 类别 | 核心属性 | 触发器效果（原始） |')
$null = $sb.AppendLine('|---|---|---|---|---|---|---|')
foreach ($t in $tools) {
  $effect = if ([string]::IsNullOrWhiteSpace($t.effect) -or $t.effect -eq '[]') { '无' } else { $t.effect }
  $null = $sb.AppendLine('| 厨具 | ' + (Escape-Md $t.id) + ' | ' + (Escape-Md $t.name) + ' | ' + (Escape-Md $t.tier) + ' | ' + (Escape-Md $t.category) + ' | ' + (Escape-Md $t.core) + ' | ' + (Escape-Md $effect) + ' |')
}

$outPath = 'docs/BattleSystem_CardEffect_FullTable.md'
Set-Content -Path $outPath -Value $sb.ToString() -Encoding UTF8
"generated=$outPath"
"dishes=$(@($dishes).Count) ingredients=$(@($ingredients).Count) tools=$(@($tools).Count)"

$sbPlain = New-Object System.Text.StringBuilder
$null = $sbPlain.AppendLine('# 战斗系统与卡牌效果总表（人话版）')
$null = $sbPlain.AppendLine('')
$null = $sbPlain.AppendLine('- 生成方式：基于仓库数据自动提取 + 规则化人话翻译（非手填）')
$null = $sbPlain.AppendLine("- 统计：菜品 $(@($dishes).Count) / 食材 $(@($ingredients).Count) / 厨具 $(@($tools).Count)")
$null = $sbPlain.AppendLine('')
$null = $sbPlain.AppendLine('## 战斗系统总览（人话版）')
$null = $sbPlain.AppendLine('')
$null = $sbPlain.AppendLine('| 模块 | 人话说明 |')
$null = $sbPlain.AppendLine('|---|---|')
$null = $sbPlain.AppendLine('| 主模式 | 默认走 V2；V1 逻辑仅作兼容保留 |')
$null = $sbPlain.AppendLine('| 时长 | 单场 30 秒 |')
$null = $sbPlain.AppendLine('| 出菜顺序 | 先看完成时间（当前时间+冷却），同一时刻香气高者先出 |')
$null = $sbPlain.AppendLine('| 评分 | 先算基础分，再叠加疲劳、偏好/厌恶、饱腹、菜系连段等修正 |')
$null = $sbPlain.AppendLine('| 触发系统 | 支持条件判断、连锁、延迟、计数器等效果 |')
$null = $sbPlain.AppendLine('| 食材作用 | 食材会改属性、改标签、附加特殊效果 |')
$null = $sbPlain.AppendLine('')
$null = $sbPlain.AppendLine('## 菜品效果表（人话版）')
$null = $sbPlain.AppendLine('')
$null = $sbPlain.AppendLine('| 类型 | ID | 名称 | 菜系 | Tier | 尺寸 | 冷却 | 标签 | 人话效果 |')
$null = $sbPlain.AppendLine('|---|---|---|---|---:|---:|---:|---|---|')
foreach ($d in $dishes) {
  $human = Humanize-DishEffect $d.effect
  $null = $sbPlain.AppendLine('| 菜品 | ' + (Escape-Md $d.id) + ' | ' + (Escape-Md $d.name) + ' | ' + (Escape-Md (Cuisine-Zh $d.cuisine)) + ' | ' + (Escape-Md $d.tier) + ' | ' + (Escape-Md $d.size) + ' | ' + (Escape-Md $d.cooldown) + ' | ' + (Escape-Md $d.tags) + ' | ' + (Escape-Md $human) + ' |')
}
$null = $sbPlain.AppendLine('')
$null = $sbPlain.AppendLine('## 食材效果表（人话版）')
$null = $sbPlain.AppendLine('')
$null = $sbPlain.AppendLine('| 类型 | ID | 名称 | Tier | 价格 | 人话效果 |')
$null = $sbPlain.AppendLine('|---|---|---|---:|---:|---|')
foreach ($i in $ingredients) {
  $human = Humanize-IngredientEffect $i
  $null = $sbPlain.AppendLine('| 食材 | ' + (Escape-Md $i.id) + ' | ' + (Escape-Md $i.name) + ' | ' + (Escape-Md $i.tier) + ' | ' + (Escape-Md $i.cost) + ' | ' + (Escape-Md $human) + ' |')
}
$null = $sbPlain.AppendLine('')
$null = $sbPlain.AppendLine('## 厨具效果表（人话版）')
$null = $sbPlain.AppendLine('')
$null = $sbPlain.AppendLine('| 类型 | ID | 名称 | Tier | 类别 | 核心属性 | 人话效果 |')
$null = $sbPlain.AppendLine('|---|---|---|---|---|---|---|')
foreach ($t in $tools) {
  $human = Humanize-ToolEffect $t.effect
  $null = $sbPlain.AppendLine('| 厨具 | ' + (Escape-Md $t.id) + ' | ' + (Escape-Md $t.name) + ' | ' + (Escape-Md $t.tier) + ' | ' + (Escape-Md $t.category) + ' | ' + (Escape-Md $t.core) + ' | ' + (Escape-Md $human) + ' |')
}

$outPathPlain = 'docs/BattleSystem_CardEffect_PlainTable.md'
Set-Content -Path $outPathPlain -Value $sbPlain.ToString() -Encoding UTF8
"generated=$outPathPlain"
