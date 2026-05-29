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
#   SUPABASE_URL              (http://localhost:54321)  Supabase project URL
#   SUPABASE_PUBLISHABLE_KEY  (required for real auth)  Supabase publishable/client key
#                                                       (legacy SUPABASE_ANON_KEY also accepted)
#   API_BASE_URL              (http://localhost:8010)   REST backend (Django) — owner signup, etc.
#   DEV_EMAIL          (unset)                      Pre-fills the login email field
#   DEV_PASSWORD       (unset)                      Pre-fills the login password field
#   BYPASS_AUTH        (unset)                      "true" = auto-login as a dev account
#   BYPASS_EMAIL       (dev@snb.com)                Dev account for BYPASS_AUTH
#   BYPASS_PASSWORD    (built-in default)           Dev account password
#
# Preview the dashboard by auto-logging-in via the backend /auth/owner/login
# (needs the REST backend reachable + a real SUPABASE_PUBLISHABLE_KEY for data):
#   BYPASS_AUTH=true SUPABASE_PUBLISHABLE_KEY=… ./scripts/run_web.sh
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
SUPABASE_PUBLISHABLE_KEY="${SUPABASE_PUBLISHABLE_KEY:-}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"
API_BASE_URL="${API_BASE_URL:-http://localhost:8010}"
DEV_EMAIL="${DEV_EMAIL:-}"
DEV_PASSWORD="${DEV_PASSWORD:-}"
BYPASS_AUTH="${BYPASS_AUTH:-}"
BYPASS_EMAIL="${BYPASS_EMAIL:-}"
BYPASS_PASSWORD="${BYPASS_PASSWORD:-}"

# Prefer the current publishable key; accept the legacy anon key as a fallback.
CLIENT_KEY="${SUPABASE_PUBLISHABLE_KEY:-$SUPABASE_ANON_KEY}"
if [ -z "$CLIENT_KEY" ]; then
  echo "WARNING: no SUPABASE_PUBLISHABLE_KEY (or legacy SUPABASE_ANON_KEY) set —" >&2
  echo "         login/session will not work against a real Supabase. The app still" >&2
  echo "         boots (public routes like /signup render). Set it in scripts/.env.web." >&2
  CLIENT_KEY="dummy-publishable-key-for-local-ui"
fi

defines=(
  "--dart-define=SUPABASE_URL=$SUPABASE_URL"
  "--dart-define=SUPABASE_PUBLISHABLE_KEY=$CLIENT_KEY"
  "--dart-define=API_BASE_URL=$API_BASE_URL"
)
[ -n "$DEV_EMAIL" ]    && defines+=("--dart-define=DEV_EMAIL=$DEV_EMAIL")
[ -n "$DEV_PASSWORD" ] && defines+=("--dart-define=DEV_PASSWORD=$DEV_PASSWORD")
[ -n "$BYPASS_AUTH" ]     && defines+=("--dart-define=BYPASS_AUTH=$BYPASS_AUTH")
[ -n "$BYPASS_EMAIL" ]    && defines+=("--dart-define=BYPASS_EMAIL=$BYPASS_EMAIL")
[ -n "$BYPASS_PASSWORD" ] && defines+=("--dart-define=BYPASS_PASSWORD=$BYPASS_PASSWORD")

echo "▶ fvm flutter run -d $DEVICE  (127.0.0.1:$PORT)"
echo "    SUPABASE_URL=$SUPABASE_URL"
echo "    API_BASE_URL=$API_BASE_URL"
[ -n "$BYPASS_AUTH" ] && echo "    BYPASS_AUTH=$BYPASS_AUTH  (auto-login as ${BYPASS_EMAIL:-dev@snb.com})"
echo "    routes: /#/  /#/schedule  /#/login  /#/signup"

exec fvm flutter run -d "$DEVICE" \
  --web-hostname=127.0.0.1 --web-port="$PORT" \
  "${defines[@]}" "$@"
