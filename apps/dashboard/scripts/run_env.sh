#!/usr/bin/env bash
#
# Run the SportBuddies Owner Dashboard with a specific environment.
#
# Usage:
#   ./scripts/run_env.sh [local|dev|prod] [flutter run args...]
#
# Examples:
#   ./scripts/run_env.sh dev
#   ./scripts/run_env.sh prod -d macos
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
cd "$APP_DIR"

# Read environment (default to local if not specified or if first argument starts with -)
ENV="local"
if [ $# -gt 0 ] && [[ ! "$1" =~ ^- ]]; then
  ENV="$1"
  shift
fi

# Validate environment
if [ "$ENV" != "local" ] && [ "$ENV" != "dev" ] && [ "$ENV" != "prod" ]; then
  echo "Error: Invalid environment '$ENV'. Supported environments: local, dev, prod" >&2
  exit 1
fi

DEVICE="${DEVICE:-chrome}"
PORT="${PORT:-8090}"

echo "▶ Launching SportBuddies Dashboard in [$ENV] environment..."
echo "▶ fvm flutter run -d $DEVICE --dart-define=ENVIRONMENT=$ENV"

exec fvm flutter run -d "$DEVICE" \
  --web-hostname=127.0.0.1 --web-port="$PORT" \
  --dart-define=ENVIRONMENT="$ENV" \
  "$@"
