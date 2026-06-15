#!/usr/bin/env bash
#
# bootstrap_env.sh — create the env files the app loads at run/build time.
#
# env.dart reads its config from compile-time `--dart-define` variables. The
# three env files (.local.env / .dev.env / .prod.env) are fed into the build
# via `--dart-define-from-file` (see scripts/run.sh and .vscode/launch.json).
#
# The files are gitignored (they may hold real keys), so every fresh clone
# needs this once:
#
#   ./scripts/bootstrap_env.sh
#
# .local.env is seeded from .example.env — fill in real values afterwards.
# Existing files are never overwritten.

set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -f .local.env ]; then
    cp .example.env .local.env
    echo "created .local.env from .example.env — fill in real values"
fi

for f in .dev.env .prod.env; do
    if [ ! -f "$f" ]; then
        cat > "$f" <<'EOF'
SUPABASE_URL=http://localhost:54321
SUPABASE_PUBLISHABLE_KEY=placeholder
API_BASE_URL=
MAP_PROVIDER=google
VIETMAP_API_KEY=
GOOGLE_MAP_API_KEY=
EOF
        echo "created $f (placeholder)"
    fi
done

echo "env files ready: .local.env .dev.env .prod.env"
echo "run the app with: ./scripts/run.sh [local|dev|prod]"
