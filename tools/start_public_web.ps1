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

$cloudflared = Get-Command cloudflared -ErrorAction SilentlyContinue
if (-not $cloudflared) {
    Write-Error "cloudflared was not found in PATH."
    exit 1
}

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$pyLauncher = Get-Command py -ErrorAction SilentlyContinue
if (-not $pythonCmd -and -not $pyLauncher) {
    Write-Error "Neither python nor py was found in PATH."
    exit 1
}

$portInUse = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($portInUse) {
    Write-Error "Port $Port is already in use by PID $($portInUse.OwningProcess). Stop it first."
    exit 1
}

$serverOutLog = Join-Path $projectRoot "debug\public_server.out.log"
$serverErrLog = Join-Path $projectRoot "debug\public_server.err.log"
$tunnelOutLog = Join-Path $projectRoot "debug\public_tunnel.out.log"
$tunnelErrLog = Join-Path $projectRoot "debug\public_tunnel.err.log"
New-Item -ItemType Directory -Path (Split-Path -Parent $serverOutLog) -Force | Out-Null

Write-Host "Starting local static server..."
$serverArgs = if ($pythonCmd) {
    "-m http.server $Port --bind 127.0.0.1"
} else {
    "-m http.server $Port --bind 127.0.0.1"
}

if ($pythonCmd) {
    $serverProc = Start-Process -FilePath "python" -ArgumentList $serverArgs -WorkingDirectory $serveRoot -RedirectStandardOutput $serverOutLog -RedirectStandardError $serverErrLog -PassThru
} else {
    $serverProc = Start-Process -FilePath "py" -ArgumentList $serverArgs -WorkingDirectory $serveRoot -RedirectStandardOutput $serverOutLog -RedirectStandardError $serverErrLog -PassThru
}

Start-Sleep -Seconds 1
if ($serverProc.HasExited) {
    Write-Error "Local server failed to start. Check: $serverOutLog / $serverErrLog"
    exit 1
}

Write-Host "Starting cloudflared tunnel..."
$tunnelCmd = "cloudflared tunnel --url http://127.0.0.1:$Port --protocol http2"
$tunnelProc = Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $tunnelCmd" -WorkingDirectory $projectRoot -RedirectStandardOutput $tunnelOutLog -RedirectStandardError $tunnelErrLog -PassThru

$publicUrl = $null
for ($i = 0; $i -lt 40; $i++) {
    Start-Sleep -Milliseconds 500
    if ((Test-Path $tunnelOutLog) -or (Test-Path $tunnelErrLog)) {
        $line = Select-String -Path @($tunnelOutLog, $tunnelErrLog) -Pattern "https://[-a-z0-9]+\.trycloudflare\.com" -AllMatches -ErrorAction SilentlyContinue | Select-Object -Last 1
        if ($line) {
            $publicUrl = $line.Matches[0].Value
            break
        }
    }
    if ($tunnelProc.HasExited) {
        break
    }
}

if (-not $publicUrl) {
    Write-Host ""
    Write-Host "Tunnel did not return URL yet. Check log:"
    Write-Host "  $tunnelOutLog"
    Write-Host "  $tunnelErrLog"
    Write-Host ""
    Write-Host "To stop background processes later:"
    Write-Host "  Stop-Process -Id $($serverProc.Id),$($tunnelProc.Id) -Force"
    exit 1
}

Write-Host ""
Write-Host "Public URL:"
Write-Host "  $publicUrl"
Write-Host ""
Write-Host "Local URL:"
Write-Host "  http://127.0.0.1:$Port/"
Write-Host ""
Write-Host "Process IDs:"
Write-Host "  server=$($serverProc.Id)  tunnel=$($tunnelProc.Id)"
Write-Host ""
Write-Host "To stop:"
Write-Host "  Stop-Process -Id $($serverProc.Id),$($tunnelProc.Id) -Force"
