param(
    [int]$Port = 8080,
    [string]$Host = "0.0.0.0",
    [string]$Root = "build/web",
    [string]$DataFile = "debug/web_analytics/events.jsonl",
    [string]$StatsToken = "",
    [switch]$TrustXForwardedFor
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$serveRoot = Join-Path $projectRoot $Root
$serverScript = Join-Path $projectRoot "tools\web_analytics_server.py"
$dataPath = Join-Path $projectRoot $DataFile

if (-not (Test-Path $serveRoot)) {
    Write-Error "Web build folder not found: $serveRoot"
    exit 1
}

if (-not (Test-Path $serverScript)) {
    Write-Error "Analytics server script not found: $serverScript"
    exit 1
}

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$pyLauncher = Get-Command py -ErrorAction SilentlyContinue
if (-not $pythonCmd -and -not $pyLauncher) {
    Write-Error "Neither python nor py was found in PATH."
    exit 1
}

New-Item -ItemType Directory -Path (Split-Path -Parent $dataPath) -Force | Out-Null

$ipv4List = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -ne "127.0.0.1" } |
    Select-Object -ExpandProperty IPAddress -Unique

Write-Host "Serving: $serveRoot"
Write-Host "Analytics data: $dataPath"
Write-Host "Local:   http://127.0.0.1:$Port/"
foreach ($ip in $ipv4List) {
    Write-Host "LAN:     http://$ip`:$Port/"
}
Write-Host "Stats:   http://127.0.0.1:$Port/api/stats"
if ($StatsToken -ne "") {
    Write-Host "Stats with token: http://127.0.0.1:$Port/api/stats?token=<your_token>"
}
Write-Host ""
Write-Host "Keep this window open. Press Ctrl+C to stop."
Write-Host ""

$args = @(
    $serverScript,
    "--root", (Resolve-Path $serveRoot).Path,
    "--host", $Host,
    "--port", "$Port",
    "--data-file", $dataPath
)
if ($StatsToken -ne "") {
    $args += @("--stats-token", $StatsToken)
}
if ($TrustXForwardedFor) {
    $args += "--trust-x-forwarded-for"
}

Push-Location $projectRoot
try {
    if ($pythonCmd) {
        python @args
    } else {
        py @args
    }
}
finally {
    Pop-Location
}
