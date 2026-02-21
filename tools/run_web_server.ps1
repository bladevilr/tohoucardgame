param(
    [int]$Port = 8080,
    [string]$Root = "build/web"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$serveRoot = Join-Path $projectRoot $Root

if (-not (Test-Path $serveRoot)) {
    Write-Error "Web build folder not found: $serveRoot"
    exit 1
}

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$pyLauncher = Get-Command py -ErrorAction SilentlyContinue
if (-not $pythonCmd -and -not $pyLauncher) {
    Write-Error "Neither python nor py was found in PATH."
    exit 1
}

$ipv4List = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -ne "127.0.0.1" } |
    Select-Object -ExpandProperty IPAddress -Unique

Write-Host "Serving: $serveRoot"
Write-Host "Local:   http://127.0.0.1:$Port/"
foreach ($ip in $ipv4List) {
    Write-Host "LAN:     http://$ip`:$Port/"
}
Write-Host ""
Write-Host "Keep this window open. Press Ctrl+C to stop."
Write-Host ""

Push-Location $serveRoot
try {
    if ($pythonCmd) {
        python -m http.server $Port --bind 0.0.0.0
    } else {
        py -m http.server $Port --bind 0.0.0.0
    }
}
finally {
    Pop-Location
}
