#!/bin/bash
# =============================================================
# secret-scanner.sh — Copilot Hook Script (postToolUse)
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
set -euo pipefail

# Read the full JSON context from stdin
INPUT=$(cat)

# Create logs directory
mkdir -p logs/copilot

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FINDINGS=""
COUNT=0

# Scan .js files in sample-app/ if the directory exists
if [ -d "sample-app" ]; then
  # Find all .js files and scan for secret patterns
  while IFS= read -r jsfile; do
    [ -z "$jsfile" ] && continue

    # API key prefixes: sk-, sk_, AKIA, ghp_, gho_, github_pat_
    while IFS= read -r match; do
      FINDINGS="${FINDINGS}${match}\n"
      COUNT=$((COUNT + 1))
    done < <(grep -nE '(sk-[A-Za-z0-9]{20,}|sk_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|gho_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,})' "$jsfile" 2>/dev/null || true)

    # Variables named password, secret, api_key, token assigned to string literals
    while IFS= read -r match; do
      FINDINGS="${FINDINGS}${match}\n"
      COUNT=$((COUNT + 1))
    done < <(grep -nEi '(password|secret|api_key|token)\s*[:=]\s*["\x27]' "$jsfile" 2>/dev/null || true)

    # Bearer tokens in strings
    while IFS= read -r match; do
      FINDINGS="${FINDINGS}${match}\n"
      COUNT=$((COUNT + 1))
    done < <(grep -nEi 'Bearer\s+[A-Za-z0-9_.+/=-]+' "$jsfile" 2>/dev/null || true)

  done < <(find sample-app -name '*.js' -type f 2>/dev/null)
fi

# Write structured log entry
LOG_ENTRY=$(cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "event": "postToolUse",
  "scanner": "secret-scanner",
  "findingCount": $COUNT,
  "scannedDirectory": "sample-app/"
}
EOF
)

echo "$LOG_ENTRY" >> logs/copilot/secret-scan.log

echo "🔍 Secret scan: $COUNT potential secret(s) found in sample-app/"
exit 0
