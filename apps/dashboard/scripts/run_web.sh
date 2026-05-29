#!/usr/bin/env bash
#
# Run the SportBuddies Owner Dashboard on Flutter web.
#
# All Flutter config for this app is passed at run time via --dart-define
# (this package uses String.fromEnvironment, NOT envied). This script wires
# those defines from environment variables / an optional local env file so you
# don't have to retype them.
#
# Usage:
#   ./scripts/run_web.sh                       # -d chrome, hot reload, port 8090
#   DEVICE=web-server ./scripts/run_web.sh      # headless dev server (CI / remote)
#   PORT=9000 ./scripts/run_web.sh
#   API_BASE_URL=https://api.staging.example.com ./scripts/run_web.sh
#   ./scripts/run_web.sh --release              # extra flags pass straight through
#
# Config (env var -> --dart-define), with defaults:
#   SUPABASE_URL       (http://localhost:54321)   Supabase project URL
#   SUPABASE_ANON_KEY  (required for real auth)    Supabase anon/public key
#   API_BASE_URL       (http://localhost:8000)     REST backend (Django) — owner signup, etc.
#   DEV_EMAIL          (unset)                      Pre-fills the login email field
#   DEV_PASSWORD       (unset)                      Pre-fills the login password field
#
# Put secrets in scripts/.env.web (git-ignored) instead of exporting each time;
# see scripts/.env.web.example.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
cd "$APP_DIR"

# Optional local overrides (not committed).
if [ -f "$SCRIPT_DIR/.env.web" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$SCRIPT_DIR/.env.web"
  set +a
fi

DEVICE="${DEVICE:-chrome}"
PORT="${PORT:-8090}"
SUPABASE_URL="${SUPABASE_URL:-http://localhost:54321}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"
API_BASE_URL="${API_BASE_URL:-http://localhost:8000}"
DEV_EMAIL="${DEV_EMAIL:-}"
DEV_PASSWORD="${DEV_PASSWORD:-}"

if [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "WARNING: SUPABASE_ANON_KEY is empty — login/session will not work against a real" >&2
  echo "         Supabase. The app still boots (public routes like /signup render fine)." >&2
  echo "         Set it in scripts/.env.web or export it. Using a placeholder for now." >&2
  SUPABASE_ANON_KEY="dummy-anon-key-for-local-ui"
fi

defines=(
  "--dart-define=SUPABASE_URL=$SUPABASE_URL"
  "--dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
  "--dart-define=API_BASE_URL=$API_BASE_URL"
)
[ -n "$DEV_EMAIL" ]    && defines+=("--dart-define=DEV_EMAIL=$DEV_EMAIL")
[ -n "$DEV_PASSWORD" ] && defines+=("--dart-define=DEV_PASSWORD=$DEV_PASSWORD")

echo "▶ fvm flutter run -d $DEVICE  (127.0.0.1:$PORT)"
echo "    SUPABASE_URL=$SUPABASE_URL"
echo "    API_BASE_URL=$API_BASE_URL"
echo "    routes: /#/login  /#/signup"

exec fvm flutter run -d "$DEVICE" \
  --web-hostname=127.0.0.1 --web-port="$PORT" \
  "${defines[@]}" "$@"
