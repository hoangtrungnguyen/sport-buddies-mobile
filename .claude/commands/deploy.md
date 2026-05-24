---
description: Route + dispatch grava issues via the orchestrator agent.
---

`/deploy [<id>] [--team fix-bug|qa|task-generator|epic-task] [--parallel] [--retry] [--skip-verify]`

Delegates to the **orchestrator** sub-agent. See
`.claude/agents/orchestrator.md` for the full pipeline (route, fix-bug, QA,
epic-task, task-generator expand).

With `<id>`: routes a single issue. Without: picks next ready item per team.
`--parallel` fans out across all four teams.
