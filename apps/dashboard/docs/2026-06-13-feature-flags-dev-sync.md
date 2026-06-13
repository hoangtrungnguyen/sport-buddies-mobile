# Feature-flag dev profile sync + `/fixed` gate — 2026-06-13

Aligned the dev feature-flag profile with staging, documented why YAML flag
edits weren't taking effect, and added a route gate for the fixed-slot-booking
nav item.

**Repo:** `sport-buddies-mobile` (dashboard app) · **File:**
`lib/assets/flags/feature_flags.dev.yaml`

## 1. Sync dev flags to staging

Three flags in `feature_flags.dev.yaml` were brought in line with
`feature_flags.staging.yaml`:

| Flag | Before (dev) | After (dev) | staging |
|---|---|---|---|
| `ai_demand_forecast` | `false` | `true` | `true` |
| `payout_dashboard` | `false` | `true` | `true` |
| `verbose_logging` | `true` | `false` | `false` |

## 2. Why YAML flag edits didn't take effect

**Symptom:** editing a flag in the YAML (e.g. `advanced_analytics.enabled:
false`) did not hide the gated nav item in the running app.

**Root cause — not a code bug.** Verified the resolution path is correct: with
no feature-flag backend, both remote fetches return `{}` and the service falls
back to YAML. Parsing the actual dev.yaml through the project's
`isRouteEnabled` logic yields `isRouteEnabled('/analytics') = false` — the gate
works.

The YAML is a **pubspec asset**, loaded via `rootBundle.loadString`
(`feature_flag_service.dart:96`). Assets are compiled into the app bundle at
**build time**. Neither hot reload nor hot restart re-bundles assets, so a
running app keeps serving the old flag values.

**Fix (operational, no code change):** fully stop the process and rebuild —
e.g. `flutter run -d chrome --dart-define=ENVIRONMENT=local` (use
`flutter clean` first if still stale). Confirm via the debug-only
`_logSummary` table (`feature_flag_service.dart:127`) printed at startup as
`FeatureFlags [dev]`.

> Gotcha: a route gate matches the **internal go_router path** exactly
> (`isRouteEnabled`: `flag.route == route`). Use `/analytics`, not the browser
> URL `http://127.0.0.1:8090/#/analytics` — the full URL never matches and the
> item stays visible.

## 3. Add `fixed_slot_booking` route gate

The `/fixed` ("Lịch cố định") nav item (`app_shell.dart:51`) had no flag
governing it — always visible. Added a route-gated flag:

```yaml
fixed_slot_booking:
  enabled: false   # dev: currently off
  route: /fixed
```

How route gating works: `_visibleNav` (`app_shell.dart:39`) keeps a nav item
only when `isRouteEnabled(route)` is true; a route no flag declares stays
visible, and a flag whose `route:` matches hides that item unless `enabled`.

### Follow-ups (not yet done)

- Add the canonical constant in `feature_names.dart`:
  `static const fixedSlotBooking = 'fixed_slot_booking';`
- Mirror the flag in `feature_flags.staging.yaml` and `feature_flags.prod.yaml`
  — currently `/fixed` is unflagged there (always visible), which is
  inconsistent with dev.
