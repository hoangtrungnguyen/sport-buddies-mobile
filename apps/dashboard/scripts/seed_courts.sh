#!/usr/bin/env bash
# Seed mock courts for the dev owner (dev@snb.com) so the schedule/booking UI
# has data to render. Reads keys from scripts/.env.web. Idempotent-ish: skips
# seeding when the owner already has >= 3 active courts.
set -euo pipefail

cd "$(dirname "$0")"
# Load config (strip quotes).
SUPABASE_URL=$(grep -E '^SUPABASE_URL=' .env.web | cut -d= -f2- | tr -d "'\"")
PUBKEY=$(grep -E '^SUPABASE_PUBLISHABLE_KEY=' .env.web | cut -d= -f2- | tr -d "'\"")
API=$(grep -E '^API_BASE_URL=' .env.web | cut -d= -f2- | tr -d "'\"")
EMAIL=$(grep -E '^DEV_EMAIL=' .env.web | cut -d= -f2- | tr -d "'\"")
PASS=$(grep -E '^DEV_PASSWORD=' .env.web | cut -d= -f2- | tr -d "'\"")

echo "→ login $EMAIL @ $API"
LOGIN=$(curl -s -X POST "$API/auth/owner/login" \
  -H 'Content-Type: application/json' \
  --data "$(jq -nc --arg e "$EMAIL" --arg p "$PASS" '{email:$e,password:$p}')")
TOKEN=$(echo "$LOGIN" | jq -r '.access_token')
OWNER_UID=$(echo "$LOGIN" | jq -r '.user.id')
echo "  uid=$OWNER_UID token=${TOKEN:0:12}…"
[ "$TOKEN" = "null" ] && { echo "login failed: $LOGIN"; exit 1; }

REST="$SUPABASE_URL/rest/v1/courts"
hdr=(-H "apikey: $PUBKEY" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json')

EXISTING=$(curl -s "${hdr[@]}" "$REST?select=id,name&owner_id=eq.$OWNER_UID&status=neq.inactive")
COUNT=$(echo "$EXISTING" | jq 'length')
echo "→ existing active courts: $COUNT"
echo "$EXISTING" | jq -r '.[] | "   - \(.name)"' 2>/dev/null || true
if [ "$COUNT" -ge 3 ]; then
  echo "✓ already seeded (>=3); nothing to do."
  exit 0
fi

ts=$(date +%s)
seed_one () { # name sports capacity open close price
  local name="$1" sports="$2" cap="$3" oh="$4" ch="$5" price="$6"
  local slug; slug=$(echo "$name-$ts-$RANDOM" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-')
  local body; body=$(jq -nc \
    --arg n "$name" --arg s "$slug" --argjson sp "$sports" \
    --argjson cap "$cap" --argjson oh "$oh" --argjson ch "$ch" \
    --argjson pr "$price" --arg uid "$OWNER_UID" \
    '{name:$n,slug:$s,sport_types:$sp,capacity:$cap,price_per_hour:$pr,operating_hours:{open:$oh,close:$ch},owner_id:$uid,status:"approved"}')
  curl -s "${hdr[@]}" -H 'Prefer: return=representation' -X POST "$REST" --data "$body" \
    | jq -r 'if type=="array" then .[0] else . end | "   + \(.name // .message // .) (\(.id // "ERR"))"'
}

echo "→ seeding mock courts"
seed_one "Sân Cầu Lông A"        '["Cầu lông"]'  4  6 22 120000
seed_one "Sân Tennis Trung Tâm"  '["Tennis"]'    4  6 22 250000
seed_one "Sân Pickleball B"      '["Pickleball"]' 4 6 22 150000
seed_one "Sân Bóng Rổ"           '["Bóng rổ"]'   10 6 22 300000
echo "✓ done"
