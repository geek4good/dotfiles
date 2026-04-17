---
name: ghpm
description: GitHub Project Management workflow for Claude Code. Provides slash commands for managing product development workflows with a structured flow from PRD to Epics to Tasks to TDD implementation, with conventional commits for automated changelog generation. Use when managing GitHub Issues-based project planning, creating PRDs, breaking work into epics/tasks, TDD implementation, or QA testing.
---

# GitHub Project Management (GHPM)

Spec-driven development using GitHub Issues as the persistent store. Provides a structured workflow from Product Requirements Document (PRD) through Epics, Tasks, TDD implementation, and QA testing.

## Structure

- `commands/` — Slash command definitions for each workflow step
- `agents/` — Sub-agent definitions for review cycles (pr-review, conflict-resolver, review-cycle-coordinator, ci-check)
- `skills/` — Shared helper skills (issue claiming)

## Commands

| Command | Description |
|---------|-------------|
| `/ghpm:create-project` | Create a GitHub Project and link to repository |
| `/ghpm:create-prd` | Create a Product Requirements Document |
| `/ghpm:create-epics` | Break PRD into Epics |
| `/ghpm:create-tasks` | Break Epics into atomic Tasks |
| `/ghpm:execute` | Execute Task (routes to TDD or non-TDD workflow) |
| `/ghpm:tdd-task` | Implement Task using TDD |
| `/ghpm:changelog` | Generate changelog from commits |
| `/ghpm:qa-create` | Create QA Issue for PRD acceptance testing |
| `/ghpm:qa-create-steps` | Create QA Steps for QA Issue |
| `/ghpm:qa-execute` | Execute QA Steps with Playwright automation |
| `/ghpm:quick-issue` | Create a quick issue from a prompt |

## Workflow

```
PRD → Epics → Tasks → Execute/TDD → PR → Review → Merge
                      ↘ QA → QA Steps → QA Execute → Bugs → Tasks
```

## Agents

| Agent | Purpose |
|-------|---------|
| pr-review | Reviews PRs against Task specifications |
| conflict-resolver | Detects and resolves merge conflicts |
| review-cycle-coordinator | Orchestrates review-fix-review cycle |
| ci-check | Monitors CI status and handles failures |
