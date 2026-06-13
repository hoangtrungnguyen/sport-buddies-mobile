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
# VM Service port flutter-skill connects to (connect_app ws://127.0.0.1:$VM_SERVICE_PORT).
# Fixed so the MCP server has a stable URI instead of a random per-run port.
VM_SERVICE_PORT="${VM_SERVICE_PORT:-8181}"

# ── flutter-skill self-heal ──────────────────────────────────────────────────
# The flutter-skill npm release (0.9.36) is broken out of the box: it ships an
# empty native binary (no arm64 asset is published — the release URL 404s), so
# its CLI execs a 0-byte file and dies with ENOEXEC instead of using the bundled
# Dart server; and that Dart fallback's pubspec is mis-named `flutter_skill_npm`
# while every import expects `package:flutter_skill`, so it won't compile either.
# Heal both so the `flutter-skill server` MCP process Claude Code launches starts.
# Idempotent — safe to run every launch. (Re)start your Claude Code session after
# the first heal so the MCP server picks up the fix.
heal_flutter_skill() {
  # 1. Drop any empty/broken cached native binary → CLI falls back to the Dart server.
  if [ -d "$HOME/.flutter-skill/bin" ]; then
    find "$HOME/.flutter-skill/bin" -type f -empty -delete 2>/dev/null || true
  fi
  # 2. Fix the Dart fallback's package name wherever flutter-skill is installed
  #    (global npm install + any npx cache copy the MCP config resolves to).
  local dirs=""
  if command -v npm >/dev/null 2>&1; then
    dirs="$(npm root -g 2>/dev/null)/flutter-skill"
  fi
  dirs="$dirs $(ls -d "$HOME"/.npm/_npx/*/node_modules/flutter-skill 2>/dev/null || true)"
  local r pub
  for r in $dirs; do
    pub="$r/dart/pubspec.yaml"
    if [ -f "$pub" ] && grep -q '^name: flutter_skill_npm' "$pub"; then
      sed -i '' 's/^name: flutter_skill_npm/name: flutter_skill/' "$pub"
      echo "▶ flutter-skill: patched Dart package name in $pub"
    fi
  done
}
heal_flutter_skill

# Load the per-environment vars (API_BASE_URL, SUPABASE_*, BYPASS_*) from the
# matching dotenv file via --dart-define-from-file. Keys map 1:1 to the
# String.fromEnvironment names in lib/core/env/env.dart.
ENV_FILE="$APP_DIR/.$ENV.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: env file '$ENV_FILE' not found." >&2
  exit 1
fi

echo "▶ Launching SportBuddies Dashboard in [$ENV] environment..."
echo "▶ fvm flutter run -d $DEVICE --dart-define=ENVIRONMENT=$ENV --dart-define-from-file=$ENV_FILE"
echo "▶ flutter-skill: VM Service will be at ws://127.0.0.1:$VM_SERVICE_PORT (use connect_app)"

exec fvm flutter run -d "$DEVICE" \
  --web-hostname=127.0.0.1 --web-port="$PORT" \
  --vm-service-port="$VM_SERVICE_PORT" \
  --dart-define=ENVIRONMENT="$ENV" \
  --dart-define-from-file="$ENV_FILE" \
  "$@"
