# Env config rework + dev nav-icon fix — 2026-06-13

Three related fixes: removed compile-time env codegen (envied), updated the
deploy pipeline to match, and fixed disappearing navigation icons on the
deployed dev dashboard.

## 1. Replace envied codegen with `--dart-define` config

**Repo:** `sport-buddies-mobile` (dashboard app) · **Commit:** `63ee8a5`

- Dropped the `envied` / `envied_generator` packages and the generated
  `lib/core/env/env.g.dart`.
- `lib/core/env/env.dart` now reads config with plain `String.fromEnvironment`
  / `bool.fromEnvironment`. Public API (`Env.apiBaseUrl`, `Env.supabaseUrl`,
  `Env.bypassAuth`, …) is unchanged.
- `scripts/run_env.sh` now injects per-environment values via
  `--dart-define-from-file=.<env>.env` (keys map 1:1 to the `fromEnvironment`
  names). No more `build_runner` step for env.

**Why:** the generated `env.g.dart` had gone **stale** — it baked an old Cloud
Run API URL at codegen time and was never regenerated after `.dev.env`
changed, so dev builds pointed at a dead backend (the real dev backend is
`https://dashboard.snb-dev.duckdns.org`). Reading dart-defines directly
removes the staleness entirely.

> Note: `.local.env` / `.dev.env` / `.prod.env` are gitignored (secrets). A
> duplicate `BYPASS_AUTH` key in `.prod.env` was corrected to `BYPASS_EMAIL`
> locally.

## 2. Drop envied from the deploy pipeline

**Repo:** `snb-devops` · **Commit:** `b48eb3d` · **File:**
`scripts/deploy-owner-dashboard.sh`

- Release build now injects config via
  `--dart-define-from-file=.<env>.env` instead of generating env files for
  codegen.
- Removed the `build_runner` step (freezed / json_serializable sources are
  committed to the repo) and the now-dead `$DART` / `DART_BIN` and
  placeholder-env loop.

## 3. Fix nav icons disappearing on selection (dev site)

**Repo:** `snb-devops` · **Commit:** `b65fc68` · **File:**
`scripts/deploy-owner-dashboard.sh`

**Symptom:** on `https://dashboard.snb-dev.duckdns.org/#/courts`, navigation
icons vanished when a destination became selected. Only on the deployed dev
build, never in local `flutter run`.

**Root cause:** the nav renders the selected state as
`Icon(item.icon, fill: 1)` using `material_symbols_icons`, which is a
**variable font**. `flutter build web --release` runs `--tree-shake-icons` by
default, and Flutter's icon tree-shaker does not understand variable-font axes
(`fill`, `weight`, …), so it subsets out the filled glyph. The selected icon
then renders blank — i.e. disappears exactly on switch. Local runs are debug
(no tree-shaking), so the bug never reproduced locally.

**Fix:** build the web release with `--no-tree-shake-icons`:

```sh
flutter build web --release --no-tree-shake-icons "${BUILD_DEFINES[@]}"
```

**To go live:** redeploy dev — `./scripts/deploy-owner-dashboard.sh` with
`ENVIRONMENT=dev`.
