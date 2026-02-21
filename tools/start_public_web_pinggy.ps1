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

$pyLauncher = Get-Command py -ErrorAction SilentlyContinue
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pyLauncher -and -not $pythonCmd) {
    Write-Error "Neither py nor python was found in PATH."
    exit 1
}

$sshCmd = Get-Command ssh -ErrorAction SilentlyContinue
if (-not $sshCmd) {
    Write-Error "ssh was not found in PATH."
    exit 1
}

$portInUse = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($portInUse) {
    Write-Error "Port $Port is already in use by PID $($portInUse.OwningProcess)."
    exit 1
}

$logDir = Join-Path $projectRoot "debug"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$serverOut = Join-Path $logDir "pinggy_server.out.log"
$serverErr = Join-Path $logDir "pinggy_server.err.log"
$tunnelOut = Join-Path $logDir "pinggy_tunnel.out.log"
$tunnelErr = Join-Path $logDir "pinggy_tunnel.err.log"

Write-Host "Starting local static server..."
if ($pyLauncher) {
    $serverProc = Start-Process -FilePath "py" -ArgumentList "-m http.server $Port --bind 127.0.0.1" -WorkingDirectory $serveRoot -RedirectStandardOutput $serverOut -RedirectStandardError $serverErr -PassThru
} else {
    $serverProc = Start-Process -FilePath "python" -ArgumentList "-m http.server $Port --bind 127.0.0.1" -WorkingDirectory $serveRoot -RedirectStandardOutput $serverOut -RedirectStandardError $serverErr -PassThru
}

Start-Sleep -Milliseconds 800
if ($serverProc.HasExited) {
    Write-Error "Local server failed to start. Check logs: $serverOut / $serverErr"
    exit 1
}

Write-Host "Starting Pinggy tunnel..."
$tunnelProc = Start-Process -FilePath "ssh" -ArgumentList "-p 443 -o StrictHostKeyChecking=no -o ServerAliveInterval=30 -R0:localhost:$Port a.pinggy.io" -WorkingDirectory $projectRoot -RedirectStandardOutput $tunnelOut -RedirectStandardError $tunnelErr -PassThru

$publicHttps = $null
$publicHttp = $null
for ($i = 0; $i -lt 40; $i++) {
    Start-Sleep -Milliseconds 500
    $lines = @()
    if (Test-Path $tunnelOut) { $lines += Get-Content $tunnelOut -Tail 80 }
    if (Test-Path $tunnelErr) { $lines += Get-Content $tunnelErr -Tail 80 }
    foreach ($line in $lines) {
        if (-not $publicHttps) {
            $m = [regex]::Match($line, "https://[a-z0-9\\-\\.]+")
            if ($m.Success) { $publicHttps = $m.Value }
        }
        if (-not $publicHttp) {
            $m2 = [regex]::Match($line, "http://[a-z0-9\\-\\.]+")
            if ($m2.Success) { $publicHttp = $m2.Value }
        }
    }
    if ($publicHttps -and $publicHttp) { break }
    if ($tunnelProc.HasExited) { break }
}

if (-not $publicHttps -and -not $publicHttp) {
    Write-Host "Tunnel started but URL not detected yet. Check logs:"
    Write-Host "  $tunnelOut"
    Write-Host "  $tunnelErr"
    Write-Host ""
    Write-Host "To stop:"
    Write-Host "  Stop-Process -Id $($serverProc.Id),$($tunnelProc.Id) -Force"
    exit 1
}

Write-Host ""
if ($publicHttps) { Write-Host "Public HTTPS: $publicHttps" }
if ($publicHttp)  { Write-Host "Public HTTP:  $publicHttp" }
Write-Host "Local URL:    http://127.0.0.1:$Port/"
Write-Host ""
Write-Host "Process IDs: server=$($serverProc.Id) tunnel=$($tunnelProc.Id)"
Write-Host "To stop:"
Write-Host "  Stop-Process -Id $($serverProc.Id),$($tunnelProc.Id) -Force"
