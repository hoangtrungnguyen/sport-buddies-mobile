#!/usr/bin/env bash
#
# Web UI e2e — runs the integration_test targets in a real Chrome browser via
# `flutter drive`. These tests are self-contained (fake repo, no backend), so
# no env file or credentials are needed.
#
# Requires chromedriver matching your installed Chrome, reachable on :4444.
# Install: `brew install chromedriver` (macOS) or download from
# https://googlechromelabs.github.io/chrome-for-testing/ .
#
# Usage:
#   ./scripts/web_e2e.sh                                   # all integration_test/*
#   ./scripts/web_e2e.sh integration_test/create_court_test.dart
#   HEADLESS=1 ./scripts/web_e2e.sh                        # headless (CI)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
cd "$APP_DIR"

TARGET="${1:-integration_test/create_court_test.dart}"
PORT="${CHROMEDRIVER_PORT:-4444}"

if ! command -v chromedriver >/dev/null 2>&1; then
  echo "Error: chromedriver not found on PATH." >&2
  echo "  macOS: brew install chromedriver" >&2
  echo "  or:    https://googlechromelabs.github.io/chrome-for-testing/" >&2
  exit 1
fi

# Start chromedriver if nothing is already listening on $PORT.
STARTED_DRIVER=""
if ! curl -fsS "http://localhost:$PORT/status" >/dev/null 2>&1; then
  echo "▶ starting chromedriver on :$PORT"
  chromedriver --port="$PORT" >/tmp/chromedriver.log 2>&1 &
  STARTED_DRIVER=$!
  trap '[ -n "$STARTED_DRIVER" ] && kill "$STARTED_DRIVER" 2>/dev/null || true' EXIT
  # Wait for it to come up.
  for _ in $(seq 1 20); do
    curl -fsS "http://localhost:$PORT/status" >/dev/null 2>&1 && break
    sleep 0.5
  done
fi

DEVICE="chrome"
EXTRA=()
if [ "${HEADLESS:-}" = "1" ]; then
  DEVICE="web-server"
  EXTRA=(--browser-name=chrome --headless)
fi

echo "▶ flutter drive [$DEVICE] → $TARGET"
exec fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target="$TARGET" \
  -d "$DEVICE" \
  "${EXTRA[@]+"${EXTRA[@]}"}"
