---
description: Run the QA checklist pipeline on a grava issue labelled `qa-ready`.
---

`/qa <id> [--checklist <path>] [--type cli|api|web|mobile] [--batch <label>]`

Delegates to the **orchestrator** sub-agent's QA team
(`docs/repository-folder-level-orchestrator/ORCHESTRATOR_AGENT.md`). Loads a
checklist (explicit path → `--type` template → wisp → repo default → bundled
default), runs the review, posts a report comment, and labels the issue
`qa-passed` or `qa-failed`.
