# ── Read JSON context from stdin (required by Copilot hooks) ──
$Context = $input | Out-String

# ── Run tests ──
Push-Location sample-app
npm test
$TestExit = $LASTEXITCODE
Pop-Location

# ── Ensure log directory exists ──
if (-not (Test-Path "logs/copilot")) {
    New-Item -ItemType Directory -Path "logs/copilot" -Force | Out-Null
}

$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$LogFile = "logs/copilot/test-gate.log"

if ($TestExit -eq 0) {
    $Entry = @{ event = "agentStop"; hook = "test-gate"; status = "passed"; timestamp = $Timestamp } | ConvertTo-Json -Compress
    Add-Content -Path $LogFile -Value $Entry
    Write-Host "✅ TEST GATE PASSED: All tests pass."
    exit 0
} else {
    $Entry = @{ event = "agentStop"; hook = "test-gate"; status = "failed"; exitCode = $TestExit; timestamp = $Timestamp } | ConvertTo-Json -Compress
    Add-Content -Path $LogFile -Value $Entry
    Write-Host "🚨 TEST GATE FAILED: Tests did not pass. Fix failing tests before proceeding."
    exit 1
}
