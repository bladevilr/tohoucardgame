[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$lines = [System.IO.File]::ReadAllLines('I:\TouhouBazaar\ui\UIHelper.gd', [System.Text.Encoding]::UTF8)
for ($i=99; $i -le 108; $i++) {
    Write-Output ("{0}: {1}" -f $i, $lines[$i])
}
Write-Output "---"
for ($i=462; $i -le 470; $i++) {
    Write-Output ("{0}: {1}" -f $i, $lines[$i])
}
