---
description: Plane spec page → Plane epics/stories/tasks + Grava mirror (task-generator).
---

`/generate [<page_id>] [--project <project_id>] [--dry-run]`

Delegates to the **task-generator** sub-agent. With `<page_id>` + `<project_id>`:
runs the three-phase pipeline (preview → Plane writes → Grava mirror). Without:
the **orchestrator** auto-picks the next epic from the backlog.

Equivalent CLI: `se taskgen <project_id> <page_id> --yes`.
