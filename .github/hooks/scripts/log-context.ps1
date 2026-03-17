# =============================================================
# log-context.ps1 — Copilot Hook Script (sessionStart)
# =============================================================
# Runs when a Copilot agent session starts.
# Purpose: Log the session context as structured JSON for debugging.
#
# This hook:
#   1. Reads the JSON context provided by the hook system via stdin
#   2. Writes a structured log entry with timestamp and working directory
#   3. Creates the log directory if needed
#
# Hook context is passed via stdin as JSON.
# Exit 0 = allow the session to proceed.
# =============================================================

$ErrorActionPreference = 'Stop'

# Read the full JSON context from stdin
$Input = [Console]::In.ReadToEnd()

# Create logs directory
$logDir = Join-Path (Join-Path $PWD 'logs') 'copilot'
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$cwd = $PWD.Path
$user = $env:USERNAME
if (-not $user) { $user = 'unknown' }

try {
    $nodeVersion = & node -v 2>$null
} catch {
    $nodeVersion = 'not-found'
}
if (-not $nodeVersion) { $nodeVersion = 'not-found' }

# Write structured log entry
# Note: We intentionally do NOT log the full INPUT to avoid
# accidentally capturing sensitive data. We log metadata only.
$logEntry = @{
    timestamp     = $timestamp
    event         = 'sessionStart'
    cwd           = $cwd
    user          = $user
    nodeVersion   = $nodeVersion
    inputReceived = $true
} | ConvertTo-Json -Compress

$logFile = Join-Path $logDir 'session.log'
Add-Content -Path $logFile -Value $logEntry

Write-Host "Session context logged to logs/copilot/session.log"
exit 0
