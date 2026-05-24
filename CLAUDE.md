# sport-buddies-mobile

SportBuddies customer-facing Flutter app. Court booking marketplace for Ho Chi Minh City.

**Stack:** Flutter Web (flutter_bloc ^8, supabase_flutter ^2, go_router ^14, flutter_map ^7 + Goong)
**Backend:** Django 5.x + DRF + Supabase (Postgres + Auth + Storage + Realtime)
**Hosting:** Firebase Hosting (`customer` target)
**Shared package:** `packages/spb_core` (models, repos, AppColors)

## Build & Test Commands

```bash
# Install deps
flutter pub get

# Run tests
flutter test

# Lint
flutter analyze

# Run dev (local Supabase)
flutter run --dart-define=SUPABASE_URL=http://localhost:54321 \
            --dart-define=SUPABASE_ANON_KEY=<local-anon-key> \
            --dart-define=GOONG_MAP_KEY=<key>

# Build for Firebase Hosting
flutter build web --web-renderer html --release
firebase deploy --only hosting:customer
```

**Code gen:** `dart run build_runner build --delete-conflicting-outputs`

## Grava DB

Port: **3330** (auto-picked; stored in `.grava.yaml`)
Connection: `root@tcp(127.0.0.1:3330)/dolt?parseTime=true`

```bash
grava db-start    # start Dolt server
grava doctor      # health check
grava list        # show open issues
```

---

## Agent Team

| Command | Description | Skills Used |
|---------|-------------|-------------|
| `/ship <id>` | Single-issue pipeline (code → review → PR → handoff) | grava-dev-task, grava-code-review |
| `/ship <id> --force` | Bypass Phase 0 precondition gate | grava-dev-task, grava-code-review |
| `/ship <id> --retry` | Re-run rejected PR with rejection feedback | grava-dev-task, grava-code-review |
| `/ship <id> --retry --rebase-only` | Rebase stale-but-approved branch, open fresh PR | grava-dev-task |
| `/plan <doc>` | Generate issues from PRD/spec markdown | grava-gen-issues |
| `/hunt [scope]` | Audit codebase, file bugs as issues | grava-bug-hunt |

> Backlog drain: `/ship` (no id) — Phase 0 auto-discovers next ready leaf issue.

> PR rejection recovery: watcher detects CLOSED PR → appends "PR Rejection Notes", labels `pr-rejected`. Run `/ship <id> --retry`. Capped at `MAX_PR_RETRIES=2`, then `needs-human`.

## Skill ↔ Agent Map

| Skill | Owned By | Purpose |
|-------|----------|---------|
| grava-cli | all agents | First-load context primer |
| grava-dev-task | coder | Spec-check → atomic claim → TDD workflow + DoD |
| grava-code-review | reviewer | 5-axis review with severity classification |
| grava-bug-hunt | bug-hunter | Parallel codebase audit |
| grava-gen-issues | planner | Doc → issue hierarchy with deps |
| (no skill) | pr-creator | Push branch + `gh pr create` + template |
| (inline in `/ship` Phase 0) | orchestrator | Discover next ready leaf issue (`grava ready --json`) |

---

## Pipeline Signals (agent ↔ orchestrator contract)

> **Signal protocol: v2.** Agents call `grava signal <KIND> --issue $ID [--payload $V]` which writes `pipeline_phase` and auxiliary wisps atomically. Orchestrator reads state via `grava wisp read` / `grava show --json`. CLI also prints `<KIND>: <payload>` as final stdout line for fallback parsing.

> **Signal preconditions:** `PR_CREATED` requires `pr_number` and `pr_awaiting_merge_since` wisps first; CLI rejects with `SIGNAL_PRECONDITION_UNMET` otherwise. Use `scripts/agent-bot/finalize-pr.sh` which sets all four atomically.

| Signal | Emitter | Meaning |
|--------|---------|---------|
| `CODER_DONE: <sha>` | coder | grava-dev-task completed, code_review label set |
| `CODER_HALTED: <reason>` | coder | TDD or context loading hit blocker |
| `REVIEWER_APPROVED` | reviewer | grava-code-review verdict APPROVED |
| `REVIEWER_BLOCKED: <findings>` | reviewer | grava-code-review verdict CHANGES_REQUESTED |
| `PR_CREATED: <url>` | pr-creator (via `finalize-pr.sh`) | PR opened. Requires `pr_number` + `pr_awaiting_merge_since` wisps. |
| `PR_FAILED: <reason>` | pr-creator | Push or `gh pr create` failed |
| `PR_COMMENTS_RESOLVED: <round>` | orchestrator | Coder fixed PR feedback, pushed to branch |
| `PR_MERGED` | pr-merge-watcher | PR merged on GitHub; watcher closed the grava issue |
| `PIPELINE_HANDOFF: <id>` | orchestrator | `/ship` exiting; pr-merge-watcher owns from here |
| `PIPELINE_COMPLETE: <id>` | watcher / orchestrator on re-entry | PR merged + `grava close` done |
| `PIPELINE_HALTED: <reason>` | orchestrator | Human intervention needed |
| `PIPELINE_FAILED: <reason>` | orchestrator | Signal parse failure or PR closed without merge |
| `PIPELINE_INFO: <reason>` | orchestrator | Re-entry no-op (e.g. still awaiting merge) |
| `PLANNER_DONE` | planner | grava-gen-issues created N issues |
| `PLANNER_NEEDS_INPUT: <summary>` | planner | Generation paused on missing info |
| `BUG_HUNT_COMPLETE` | bug-hunter | grava-bug-hunt filed N bug issues |

---

## Wisp Keys (canonical state vocabulary)

| Key | Owner | Values | Read By |
|-----|-------|--------|---------|
| `pipeline_phase` | `grava signal` CLI | `claimed` → `coding_complete` → `review_blocked` → `review_approved` → `pr_created` → `pr_awaiting_merge` → `pr_comments_resolved` → `pr_merged` → `complete`. Terminal: `halted_human_needed`, `coding_halted`, `planner_needs_input`. Recoverable: `failed` | `/ship` re-entry, `pr-merge-watcher.sh`, `grava doctor` |
| `step` | `grava-dev-task` checkpoints | `claimed`, `context-loaded`, `validated`, `complete` | The skill itself on resume |
| `orchestrator_heartbeat` | `/ship` + `grava-dev-task` | UTC unix timestamp | `grava doctor` (stale >30 min while non-terminal) |
| `pr_url`, `pr_number`, `pr_new_comments`, `pr_fix_round` | `pr-merge-watcher.sh`, `/ship` Phase 4 | URL / int / JSON / counter | `/ship` re-entry |
| `pr_close_reason`, `pr_rejection_notes`, `pr_closed_at` | `pr-merge-watcher.sh` CLOSED branch | category / markdown / unix ts | `/ship --retry` Phase 5 |
| `pr_retry_count` | `/ship --retry` Phase 5 | int 1..2 | `/ship --retry` re-entry guard |
| `coder_halted` | coder on HALT | reason string | Human triage |
| `current_task` | `grava-dev-task` Step 4 | short description of in-flight unit | Skill resume |

---

## Context Passing

Agents do NOT inherit env vars from parent. All context passed via Agent tool `prompt` parameter.

| Context | How Passed |
|---------|------------|
| Issue ID | In `prompt` string |
| Commit SHA | In `prompt` string (from prior agent result) |
| Review findings | Appended to `prompt` on re-spawn |
| Worktree | grava-provisioned at `.worktree/<id>` |

---

## Operator Hazards

| Hazard | Why | Avoid |
|--------|-----|-------|
| `grava db-stop` while issues `in_progress` | Wisps stranded, pipeline_phase stale | Wait for `grava list --status in_progress` to be empty; `db-stop` requires `--force` |
| Editing `.grava.yaml` mid-flight | Config re-read mid-pipeline | Edit only when no in-progress issues |
| `/ship X` from two terminals | Second halts at `ALREADY_CLAIMED` (safe) | Check `grava show X --json \| jq .status` first |
| `git push --force` to `grava/<id>` from two terminals | Conflict / lost commits | Don't force-push `grava/*` branches outside pipeline |
| Editing `.worktree/<id>/` while agent runs | Agent view diverges from disk | Don't touch `.worktree/<id>/` while issue `in_progress` |
| Restarting Dolt on different port | Old `.grava.yaml` points at stale port | Update `.grava.yaml` first, then `db-start` |

---

## Plane Integration

**Workspace:** sportbuddies · **Project:** CAPP (`7f970183-a7bf-4511-add1-f201313b37ea`)

All grava issues carry `plane:<plane-uuid>` label for traceability. Grava is authoritative; Plane is the stakeholder view.
