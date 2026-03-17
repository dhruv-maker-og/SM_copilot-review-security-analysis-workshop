#!/usr/bin/env bash
set -euo pipefail

# ── Read JSON context from stdin (required by Copilot hooks) ──
CONTEXT=$(cat)

# ── Run tests ──
cd sample-app
npm test && TEST_EXIT=0 || TEST_EXIT=$?

# ── Ensure log directory exists ──
cd ..
mkdir -p logs/copilot

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="logs/copilot/test-gate.log"

if [ "$TEST_EXIT" -eq 0 ]; then
  echo "{\"event\":\"agentStop\",\"hook\":\"test-gate\",\"status\":\"passed\",\"timestamp\":\"$TIMESTAMP\"}" >> "$LOG_FILE"
  echo "✅ TEST GATE PASSED: All tests pass."
  exit 0
else
  echo "{\"event\":\"agentStop\",\"hook\":\"test-gate\",\"status\":\"failed\",\"exitCode\":$TEST_EXIT,\"timestamp\":\"$TIMESTAMP\"}" >> "$LOG_FILE"
  echo "🚨 TEST GATE FAILED: Tests did not pass. Fix failing tests before proceeding."
  exit 1
fi
