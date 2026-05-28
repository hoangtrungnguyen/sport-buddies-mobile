# sport-buddies-mobile

SportBuddies customer-facing Flutter app. Court booking marketplace for Ho Chi Minh City.

**Stack:** Flutter Web (flutter_bloc ^8, supabase_flutter ^2, go_router ^14, flutter_map ^7 + Goong)
**Shared package:** `packages/spb_core` (models, repos, AppColors)

## Build & Test Commands

All Flutter/Dart commands go through `fvm`. Run `fvm install` once after clone to fetch the pinned SDK (3.35.7, see `.fvmrc` / `.fvm/fvm_config.json`).

**Workspace layout:** Flutter packages live under `apps/customer/` and `packages/spb_core/`. There is no top-level `pubspec.yaml` — all `fvm flutter` commands must run from inside the relevant package directory.

```bash
# Install deps (run from apps/customer/)
cd apps/customer && fvm flutter pub get

# Run tests (run from apps/customer/)
cd apps/customer && fvm flutter test

# Lint (run from apps/customer/)
cd apps/customer && fvm flutter analyze

# Run dev (local Supabase — from apps/customer/)
cd apps/customer && fvm flutter run \
                --dart-define=SUPABASE_URL=http://localhost:54321 \
                --dart-define=SUPABASE_ANON_KEY=<local-anon-key> \
                --dart-define=GOONG_MAP_KEY=<key>

# Build for Firebase Hosting (from apps/customer/)
# Note: --web-renderer was removed in Flutter 3.22+. Use --wasm for newer renderer.
cd apps/customer && fvm flutter build web --release
```

**Code gen:** `cd apps/customer && fvm dart run build_runner build --delete-conflicting-outputs`

## Grava DB

Port: **3330** (auto-picked; stored in `.grava.yaml`)
Connection: `root@tcp(127.0.0.1:3330)/dolt?parseTime=true`

```bash
grava db-start    # start Dolt server
grava doctor      # health check
grava list        # show open issues
```

---

## Plane Integration

**Workspace:** sportbuddies · **Project:** CAPP (`7f970183-a7bf-4511-add1-f201313b37ea`)

All grava issues carry `plane:<plane-uuid>` label for traceability. Grava is authoritative; Plane is the stakeholder view.