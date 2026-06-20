#!/usr/bin/env bash
#
# Daily API health check — probes the live backend and reports which endpoint
# is broken. Logs in as the owner, then hits every read-only API.
#
# Usage:
#   ./scripts/api_health.sh [dev|prod|local] [extra flutter test args...]
#
# Examples:
#   ./scripts/api_health.sh dev
#   ./scripts/api_health.sh dev --dart-define=API_HEALTH_EMAIL=ci@snb.com \
#                                --dart-define=API_HEALTH_PASSWORD=secret
#
# Exit code is non-zero if any endpoint is down, so it drops straight into cron.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
cd "$APP_DIR"

ENV="dev"
if [ $# -gt 0 ] && [[ ! "$1" =~ ^- ]]; then
  ENV="$1"
  shift
fi

ENV_FILE="$APP_DIR/.$ENV.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: env file '$ENV_FILE' not found." >&2
  exit 1
fi

# Login account. The bypass owner in .<env>.env is usually NOT a real account,
# so pick up the real owner creds from .env.web (DEV_EMAIL / DEV_PASSWORD) — the
# same file scripts/seed_courts.sh uses — when present. Override on the CLI with
# --dart-define=API_HEALTH_EMAIL=... --dart-define=API_HEALTH_PASSWORD=...
CRED_ARGS=()
if [ -f "$APP_DIR/.env.web" ]; then
  EMAIL=$(grep -E '^DEV_EMAIL=' "$APP_DIR/.env.web" | cut -d= -f2- | tr -d "'\"")
  PASS=$(grep -E '^DEV_PASSWORD=' "$APP_DIR/.env.web" | cut -d= -f2- | tr -d "'\"")
  if [ -n "$EMAIL" ] && [ -n "$PASS" ]; then
    CRED_ARGS=(--dart-define=API_HEALTH_EMAIL="$EMAIL"
               --dart-define=API_HEALTH_PASSWORD="$PASS")
    echo "▶ Using owner account $EMAIL from .env.web"
  fi
fi

echo "▶ API health check against [$ENV] ($ENV_FILE)"
exec fvm flutter test test/api_health \
  --tags api-health \
  --dart-define=ENVIRONMENT="$ENV" \
  --dart-define-from-file="$ENV_FILE" \
  ${CRED_ARGS[@]+"${CRED_ARGS[@]}"} \
  "$@"
