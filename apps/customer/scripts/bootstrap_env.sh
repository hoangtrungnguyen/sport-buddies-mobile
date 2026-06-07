#!/usr/bin/env bash
#
# bootstrap_env.sh — create the env files envied codegen requires.
#
# env.dart declares @Envied for .local.env, .dev.env AND .prod.env — all three
# must exist or `dart run build_runner build` fails with
# "Environment variable not found". The files are gitignored (they may hold
# real keys), so every fresh clone needs this once:
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
        printf 'SUPABASE_URL=http://localhost:54321\nSUPABASE_PUBLISHABLE_KEY=placeholder\n' > "$f"
        echo "created $f (placeholder)"
    fi
done

echo "env files ready: .local.env .dev.env .prod.env"
