Add-Type -AssemblyName System.Drawing
$dirs = @('e:\TouhouBazaar\assets\ui\ingredients', 'e:\TouhouBazaar\assets\ui\dishes', 'e:\TouhouBazaar\assets\ui\tools', 'e:\TouhouBazaar\assets\ui\cookware', 'e:\TouhouBazaar\assets\ui\utensils')
$false_transparent = @()

foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) { continue }
    foreach ($file in Get-ChildItem $dir -Filter "*.png") {
        try {
            $bmp = New-Object System.Drawing.Bitmap($file.FullName)
            $w = $bmp.Width
            $h = $bmp.Height
            if ($w -lt 10 -or $h -lt 10) { $bmp.Dispose(); continue }
            
            $points = @($bmp.GetPixel(0, 0), $bmp.GetPixel(1, 0), $bmp.GetPixel(0, 1), $bmp.GetPixel(5, 5), $bmp.GetPixel(9, 9))
            $is_opaque_gray_white = $true
            foreach ($c in $points) {
                if ($c.A -ne 255 -or $c.R -lt 150 -or [Math]::Abs($c.R - $c.G) -gt 15 -or [Math]::Abs($c.G - $c.B) -gt 15) {
                    $is_opaque_gray_white = $false
                    break
                }
            }
            if ($is_opaque_gray_white) {
                $false_transparent += $file.FullName
            }
            $bmp.Dispose()
        }
        catch { }
    }
}
Write-Host "FalseTransparentFiles:"
$false_transparent | ForEach-Object { Write-Host $_ }
