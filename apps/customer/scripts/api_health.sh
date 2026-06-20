#!/usr/bin/env bash
# Daily API health check against a backend env (default: dev).
# Tells you which API endpoint is broken / whether the server is up.
#
# Usage:
#   ./scripts/api_health.sh          # checks the dev server (.dev.env)
#   ./scripts/api_health.sh prod     # checks prod (.prod.env)
set -euo pipefail
cd "$(dirname "$0")/.."

ENV="${1:-dev}"
ENV_FILE=".${ENV}.env"
[[ -f "$ENV_FILE" ]] || { echo "Missing $ENV_FILE"; exit 1; }

echo "→ API health check against $ENV ($ENV_FILE)"
fvm flutter test --tags api --dart-define-from-file="$ENV_FILE" \
  test/api_health/api_health_test.dart
