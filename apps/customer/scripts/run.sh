#!/usr/bin/env bash
#
# run.sh — launch the customer app, loading the matching env file as
# compile-time --dart-define values.
#
# env.dart reads config via String.fromEnvironment, so the .env file must be
# fed into the build with --dart-define-from-file (Flutter parses KEY=VALUE
# lines; # comments and blank lines are ignored).
#
# Usage:
#   ./scripts/run.sh [local|dev|prod] [extra flutter args...]
#
# Examples:
#   ./scripts/run.sh                 # local on the default device
#   ./scripts/run.sh dev -d chrome   # dev on Chrome
#   ./scripts/run.sh prod --release  # prod, release mode

set -euo pipefail
cd "$(dirname "$0")/.."

ENV="${1:-local}"
[ $# -gt 0 ] && shift || true

case "$ENV" in
    local) ENV_FILE=".local.env" ;;
    dev)   ENV_FILE=".dev.env" ;;
    prod)  ENV_FILE=".prod.env" ;;
    *)
        echo "Unknown environment: '$ENV' (use: local | dev | prod)" >&2
        exit 1
        ;;
esac

if [ ! -f "$ENV_FILE" ]; then
    echo "Missing $ENV_FILE — run ./scripts/bootstrap_env.sh first." >&2
    exit 1
fi

# Prefer fvm when present so the pinned Flutter SDK is used.
if command -v fvm >/dev/null 2>&1; then
    FLUTTER=(fvm flutter)
else
    FLUTTER=(flutter)
fi

echo "Loading $ENV_FILE (ENVIRONMENT=$ENV)"
exec "${FLUTTER[@]}" run \
    --dart-define-from-file="$ENV_FILE" \
    --dart-define=ENVIRONMENT="$ENV" \
    "$@"
