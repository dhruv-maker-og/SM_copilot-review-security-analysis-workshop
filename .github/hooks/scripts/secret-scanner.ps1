# =============================================================
# secret-scanner.ps1 — Copilot Hook Script (postToolUse)
# =============================================================
# Runs after each tool use during a Copilot agent session.
# Purpose: Scan sample-app/ .js files for hardcoded secrets.
#
# This hook:
#   1. Reads the JSON context provided by the hook system via stdin
#   2. Scans all .js files in sample-app/ for hardcoded secret patterns
#   3. Logs findings to logs/copilot/secret-scan.log as JSON
#   4. Prints a summary to stdout
#
# Exit 0 = warn only, does NOT block the workflow.
# =============================================================

$ErrorActionPreference = 'Stop'

# Read the full JSON context from stdin
$InputData = [Console]::In.ReadToEnd()

# Create logs directory
$logDir = Join-Path (Join-Path $PWD 'logs') 'copilot'
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$count = 0

$sampleAppDir = Join-Path $PWD 'sample-app'

if (Test-Path $sampleAppDir) {
    $jsFiles = Get-ChildItem -Path $sampleAppDir -Filter '*.js' -Recurse -File -ErrorAction SilentlyContinue

    foreach ($file in $jsFiles) {
        $lines = Get-Content -Path $file.FullName -ErrorAction SilentlyContinue
        if (-not $lines) { continue }

        foreach ($line in $lines) {
            # API key prefixes: sk-, sk_, AKIA, ghp_, gho_, github_pat_
            if ($line -match '(sk-[A-Za-z0-9]{20,}|sk_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|gho_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,})') {
                $count++
            }

            # Variables named password, secret, api_key, token assigned to string literals
            if ($line -match '(?i)(password|secret|api_key|token)\s*[:=]\s*[''"]') {
                $count++
            }

            # Bearer tokens in strings
            if ($line -match '(?i)Bearer\s+[A-Za-z0-9_.+/=-]+') {
                $count++
            }
        }
    }
}

# Write structured log entry
$logEntry = @{
    timestamp        = $timestamp
    event            = 'postToolUse'
    scanner          = 'secret-scanner'
    findingCount     = $count
    scannedDirectory = 'sample-app/'
} | ConvertTo-Json -Compress

$logFile = Join-Path $logDir 'secret-scan.log'
Add-Content -Path $logFile -Value $logEntry

Write-Host "`u{1F50D} Secret scan: $count potential secret(s) found in sample-app/"
exit 0
